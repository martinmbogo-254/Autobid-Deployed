from .models import Vehicle, Bidding, VehicleView, Auction, AuctionHistory, NotificationRecipient,  BiddingFeePayment,PaymentConfirmation
from django.contrib.auth import logout
from .filters import VehicleFilter
from .forms import AuctionForm, FeedbackForm, BidForm,PaymentConfirmationForm
from django.utils import timezone
from django.utils.html import strip_tags
from django.core.paginator import Paginator, PageNotAnInteger, EmptyPage
from users.models import User
from django.core.mail import send_mail
from django.template.loader import render_to_string
import json
import logging
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse, HttpResponse
from django.conf import settings
from .mpesa.stkservice import initiate_stk_push
from .mpesa.mpesautil import format_phone_number
from .decorators import requires_bidding_fee
logger = logging.getLogger(__name__)
import base64
import uuid
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.core.files.base import ContentFile
from django.views.decorators.http import require_POST
import os
from django.shortcuts import get_object_or_404
from django.http import FileResponse, Http404
from django.utils import timezone
from .models import UpcomingAuction
from settings.models import SiteSettings

# Awarded Bids List

@login_required
def awarded_bids(request):
    """
    Lists all bids awarded to the logged-in user.
    Passes a fresh PaymentConfirmationForm to the template
    so the modal form is rendered server-side.
    """
    bids = (
        Bidding.objects
        .filter(user=request.user, awarded=True)
        .select_related('vehicle')
        .prefetch_related('payment_confirmation')
        .order_by('-awarded_at')
    )

    for bid in bids:
        bid.payment_confirmed = hasattr(bid, 'payment_confirmation')

    return render(request, 'vehicles/awarded_bids.html', {
        'awarded_bids': bids,
        'form': PaymentConfirmationForm(),   # fresh form for the modal
    })


# Submit Payment Confirmation


@login_required
@require_POST
def submit_payment_confirmation(request):
    """
    Validates via PaymentConfirmationForm, then saves the confirmation.
    Redirects back to the awarded bids page with a Django message.
    """
    form = PaymentConfirmationForm(request.POST, request.FILES)

    if not form.is_valid():
        error_list = [
            error
            for field_errors in form.errors.values()
            for error in field_errors
        ]
        messages.error(request, ' '.join(error_list))
        return redirect('awarded_bids')

    data  = form.cleaned_data
    ctype = data['confirmation_type']

    # ── Validate bid ownership
    bid = get_object_or_404(
        Bidding,
        id=data['bid_id'],
        user=request.user,
        awarded=True,
    )

    # ── Guard: already submitted
    if hasattr(bid, 'payment_confirmation'):
        messages.warning(
            request,
            'You have already submitted payment proof for this vehicle.'
        )
        return redirect('awarded_bids')

    # ── Build and save the confirmation
    confirmation = PaymentConfirmation(
        bid=bid,
        user=request.user,
        confirmation_type=ctype,
    )

    try:
        if ctype == 'text':
            confirmation.text_note = data['text_note']

        elif ctype == 'image':
            raw_data  = data.get('compressed_image_data', '')
            file_name = data.get('compressed_image_name') or f'proof_{uuid.uuid4().hex}.jpg'

            if raw_data and ',' in raw_data:
                # JS-compressed base64 path (primary)
                _, b64_data = raw_data.split(',', 1)
                image_bytes = base64.b64decode(b64_data)
                confirmation.image_file.save(
                    file_name,
                    ContentFile(image_bytes),
                    save=False,
                )
            else:
                # Fallback: raw file if JS compression was unavailable
                confirmation.image_file = data['image_file']

        elif ctype == 'pdf':
            confirmation.pdf_file = data['pdf_file']

        confirmation.save()
        messages.success(
            request,
            f'Thank you for submitting payment confirmation for '
            f'{bid.vehicle.registration_no}.'
        )

    except Exception as e:
        messages.error(
            request,
            f'Something went wrong while saving your confirmation: {str(e)}'
        )

    return redirect('awarded_bids')


#Payment Initiation

