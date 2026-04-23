from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.shortcuts import render
from django.urls import path
from users.models import Profile
from django.contrib.auth.models import User
from django.contrib import admin
from django.utils import timezone

from .admin_forms import ReviseVehiclePriceForm
from .models import AdminActionLog, Auction, Vehicle, AuctionHistory, VehiclePriceRevision, NotificationLog
from django.contrib import admin, messages
from .forms import AuctionForm
from django.utils import timezone
from django.contrib import admin
from django.utils import timezone
from .models import Auction, Vehicle, AuctionHistory
from django.contrib import admin
from django.utils import timezone
from .models import (
    VehicleImage, VehicleMake, VehicleModel,
    ManufactureYear, FuelType, VehicleBody, Vehicle, Bidding, Auction, VehicleView, AuctionHistory,NotificationRecipient,Financier,Yard,AwardHistory,BiddingFeePayment
)


from django.contrib import admin
from django.http import HttpResponse
import csv
from django.core.mail import send_mail
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags, format_html
import os
from reportlab.platypus import Image
from django.contrib import messages
from .Utils.sms import send_sms
# from rangefilter.filters import DateRangeFilter

from datetime import datetime
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
import tempfile
import os
from simple_history.admin import SimpleHistoryAdmin

from datetime import datetime
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib.units import inch



# Add a description to the custom action
@admin.register(AwardHistory)
class AwardHistoryAdmin(admin.ModelAdmin):
    list_display = ('vehicle', 'user_full_name', 'user_email', 'amount', 'awarded_by','awarded_at')
    search_fields = ('vehicle__registration_no', 'user__username', 'user__email')
    list_filter = ('awarded_at',)
    list_per_page = 20
    list_max_show_all = 1000 
    show_full_result_count = True  
    actions = ['generate_awardhistory_report']

    def user_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"
    user_full_name.short_description = 'User Full Name'

    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'User Email'

    def awarded_by(self, obj):
        return obj.awarded_by.email
    awarded_by.short_description = 'Awarded By'

    def amount(self, obj):
        return f"Ksh {obj.amount:,}"
    amount.short_description = 'Amount'

    def generate_awardhistory_report(self, request, queryset):
        from django.http import HttpResponse
        import csv
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="award_history_report.csv"'

        writer = csv.writer(response)
        writer.writerow(['Vehicle', 'Awarded User','Amount Awarded','Awarded By','Awarded At' ])

        # Iterate over the selected vehicles in the admin panel
        for awardHistory in queryset:
           
            writer.writerow([
               
                awardHistory.vehicle,
                awardHistory.user,
                awardHistory.amount,
                awardHistory.awarded_by,
                awardHistory.awarded_at,
                
            ])
        
        return response

    generate_awardhistory_report.short_description = "Generate CSV report for selected award histories"

    # Optional: Customize the ordering of the records
    ordering = ('-awarded_at',)

from django.contrib import admin
from django.db.models import Max
from django.contrib.admin import SimpleListFilter
from django.core.exceptions import ValidationError
from datetime import timedelta


from django.db.models import Max, OuterRef, Subquery, F, Min

class HighestBidPerUserFilter(SimpleListFilter):
    title = 'Highest Bids Only'
    parameter_name = 'highest_bids_only'

    def lookups(self, request, model_admin):
        return (
            ('yes', 'Show only highest bids per user per vehicle'),
            ('no', 'Show all bids'),
        )

    def queryset(self, request, queryset):
        if self.value() == 'yes':
            max_bid_amount_subquery = (
                queryset
                .filter(user=OuterRef('user'), vehicle=OuterRef('vehicle'))
                .values('user', 'vehicle')
                .annotate(max_amount=Max('amount'))
                .values('max_amount')[:1]
            )

            annotated_queryset = queryset.annotate(
                max_amount=Subquery(max_bid_amount_subquery)
            ).filter(amount=F('max_amount'))

            min_pk_subquery = (
                annotated_queryset
                .filter(user=OuterRef('user'), vehicle=OuterRef('vehicle'))
                .values('user', 'vehicle')
                .annotate(min_pk=Min('pk'))
                .values('min_pk')[:1]
            )

            return annotated_queryset.filter(
                pk=Subquery(min_pk_subquery)
            )

        return queryset

# class HighestBidPerUserFilter(SimpleListFilter):
#     title = 'Highest Bids Only'
#     parameter_name = 'highest_bids_only'

#     def lookups(self, request, model_admin):
#         return (
#             ('yes', 'Show only highest bids per user per vehicle'),
#             ('no', 'Show all bids'),
#         )

#     def queryset(self, request, queryset):
#         if self.value() == 'yes':
#             # Subquery to get the max amount per user+vehicle
#             max_bid_subquery = (
#                 queryset
#                 .filter(user=OuterRef('user'), vehicle=OuterRef('vehicle'))
#                 .values('user', 'vehicle')
#                 .annotate(max_amount=Max('amount'))
#                 .values('max_amount')[:1]
#             )
#             return queryset.annotate(
#                 max_amount=Subquery(max_bid_subquery)
#             ).filter(amount=F('max_amount'))

#         return queryset



