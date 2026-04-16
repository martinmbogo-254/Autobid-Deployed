from django.shortcuts import get_object_or_404, render,redirect
from .models import Vehicle, Bidding, VehicleView, Auction, AuctionHistory, NotificationRecipient, BiddingFeePayment
from django.contrib.auth import logout
from django.contrib.auth.decorators import login_required
from .forms import BidForm, AuctionForm
from django.http.response import HttpResponseRedirect
from django.urls import reverse
from .filters import VehicleFilter
from django.contrib import messages
from .forms import AuctionForm,FeedbackForm
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.core.paginator import Paginator, PageNotAnInteger, EmptyPage
from django.http import HttpResponse,JsonResponse
from .models import Vehicle, Auction, Bidding, AwardHistory
from users.models import User

from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.conf import settings
from django.views.decorators.cache import cache_page
from django.views.decorators.csrf import csrf_exempt
import json
from .Utils.mpesautils import initiate_bidding_fee_payment
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

@login_required
def pay_bidding_fee(request, vehicle_pk):
    vehicle = get_object_or_404(Vehicle, pk=vehicle_pk)
    bidding_fee_amount = 1000  # Change this value as needed

    if request.method == 'POST':
        phone_number = request.POST.get('phone_number', '').strip()

        # Auto-fill from Profile if empty
        if not phone_number:
            try:
                prof = request.user.profile
                if prof.phone_number:
                    phone_number = f"254{str(prof.phone_number).lstrip('0')}"
            except:
                pass

        if not phone_number.startswith('254') or len(phone_number) != 12:
            messages.error(request, 'Please enter a valid phone number starting with 254 (e.g. 254712345678)')
            return redirect('pay_bidding_fee', vehicle_pk=vehicle.pk)

        # Create pending payment
        payment = BiddingFeePayment.objects.create(
            user=request.user,
            vehicle=vehicle,
            amount=bidding_fee_amount,
            phone_number=phone_number,
        )

        callback_url = request.build_absolute_uri('/mpesa/bidding-fee-callback/')

        success, message = initiate_bidding_fee_payment(
            phone_number=phone_number,
            amount=bidding_fee_amount,
            account_reference=f"BidFee-{vehicle.registration_no}",
            transaction_desc=f"Bidding fee for {vehicle.registration_no}",
            callback_url=callback_url,
            payment_instance=payment
        )

        if success:
            messages.info(request, message)
            return redirect('bidding_fee_status', payment_id=payment.id)
        else:
            payment.delete()
            messages.error(request, message)
            return redirect('pay_bidding_fee', vehicle_pk=vehicle.pk)

    # GET request
    default_phone = ""
    try:
        if request.user.profile.phone_number:
            default_phone = f"254{str(request.user.profile.phone_number).lstrip('0')}"
    except:
        pass

    context = {
        'vehicle': vehicle,
        'bidding_fee': bidding_fee_amount,
        'default_phone': default_phone,
    }
    return render(request, 'vehicles/payments/pay_bidding_fee.html', context)