@login_required
@login_required
def pay_bidding_fee(request, vehicle_id):
    """Show payment form and trigger STK Push."""
    vehicle = get_object_or_404(Vehicle, pk=vehicle_id)
    cfg = SiteSettings.get()
    amount = cfg.bidding_fee

    if BiddingFeePayment.has_paid(request.user, vehicle):
        messages.success(request, "You have already paid the bidding fee for this vehicle.")
        return redirect("vehicle_detail", pk=vehicle_id)

    if request.method == "POST":
        phone = request.POST.get("phone_number", "").strip()
        if not phone:
            messages.error(request, "Please enter your M-Pesa phone number.")
            return render(request, "vehicles/payments/pay_bidding_fee.html", {
                "vehicle": vehicle,
                "amount": amount,
            })

        formatted_phone = format_phone_number(phone)

        try:
            response = initiate_stk_push(
                phone_number=formatted_phone,
                amount=amount,
                account_reference=f"AUTOBID-{vehicle.registration_no}",
                transaction_desc=f"Bidding fee for {vehicle.registration_no}",
            )

            payment = BiddingFeePayment.objects.create(
                user=request.user,
                vehicle=vehicle,
                phone_number=formatted_phone,
                amount=amount,
                merchant_request_id=response.get("MerchantRequestID", ""),
                checkout_request_id=response.get("CheckoutRequestID", ""),
                status="pending",
            )

            messages.info(
                request,
                f"STK Push sent to {phone}. Enter your M-Pesa PIN to complete payment.",
            )
            return redirect("payment_pending", payment_id=payment.pk)

        except Exception as e:
            logger.error("STK Push error for user %s: %s", request.user, e)
            messages.error(request, f"Payment initiation failed: {str(e)}")

    return render(request, "vehicles/payments/pay_bidding_fee.html", {
        "vehicle": vehicle,
        "amount": amount,
    })


@login_required
def payment_pending(request, payment_id):
    """Polling page — user waits here while we confirm payment."""
    payment = get_object_or_404(BiddingFeePayment, pk=payment_id, user=request.user)
    return render(request, "vehicles/payments/bidding_fee_status.html", {"payment": payment})


@login_required
def check_payment_status(request, payment_id):
    """AJAX endpoint polled by the pending page."""
    payment = get_object_or_404(BiddingFeePayment, pk=payment_id, user=request.user)
    return JsonResponse({
        "status": payment.status,
        "vehicle_id": payment.vehicle_id,
    })


@csrf_exempt
def mpesa_callback(request):
    """
    Safaricom POSTs the payment result here.
    Must be publicly accessible (no login required).
    """
    if request.method != "POST":
        return HttpResponse(status=405)

    try:
        body = json.loads(request.body)
        logger.info("M-Pesa callback received: %s", body)

        stk_callback = body["Body"]["stkCallback"]
        checkout_request_id = stk_callback["CheckoutRequestID"]
        result_code = stk_callback["ResultCode"]

        payment = BiddingFeePayment.objects.filter(
            checkout_request_id=checkout_request_id
        ).first()

        if not payment:
            logger.warning("No payment found for CheckoutRequestID: %s", checkout_request_id)
            return JsonResponse({"ResultCode": 0, "ResultDesc": "Accepted"})

        if result_code == 0:
            callback_metadata = stk_callback.get("CallbackMetadata", {}).get("Item", [])
            receipt = next(
                (item["Value"] for item in callback_metadata if item["Name"] == "MpesaReceiptNumber"),
                "",
            )
            payment.status = "completed"
            payment.mpesa_receipt_number = receipt
        else:
            payment.status = "failed"

        payment.save()

    except Exception as e:
        logger.error("Callback processing error: %s", e, exc_info=True)

    # Always return success so Safaricom doesn't retry
    return JsonResponse({"ResultCode": 0, "ResultDesc": "Accepted"})