@admin.register(Bidding)
class BidAdmin(admin.ModelAdmin):
    search_fields = ('vehicle__registration_no', 'user__username')
    list_display = ('vehicle', 'vehicle_details','paid','vehicle_reserveprice', 'formatted_amount','user_email','user_phonenumber','is_auction_bid','awarded','awarded_at','awarded_by','time_since_award','disqualified' , 'bid_time','time_since_bid','referrer')
    actions = ['generate_bid_report','award_bid','disqualify_bids','mark_selected_bids_as_paid']
    list_filter = ('awarded','disqualified','paid','is_auction_bid',HighestBidPerUserFilter,'bid_time')
    readonly_fields = [field.name for field in Bidding._meta.fields if field.name not in [ "awarded", "disqualified"]]

    def time_since_award (self, obj):
        return obj.time_since_award()

    time_since_award.short_description = "Bid Awarded"

    def time_since_bid (self, obj):
        return obj.time_since_bid()

    time_since_bid.short_description = "Bid Placed"

    def get_actions(self, request):
        actions = super().get_actions(request)

        # Check user group
        if not request.user.groups.filter(name__in=['Admins', 'DEV']).exists():
            # Remove restricted actions if not in the  group
            restricted = ['award_bid', 'disqualify_bids']
            for action in restricted:
                if action in actions:
                    del actions[action]
        if not request.user.has_perm('vehicles.can_mark_bid_paid'):
            actions.pop('mark_selected_bids_as_paid', None)

        return actions

    def mark_selected_bids_as_paid(self, request, queryset):
        success = 0
        errors = 0

        for bid in queryset.select_related('vehicle'):
            try:
                # Validation
                if not bid.awarded:
                    raise ValidationError("Only awarded bids can be paid.")

                if bid.paid:
                    raise ValidationError("Bid is already marked as paid.")

                vehicle = bid.vehicle
                if vehicle.status != 'bid_won':
                    raise ValidationError("Vehicle is not in a payable state.")

                # mark bid as paid
                bid.paid = True
                bid.paid_at = timezone.now()
                bid.marked_paid_by = request.user
                bid.save(update_fields=['paid', 'paid_at', 'marked_paid_by'])

                # Update vehicle status
                vehicle.status = 'sold'
                vehicle.save(update_fields=['status'])

                success += 1

            except ValidationError as e:
                errors += 1
                self.message_user(
                    request,
                    f"Bid for {bid.vehicle}: {e.message}",
                    level=messages.ERROR
                )

        if success:
            self.message_user(
                request,
                f"{success} bid(s) successfully marked as PAID and vehicles SOLD.",
                level=messages.SUCCESS
            )

        if errors:
            self.message_user(
                request,
                f"{errors} bid(s) failed validation.",
                level=messages.WARNING
            )

    mark_selected_bids_as_paid.short_description = "Mark selected awarded bids as PAID"

    def view_on_site(self, obj):
        # Check if *any* bid for this vehicle is awarded
        vehicle_has_awarded_bid = Bidding.objects.filter(
            vehicle=obj.vehicle,
            awarded=True
        ).exists()

        # Check if vehicle is approved
        if obj.vehicle.is_approved==True and obj.vehicle.status=='available':
            return obj.get_frontend_url()
        return None

        if not vehicle_has_awarded_bid:
            return obj.get_frontend_url()
        return None  # disables the "View on site" link
    
    # Method to extract user's full name (first_name + last_name)
    def user_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"

    def referrer(self, obj):
        return obj.referred_by

    user_full_name.short_description = 'User Full Name'  # This sets the column name in the admin list view

    def vehicle_reserveprice(self, obj):
        return '{:,.0f}'.format(obj.vehicle.reserve_price)

    vehicle_reserveprice.short_description ='Reserve Price' 

    def vehicle_details(self, obj):
        return f"{obj.vehicle.YOM} {obj.vehicle.make} {obj.vehicle.model}"

    vehicle_details.short_description ='Vehicle Details' 

    # Method to extract user's email
    def user_email(self, obj):
        return obj.user.email

    user_email.short_description = 'User Email'  # This sets the column name in the admin list view

    # Method to extract user's email
    def user_phonenumber(self, obj):
        return obj.user.profile.phone_number

    user_phonenumber.short_description = 'User phone number'  # This sets the column name in the admin list view

    # Method to format the 'amount' field with thousands separator
    def formatted_amount(self, obj):
        return '{:,.0f}'.format(obj.amount)

    formatted_amount.short_description = 'Offer Amount'  # This sets the column name in the admin list view
    
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('disqualify-bid/<int:bid_id>/', self.admin_site.admin_view(self.disqualify_bid_view), name="disqualify_bid"),
        ]
        return custom_urls + urls

    def disqualify_bid_view(self, request, bid_id):
        bid = Bidding.objects.get(id=bid_id)
        if request.method == "POST":
            comment = request.POST.get("comment", "")
            bid.disqualified = True
            bid.disqualification_comment = comment
            bid.save()
            self.message_user(request, f"Bid {bid_id} disqualified successfully!", messages.SUCCESS)
            return render(request, "vehicles/admin/bid_disqualified.html", {"bid": bid})

        return render(request, "vehicles/admin/disqualify_bid.html", {"bid": bid})

    @admin.action(description="Disqualify selected bids")
    def disqualify_bids(self, request, queryset):
        import requests
        from django.contrib import messages
        from django.utils import timezone

        # Tiara API details
        TIARA_API_URL = settings.TIARA_API_URL
        AUTH_TOKEN = settings.AUTH_TOKEN

        def send_sms(bid):
            """
            Function to send an SMS using the Tiara API
            """
            try:
                # Verify phone number exists
                if not bid.user.profile.phone_number:
                    print(f"No phone number found for user {bid.user.get_full_name()}")
                    return False

                SMS_DATA = {
                    "from": "Riverlong",  # Sender ID
                    "to": bid.user.profile.phone_number,  # Recipient phone number
                    "message": f"Dear {bid.user.get_full_name()}, your bid for vehicle {bid.vehicle.registration_no} "
                            f"has been disqualified. Please contact 0701689319 for more details.",
                }

                HEADERS = {
                    "Authorization": AUTH_TOKEN,
                    "Content-Type": "application/json",
                }

                # Send the POST request to the Tiara API
                response = requests.post(TIARA_API_URL, json=SMS_DATA, headers=HEADERS)

                # Check if the request was successful
                if response.status_code == 200:
                    print(f"SMS sent successfully to {bid.user.profile.phone_number}")
                    return True
                else:
                    print(f"Failed to send SMS. Status code: {response.status_code}")
                    return False

            except Exception as e:
                print(f"An error occurred while sending SMS: {e}")
                return False

        admin_user = request.user  # Get the logged-in admin user
        admin_name = admin_user.get_full_name() or admin_user.username  # Use full name if available, otherwise username
        disqualification_time = timezone.now().strftime('%Y-%m-%d %H:%M:%S')  # Format time

        disqualified_count = 0
        already_disqualified = 0
        sms_failed_count = 0
        revoked_awards_count = 0

        for bid in queryset:
            if bid.disqualified:  # Check if already disqualified
                already_disqualified += 1
                continue  # Skip already disqualified bids
            
            # If bid was awarded, revoke the award
            was_awarded = bid.awarded
            if was_awarded:
                bid.awarded = False
                revoked_awards_count += 1
                
            bid.disqualified = True
            bid.disqualification_comment = (
                f"Disqualified via admin action by {admin_name} ({admin_user.email}) at {disqualification_time}"
            )
            bid.save()
            disqualified_count += 1

            # Attempt to send SMS notification
            if not send_sms(bid):
                sms_failed_count += 1

        # Send feedback messages to the admin
        if disqualified_count:
            msg = f"{disqualified_count} bid(s) successfully disqualified!"
            if revoked_awards_count:
                msg += f" {revoked_awards_count} previously awarded bid(s) had their awards revoked."
            self.message_user(request, msg, messages.SUCCESS)
            
        if already_disqualified:
            self.message_user(
                request, f"{already_disqualified} bid(s) were already disqualified and skipped.", messages.WARNING
            )
        if sms_failed_count:
            self.message_user(
                request, f"Failed to send SMS for {sms_failed_count} disqualified bid(s).", messages.WARNING
            )

    @admin.action(description="Disqualify selected bid silently")
    def disqualify_bids_silently(self, request, queryset):
        admin_user = request.user  # Get the logged-in admin user
        admin_name = admin_user.get_full_name() or admin_user.username  # Use full name if available, otherwise username
        disqualification_time = timezone.now().strftime('%Y-%m-%d %H:%M:%S')  # Format time

        disqualified_count = 0
        already_disqualified = 0
        sms_failed_count = 0
        revoked_awards_count = 0

        for bid in queryset:
            if bid.disqualified:  # Check if already disqualified
                already_disqualified += 1
                continue  # Skip already disqualified bids

            # If bid was awarded, revoke the award
            was_awarded = bid.awarded
            if was_awarded:
                bid.awarded = False
                revoked_awards_count += 1

            bid.disqualified = True

            bid.disqualification_comment = (
                f"Disqualified via admin action by {admin_name} ({admin_user.email}) at {disqualification_time}"
            )
            bid.save()
            disqualified_count += 1

        # Send feedback messages to the admin
        if disqualified_count:
            msg = f"{disqualified_count} bid(s) successfully disqualified!"
            if revoked_awards_count:
                msg += f" {revoked_awards_count} previously awarded bid(s) had their awards revoked."
            self.message_user(request, msg, messages.SUCCESS)

        if already_disqualified:
            self.message_user(
                request, f"{already_disqualified} bid(s) were already disqualified and skipped.", messages.WARNING
            )

    def award_bid(self, request, queryset):
        from django.contrib import messages
        
        # Ensure only one bid is selected
        if queryset.count() != 1:
            self.message_user(
                request,
                "Please select exactly one bid to award.",
                level=messages.WARNING
            )
            return

        bid = queryset.first()
        vehicle = Vehicle.objects.select_for_update().get(pk=bid.vehicle.pk)

        # Prevent awarding if bid is less than 6hrs old since placement
        # bid_age = timezone.now() - bid.bid_time
        # if bid_age < timedelta(hours=6):
        #     remaining = timedelta(hours=6) - bid_age
        #     hours, remainder = divmod(remaining.seconds, 3600)
        #     minutes = remainder // 60
        #
        #     self.message_user(
        #         request,
        #         (
        #             "This bid cannot be awarded yet. "
        #             f"Please wait {hours}h {minutes}m before awarding."
        #         ),
        #         level=messages.WARNING
        #     )
        #     return

        # Check if the vehicle bid is currently on auction
        if bid.vehicle.status == 'on_auction' and bid.vehicle.is_in_active_auction():
            self.message_user(
                request,
                "Sorry you cannot Award this vehicle as it is currently on auction.",
                level=messages.ERROR
            )
            return
        
        # Check if the vehicle bid is currently on bid_won
        if bid.vehicle.status == 'bid_won' :
            self.message_user(
                request,
                "Sorry you cannot Award this vehicle as it is currently on bid_won status.",
                level=messages.ERROR
            )
            return
        # Check if this bid is already awarded
        if bid.awarded:
            self.message_user(
                request,
                "This bid is already awarded.",
                level=messages.ERROR
            )
            return
        
        # Check if this bid is disqualified
        if bid.disqualified:
            self.message_user(
                request,
                "Cannot award a disqualified bid.",
                level=messages.ERROR
            )
            return
        
        # Check if there's any other awarded bid for this vehicle
        existing_awarded_bid = Bidding.objects.select_for_update().filter(
            vehicle=vehicle,
            awarded=True,
            disqualified=False
        ).exclude(pk=bid.pk).first()

        if existing_awarded_bid:
            self.message_user(
                request,
                f"Vehicle {vehicle.registration_no} already has an awarded bid to "
                f"{existing_awarded_bid.user.get_full_name()} for "
                f"Ksh {'{:,.0f}'.format(existing_awarded_bid.amount)}.",
                level=messages.ERROR
            )
            return
        
        # Check if there's any other disqualified bid for this vehicle
        # existing_disqualified_bid = Bidding.objects.select_for_update().filter(
        #     vehicle=vehicle,
        #     disqualified=True
        # ).exclude(pk=bid.pk).first()

        # if existing_disqualified_bid:
        #     self.message_user(
        #         request,
        #         f"Vehicle {vehicle.registration_no} has disqualified bids. "
        #         "Please resolve them before awarding.",
        #         level=messages.ERROR
        #     )
        #     return
        
        # All checks passed - award the bid
        try:
            bid.awarded = True
            bid.awarded_by = request.user
            bid.awarded_at = timezone.now()
            bid.save()
            
            # Update the associated vehicle's status
            vehicle.status = 'bid_won'
            vehicle.save()
            
            self.message_user(
                request,
                f"Successfully awarded bid to {bid.user.get_full_name()} for "
                f"Ksh {'{:,.0f}'.format(bid.amount)} on vehicle {vehicle.registration_no}",
                level=messages.SUCCESS
            )
        except Exception as e:
            self.message_user(
                request,
                f"Failed to award bid: {str(e)}",
                level=messages.ERROR
            )
            # Create an entry in the AwardHistory model
        try:
            AwardHistory.objects.create(
                user=bid.user,
                vehicle=bid.vehicle,
                amount=bid.amount,
                awarded_at=bid.bid_time,
                awarded_by=request.user
            )
        except Exception as e:
            self.message_user(
                request,
                f"Failed to update award history. Error: {e}",
                level=messages.ERROR
            )
            return

        # Now, we handle the email notification to the financier's listed email recipients
        try:
            from django.core.mail import EmailMultiAlternatives
            from django.template.loader import render_to_string
            from django.conf import settings

            # Email subject
            admin_email_subject = "🚨  Bid Award Notification - Autobid by Riverlong Limited"
            
            # Context for email template
            admin_email_context = {
                'bidder_name': bid.user.get_full_name(),
                'vehicle_financier':vehicle.Financier.name,
                'bidder_email': bid.user.email,
                'vehicle_reg': vehicle.registration_no,
                'amount': '{:,.0f}'.format(bid.amount),
            }
            
            # Render HTML email content
            admin_html_content = render_to_string('vehicles/emails/bidaward_admins.html', admin_email_context)

            # Create plain text version for email clients that don't support HTML
            admin_text_content = f""" Bid Award Notification!

                Bid Details:
                Bidder: {bid.user.first_name}
                Vehicle: {vehicle.registration_no}
                Winning Bid: KSH {'{:,.0f}'.format(bid.amount)}

                Please review and process the awarded bid."""

            # Get the associated financier from the vehicle
            financier = vehicle.Financier  # Assuming vehicle has a 'financier' relationship

            # Get the notification emails from the Financier model
            if financier and financier.notification_emails:
                recipient_list = financier.get_notification_emails()
            else:
                # Fallback email recipients if no financier or no emails are found
                recipient_list = ['autobid.riverlong.com']

            # Create email message
            admin_email = EmailMultiAlternatives(
                subject=admin_email_subject,
                body=admin_text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=recipient_list  # Send to emails from Financier model
            )

            # Attach HTML content
            admin_email.attach_alternative(admin_html_content, "text/html")

            # Send the email notification
            admin_email.send()

        except Exception as e:
            self.message_user(
                request,
                f"Failed to send email notification. Error: {e}",
                level=messages.ERROR
            )
       

        # Generate offer letter as PDF
        try:
            from reportlab.lib import colors
            from reportlab.lib.pagesizes import letter
            from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
            from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
            from reportlab.lib.units import inch
            import tempfile
            from datetime import datetime
            from reportlab.platypus import Image


            # Assuming you have the path to the image file
            image_path = 'vehicles\static\images\RL-Logo.png'
            # Create a temporary file for the PDF
            with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as tmp_file:
                pdf_file_path = tmp_file.name

            # Create the PDF document
            doc = SimpleDocTemplate(
                pdf_file_path,
                pagesize=letter,
                rightMargin=72,
                leftMargin=72,
                # topMargin=72,
                bottomMargin=72
            )

            # Prepare the story (content) for the PDF
            story = []
            styles = getSampleStyleSheet()
            
            # Add custom style for the header
            styles.add(ParagraphStyle(
                name='CustomTitle',
                parent=styles['Heading1'],
                alignment=1,  # Center alignment
                spaceAfter=30
            ))

            # Add the header
            # Append the image to your story
            story.append(Image(image_path, width=100, height=100))
            # story.append(Paragraph("Riverlong Limited", styles['CustomTitle']))
            story.append(Paragraph("Vehicle Bid Award Letter", styles['CustomTitle']))
            story.append(Spacer(1, 10))

            # Add the date
            story.append(Paragraph(
                f"Date: {datetime.now().strftime('%d %B %Y')}", 
                styles['Normal']
            ))
            story.append(Spacer(1, 20))
            story.append(Paragraph(f"<b><u>RE: SALE OF MOTOR VEHICLE REG NO. {vehicle.registration_no}.</u></b>", styles['Normal']))
            # Add client information
            # story.append(Paragraph(f"Dear {bid.user.get_full_name()},", styles['Normal']))
            # story.append(Paragraph(f"ID Number: {bid.user.profile.ID_number}", styles['Normal']))
            story.append(Spacer(1, 10))

            # Add main content
            story.append(Paragraph(
                f"<b>{bid.user.get_full_name()}</b> of ID <b>{bid.user.profile.ID_number}</b> is hereby granted the opportunity to make payment of Kes.<b> {'{:,.0f}'.format(bid.amount)}</b> "
                f"towards purchase of vehicle <b>{vehicle.registration_no}</b>. "
                f"Kindly but urgently deposit the above forestated amount to the below bank account.",
                styles['Normal']
            ))
            story.append(Spacer(1, 20))

            # Add bank details
            financier_name = vehicle.Financier.name.strip().lower()

            # Select bank details based on the financier
            if "tijaara" in financier_name:
                mpesa_data =[
                    ["Payment Method","MPESA PAYBILL"],
                    ["Paybill Number:", "880100"],
                    ["Account Number:", "3190500038"],
                  
                ]
                bank_data = [
                    ["Bank Name:", "NCBA"],
                    ["Account Name:", "TIJAARA FINANCE"],
                    ["Account Number:", "3190500038"],
                    ["Branch:", "KENYATTA AVENUE BRANCH"]
                ]
            elif "zazipay" in financier_name:
                mpesa_data =[
                    ["Payment Method","MPESA PAYBILL"],
                    ["Paybill Number:", "707879"],
                    ["Account Number:", f"{vehicle.registration_no}"],
                 
                  
                ]
                bank_data = [
                    ["Bank Name:", "NCBA"],
                    ["Account Name:", "ZAZI PAY INTERNATIONAL LTD "],
                    ["Account Number:", "9081590019"],
                    ["Branch:", "KENYATTA AVENUE BRANCH"]
                ]
            elif "mycredit" in financier_name:
                mpesa_data =[
                    ["Payment Method","MPESA PAYBILL"],
                    ["Paybill Number:", "795902"],
                    ["Account Number:", f"{vehicle.registration_no}"],
                  
                ]
                bank_data = [
                    ["Bank Name:", "NCBA Bank"],
                    ["Account Name:", "MYCREDIT LIMITED"],
                    ["Account Number:", "1004557111"],
                    ["Branch:", "KENYATTA AVENUE BRANCH"]
                ]
            elif "watu" in financier_name:
                mpesa_data =[
                    ["Payment Method","MPESA PAYBILL"],
                    ["Paybill Number:", "4073003"],
                    ["Account Number:", f"{bid.user.profile.ID_number}"],
                ]
                bank_data = [
                    ["Bank Name:", "STANBIC BANK"],
                    ["Account Name:", "WATU GARI LIMITED"],
                    ["Account Number:", "0100009321505"],
                    ["Branch:", "NYALI BRANCH"]
                ]
            
            elif "jefigs" in financier_name:
                mpesa_data =[
                    ["Payment Method","NA"],
                    ["Paybill Number:", "NA"],
                    ["Account Number:", "NA"],
                ]
                bank_data = [
                    ["Bank Name:", "COOP BANK"],
                    ["Account Name:", "JEFIGS CREDIT LTD"],
                    ["Account Number:", "01148732209300"],
                    ["Branch:", "AGHA KHAN WALK BRANCH"]
                ]
            elif "riverlong" in financier_name:
                mpesa_data =[
                    ["Payment Method","NA"],
                    ["Paybill Number:", "NA"],
                    ["Account Number:", "NA"],
                ]
                bank_data = [
                    ["Bank Name:", "SIDIAN BANK"],
                    ["Account Name:", "RIVERLONG LTD"],
                    ["Account Number:", "01003020040447"],
                    ["Branch:", "KENYATTA AVENUE"]
                ]

            else:
                mpesa_data =[
                    ["Payment Method","Test"],
                    ["Paybill Number:", "Test"],
                    ["Account Number:", f"{vehicle.registration_no}"],
                ]
                bank_data = [
                    ["Bank Name:", "Test"],
                    ["Paybill Number:", "Test"],
                    ["Account Name:", "Test"],
                    ["Account Number:", "Test"],
                    ["Branch:", "Test"]
                ]
            


            table = Table(mpesa_data, colWidths=[2*inch, 3*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (0, -1), colors.lightgrey),
                ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
                ('BACKGROUND', (1, 0), (-1, -1), colors.white),
                ('FONTNAME', (1, 0), (-1, -1), 'Helvetica'),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            story.append(table)
            story.append(Spacer(1, 20))

            table = Table(bank_data, colWidths=[2*inch, 3*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (0, -1), colors.lightgrey),
                ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
                ('BACKGROUND', (1, 0), (-1, -1), colors.white),
                ('FONTNAME', (1, 0), (-1, -1), 'Helvetica'),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            story.append(table)
            story.append(Spacer(1, 20))

            

            # Add terms and conditions
            story.append(Paragraph("Terms and Conditions:", styles['Heading2']))
            terms = [
                "Payment must be made within 3 hours of receiving this letter.",
                "The vehicle will only be released after full payment confirmation.",
                "This offer is non-transferable."
            ]
            for term in terms:
                story.append(Paragraph(f"• {term}", styles['Normal']))
                story.append(Spacer(1, 10))

            # Add footer
            story.append(Spacer(1, 30))
            story.append(Paragraph(
                "For any queries, please contact us at autobid@riverlong.com",
                styles['Normal']
            ))
            story.append(Paragraph("Riverlong Limited", styles['Normal']))

            # Build the PDF
            doc.build(story)

            # [Rest of the email sending code remains the same]

        except Exception as e:
            self.message_user(
                request,
                f"Failed to generate the offer letter. Error: {e}",
                level=messages.ERROR
            )
            return
        

        import requests
        from django.contrib import messages

        # Tiara API details
        TIARA_API_URL =settings.TIARA_API_URL
        AUTH_TOKEN = settings.AUTH_TOKEN

        def send_sms(message):
            """
            Function to send an SMS using the Tiara API
            """
            SMS_DATA = {
                "from": "Riverlong",  # Sender ID
                "to": bid.user.profile.phone_number,  # Recipient phone number
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
                    print(f"SMS sent successfully! to {bid.user.profile.phone_number}")# Debugging step: Print the phone number
                

                else:
                    print(f"Failed to send SMS. Status code: {response.status_code}")
                    # Optionally log or handle the error further
            except Exception as e:
                print(f"An error occurred: {e}")
                
        # Send SMS to the user who won the bid
        try:
            financier_name = vehicle.Financier.name.strip().lower() if vehicle.Financier and vehicle.Financier.name else ""

            # Defaults
            mpesa_paybill = "000000"
            mpesa_acc_no = "000000"
            bank_name = "Default Bank"
            bank_acc_name = "Riverlong Ltd"
            bank_acc_no = "0000000000"
            bank_branch = "Main Branch"
            

            # Financier-specific details
            if "tijaara" in financier_name:
                mpesa_paybill = "880100"
                mpesa_acc_no = "3190500038"
                bank_name = "NCBA"
                bank_acc_name = "TIJAARA FINANCE"
                bank_acc_no = "3190500038"
                bank_branch = "KENYATTA AVENUE BRANCH"
                

            elif "zazipay" in financier_name:
                mpesa_paybill = "707879"
                mpesa_acc_no = vehicle.registration_no
                bank_name = "NCBA"
                bank_acc_name = "ZAZI PAY INTERNATIONAL LTD"
                bank_acc_no = "9081590019"
                bank_branch = "KENYATTA AVENUE BRANCH"
            

            elif "mycredit" in financier_name:
                mpesa_paybill = "795902"
                mpesa_acc_no = vehicle.registration_no
                bank_name = "NCBA Bank"
                bank_acc_name = "MYCREDIT LIMITED"
                bank_acc_no = "1004557111"
                bank_branch = "KENYATTA AVENUE BRANCH"

            elif "watu" in financier_name:
                mpesa_paybill = "4073003"
                mpesa_acc_no = f"{bid.user.profile.ID_number}"
                bank_name = "STANBIC BANK"
                bank_acc_name = "WATU GARI LIMITED"
                bank_acc_no = "0100009321505"
                bank_branch = "NYALI BRANCH"

            elif "jefigs" in financier_name:
                mpesa_paybill = "NA"
                mpesa_acc_no = "NA"
                bank_name = "COOP BANK"
                bank_acc_name = "JEFIGS CREDIT LTD"
                bank_acc_no = "01148732209300"
                bank_branch = "AGHA KHAN WALK BRANCH "

            elif "riverlong" in financier_name:
                mpesa_paybill = "NA"
                mpesa_acc_no = "NA"
                bank_name = "SIDIAN BANK"
                bank_acc_name = "RIVERLONG LTD"
                bank_acc_no = "01003020040447"
                bank_branch = "KENYATTA AVENUE "

            # Construct the message
            message = (
                f"Congratulations {bid.user.get_full_name()}! You have won {vehicle.registration_no} for Ksh {'{:,.0f}'.format(bid.amount)}.\n\n"
                f"MPESA PAYMENT:\n"
                f"Paybill: {mpesa_paybill}\n"
                f"Acc No: {mpesa_acc_no}\n\n"
                f"BANK PAYMENT:\n"
                f"Bank: {bank_name}\n"
                f"Acc Name: {bank_acc_name}\n"
                f"Acc No: {bank_acc_no}\n"
                f"Branch: {bank_branch}\n\n"
                
            )

            send_sms(message)

        except Exception as e:
            self.message_user(
                request,
                f"Failed to send SMS notification. Error: {e}",
                level=messages.WARNING
            )
        try:
            from django.core.mail import EmailMultiAlternatives
            from django.template.loader import render_to_string
            
            # Email subject
            email_subject = "🎉 Bid Win Notification - Autobid by Riverlong Limited"
            
            # Context for email template
            email_context = {
                'user_name': bid.user.first_name,
                'vehicle_reg': vehicle.registration_no,
                'amount': '{:,.0f}'.format(bid.amount),
                # 'site_settings': site_settings
            }
            
            # Render HTML email content
            html_content = render_to_string('vehicles/emails/bid_award.html', email_context)
            
            # Create plain text version for email clients that don't support HTML
            text_content = f"""Congratulations!

        Dear {bid.user.first_name},

        You have won the bid for:
        Vehicle: {vehicle.registration_no}
        Winning Bid: KSH {'{:,.0f}'.format(bid.amount)}

        The Buyer and Seller are responsible for completion of sale within 3hrs.

        Please find the attached offer letter with complete details.

        Best regards,
        Riverlong Auction Team"""
            
            primary_recipient = bid.user.email
            if financier and financier.notification_emails:
                additional_recipients = financier.get_notification_emails()  # Should return a list
            else:
                additional_recipients = ['autobid@riverlong.com']

            # Create email message
            email = EmailMultiAlternatives(
                subject=email_subject,
                body=text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[bid.user.email],
                cc=additional_recipients  # CC to additional recipients from Financier model
            )
            
            # Attach HTML content
            email.attach_alternative(html_content, "text/html")
            
            # Attach the generated PDF
            with open(pdf_file_path, 'rb') as pdf:
                email.attach(
                    f'Vehicle_Award_{vehicle.registration_no}.pdf',
                    pdf.read(),
                    'application/pdf'
                )

            email.send()

            # Clean up the temporary PDF file
            import os
            os.unlink(pdf_file_path)

        except Exception as e:
            self.message_user(
                request,
                f"Notification email failed to send. Error: {e}",
                level=messages.ERROR
            )
            return

        # Notify the admin about the success of the operation
        self.message_user(
            request,
            f"Bid awarded successfully for vehicle {vehicle.registration_no}. Offer letter has been sent to {bid.user.email}",
            level=messages.SUCCESS
        )

    award_bid.short_description = "Award selected bid"


    # CSV export function (modified to include user details)
    def generate_bid_report(self, request, queryset):
        # Create the HttpResponse object with the appropriate CSV header
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="bid_report.csv"'
        writer = csv.writer(response)
        
        # Write header row with columns
        writer.writerow(['Financier','Vehicle','Yard', 'Vehicle Details','Vehicle Reserveprice' ,'Offer Amount','User Email','User Phone', 'Bid Time','Time Since Bid Placement','Awarded','Awarded At','Awarded By','Time Since Award','disqualified','Referred By'])

        # Write rows with the relevant data
        for bid in queryset:
            writer.writerow([
                bid.vehicle.Financier,
                bid.vehicle.registration_no,  # Vehicle registration number
                bid.vehicle.yard.name,
                self.vehicle_details(bid),
                self.vehicle_reserveprice(bid),
                self.formatted_amount(bid),
                bid.user.email,  # User's email
                bid.user.profile.phone_number, #user's phone
                bid.bid_time , # Bid time
                self.time_since_bid(bid),
                bid.awarded ,# Awarded status
                bid.awarded_at,
                bid.awarded_by,
                self.time_since_award(bid),
                bid.disqualified,
                bid.referred_by
            ])
        
        return response

    generate_bid_report.short_description = "Generate bid report for selected vehicles"

from django.utils.html import format_html
from .models import BiddingFeePayment


@admin.register(BiddingFeePayment)
class BiddingFeePaymentAdmin(admin.ModelAdmin):

    # ── List view
    list_display = (
        'id',
        'user',
        'vehicle',
        'phone_number',
        'amount',
        'status_badge',
        'mpesa_receipt_number',
        'created_at',
        'updated_at',
    )
    list_filter = ('status', 'created_at', 'vehicle')
    search_fields = (
        'user__email',
        'user__username',
        'phone_number',
        'mpesa_receipt_number',
        'checkout_request_id',
        'merchant_request_id',
        'vehicle__registration_no',
    )
    ordering = ('-created_at',)
    date_hierarchy = 'created_at'
    list_per_page = 25

    # ── Detail view
    readonly_fields = (
        'user',
        'vehicle',
        'phone_number',
        'amount',
        'merchant_request_id',
        'checkout_request_id',
        'mpesa_receipt_number',
        'status',
        'created_at',
        'updated_at',
    )

    fieldsets = (
        ('Customer', {
            'fields': ('user', 'vehicle', 'phone_number', 'amount'),
        }),
        ('M-Pesa Transaction', {
            'fields': (
                'mpesa_receipt_number',
                'merchant_request_id',
                'checkout_request_id',
            ),
        }),
        ('Status & Timestamps', {
            'fields': ('status', 'created_at', 'updated_at'),
        }),
    )

    # ── Disable all write operations
    # def has_add_permission(self, request):
    #     return False
    #
    # def has_change_permission(self, request, obj=None):
    #     return False
    #
    # def has_delete_permission(self, request, obj=None):
    #     return False

    # ── Coloured status badge
    @admin.display(description='Status')
    def status_badge(self, obj):
        colours = {
            'completed':  '#28a745',
            'pending':    '#ffc107',
            'failed':     '#dc3545',
            'cancelled':  '#6c757d',
        }
        colour = colours.get(obj.status, '#6c757d')
        return format_html(
            '<span style="'
            'background:{};color:#fff;padding:3px 10px;'
            'border-radius:12px;font-size:0.8rem;font-weight:600;">'
            '{}</span>',
            colour,
            obj.get_status_display(),
        )

class VehicleImageInline(admin.TabularInline):
    model = VehicleImage
    extra = 1  # Number of empty forms to display

class BidInline(admin.TabularInline):
    model = Bidding
    readonly_fields = ('user', 'amount', 'bid_time',)  
    # extra = 1  
    can_delete = False

class VehicleViewInline(admin.TabularInline):
    model = VehicleView
    # extra = 1 
    readonly_fields=('vehicle','user','viewed_at')
    can_delete = False


@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    class PriceRangeFilter(admin.SimpleListFilter):
    # Human-readable title which will be displayed in the right sidebar
        title = 'Price Range (Reserve Price)'

        # Parameter for the filter that will be used in the URL query
        parameter_name = 'reserve_price_range'

        def lookups(self, request, model_admin):
            """
            Returns a list of tuples. Each tuple is (query_parameter, human_readable_name).
            """
            return (
                ('0_500k', '0 - 500k'),
                ('500k - 1M', '500k - 1M'),
                ('1M - 2M', '1M - 2M'),
                ('2M - 5M', '2M - 5M'),
                ('above - 5M', 'Above 5M'),
            )

        def queryset(self, request, queryset):
            """
            Returns the filtered queryset based on the value selected.
            """
            if self.value() == '0_500k':
                return queryset.filter(reserve_price__lte=500000)
            elif self.value() == '500k - 1M':
                return queryset.filter(reserve_price__gt=500001, reserve_price__lte=1000000)
            elif self.value() == '1M - 2M':
                return queryset.filter(reserve_price__gt=1000001, reserve_price__lte=2000000)
            elif self.value() == '2M - 5M':
                return queryset.filter(reserve_price__gt=2000001, reserve_price__lte=5000000)
            elif self.value() == 'above - 5M':
                # Assumes the reserve_price is not negative
                return queryset.filter(reserve_price__gt=5000001)
        
            return queryset
        
    # Custom formatted methods
    def formatted_reserve_price(self, obj):
        # Format the reserve price with thousands separator
        return '{:,.0f}'.format(obj.reserve_price)
    formatted_reserve_price.short_description = 'Reserve Price'

    def formatted_mileage(self, obj):
        # Format the mileage with thousands separator
        return '{:,.0f}'.format(obj.mileage) if obj.mileage is not None else 'N/A'
    formatted_mileage.short_description = 'Mileage'

    def formatted_views(self, obj):
        # Format the views with thousands separator
        return '{:,.0f}'.format(obj.views)
    formatted_views.short_description = 'Views'

    def view_on_site(self, obj):
        if obj.is_approved and obj.status == 'available' or obj.status == 'on_auction':
            return obj.get_frontend_url()
        return None  # disables "View on site" if conditions not met

    from django.contrib import admin

    class AwardedBidderFilter(admin.SimpleListFilter):
        title = 'Awarded Bidder'
        parameter_name = 'awarded_bidder'

        def lookups(self, request, model_admin):
            return (
                ('has_bidder', 'Has Awarded Bidder'),
                ('no_bidder', 'No Awarded Bidder'),
            )

        def queryset(self, request, queryset):
            if self.value() == 'has_bidder':
                return queryset.filter(bidding__awarded=True).distinct()
            if self.value() == 'no_bidder':
                return queryset.exclude(bidding__awarded=True)
            return queryset


    # Ensure you're using the correct method names in list_display
    list_display = (
        'registration_no', 'Financier', 'make', 'model', 'YOM', 'formatted_mileage', 'engine_cc', 
        'body_type', 'color', 'yard', 'fuel_type', 'is_approved', 'status', 'formatted_reserve_price', 
        'is_hotsale','is_flashsale', 'created_at', 'approved_at', 'updated_at','sold_at','sold_by','days_since_approval','days_since_creation', 'current_auction_end_date', 'formatted_views','get_winning_bidder'
    )

    # Other configurations
    search_fields = ('make__name', 'registration_no', 'model__name', 'YOM__year', 'status','yard__name','Financier__name')
    list_filter = ('Financier',PriceRangeFilter,'yard',AwardedBidderFilter,'status','is_hotsale', 'is_flashsale' ,'fuel_type', 'created_at', 'updated_at','approved_at','disapproved_at','disapproved_by', 'is_approved')
    inlines = [VehicleImageInline, BidInline, VehicleViewInline]
    readonly_fields = ('views','is_approved', 'approved_by', 'approved_at','disapproved_by', 'disapproved_at','sold_at','sold_by')
    actions = ['make_available', 'generate_vehicle_report', 'approve_vehicle','disapprove_vehicle','revise_price','stop_sale','add_to_flashsale','remove_from_flashsale']
    list_per_page = 15  # Items per page
    list_max_show_all = 1000  # Maximum items when showing all
    show_full_result_count = True  # Show total count in pagination

    def get_actions(self, request):
        actions = super().get_actions(request)

        # Check if user is in 'admin' group
        if not request.user.groups.filter(name__in=['Admins', 'DEV']).exists():
            # Remove restricted actions if not in the admin group
            restricted = ['make_available', 'sell', 'approve_vehicle', 'disapprove_vehicle']
            for action in restricted:
                if action in actions:
                    del actions[action]
        return actions

    def revise_price(self, request, queryset):
        import sys
        sys.path.append('C:\\inetpub\\wwwroot\\Auto-auction\\myenv\\Lib\\site-packages')
        import requests
        from django.conf import settings
        import logging

        logger = logging.getLogger(__name__)

        TIARA_API_URL = settings.TIARA_API_URL
        AUTH_TOKEN = settings.AUTH_TOKEN

        from .models import NotificationLog

        if request.method == "POST" and "apply" in request.POST:
            form = ReviseVehiclePriceForm(request.POST)

            if form.is_valid():
                new_price = form.cleaned_data['new_price']
                blocked_vehicles = []

                # 1. Pre-check: block awarded vehicles
                for vehicle in queryset:
                    not_revisable = Bidding.objects.filter(
                        vehicle=vehicle,
                        awarded=True,
                        disqualified=False,
                        paid=True
                    ).exists()

                    if not_revisable:
                        blocked_vehicles.append(vehicle.registration_no)

                if blocked_vehicles:
                    self.message_user(
                        request,
                        (
                                "Price revision aborted. "
                                "The vehicle already has an awarded bid, is disqualified or is already paid for. "
                                + ", ".join(blocked_vehicles)
                        ),
                        level=messages.ERROR
                    )
                    return None

                for vehicle in queryset:
                    old_price = vehicle.reserve_price

                    if old_price == new_price:
                        continue

                    VehiclePriceRevision.objects.create(
                        vehicle=vehicle,
                        old_price=old_price,
                        new_price=new_price,
                        revised_by=request.user,
                    )

                    vehicle.reserve_price = new_price
                    vehicle.is_flashsale = True
                    vehicle.save(update_fields=['reserve_price','is_flashsale'])

                    bidders = (
                        Bidding.objects
                        .filter(vehicle=vehicle)
                        .select_related('user', 'user__profile')
                    )

                    notified_users = set()

                    for bid in bidders:
                        user = bid.user
                        profile = getattr(user, "profile", None)

                        if not user or not profile or not profile.phone_number:
                            continue

                        if user.id in notified_users:
                            continue

                        notified_users.add(user.id)

                        first_name = user.first_name.strip() if user.first_name else "Customer"

                        message = (
                            f"Hello {first_name},\n"
                            f"\n"
                            f"AutoBid Price Revision:\n"
                            f"Reserve price for {vehicle.registration_no} "
                            f"has changed from Ksh {old_price:,} "
                            f"to Ksh {new_price:,}.\n"
                            f"View vehicle to place your bid: {vehicle.get_frontend_url()}"
                        )

                        success, response = send_sms(profile.phone_number, message)

                        #  LOG NOTIFICATION
                        NotificationLog.objects.create(
                            vehicle=vehicle,
                            user=user,
                            phone_number=profile.phone_number,
                            event_type=NotificationLog.PRICE_REVISION,
                            message=message,
                            sent=success,
                            provider_response=response,
                        )

                self.message_user(
                    request,
                    "Vehicle price revised and bidders notified successfully.",
                    messages.SUCCESS
                )
                return None

        else:
            form = ReviseVehiclePriceForm()

        return render(
            request,
            "admin/revise_vehicle_price.html",
            {
                "vehicles": queryset,
                "form": form,
                "action": "revise_price",
            }
        )

    revise_price.short_description = "Revise price & notify bidders"

    # Custom action for generating reports
    def generate_vehicle_report(self, request, queryset):
        from django.http import HttpResponse
        import csv
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="vehicle_report.csv"'

        writer = csv.writer(response)
        writer.writerow(['Registration No', 'Financier', 'Make', 'Model', 'Year of Manufacture', 'Mileage', 'Transmission', 'Engine CC', 'Body Type', 'Seats', 'Color', 'Fuel Type', 'Storage Yard', 'Reserve Price', 'Date Created','Date Approved','Date Updated','Status','Date Sold','Sold By','Days Since Approval', 'Days Since Creation','Awarded Bidder'])

        # Iterate over the selected vehicles in the admin panel
        for vehicle in queryset:
            # Determine the winning bidder
            if vehicle.status == 'sold':
                winning_bid = vehicle.bidding.filter(awarded=True).first()
                awarded_bidder = f"{winning_bid.user.first_name} {winning_bid.user.last_name}".strip() if winning_bid else "-"
            else:
                awarded_bidder = "Vehicle not sold"
            writer.writerow([
                vehicle.registration_no,
                vehicle.Financier,
                vehicle.make.name,
                vehicle.model.name,
                vehicle.YOM.year,
                vehicle.mileage,
                vehicle.transmission,
                vehicle.engine_cc,
                vehicle.body_type.name,
                vehicle.seats,
                vehicle.color,
                vehicle.fuel_type.name,
                vehicle.yard,
                vehicle.reserve_price,
                vehicle.created_at,
                vehicle.approved_at,
                vehicle.updated_at,
                vehicle.status,
                vehicle.sold_at,
                vehicle.sold_by,
                vehicle.days_since_approval(),
                vehicle.days_since_creation(),
                awarded_bidder
            ])
        
        return response

    generate_vehicle_report.short_description = "Generate CSV report for selected vehicles"

    def get_winning_bidder(self, obj):
        # Check if the vehicle is sold
        if obj.status == 'sold':
            # Get the winning bid for the vehicle
            winning_bid = obj.bidding.filter(awarded=True).first()
            if winning_bid:
                return f"{winning_bid.user.first_name} {winning_bid.user.last_name}".strip()
            return "No winning bidder"
        return "Vehicle not sold"

    get_winning_bidder.short_description = 'Awarded Bidder'  # Column header
    # Admin action for marking vehicles as available
    # def make_available(self, request, queryset):
    #     updated = queryset.update(status='available')
    #     self.message_user(request, f"{updated} vehicle(s) successfully marked as available.")
    # make_available.short_description = "Mark selected vehicles as available"

    def make_available(self, request, queryset):
      
        # Filter out vehicles that have an awarded bid
        invalid_vehicles_awarded_bid = queryset.filter(bidding__awarded=True)
        
        # Filter out vehicles that are in 'sold' status
        invalid_vehicles_sold = queryset.filter(status='sold')
        
        # Combine all invalid vehicles
        invalid_vehicles = invalid_vehicles_awarded_bid | invalid_vehicles_sold
        
        if invalid_vehicles.exists():
            # Notify the admin that some vehicles cannot be marked as available
            self.message_user(
                request,
                f"{invalid_vehicles.count()} selected vehicle(s) are either sold or have an awarded bid and cannot be marked as available.",
                level=messages.ERROR
            )
        
        # Filter the queryset to exclude invalid vehicles
        valid_vehicles = queryset.exclude(status='sold').exclude(status='sold').exclude(bidding__awarded=True)
        
        # Update the status of valid vehicles
        updated = valid_vehicles.update(status='available')
        
        # Notify the admin of successful updates
        if updated:
            self.message_user(
                request,
                f"{updated} vehicle(s) successfully marked as available.",
                level=messages.SUCCESS
            )

    make_available.short_description = "Mark selected vehicles as available"

    def stop_sale(self, request, queryset):
        if not request.user.groups.filter(name='Approvers').exists():
            self.message_user(request, "Only authorised persons can add vehicles to stop sale.", level=messages.WARNING)
            return

        if request.method == "POST" and "confirm" not in request.POST:
            return render(
                request,
                "admin/action_confirm.html",
                {
                    "title": "Confirm Vehicle stop sale",
                    "message": "Are you sure you want to stop the selected vehicle(s) from sale?",
                    "warning": "This action cannot be undone.",
                    "confirm_label": "Yes, add ",
                }
            )

        count = 0
        for vehicle in queryset.filter():
            vehicle.status = "stop_sale"
            vehicle.save()
            count += 1

        self.message_user(request, f"{count} vehicle(s) have been stopped from sale.", level=messages.SUCCESS)

    stop_sale.short_description = "Stop selected vehicle from sale."
    # Admin action for selling vehicles
    def sell(self, request, queryset):
        already_sold = queryset.filter(status='sold').count()
        not_bid_won = queryset.exclude(status__in=['bid_won', 'sold']).count()
        valid_for_sale = queryset.filter(status='bid_won')

        updated = 0
        if valid_for_sale.exists():
            updated = valid_for_sale.update(
                status='sold',
                sold_at=timezone.now(),
                sold_by=request.user
            )
            self.message_user(request, f"{updated} vehicle(s) successfully marked as sold.", level=messages.SUCCESS)

        if already_sold > 0:
            self.message_user(request, f"Sorry, This vehicle is already sold.", level=messages.WARNING)

        if not_bid_won > 0:
            self.message_user(request, f"{not_bid_won} vehicle(s) could not be sold because they are not in 'bid_won' status.", level=messages.WARNING)

    sell.short_description = "Mark selected vehicles as sold"
    # Get auction end date for the vehicle
    def current_auction_end_date(self, obj):
        return obj.current_auction_end_date()
    current_auction_end_date.short_description = 'Auction End Date'

    # Admin action for approving vehicles
    def approve_vehicle(self, request, queryset):
        if not request.user.groups.filter(name='Approvers').exists():
            self.message_user(request, "Only Admins can approve vehicles.", level=messages.WARNING)
            return

        count = 0
        for vehicle in queryset.filter(is_approved=False):
            vehicle.approve(request.user)
            count += 1

        self.message_user(request, f"{count} vehicle(s) have been approved.", level=messages.SUCCESS)
    approve_vehicle.short_description = "Approve selected vehicles"

    def disapprove_vehicle(self, request, queryset):
        if not request.user.groups.filter(name='Approvers').exists():
            self.message_user(request, "Only Admins can disapprove vehicles.", level=messages.WARNING)
            return

        count = 0
        for vehicle in queryset.filter(is_approved=True):
            vehicle.is_approved = False
            vehicle.disapproved_by = request.user
            vehicle.disapproved_at = timezone.now()
            # vehicle.status='idle'
            vehicle.save()
            count += 1

        self.message_user(request, f"{count} vehicle(s) have been disapproved.", level=messages.SUCCESS)

    disapprove_vehicle.short_description = "Disapprove selected vehicles"

    def add_to_flashsale(self, request, queryset):
        if not request.user.groups.filter(name='Approvers').exists():
            self.message_user(request, "Only Admins can add vehicles to flashsale.", level=messages.WARNING)
            return

        if request.method == "POST" and "confirm" not in request.POST:
            return render(
                request,
                "admin/action_confirm.html",
                {
                    "title": "Confirm Vehicle addition to flashsale",
                    "message": "Are you sure you want to add the selected vehicle(s) to flashsale?",
                    "warning": "This action cannot be undone.",
                    "confirm_label": "Yes, add ",
                }
            )

        count = 0
        for vehicle in queryset.filter(is_flashsale=False):
            vehicle.is_flashsale = True
            vehicle.save()
            count += 1

        self.message_user(request, f"{count} vehicle(s) have been added to Flashsale.", level=messages.SUCCESS)

    def remove_from_flashsale (self, request, queryset):
        if not request.user.groups.filter(name='Approvers').exists():
            self.message_user(request, "Only Admins can remove vehicles from flashsale.", level=messages.WARNING)
            return

        count = 0
        for vehicle in queryset.filter(is_flashsale=True):
            vehicle.is_flashsale = False
            vehicle.save()
            count += 1

        self.message_user(request, f"{count} vehicle(s) have been removed from Flashsale.", level=messages.SUCCESS)

    remove_from_flashsale.short_description = "Remove selected vehicles from flashsale."


# admin.site.register(VehicleAdmin)

admin.site.register(NotificationRecipient)
admin.site.register(Yard)
@admin.register(VehicleMake)
class VehicleMakeAdmin(admin.ModelAdmin):
    list_display = ( 'name',)
    search_fields = ('name',)

@admin.register(VehicleModel)
class VehicleModelAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)

@admin.register(ManufactureYear)
class ManufactureYearAdmin(admin.ModelAdmin):
    list_display = ('year',)
    search_fields = ('year',)

@admin.register(FuelType)
class FuelTypeAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)
    class Meta:
        verbose_name_plural = "Fuel Types"

@admin.register(VehicleBody)
class VehicleBodyAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)