@csrf_exempt
def bidding_fee_callback(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            stk = data.get('Body', {}).get('stkCallback', {})
            result_code = stk.get('ResultCode')
            checkout_id = stk.get('CheckoutRequestID')

            payment = BiddingFeePayment.objects.filter(checkout_request_id=checkout_id).first()

            if payment:
                if result_code == 0:  # Success
                    items = stk.get('CallbackMetadata', {}).get('Item', [])
                    receipt = next((item.get('Value') for item in items if item.get('Name') == 'MpesaReceiptNumber'), None)
                    payment.mark_as_paid(transaction_id=receipt)
                else:
                    payment.status = 'failed'
                    payment.save()
        except Exception:
            pass  # Add logging in production

    return JsonResponse({"ResultCode": 0, "ResultDesc": "Accepted"})

@login_required
def bidding_fee_status(request, payment_id):
    payment = get_object_or_404(BiddingFeePayment, id=payment_id, user=request.user)
    return render(request, 'vehicles/payments/bidding_fee_status.html', {'payment': payment})


@login_required(login_url='login')
def place_bid(request, pk, allowed_statuses=None):
    vehicle = get_object_or_404(Vehicle, id=pk)
    # Get the vehicle using the slugified registration number
    # vehicle = get_object_or_404(Vehicle, registration_no__iexact=registration_no.replace("-", " "))

    if request.method == 'POST':
        amount = request.POST.get('amount')
        accept_terms = request.POST.get('accept_terms')
        referred_by = request.POST.get('referred_by')

        # bidding fee check
        has_paid = BiddingFeePayment.objects.filter(
            user=request.user,
            vehicle=vehicle,
            status='completed'
        ).exists()

        if not has_paid:
            messages.info(request, 'You must pay the bidding fee first before placing a bid.')
            return redirect('pay_bidding_fee', vehicle_pk=vehicle.pk)


        try:
            amount = int(amount)
        except (ValueError, TypeError):
            messages.error(request, 'Please enter a valid bid amount.')
            return redirect('detail', vehicle.id)

        if not accept_terms:
            messages.error(request, 'You must accept the Terms and Conditions to place a bid.')
            return redirect('detail', vehicle.id)

        allowed_statuses = ['on_auction', 'available']

        # Check if the vehicle status is one of the allowed statuses
        if vehicle.status in allowed_statuses:
            current_highest_bid = Bidding.objects.filter(
                vehicle=vehicle,
                disqualified=False,
                awarded=False
            ).order_by('-amount').first()

            if current_highest_bid and amount <= current_highest_bid.amount:
                messages.warning(request, f'Sorry ,Your bid must be higher than the current highest bid.')
                return redirect('detail', vehicle.id)
        else:
            messages.warning(request, 'Bidding is not allowed for this vehicle.')
            return redirect('detail', vehicle.id)

        # Check if this vehicle is already awarded and warn the user
        bid_awarded = Bidding.objects.filter(vehicle=vehicle,awarded=True)
        if bid_awarded:
            messages.warning(request,f'Sorry , This vehicle is nolonger on sale!')
            return redirect('available_vehicles')
        
        low_bid = vehicle.reserve_price * 0.7  
        if amount< low_bid:
            bid = Bidding.objects.create(
                vehicle=vehicle,
                user=request.user,
                amount=amount,
                referred_by=referred_by,
                disqualified=True,  # ✅ Mark as disqualified,
                disqualification_comment = "Bid below 70% of reserved price."

            )
      

            # Send notification email to admin or other recipients
            send_bid_notification(bid, vehicle)

            # Send "Thank You" email to the bidder
            send_thank_you_notification(bid, vehicle)

            # Notify user via SMS
            send_sms(
                request.user.profile.phone_number,
                f"Thank You for placing your offer of Ksh {amount:,.0f} for {vehicle.registration_no},\n.This has however been paused as it is too low, consider placing a higher offer amount."
            )

            messages.success(request, 'Thank You for placing your bid!.')
            return redirect('detail', vehicle.id)

        # Ensure the bid is above 0 Ksh
        min_bid = vehicle.reserve_price * 0
        if amount <= min_bid:
            messages.warning(request, f'Your bid must be equal to or greater than 1 Ksh.')
            return redirect('detail', vehicle.id)
        

        # Notify the current highest bidder if they are outbid
        if current_highest_bid:
            send_outbid_notification(current_highest_bid.user, vehicle, current_highest_bid.amount)
            send_sms(current_highest_bid.user.profile.phone_number, f"You've been outbid on {vehicle.registration_no}.\nPlace a higher bid amount to increase your chances of winning the vehicle. ")  # Send SMS to the outbid user

        # Create the new bid if all the above checks pass
        bid = Bidding.objects.create(vehicle=vehicle, user=request.user, amount=amount, referred_by=referred_by)
        messages.success(request, 'Your bid has been placed successfully!')

        # Send "Thank You" email to the bidder
        send_thank_you_notification(bid, vehicle)

        # Send notification email to admin or other recipients
        send_bid_notification(bid, vehicle)
         # Send SMS to the bidder
        send_sms(request.user.profile.phone_number, f"Thank you for placing your bid of Ksh {amount:,.0f} on the vehicle {vehicle.registration_no}.\nYou will be notified if anyone places a bid higher than yours.")  
        return redirect('detail', vehicle.id)

    return redirect('detail', vehicle.id)
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