@login_required(login_url='login')
def dashboard_view(request):
    """System dashboard showing summary statistics and admin links."""
    
    # Summary statistics
    total_vehicles = Vehicle.objects.count()
    available_vehicles = Vehicle.objects.filter(status='available',is_approved=True).count()
    sold_vehicles = Vehicle.objects.filter(status='sold').count()
    bidon_vehicles = Vehicle.objects.filter(status='on_bid').count()
    on_auction_vehicles = Vehicle.objects.filter(status='on_auction').count()
    total_auctions = Auction.objects.count()
    active_auctions = Auction.objects.filter(end_date__gte=timezone.now()).count()
    total_bids = Bidding.objects.count()
    total_users = User.objects.count()
    total_awarded_bids = Bidding.objects.filter(awarded='True',disqualified=False).count()

    context = {  
        'total_vehicles': total_vehicles,
        'available_vehicles': available_vehicles,
        'on_auction_vehicles': on_auction_vehicles,
        'total_auctions': total_auctions,
        'active_auctions': active_auctions,
        'total_bids': total_bids,
        'total_users': total_users,
        'total_awarded_bids': total_awarded_bids,
        'sold_vehicles':sold_vehicles,
        'bidon_vehicles':bidon_vehicles

       
    }

    return render(request, 'vehicles/dashboard.html', context)
@login_required(login_url='login')
def robots_txt(request):
    content = """User-agent: *
    Disallow: /admin/
    Disallow: /profile/
    Disallow: /logout/
    Allow: / 
    Sitemap: autobid.riverlong.com/sitemap.xml/
    Sitemap: 127.0.0.1:2000/sitemap.xml
    """
    return HttpResponse(content, content_type="text/plain")

def reports(request):
    vehicles = Vehicle.objects.all()
    total_vehicles = vehicles.count()
    context = {
        'total_vehicles': total_vehicles,
       
    }
    return render(request, 'Admin/reports.html', context)
# Create your views here.
def homepage(request):
    upcoming_auctions = Vehicle.objects.filter(status='available')
    hotsale = Vehicle.objects.filter(is_hotsale =True,status='available')
    flashsale_exists = Vehicle.objects.filter(is_flashsale=True, status='available').exists()
    context = {
        'upcoming_auctions': upcoming_auctions,
        'hotsale':hotsale,
        'flashsale_exists': flashsale_exists,
    }
    return render(request, 'vehicles/home.html', context)

def privacy_policy(request):
    context = {

    }
    return render(request, 'vehicles/privacy_policy.html', context)

def aboutus(request):
    context = {

    }
    return render(request, 'vehicles/aboutus.html', context)

def terms(request):
    context = {

    }
    return render(request, 'vehicles/t&c.html', context)

def contactus(request):
    context = {

    }
    return render(request, 'vehicles/contactus.html', context)