# vehicles/admin.py
class EndedFilter(admin.SimpleListFilter):
    title = 'ended'
    parameter_name = 'ended'

    def lookups(self, request, model_admin):
        return (
            ('Yes', 'Ended'),
            ('No', 'Not Ended'),
        )

    def queryset(self, request, queryset):
        if self.value() == 'Yes':
            return queryset.filter(end_date__lt=timezone.now())
        if self.value() == 'No':
            return queryset.filter(end_date__gte=timezone.now())

class AuctionHistoryInline(admin.TabularInline):
    model = AuctionHistory
    extra = 0
    list_display = ('vehicle', 'start_date', 'end_date')
    readonly_fields = ('vehicle', 'start_date', 'end_date', 'on_bid', 'returned_to_available','sold')
    can_delete = False

@admin.register(Financier)
class FinancierAdmin(admin.ModelAdmin):
    search_fields = ('name',)


@admin.register(Auction)
class AuctionAdmin(admin.ModelAdmin):
    list_display = ('id','auction_id', 'start_date', 'end_date','created_at', 'approved','is_ended','completed','completed_at','completed_by')
    search_fields = ('vehicles__registration_no','auction_id')
    filter_horizontal = ('vehicles',)
    list_filter = ('approved',EndedFilter,'start_date', 'end_date','created_at',)
    inlines = [AuctionHistoryInline]
    readonly_fields = ('approved','processed','approved_by','approved_at','completed','has_extended','completed_at','completed_by')
    actions = ['update_vehicle_status','approve_auction','disapprove_auction']

    def get_form(self, request, obj=None, **kwargs):
        # Call the superclass method to get the form class
        form = super().get_form(request, obj, **kwargs)
        # Modify the form's vehicle queryset,fetch only available and approved vehicles
        form.base_fields['vehicles'].queryset = Vehicle.objects.filter(status='available',is_approved=True)
        return form
    
    def is_ended(self, obj):
        return obj.ended
    is_ended.boolean = True
    is_ended.short_description = 'Ended'

    def save_model(self, request, obj, form, change):
                super().save_model(request, obj, form, change)
                selected_vehicles = form.cleaned_data['vehicles']
                for vehicle in selected_vehicles:
                    vehicle.status = 'on_auction'  
                    vehicle.save()
                    AuctionHistory.objects.create(
                        vehicle=vehicle,
                        auction=obj,
                        start_date=obj.start_date,
                        end_date=obj.end_date,
                        on_bid=False
                    )

    # Custom admin action to approve auctions
    def approve_auction(modeladmin, request, queryset):
        # Check if the user is part of the 'Approvers' group
        if not request.user.groups.filter(name='Approvers').exists():
            modeladmin.message_user(request, "You do not have permission to approve auctions.", level='error')
            return
        
        # Check if the auction is already approved
        already_approved = queryset.filter(approved=True)
        if already_approved.exists():
            modeladmin.message_user(request, f"{already_approved.count()} auction(s) already approved.", level='error')
            return  # Do nothing if any of the selected auctions are already approved
        
        # Approve all selected auctions
        queryset.update(approved=True)
        modeladmin.message_user(request, f"{queryset.count()} auction(s) approved successfully.")

    approve_auction.short_description = "Approve selected auctions"

    # Custom admin action to disapprove auctions
    def disapprove_auction(modeladmin, request, queryset):
        # Check if the user is part of the 'Approvers' group
        if not request.user.groups.filter(name='Approvers').exists():
            modeladmin.message_user(request, "You do not have permission to disapprove auctions.", level='error')
            return
        
        # Disapprove all selected auctions
        queryset.update(approved=False)
        modeladmin.message_user(request, f"{queryset.count()} auction(s) disapproved successfully.")

    disapprove_auction.short_description = "Disapprove selected auctions"

    def update_vehicle_status(self, request, queryset):
        now = timezone.now()
        for auction in queryset:
            if auction.completed:
                self.message_user(
                    request,
                    f"Auction {auction.auction_id} has already been completed.",
                    level=messages.ERROR
                )
                continue  # Skip to the next auction
            if auction.end_date <= now and auction.approved:
                for vehicle in auction.vehicles.all():
                    # Get highest non-disqualified bid
                    highest_bid = vehicle.bidding.filter(disqualified=False,awarded=False,is_auction_bid=True).order_by('-amount').first()
                    
                    if highest_bid and highest_bid.amount >= vehicle.reserve_price:
                        # Notify winner
                        self.bid_award_notification(highest_bid,request)
                        self.send_winner_sms(highest_bid,request)
                        self.send_winner_email(highest_bid,request)
                        vehicle.status = 'bid_won'
                       

                        # Update bidding record
                        highest_bid.awarded = True
                        highest_bid.awarded_at = timezone.now()
                        highest_bid.awarded_by = request.user
                        highest_bid.save()

                            # Create an entry in the AwardHistory model
                        try:
                            AwardHistory.objects.create(
                                user=highest_bid.user,
                                vehicle=highest_bid.vehicle,
                                amount=highest_bid.amount,
                                awarded_at=highest_bid.bid_time,
                                awarded_by=request.user
                            )
                        except Exception as e:
                            self.message_user(
                                request,
                                f"Failed to update award history. Error: {e}",
                                level=messages.ERROR
                            )
                            return
                        try:
                            auction.completed = True
                            auction.completed_at = timezone.now()
                            auction.completed_by = request.user
                            auction.save()
                        except Exception as e:
                            self.message_user(
                                request,
                                f"Failed to update auction completion status. Error: {e}",
                                level=messages.ERROR
                            )
                            return
                            
                        
                        
                    else:
                        vehicle.status = 'available'
                        # Optionally revoke any previous awarded bids
                        awarded_bid = vehicle.bidding.filter(awarded=True).first()
                        if awarded_bid:
                            awarded_bid.awarded = False
                            awarded_bid.save()
                        
                    vehicle.save()

                
                self.message_user(request, f"Updated vehicle statuses for auction {auction.auction_id}", level=messages.SUCCESS)
            else:
                self.message_user(request, f"Auction {auction.auction_id} is not yet ended or not approved.", level=messages.ERROR)

    update_vehicle_status.short_description = "Complete Selected Auctions"

  
    def send_winner_email(self, winning_bid,request):
        vehicle = winning_bid.vehicle
        user = winning_bid.user

        try:
            from reportlab.lib import colors
            from reportlab.lib.pagesizes import letter
            from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
            from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
            from reportlab.lib.units import inch
            import tempfile
            from datetime import datetime
            from reportlab.platypus import Image

            with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as tmp_file:
                pdf_file_path = tmp_file.name

            doc = SimpleDocTemplate(pdf_file_path, pagesize=letter, rightMargin=72, leftMargin=72, bottomMargin=72)
            styles = getSampleStyleSheet()
            styles.add(ParagraphStyle(name='CustomTitle', parent=styles['Heading1'], alignment=1, spaceAfter=30))
            story = []

            image_path = 'vehicles/static/images/RL-Logo.png'
            story.append(Image(image_path, width=100, height=100))
            story.append(Paragraph("Vehicle Bid Award Letter", styles['CustomTitle']))
            story.append(Spacer(1, 10))
            story.append(Paragraph(f"Date: {datetime.now().strftime('%d %B %Y')}", styles['Normal']))
            story.append(Spacer(1, 20))
            story.append(Paragraph(f"<b><u>RE: SALE OF MOTOR VEHICLE REG NO. {vehicle.registration_no}.</u></b>", styles['Normal']))
            story.append(Spacer(1, 10))
            story.append(Paragraph(
                f"<b>{user.get_full_name()}</b> of ID <b>{user.profile.ID_number}</b> is hereby granted the opportunity to make payment of Kes.<b> {'{:,.0f}'.format(winning_bid.amount)}</b> "
                f"towards purchase of vehicle <b>{vehicle.registration_no}</b>. Kindly but urgently deposit the above forestated amount to the below bank account.",
                styles['Normal']
            ))
            story.append(Spacer(1, 20))

            financier_name = vehicle.Financier.name.strip().lower() if vehicle.Financier else ""

            if "tijaara" in financier_name:
                mpesa_data = [["Payment Method", "MPESA PAYBILL"], ["Paybill Number:", "880100"], ["Account Number:", "3190500038"]]
                bank_data = [["Bank Name:", "NCBA"], ["Account Name:", "TIJAARA FINANCE"], ["Account Number:", "3190500038"], ["Branch:", "KENYATTA AVENUE BRANCH"]]
            elif "zazipay" in financier_name:
                mpesa_data = [["Payment Method", "MPESA PAYBILL"], ["Paybill Number:", "707879"], ["Account Number:", vehicle.registration_no]]
                bank_data = [["Bank Name:", "NCBA"], ["Account Name:", "ZAZI PAY INTERNATIONAL LTD"], ["Account Number:", "9081590019"], ["Branch:", "KENYATTA AVENUE BRANCH"]]
            elif "mycredit" in financier_name:
                mpesa_data = [["Payment Method", "MPESA PAYBILL"], ["Paybill Number:", "795902"], ["Account Number:", vehicle.registration_no]]
                bank_data = [["Bank Name:", "NCBA Bank"], ["Account Name:", "MYCREDIT LIMITED"], ["Account Number:", "1004557111"], ["Branch:", "KENYATTA AVENUE BRANCH"]]
            elif "riverlong" in financier_name:
                mpesa_data = [["Payment Method", "MPESA PAYBILL"], ["Paybill Number:", ""], ["Account Number:", ]]
                bank_data = [["Bank Name:", "Equity Bank"], ["Account Name:", "RIVERLONG LIMITED"], ["Account Number:", "1340282343193"], ["Branch:", "RIDGEWAYS"]]
            else:
                mpesa_data = [["Payment Method", "Test"], ["Paybill Number:", "Test"], ["Account Number:", vehicle.registration_no]]
                bank_data = [["Bank Name:", "Test"], ["Account Name:", "Test"], ["Account Number:", "Test"], ["Branch:", "Test"]]

            for data in [mpesa_data, bank_data]:
                table = Table(data, colWidths=[2 * inch, 3 * inch])
                table.setStyle(TableStyle([
                    ('BACKGROUND', (0, 0), (0, -1), colors.lightgrey),
                    ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                    ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
                    ('FONTSIZE', (0, 0), (-1, -1), 10),
                    ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
                    ('BACKGROUND', (1, 0), (-1, -1), colors.white),
                    ('FONTNAME', (1, 0), (-1, -1), 'Helvetica'),
                    ('GRID', (0, 0), (-1, -1), 1, colors.black)
                ]))
                story.append(table)
                story.append(Spacer(1, 20))

            story.append(Paragraph("Terms and Conditions:", styles['Heading2']))
            terms = [
                "Payment must be made within 3 hours of receiving this letter.",
                "The vehicle will only be released after full payment confirmation.",
                "This offer is non-transferable."
            ]
            for term in terms:
                story.append(Paragraph(f"• {term}", styles['Normal']))
                story.append(Spacer(1, 10))

            story.append(Spacer(1, 30))
            story.append(Paragraph("For any queries, please contact us at autobid@riverlong.com", styles['Normal']))
            story.append(Paragraph("Riverlong Limited", styles['Normal']))
            doc.build(story)

        except Exception as e:
            self.message_user(request, f"Failed to generate PDF. Error: {e}", level=messages.ERROR)
            return

        # Prepare and send email with PDF
        try:
            context = {
                'username': user.username,
                'registration_no': vehicle.registration_no,
                'amount': "{:,.2f}".format(winning_bid.amount),
                'email': user.email
            }

            html_message = render_to_string('vehicles/emails/bidwin.html', context)
            plain_message = strip_tags(html_message)

            subject = f"🎉 You have Won the Bid for {vehicle.registration_no}!"
            to_email = [user.email]
            cc = vehicle.Financier.get_notification_emails() if vehicle.Financier and vehicle.Financier.notification_emails else ['mmburu@riverlong.com']

            email = EmailMultiAlternatives(
                subject=subject,
                body=plain_message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=to_email,
                cc=cc
            )
            email.attach_alternative(html_message, "text/html")

            with open(pdf_file_path, 'rb') as pdf:
                email.attach(f'Vehicle_Award_{vehicle.registration_no}.pdf', pdf.read(), 'application/pdf')

            email.send()
            os.unlink(pdf_file_path)

        except Exception as e:
            self.message_user(request, f"Failed to send email. Error: {e}", level=messages.ERROR)

    def send_winner_sms(self, winning_bid, request):
        """
        Generates a winner SMS and sends it via the Tiara API.
        """
        import requests

        user = winning_bid.user
        vehicle = winning_bid.vehicle

        try:
            financier_name = vehicle.Financier.name.strip().lower() if vehicle.Financier and vehicle.Financier.name else ""

            # Default payment info
            mpesa_paybill = "000000"
            mpesa_acc_no = vehicle.registration_no
            bank_name = "Default Bank"
            bank_acc_name = "Riverlong Ltd"
            bank_acc_no = "0000000000"
            bank_branch = "Main Branch"

            # Financier-specific payment info
            if "tijaara" in financier_name:
                mpesa_paybill = "880100"
                mpesa_acc_no = "3190500038"
                bank_name = "NCBA"
                bank_acc_name = "TIJAARA FINANCE"
                bank_acc_no = "3190500038"
                bank_branch = "KENYATTA AVENUE BRANCH"

            elif "zazipay" in financier_name:
                mpesa_paybill = "707879"
                mpesa_acc_no = vehicle.registration_no
                bank_name = "NCBA"
                bank_acc_name = "ZAZI PAY INTERNATIONAL LTD"
                bank_acc_no = "9081590019"
                bank_branch = "KENYATTA AVENUE BRANCH"

            elif "mycredit" in financier_name:
                mpesa_paybill = "795902"
                mpesa_acc_no = vehicle.registration_no
                bank_name = "NCBA Bank"
                bank_acc_name = "MYCREDIT LIMITED"
                bank_acc_no = "1004557111"
                bank_branch = "KENYATTA AVENUE BRANCH"
            
            elif "riverlong" in financier_name:
                mpesa_paybill = ""
                mpesa_acc_no = vehicle.registration_no
                bank_name = "EQUITY Bank"
                bank_acc_name = "RIVERLONG LTD"
                bank_acc_no = "1340282343193"
                bank_branch = "RIDGEWAYS"

            # Construct the message
            message = (
                f"Congratulations {user.get_full_name()}! You have won {vehicle.registration_no} for Ksh {'{:,.0f}'.format(winning_bid.amount)}.\n\n"
                f"MPESA PAYMENT:\n"
                f"Paybill: {mpesa_paybill}\n"
                f"Acc No: {mpesa_acc_no}\n\n"
                f"BANK PAYMENT:\n"
                f"Bank: {bank_name}\n"
                f"Acc Name: {bank_acc_name}\n"
                f"Acc No: {bank_acc_no}\n"
                f"Branch: {bank_branch}\n"
            )

            # Send SMS using Tiara API
            SMS_DATA = {
                "from": "Riverlong",
                "to": user.profile.phone_number,
                "message": message,
            }

            TIARA_API_URL =settings.TIARA_API_URL
            AUTH_TOKEN = settings.AUTH_TOKEN
            HEADERS = {
                "Authorization": AUTH_TOKEN,
                "Content-Type": "application/json",
            }

            response = requests.post(TIARA_API_URL, json=SMS_DATA, headers=HEADERS)

            if response.status_code == 200:
                print(f"SMS sent to {user.profile.phone_number}")
            else:
                self.message_user(
                    request,
                    f"SMS sending failed. Status: {response.status_code}, Response: {response.text}",
                    level=messages.WARNING
                )

        except Exception as e:
            self.message_user(
                request,
                f"Failed to send SMS notification. Error: {e}",
                level=messages.WARNING
            )


    def bid_award_notification(self, winning_bid,request):
        import requests
        vehicle = winning_bid.vehicle
        user = winning_bid.user
        try:
            from django.core.mail import EmailMultiAlternatives
            from django.template.loader import render_to_string
            from django.conf import settings

            # Email subject
            admin_email_subject = "🚨  Bid Award Notification - Autobid by Riverlong Limited"
            
            # Context for email template
            admin_email_context = {
                'bidder_name': user.get_full_name(),
                'vehicle_financier':vehicle.Financier.name,
                'bidder_email':user.email,
                'vehicle_reg': vehicle.registration_no,
                'amount': '{:,.0f}'.format(winning_bid.amount),
            }
            
            # Render HTML email content
            admin_html_content = render_to_string('vehicles/emails/bidaward_admins.html', admin_email_context)

            # Create plain text version for email clients that don't support HTML
            admin_text_content = f""" Bid Award Notification!

                Bid Details:
                Bidder: {user.first_name}
                Vehicle: {vehicle.registration_no}
                Winning Bid: KSH {'{:,.0f}'.format(winning_bid.amount)} 

                Please review and process the awarded bid."""

            # Get the associated financier from the vehicle
            financier = vehicle.Financier  # Assuming vehicle has a 'financier' relationship

            # Get the notification emails from the Financier model
            if financier and financier.notification_emails:
                recipient_list = financier.get_notification_emails()
            else:
                # Fallback email recipients if no financier or no emails are found
                recipient_list = ['autobid.riverlong.com']

            # Create email message
            admin_email = EmailMultiAlternatives(
                subject=admin_email_subject,
                body=admin_text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=recipient_list  # Send to emails from Financier model
            )

            # Attach HTML content
            admin_email.attach_alternative(admin_html_content, "text/html")

            # Send the email notification
            admin_email.send()

        except Exception as e:
            self.message_user(
                request,
                f"Failed to send email notification. Error: {e}",
                level=messages.ERROR
            )

    def changelist_view(self, request, extra_context=None):
        # Check if there is an active auction
        now = timezone.now()
        has_active_auction = Auction.objects.filter(end_date__gt=now, approved=True).exists()
        extra_context = extra_context or {}
        extra_context['has_active_auction'] = has_active_auction

        return super().changelist_view(request, extra_context=extra_context)

