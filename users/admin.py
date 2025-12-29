import csv
from os import path
from django.contrib import admin
from django.contrib import messages
from django.contrib.auth import get_user_model
from django.http import HttpResponse
from django.shortcuts import redirect, render
from .models import Profile, Location
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.core.mail import send_mail
from django import forms
from django.contrib import messages
from django.utils.html import format_html
from django.contrib.auth import get_user_model
from django.conf import settings  # Import Django settings
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.contrib.auth.models import Group


import sys
sys.path.append('C:\\inetpub\\wwwroot\\Auto-auction\\myenv\\Lib\\site-packages')
import requests
User = get_user_model()

# Register Location model
admin.site.register(Location)

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    search_fields = ('phone_number', 'ID_number','user__email','full_name')
    list_display = ('user','full_name','phone_number','ID_number')
    list_filter = ('location',)
    actions = ['generate_profile_report']  # Attach the CSV export function to actions
    list_per_page = 50  # Items per page
    list_max_show_all = 1000  # Maximum items when showing all
    show_full_result_count = True  # Show total count in pagination

    def generate_profile_report(self, request, queryset):
        # Create the HttpResponse object with CSV content type
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="profile_report.csv"'
        writer = csv.writer(response)

        # Write header row with column names
        writer.writerow([ 'Full Name', 'Email', 'ID Number', 'Phone Number', 'Location'])

        # Write rows with relevant data
        for profile in queryset:
            writer.writerow([
               
                f"{profile.user.first_name} {profile.user.last_name}",
                profile.user.email,
                profile.ID_number,
                profile.phone_number,
                profile.location if profile.location else "N/A"
            ])

        return response

    # Short description for Django Admin
    generate_profile_report.short_description = "Generate profile report for selected users"


def send_sms(phone_number, message):
    """Function to send SMS via the configured API."""
    try:
        # Use settings from environment variables
        api_url = settings.TIARA_API_URL
        auth_token = settings.AUTH_TOKEN

        if not api_url or not auth_token:
            print("SMS settings not configured.")
            return False

        headers = {
            "Authorization": f"{auth_token}",
            "Content-Type": "application/json"
        }

        payload = {
            "to": phone_number,
            "message": message,
            "from": "Riverlong"  # Replace with your sender ID or use a default
        }

        response = requests.post(api_url, json=payload, headers=headers)
        return response.status_code == 200
    except Exception as e:
        print(f"Error sending SMS: {e}")
        return False

@admin.action(description="Send SMS to selected users")
def send_sms_to_users(modeladmin, request, queryset):
    """Admin action to send SMS to selected users."""
    sms_message = "Ready to drive away with something special? 🚙 Join us this Friday, February 21st 10.30am, at Riverlong Storage Yard for a thrilling car auction! We’ve got a variety of vehicles waiting for a new owner. Be sure to bid early and bid often at https://autobid.riverlong.com"
    
    successful_count = 0
    failed_count = 0

    for user in queryset:
        profile = getattr(user, 'profile', None)  # Safely retrieve the profile
        if profile and profile.phone_number:
            success = send_sms(profile.phone_number, sms_message)
            if success:
                successful_count += 1
            else:
                failed_count += 1

    messages.success(request, f"✅ SMS sent to {successful_count} users. ❌ Failed for {failed_count} users.")

@admin.action(description="Send Email to selected users")
def send_email_to_users(modeladmin, request, queryset):
    """
    Admin action to send Email to selected users.
    - Throws an error if no users are selected.
    - Shows a success message if emails are sent successfully.
    """
    if not queryset.exists():
        messages.error(request, "❌ No users selected. Please select at least one user.")
        return

    email_subject = "🚗 Join Us This Friday - Exciting Car Auction!"
    
    # Context for the email template
    context = {
        'auction_date': 'February 21st',
        'auction_time': '10:30am',
        'auction_location': 'Riverlong Storage Yard',
        'auction_url': 'https://autobid.riverlong.com/available_vehicles'
    }
    
    # Render HTML email content
    html_message = render_to_string('users/admin/auction_notification.html', context)
    # Create plain text version
    plain_message = strip_tags(html_message)
    
    successful_count = 0
    failed_count = 0

    for user in queryset:
        if user.email:
            try:
                send_mail(
                    subject=email_subject,
                    message=plain_message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[user.email],
                    html_message=html_message,
                    fail_silently=False,
                )
                successful_count += 1
            except Exception as e:
                print(f"Error sending email to {user.email}: {e}")
                failed_count += 1

    if successful_count > 0:
        messages.success(request, f"✅ Auction notification sent to {successful_count} users.")
    if failed_count > 0:
        messages.warning(request, f"❌ Failed to send notification to {failed_count} users.")


class UserAdmin(admin.ModelAdmin):
    list_display = (
        'username',
        'email',
        'date_joined',
        'is_active',
        'profile_id_number',
        'profile_phone_number',
        'profile_location',
    )
    actions = [send_sms_to_users, send_email_to_users, 'generate_user_report']
    search_fields = ('username', 'email')
    list_filter = ('date_joined', 'is_active', 'is_staff',)
    list_per_page = 200  # Items per page

    def profile_id_number(self, obj):
        return obj.profile.ID_number if hasattr(obj, "profile") else None
    profile_id_number.short_description = "ID Number"

    def profile_phone_number(self, obj):
        return obj.profile.phone_number if hasattr(obj, "profile") else None
    profile_phone_number.short_description = "Phone"

    def profile_location(self, obj):
        return obj.profile.location if hasattr(obj, "profile") else None
    profile_location.short_description = "Location"

    def generate_user_report(self, request, queryset):
        # Create the HttpResponse object with CSV content type
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="Users_report.csv"'
        writer = csv.writer(response)

        # Write header row with column names
        writer.writerow(['Email', 'Phone Number','ID Number','Location','Date Joined', 'Is Active'])

        # Write rows with relevant data
        for user in queryset:
            writer.writerow([
               
               
                user.email,
                self.profile_phone_number(user),
                self.profile_id_number(user),
                self.profile_location(user),
                user.date_joined,
                user.is_active,
               
                
            ])

        return response

    # Short description for Django Admin
    generate_user_report.short_description = "Generate report for selected users"
    

# Unregister default User admin and register the customized one
admin.site.unregister(User)
admin.site.register(User, UserAdmin)