def allvehiclespage(request):
    # Base queryset for all approved vehicles
    base_queryset = Vehicle.objects.filter(status="available",is_approved=True)
    on_auction_queryset = Vehicle.objects.filter(status="on_auction",is_approved=True)
    
    # Apply filters from the search form
    vehiclefilter = VehicleFilter(request.GET, queryset=base_queryset)
    filtered_queryset = vehiclefilter.qs

    auction_vehiclefilter =  VehicleFilter(request.GET, queryset=on_auction_queryset)
    auctionfiltered_queryset = auction_vehiclefilter.qs


    # Get sort parameter from request
    sort_by = request.GET.get('sort_by', '-approved_at')  # Default to newest first
    
    # Define allowed sorting fields and their corresponding model fields
    SORT_OPTIONS = {
        'price_low': 'reserve_price',
        'price_high': '-reserve_price',
        'newest': '-approved_at',
        'oldest': 'approved_at',
        'mileage_low': 'mileage',
        'mileage_high': '-mileage',
        'views': '-views',
        'popular': '-views',
    }
    
    # Validate and get the actual sort field
    sort_field = SORT_OPTIONS.get(sort_by, '-approved_at')  # Default to newest if invalid option

    # Separate vehicles based on their status and flash sale status
    urysia_vehicles = filtered_queryset.filter(Financier__name='Urysia',is_approved=True,status='available').order_by(sort_field)


    vehicles_on_sale = filtered_queryset.filter(status="available",is_approved=True,is_flashsale=False).order_by(sort_field)
    # vehicles_on_auction = auctionfiltered_queryset.filter(status='on_auction',is_approved=True).order_by(sort_field)

    vehicles_on_auction = auctionfiltered_queryset.filter(
        status="on_auction",
        is_approved=True,
        auctions__approved=True,
        auctions__end_date__gt=timezone.now(),
        auctions__processed=False
    ).distinct().order_by(sort_field)

    # current_auctions = filtered_queryset.filter(status='on_auction',is_approved=True).order_by(sort_field)
    
    
    # Flash sale vehicles - apply the same filters but only show flash sale items
    flashsale_vehicles = filtered_queryset.filter(
        is_flashsale=True,status="available"
    ).order_by(sort_field)[:30]  

    # Flash sale vehicles - apply the same filters but only show flash sale items
    black_friday = filtered_queryset.filter(
        is_hotsale=True,status="available"
    ).order_by(sort_field) 

    # Counting the vehicles for display purposes
    vehicles_count = filtered_queryset.count()
    on_salecount = vehicles_on_sale.count()
    on_auctioncount = vehicles_on_auction.count() 
    flashsale_count = flashsale_vehicles.count()
    urysia_count = urysia_vehicles.count()

    # Paginator for vehicles on sale
    paginator = Paginator(vehicles_on_sale, 16)  # Display 16 vehicles per page

    page = request.GET.get('page', 1)

    # Prevent vehicles on first page to appear on every page i.e flashsale, on auction and hotsale vehicles
    try:
        vehicles_on_sale = paginator.page(page)
    except PageNotAnInteger:
        vehicles_on_sale = paginator.page(1)
    except EmptyPage:
        vehicles_on_sale = paginator.page(paginator.num_pages)

    if vehicles_on_sale.number == 1:
        urysia_vehicles = filtered_queryset.filter(Financier__name='Urysia',is_approved=True,status='available').order_by(sort_field)
    else:
        urysia_vehicles = None

    if vehicles_on_sale.number == 1:
        flashsale_vehicles = filtered_queryset.filter(is_flashsale=True,status="available").order_by(sort_field)
    else:
        flashsale_vehicles = None

    if vehicles_on_sale.number == 1:
        vehicles_on_auction = auctionfiltered_queryset.filter(
        status="on_auction",
        is_approved=True,
        auctions__approved=True,
        auctions__end_date__gt=timezone.now(),
        auctions__processed=False
    ).distinct().order_by(sort_field)
    else:
        vehicles_on_auction = None

    context = {
        'vehicles_on_sale': vehicles_on_sale,
        'vehiclefilter': vehiclefilter,
        'vehicles_count': vehicles_count,
        'flashsale_vehicles': flashsale_vehicles,
        'vehicles_on_auction': vehicles_on_auction,
        'on_salecount': on_salecount,
        'on_auctioncount': on_auctioncount,
        'current_sort': sort_by,
        'sort_options': SORT_OPTIONS.keys(),
        # 'current_auctions':current_auctions,
        'flashsale_count' : flashsale_count,
        'urysia_vehicles' : urysia_vehicles,
        'urysia_count' : urysia_count,
        'black_friday' : black_friday
    }
    return render(request, 'vehicles/vehicles.html', context)


def vehicledetail(request, pk):
    vehicle = get_object_or_404(Vehicle, id=pk)
    # Get the vehicle using the slugified registration number
    # vehicle = get_object_or_404(Vehicle, registration_no__iexact=registration_no.replace("-", " "))
    if request.user.is_authenticated:
        has_paid_fee = False
        if request.user.is_authenticated:
            has_paid_fee = BiddingFeePayment.objects.filter(
                user=request.user,
                vehicle=vehicle,
                status='completed'
            ).exists()
        # Check if the user has already viewed this vehicle
        if not VehicleView.objects.filter(vehicle=vehicle, user=request.user).exists():
            vehicle.views += 1
            vehicle.save()
            # Record this view
            VehicleView.objects.create(vehicle=vehicle, user=request.user)
    # available_vehicles = Vehicle.objects.filter(status='available')
    similar_vehicles = Vehicle.objects.filter(make=vehicle.make, model=vehicle.model,is_approved=True,status='available').exclude(id=vehicle.id)
    biddings = Bidding.objects.filter(vehicle=vehicle)
    highest_bid = vehicle.bidding.filter(awarded=False,disqualified=False).order_by('-amount').first()
    context = {
       'vehicle': vehicle,
       'biddings':biddings,
       'days_since_creation': vehicle.days_since_creation(),
       'similar_vehicles': similar_vehicles,       
        'highest_bid': highest_bid,
       'similar_vehicles': similar_vehicles,
        'has_paid_fee' : has_paid_fee,

    }
    return render(request, 'vehicles/details.html', context)