class VehicleInline(admin.TabularInline):
    model = AuctionHistory
    extra = 0
    readonly_fields = ['vehicle', 'start_date', 'end_date', 'on_bid', 'returned_to_available']
    # fields = ['vehicle', 'start_date', 'end_date', 'on_bid', 'returned_to_available']


@admin.register(AuctionHistory)
class AuctionHistoryAdmin(admin.ModelAdmin):
    list_display = [
        'vehicle', 'auction', 'start_date', 'end_date', 'reserve_price', 'total_bids',
        'top_bid_amount', 'highest_bidder_email'
         
    ]
    list_filter = (
        'vehicle', 'start_date', 'end_date',
         'on_bid', 'returned_to_available','sold'
    )
    search_fields = ('vehicle__registration_no', 'auction__auction_id')
    readonly_fields = ('vehicle', 'auction', 'start_date', 'end_date', 'on_bid', 'returned_to_available')
    # inlines = [BidInline]
    actions =['history_report','vehicle_details']

    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        queryset = queryset.select_related('vehicle', 'auction').prefetch_related('vehicle__bidding')
        return queryset

    def vehicle_details(self, obj):
        highest_bid = obj.vehicle.bidding.order_by('-amount').first()
        return highest_bid.amount if highest_bid else 'No Bids'
    
    vehicle_details.short_description = 'Highest Bid'

    def vehicle_registration_no(self, obj):
        return obj.vehicle.registration_no
    vehicle_registration_no.short_description = 'Vehicle Registration No'
    
    def auction_id(self, obj):
        return obj.auction.auction_id[:8]
    auction_id.short_description = 'Auction ID'


    def highest_bidder_email(self, obj):
        return obj.highest_bidder_email()

    def total_bids(self, obj):
        return obj.total_bids()

    def top_bid_amount(self, obj):
        return obj.top_bid_amount()

    def reserve_price(self, obj):
        return obj.reserve_price()

   # Action to export selected AuctionHistory records as CSV
    def history_report(self, request, queryset):
        # Define the HTTP response to download the CSV
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename=auction_history_report.csv'

        # Create a CSV writer
        writer = csv.writer(response)

        # Write the header row
        writer.writerow([
            'Vehicle', 'Auction ID', 'Start Date', 'End Date', 'Reserve Price', 
            'Total Bids', 'Top Bid Amount', 'Highest Bidder Email', 'On Bid', 'Returned to Available','sold'
        ])

        # Write data rows
        for auction_history in queryset:
            writer.writerow([
                auction_history.vehicle.registration_no,
                auction_history.auction.auction_id,
                auction_history.start_date,
                auction_history.end_date,
                auction_history.reserve_price(),
                auction_history.total_bids(),
                auction_history.top_bid_amount(),
                auction_history.highest_bidder_email(),
                auction_history.on_bid,
                auction_history.returned_to_available
            ])

        return response

    # Set a custom label for the action in the admin interface
    history_report.short_description = "Generate CSV for the selected vehicles in auctions"

    top_bid_amount.short_description = 'Top Bid'
    reserve_price.short_description = 'Reserve Price'
    highest_bidder_email.short_description = 'Highest Bidder Email'
    total_bids.short_description = 'Total Bids'



@admin.register(AdminActionLog)
class AdminActionLogAdmin(admin.ModelAdmin):
    list_display = ('timestamp', 'user', 'action_type', 'ip_address', 'content_type', 'object_repr')
    list_filter = ('action_type', 'timestamp', 'content_type')
    search_fields = ('user__username', 'ip_address', 'object_repr', 'change_message')
    date_hierarchy = 'timestamp'
    readonly_fields = ('user', 'timestamp', 'action_type', 'ip_address', 'content_type', 
                       'object_id', 'object_repr', 'change_message', 'user_agent')
    
    def has_add_permission(self, request):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False


@admin.register(VehiclePriceRevision)
class VehiclePriceRevisionAdmin(admin.ModelAdmin):
    list_display = (
        'vehicle',
        'price_change',
        'revised_by',
        'revised_at',
    )
    list_filter = ('revised_at',)
    search_fields = ('vehicle__registration_no',)
    readonly_fields = (
        'vehicle',
        'old_price',
        'new_price',
        'revised_by',
        'revised_at',
    )

    def price_change(self, obj):
        return f"Ksh {obj.old_price:,} → Ksh {obj.new_price:,}"

    price_change.short_description = "Price (From → To)"


@admin.register(NotificationLog)
class NotificationLogAdmin(admin.ModelAdmin):
    list_display = (
        "event_type",
        "vehicle",
        "user",
        "phone_number",
        "sent",
        "created_at",
    )
    list_filter = ("event_type", "sent", "created_at")
    search_fields = ("phone_number", "user__username", "vehicle__registration_no")
    readonly_fields = [f.name for f in NotificationLog._meta.fields]


admin.site.site_header = "Autobid Admin"
admin.site.site_title = "Riverlong Autobid"
admin.site.index_title = "Welcome to Autobid Admin"