import sys
sys.path.append('C:\\inetpub\\wwwroot\\Auto-auction\\myenv\\Lib\\site-packages')
import requests
from django.contrib import messages

def send_sms(phone_number, message):
    """
    Function to send an SMS using the Tiara API
    """
    TIARA_API_URL = settings.TIARA_API_URL
    AUTH_TOKEN = settings.AUTH_TOKEN
    
    SMS_DATA = {
        "from": "Riverlong",  # Sender ID
        "to": phone_number,  # Recipient phone number
        "message": message,  # SMS message
    }

    HEADERS = {
        "Authorization": AUTH_TOKEN,
        "Content-Type": "application/json",
    }

    try:
        # Send the POST request to the Tiara API
        response = requests.post(TIARA_API_URL, json=SMS_DATA, headers=HEADERS)

        # Check if the request was successful
        if response.status_code == 200:
            print(f"SMS sent successfully to {phone_number}")
        else:
            print(f"Failed to send SMS. Status code: {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"An error occurred while sending SMS: {e}")



def send_thank_you_notification(bid, vehicle):
    formatted_amount = f"{bid.amount:,.0f}"
    # Context data for the template
    context = {
        'username': bid.user.username,
        'registration_no': vehicle.registration_no,
        'amount': formatted_amount,  # Formats number with commas
        'make': vehicle.make,
        'model': vehicle.model
    }
    
    # Render the HTML content
    html_message = render_to_string('vehicles/emails/bid_confirmation.html', context)
    
    # Create plain text version for email clients that don't support HTML
    plain_message = strip_tags(html_message)
    
    subject = "Thank You for Placing Your Bid!"
    
    # Send email with both HTML and plain text versions
    send_mail(
        subject=subject,
        message=plain_message,
        html_message=html_message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[bid.user.email],
        fail_silently=False
    )


@login_required(login_url='login')
def place_bid(request, pk, allowed_statuses=None):
    vehicle = get_object_or_404(Vehicle, id=pk)

    # Check for the user's own active (non-disqualified) bid on this vehicle
    existing_bid = Bidding.objects.filter(
        vehicle=vehicle,
        user=request.user,
        disqualified=False
    ).first()

    if request.method == 'POST':
        form = BidForm(request.POST, existing_bid=existing_bid)
        accept_terms = request.POST.get('accept_terms')

        if not accept_terms:
            messages.error(request, 'You must accept the Terms and Conditions to place a bid.')
            return redirect('detail', vehicle.id)

        if not form.is_valid():
            for error in form.errors.values():
                messages.error(request, error.as_text())
            return redirect('detail', vehicle.id)

        amount = form.cleaned_data['amount']
        referred_by = form.cleaned_data.get('referred_by')

        # Bidding fee check
        has_paid = BiddingFeePayment.objects.filter(
            user=request.user,
            vehicle=vehicle,
            status='completed'
        ).exists()

        allowed_statuses = ['on_auction', 'available']

        if vehicle.status not in allowed_statuses:
            messages.warning(request, 'Bidding is not allowed for this vehicle.')
            return redirect('detail', vehicle.id)

        # Check if vehicle is already awarded
        if Bidding.objects.filter(vehicle=vehicle, awarded=True).exists():
            messages.warning(request, 'Sorry, this vehicle is no longer on sale!')
            return redirect('available_vehicles')

        # Check against current highest bid
        current_highest_bid = Bidding.objects.filter(
            vehicle=vehicle,
            disqualified=False,
            awarded=False
        ).order_by('-amount').first()

        if current_highest_bid and amount <= current_highest_bid.amount:
            messages.warning(request, 'Sorry, your bid must be higher than the current highest bid.')
            return redirect('detail', vehicle.id)

        # Disqualify if below 70% of reserve price
        low_bid = vehicle.reserve_price * 0.7
        if amount < low_bid:
            bid = Bidding.objects.create(
                vehicle=vehicle,
                user=request.user,
                amount=amount,
                referred_by=referred_by,
                disqualified=True,
                disqualification_comment="Bid below 70% of reserved price."
            )
            send_bid_notification(bid, vehicle)
            send_thank_you_notification(bid, vehicle)
            send_sms(
                request.user.profile.phone_number,
                f"Thank You for placing your offer of Ksh {amount:,.0f} for {vehicle.registration_no},\n"
                f"This has however been paused as it is too low, consider placing a higher offer amount."
            )
            messages.success(request, 'Thank You for placing your bid!')
            return redirect('detail', vehicle.id)

        # Notify outbid user
        if current_highest_bid:
            send_outbid_notification(current_highest_bid.user, vehicle, current_highest_bid.amount)
            send_sms(
                current_highest_bid.user.profile.phone_number,
                f"You've been outbid on {vehicle.registration_no}.\n"
                f"Place a higher bid amount to increase your chances of winning the vehicle."
            )

        # Create the bid
        bid = Bidding.objects.create(
            vehicle=vehicle,
            user=request.user,
            amount=amount,
            referred_by=referred_by
        )
        messages.success(request, 'Your bid has been placed successfully!')
        send_thank_you_notification(bid, vehicle)
        send_bid_notification(bid, vehicle)
        send_sms(
            request.user.profile.phone_number,
            f"Thank you for placing your bid of Ksh {amount:,.0f} on {vehicle.registration_no}.\n"
            f"You will be notified if anyone places a bid higher than yours."
        )
        return redirect('detail', vehicle.id)

    # GET — build a blank form, pre-filled if there's an existing bid
    initial = {'amount': existing_bid.amount} if existing_bid else {}
    form = BidForm(existing_bid=existing_bid, initial=initial)
    return render(request, 'detail.html', {
        'form': form,
        'vehicle': vehicle,
        'existing_bid': existing_bid,
    })
def send_outbid_notification(user, vehicle, amount):
    """
    Send a notification to the previous highest bidder informing them they have been outbid.

    Args:
        user (User): The user who has been outbid.
        vehicle (Vehicle): The vehicle associated with the bid.
        amount (int): The amount of the outbid.
    """
    subject = f"You've been outbid on {vehicle.registration_no}"
# Format the amount in thousands
    formatted_amount = f"{amount:,.0f}"
    # Prepare context for the email template
    context = {
        'user': user,
        'vehicle': vehicle,
        'amount': formatted_amount,
    }

    # Render the HTML message using the template
    html_message = render_to_string('vehicles/emails/outbid_notification.html', context)

    # Send the email
    from_email = settings.DEFAULT_FROM_EMAIL
    recipient_email = user.email
    send_mail(
        subject,
        '',  # Plain text message (can be empty or optional)
        from_email,
        [recipient_email],
        html_message=html_message,
        fail_silently=False,
    )

def send_thank_you_notification(bid, vehicle):
    formatted_amount = f"{bid.amount:,.0f}"
    # Context data for the template
    context = {
        'username': bid.user.username,
        'registration_no': vehicle.registration_no,
        'amount': formatted_amount,  # Formats number with commas
        'make': vehicle.make,
        'model': vehicle.model
    }
    
    # Render the HTML content
    html_message = render_to_string('vehicles/emails/bid_confirmation.html', context)
    
    # Create plain text version for email clients that don't support HTML
    plain_message = strip_tags(html_message)
    
    subject = "Thank You for Placing Your Bid!"
    
    # Send email with both HTML and plain text versions
    send_mail(
        subject=subject,
        message=plain_message,
        html_message=html_message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[bid.user.email],
        fail_silently=False
    )

def send_bid_notification(bid, vehicle, auction=None):
    subject = f"New Bid Placed on {vehicle.registration_no}"

    # Check if the vehicle is part of an auction and include auction info in the email
    auction_info = f" (Auction ID: {auction.auction_id})" if auction else ""

    # Prepare context for the email template
    context = {
        'bid': bid,
        'vehicle': vehicle,
        'auction': auction,
    }

    # Render the HTML message using the template
    html_message = render_to_string('vehicles/emails/bid_notification.html', context)

    
    financier = vehicle.Financier  

    # Get the notification emails from the Financier model
    if financier and financier.notification_emails:
        recipient_list = financier.get_notification_emails()
    else:
        # Fallback email recipients if no financier or no emails are found
        recipient_list = ['autobid@riverlong.com']

    # Send the email
    from_email = settings.DEFAULT_FROM_EMAIL
    send_mail(
        subject,
        '',  # Plain text message (can be empty or optional)
        from_email,
        recipient_list,
        html_message=html_message,
        fail_silently=False,
    )

def auction_add(request):
    if request.method == 'POST':
        form = AuctionForm(request.POST)
        if form.is_valid():
            auction = form.save()
            # Get the selected vehicles from the form
            selected_vehicles = form.cleaned_data['vehicles']
            # Update the bid_status of selected vehicles
            for vehicle in selected_vehicles:
                vehicle.status = 'on_auction'  # Update this status based on your needs
                vehicle.save()
                AuctionHistory.objects.create(
                    vehicle=vehicle,
                    auction=auction,
                    start_date=auction.start_date,
                    end_date=auction.end_date,
                    sold=False)
            messages.success(request, 'Auction added successfully!')
            return redirect('auction_list')
    else:
        form = AuctionForm()
    return render(request, 'admin/create_auction.html', {'form': form})   

def auction_list(request):
    auctions = Auction.objects.all()
    return render(request, 'admin/auctions.html', {'auctions': auctions})


def auction_detail(request, pk):
    auction = get_object_or_404(Auction, pk=pk)
    return render(request, 'admin/auction_details.html', {'auction': auction})

@login_required
def logout_view(request):
    logout(request)
    return redirect('homepage')


def auction_status_update(request):
    now = timezone.now()
    active_auctions = Auction.objects.filter(end_date__gt=now, approved=True)
    data = {
        'active_auctions_count': active_auctions.count()
    }
    return JsonResponse(data)


def feedback_view(request):
    if request.method == 'POST':
        form = FeedbackForm(request.POST)
        if form.is_valid():
            # Extract form data
            name = form.cleaned_data['name']
            email = form.cleaned_data['email']
            feedback = form.cleaned_data['feedback']

            # Prepare email content
            subject_user = "Thank you for your feedback!"
            message_user = (
                f"Hi {name},\n\n"
                "Thank you for taking the time to share your feedback with us. "
                "We truly value your input .\n\n"
                "Best regards,\nRiverlong Autobid Team"
            )

            subject_team = f"New Feedback Received from {name}"
            message_team = (
                f"Feedback Details:\n"
                f"-----------------\n"
                f"Name: {name}\n"
                f"Email: {email}\n"
                f"Feedback:\n{feedback}\n"
            )
            
            # Sending emails
            try:
                # Email to the user
                send_mail(
                    subject_user,
                    message_user,
                    settings.DEFAULT_FROM_EMAIL,
                    [email],
                    fail_silently=False,
                )

                # Fallback email recipients if none are found in the database
                recipient_list = list(NotificationRecipient.objects.values_list('email', flat=True))
                if not recipient_list:
                    recipient_list = ['autobid@riverlong.com']
                # Email to the team
                send_mail(
                    subject_team,
                    message_team,
                    settings.DEFAULT_FROM_EMAIL,
                    recipient_list,  # Your team email
                    fail_silently=False,
                )
                # Success message for the user
                messages.success(request, "Thank you for your feedback! We've received your message.")
            except Exception as e:
                messages.error(request, f"An error occurred while sending your feedback: {e}")

            # Redirect to the feedback page
            return redirect('contactus')
    else:
        form = FeedbackForm()
    
    return render(request, 'vehicles/contactus.html', {'form': form})



def upcoming_auctions(request):
    """Public list — only approved auctions, soonest first."""
    auctions = UpcomingAuction.objects.filter(
        status='approved',
        auction_startdate__gte=timezone.now(),
    ).order_by('auction_startdate')

    past_auctions = UpcomingAuction.objects.filter(
        status='approved',
        auction_startdate__lt=timezone.now(),
    ).order_by('-auction_startdate')[:6]

    return render(request, 'vehicles/upcoming_auctions.html', {
        'auctions':      auctions,
        'past_auctions': past_auctions,
    })


def download_auction_flyer(request, pk):
    """Serves the flyer image as a browser download."""
    auction = get_object_or_404(UpcomingAuction, pk=pk, status='approved')

    if not auction.image:
        raise Http404("No flyer available.")

    file_path = auction.image.path
    if not os.path.exists(file_path):
        raise Http404("Flyer file not found.")

    ext      = os.path.splitext(file_path)[1]
    filename = f"auction_{auction.auction_startdate.strftime('%Y-%m-%d')}{ext}"

    return FileResponse(open(file_path, 'rb'), as_attachment=True, filename=filename)




