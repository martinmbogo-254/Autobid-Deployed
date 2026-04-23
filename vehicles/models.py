from django.db import models
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.validators import RegexValidator
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.contrib.auth.models import User
import uuid
from django.urls import reverse
from django.utils import timezone
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings
from ckeditor.fields import RichTextField
from django.utils.html import format_html
from django.http import HttpResponseForbidden
from django.contrib.auth.models import Group
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.models import User
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey


class VehicleMake(models.Model):
    name = models.CharField(max_length=255)

    class Meta:
        verbose_name_plural = "Makes"
        ordering = ['name']
    def __str__(self):
            return self.name

class VehicleModel(models.Model):
    name = models.CharField(max_length=255)
    class Meta:
        verbose_name_plural = "Models"
        ordering = ['name']
    def __str__(self):
            return self.name

class ManufactureYear(models.Model):
    year = models.IntegerField()

    class Meta:
        verbose_name_plural = "Years of Manufacture"
        ordering = ['year']  # Ensures ascending order by default
    def __str__(self):
            return str(self.year) 

class FuelType(models.Model):
    name = models.CharField(max_length=255)
    class Meta:
        verbose_name_plural = "Fuel Types"
        ordering = ['name']
    def __str__(self):
            return self.name

class VehicleBody(models.Model):
    name = models.CharField(max_length=255)
    class Meta:
        verbose_name_plural = " Vehicle Bodies"
        ordering = ['name']
    def __str__(self):
            return self.name
class Yard(models.Model):
    name = models.CharField(max_length=255)
    link = models.CharField(max_length=255)
    contact = models.PositiveIntegerField(max_length=14,blank=True)

    def __str__(self):
            return self.name
    
class Financier(models.Model):
    name = models.CharField(max_length=255)
    notification_emails = models.TextField(blank=True, help_text="Comma-separated list of emails to receive notifications")

    def __str__(self):
        return self.name

    def get_notification_emails(self):
        """Returns a list of emails from the notification_emails field."""
        if self.notification_emails:
            return [email.strip() for email in self.notification_emails.split(',')]
#         return []
# class Financier(models.Model):
#     name = models.CharField(max_length=255)
#     def __str__(self):
#             return self.name
class Vehicle(models.Model):
    BID_STATUS_CHOICES = [
        ('idle', 'idle'),
        ('available', 'available'),
        ('on_auction', 'on_auction'),
        ('on_bid', 'on_bid'),
        ('bid_won','bid_won'),
        ('sold', 'sold'),
        ('stop_sale', 'stop_sale'),
    ]
    TRANSMISSION_CHOICES=[
        ('Automatic','Automatic'),
        ('Manual','Manual'),
    ]
    v_id = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    Financier = models.ForeignKey(Financier, null=True, blank=True, on_delete=models.SET_DEFAULT,default='MyCredit Ltd')
    registration_no = models.CharField(max_length=255,unique=True)
    make = models.ForeignKey(VehicleMake, on_delete=models.SET_DEFAULT,default='Vehicle')
    model = models.ForeignKey(VehicleModel, on_delete=models.SET_DEFAULT, default='SUV')
    YOM = models.ForeignKey(ManufactureYear, on_delete=models.SET_DEFAULT, default='2010')
    mileage = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    engine_cc = models.IntegerField()
    transmission = models.CharField(max_length=255, choices=TRANSMISSION_CHOICES,blank=True)
    body_type = models.ForeignKey(VehicleBody, on_delete=models.SET_DEFAULT,default='Vehicle')
    fuel_type = models.ForeignKey(FuelType, on_delete=models.SET_DEFAULT,default='petrol')
    color = models.CharField(max_length=10,default ='white')
    seats = models.IntegerField(default=5)
    yard = models.ForeignKey(Yard, on_delete=models.SET_DEFAULT,default='Riverlong', blank=True, null=True)
    status = models.CharField(max_length=10, choices=BID_STATUS_CHOICES, default='idle')
    reserve_price = models.IntegerField()
    description = RichTextField(blank=True)
    file = models.FileField(upload_to='images/',default='images/default-vehicle.png',blank=False)
    views = models.IntegerField(default=0)
    financed = models.BooleanField(default=False)
    financing_percentage = models.IntegerField(null=True, blank=True)
    is_hotsale = models.BooleanField(default=False)
    is_flashsale = models.BooleanField(default=False)
    flashsale_price = models.IntegerField(null=True, blank=True)
    is_approved = models.BooleanField(default=False)
    approved_by = models.ForeignKey(User, related_name="approved_vehicles", null=True, blank=True, on_delete=models.SET_NULL)
    approved_at = models.DateTimeField(null=True, blank=True)
    # is_disapproved = models.BooleanField(default=False)
    disapproved_by = models.ForeignKey(User, related_name="disapproved_vehicles", null=True, blank=True, on_delete=models.SET_NULL)
    disapproved_at = models.DateTimeField(null=True, blank=True)
    sold_at = models.DateTimeField(null=True, blank=True)
    sold_by = models.ForeignKey(User, related_name="Marked_as_sold_by", null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        indexes = [
            # Main listing page
            models.Index(fields=['is_approved', 'status', '-created_at'], name='idx_v_approved_status'),

            # Common filters
            models.Index(fields=['make'], name='idx_v_make'),
            models.Index(fields=['status'], name='idx_v_status'),
            models.Index(fields=['is_hotsale', '-created_at'], name='idx_v_hotsale'),
            models.Index(fields=['is_flashsale', '-created_at'], name='idx_v_flashsale'),

            # Sorting
            models.Index(fields=['-created_at'], name='idx_v_created_desc'),
            models.Index(fields=['-views'], name='idx_v_views_desc'),

            # Image field/file
            models.Index(fields=['file'], name='idx_v_file'),

        ]
    

    def financed_amount(self):
        if self.financed and self.financing_percentage:
            amount = self.reserve_price * (self.financing_percentage / 100)
            return f"Ksh {int(amount):,}"
        return "Ksh 0"
    

    def approve(self, user):
        """Approve the vehicle and set approved fields."""
        self.is_approved = True
        # self.is_disapproved = False
        self.approved_by = user
        self.approved_at = timezone.now()
        self.status = 'available'  # Automatically set to available if approved
        self.save()

    def disapprove(self, user):
        """Disapprove the vehicle and set approved fields."""
        # self.disapproved = True
        self.is_approved = False
        self.disapproved_by = user
        self.disapproved_at = timezone.now()
        self.status = 'idle'  # Automatically set to available if approved
        self.save()
    
    def get_frontend_url(self):
        return f"https://autobid.riverlong.com/vehicle/{self.pk}/"

    def get_absolute_url(self):
        return reverse('detail', kwargs={'registration_no': self.registration_no})
    def __str__(self):
            return self.registration_no

    def is_available(self):
        return self.status == 'available'
    def is_sold(self):
            return self.status == 'sold'

    def days_since_creation(self):
        now = timezone.now()
        delta = now - self.created_at
        return delta.days
    
    def days_since_approval(self):
        if self.approved_at is None:
             return None
        now = timezone.now()
        delta = now - self.approved_at
        return delta.days

    def is_in_active_auction(self):
        """Check if this vehicle is currently in an active auction"""
        now = timezone.now()
        return self.auctions.filter(
            start_date__lte=now,
            end_date__gte=now
        ).exists()

    def current_auction_end_date(self):
        current_auction = self.auctions.filter(end_date__gte=timezone.now()).order_by('end_date').first()
        if current_auction:
            return current_auction.end_date
        return None
    
    

class VehicleImage(models.Model):
    vehicle= models.ForeignKey(Vehicle, on_delete=models.SET_DEFAULT,default='images/default-vehicle.png')
    image = models.FileField(upload_to='vehicleimages/',default='images/default-vehicle.png')
    class Meta:
        verbose_name_plural = "Images"


class Bidding(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name='bidding')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    auction = models.ForeignKey(
        'Auction',
        on_delete=models.CASCADE,
        related_name='bids',
        null=True,
        blank=True,
        help_text="The specific auction this bid belongs to"
    )
    amount = models.IntegerField()
    referred_by = models.TextField(null=True, blank=True)
    is_auction_bid = models.BooleanField(default=False)
    disqualified = models.BooleanField(default=False)
    disqualification_comment = models.TextField(blank=True, null=True)
    awarded = models.BooleanField(default=False)  # To track awarded status
    awarded_at = models.DateTimeField(blank=True, null=True)
    awarded_by = models.ForeignKey(User, on_delete=models.SET_NULL, blank=True, null=True, related_name='awarded_by')
    bid_time = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)
    paid_at = models.DateTimeField(null=True, blank=True)
    marked_paid_by = models.ForeignKey(
        User,
        null=True,
        blank=True,
        related_name='processed_payments',
        on_delete=models.SET_NULL
    )


    class Meta:
        permissions = [
            ("can_mark_bid_paid", "Can mark awarded bids as paid"),
        ]

    def __str__(self):
        return f" Bid for {self.vehicle.registration_no} by {self.user.username} at Ksh {self.amount}"

    def get_frontend_url(self):
        return f"https://autobid.riverlong.com/vehicle/{self.vehicle.pk}/"

    def save(self, *args, **kwargs):
        # Check if this is a new bid (no ID yet)
        if not self.pk:
            # Get the related auction for the vehicle
            active_auction = self.vehicle.auctions.filter(
                start_date__lte=timezone.now(),
                end_date__gte=timezone.now()
            ).first()

            # If there's an active auction, mark as auction bid
            if active_auction:
                self.is_auction_bid = True

                # Handle auction extension logic
                if not active_auction.has_extended:
                    time_left = active_auction.end_date - timezone.now()
                    if time_left <= timedelta(minutes=5):
                        # Add 5 minutes to the auction end time
                        active_auction.end_date = active_auction.end_date + timedelta(minutes=5)
                        active_auction.has_extended = True
                        active_auction.save()

            # If no active auction and is_auction_bid not already True, set to False
            # This ensures we don't override any existing True value
            elif not self.is_auction_bid:
                self.is_auction_bid = False

        super(Bidding, self).save(*args, **kwargs)  # Call the original save method

    def time_since_award(self):
        if not self.awarded_at:
            return "-"  # or "Not awarded"

        delta = timezone.now() - self.awarded_at
        seconds = int(delta.total_seconds())

        if seconds < 60:
            return f"{seconds}s ago"

        minutes = seconds // 60
        if minutes < 60:
            return f"{minutes}m ago"

        hours = minutes // 60
        if hours < 24:
            return f"{hours}h ago"

        days = hours // 24
        return f"{days}d ago"

    def time_since_bid(self):
        delta = timezone.now() - self.bid_time
        seconds = int(delta.total_seconds())

        if seconds < 60:
            return f"{seconds}s ago"

        minutes = seconds // 60
        if minutes < 60:
            return f"{minutes}m ago"

        hours = minutes // 60
        if hours < 24:
            return f"{hours}h ago"

        days = hours // 24
        return f"{days}d ago"


class BiddingFeePayment(models.Model):
    """Tracks M-Pesa bidding fee payments per user per vehicle."""

    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("completed", "Completed"),
        ("failed", "Failed"),
        ("cancelled", "Cancelled"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="bidding_fees")
    vehicle = models.ForeignKey("Vehicle", on_delete=models.CASCADE, related_name="bidding_fees")

    # M-Pesa transaction details
    phone_number = models.CharField(max_length=15)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    merchant_request_id = models.CharField(max_length=100, blank=True)
    checkout_request_id = models.CharField(max_length=100, blank=True, db_index=True)
    mpesa_receipt_number = models.CharField(max_length=50, blank=True)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        # One active/completed fee per user per vehicle
        unique_together = []  # We'll enforce this in logic, not DB (allows retries)
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user} → {self.vehicle} [{self.status}]"

    @classmethod
    def has_paid(cls, user, vehicle):
        """Check if user has a completed bidding fee for this vehicle."""
        return cls.objects.filter(
            user=user,
            vehicle=vehicle,
            status="completed"
        ).exists()


class AwardHistory(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.IntegerField()
    awarded_at = models.DateTimeField(auto_now_add=True)
    awarded_by = models.ForeignKey(User, on_delete=models.SET_NULL, blank=True, null=True, related_name='awarder')


    def __str__(self):
        return f"Awarded {self.vehicle.registration_no} to {self.user.username} at Ksh {self.amount}"

class Auction(models.Model):
    auction_id = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    # current_time = models.DateTimeField(default=timezone.now())
    created_at = models.DateTimeField(auto_now_add=True)
    vehicles = models.ManyToManyField('Vehicle', related_name='auctions')
    approved = models.BooleanField(default=False)
    approved_by = models.ForeignKey(User, related_name="approved_auctions", null=True, blank=True, on_delete=models.SET_NULL)
    approved_at = models.DateTimeField(null=True, blank=True)
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    completed_by = models.ForeignKey(User, related_name="completed_auctions", null=True, blank=True, on_delete=models.SET_NULL)
    processed = models.BooleanField(default=False)
    has_extended = models.BooleanField(default=False)  # Flag to track if the end time was extended
    
    

    def __str__(self):
        return f"Auction {self.auction_id}"

    def get_auction_status(self):
            active_auctions = self.auctions.filter(end_date < timezone.now(), approved=True)
            if active_auctions.exists():
                return 'Active'
            return 'Ended'

        # Custom admin action to approve auctions
    

    def check_and_update_status(self):
        if self.end_date < timezone.now():
            for vehicle in self.vehicles.all():
                highest_bid = vehicle.bidding.order_by('-amount').first()
                if highest_bid and highest_bid.amount >= vehicle.reserve_price:
                    vehicle.status = 'bid_won'
                    AuctionHistory.objects.filter(vehicle=vehicle, auction=self).update(sold=True)
                else:
                    vehicle.status = 'available'
                vehicle.save()
    @property
    def ended(self):
        return self.end_date < timezone.now()

    def process_if_ended(self):
        """Check and process the auction if it has ended"""
        now = timezone.now()
        if self.end_date <= now and self.approved and not self.processed:
            from .signals import process_ended_auction
            process_ended_auction(self)
            return True
        return False

    @classmethod
    def process_ended_auctions(cls):
        """Process all ended auctions"""
        now = timezone.now()
        ended_auctions = cls.objects.filter(
            end_date__lte=now,
            approved=True,
            processed=False
        )
        processed_count = 0
        for auction in ended_auctions:
            if auction.process_if_ended():
                processed_count += 1
        return processed_count
class VehicleView(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('vehicle', 'user')

    def __str__(self):
            return self.vehicle.make.name


class AuctionHistory(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.RESTRICT, related_name='auction_history')
    auction = models.ForeignKey(Auction, on_delete=models.RESTRICT, related_name='auction_history')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    on_bid = models.BooleanField(default=False,)
    returned_to_available = models.BooleanField(default=False)
    sold = models.BooleanField(default=False)
    class Meta:
        verbose_name_plural = " Auction Histories"

    def __str__(self):
        return f"{self.vehicle.registration_no} {self.vehicle.model.name} in Auction {str(self.auction.auction_id)[:8]}"

     # Method to get the top bid amount
    def top_bid_amount(self):
        top_bid = self.vehicle.bidding.order_by('-amount').first()  # Get the highest bid
        return top_bid.amount if top_bid else "No bids"

    # Method to show the reserve price of the vehicle
    def reserve_price(self):
        return self.vehicle.reserve_price

     # Method to get the highest bidder's email
    def highest_bidder_email(self):
        top_bid = self.vehicle.bidding.order_by('-amount').first()  # Get the highest bid
        return top_bid.user.email if top_bid else "No bids"

    # Method to count the total number of bids
    def total_bids(self):
        return self.vehicle.bidding.count()

# Example Recipient model
class NotificationRecipient(models.Model):
    email = models.EmailField()
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.email

class AdminActionLog(models.Model):
    """
    Model to track all actions performed in the admin panel.
    """
    ACTION_TYPES = (
        ('CREATE', 'Create'),
        ('UPDATE', 'Update'),
        ('DELETE', 'Delete'),
        ('VIEW', 'View'),
        ('LOGIN', 'Login'),
        ('LOGOUT', 'Logout'),
        ('OTHER', 'Other'),
    )

    # Who performed the action
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='admin_actions')
    
    # When the action was performed
    timestamp = models.DateTimeField(auto_now_add=True)
    
    # The type of action (create, update, delete, etc.)
    action_type = models.CharField(max_length=10, choices=ACTION_TYPES)
    
    # IP address of the user
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    
    # What model was affected
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, null=True, blank=True)
    object_id = models.CharField(max_length=255, null=True, blank=True)
    content_object = GenericForeignKey('content_type', 'object_id')
    
    # Additional details about the action (can store JSON or serialized details)
    change_message = models.TextField(blank=True)
    
    # Optional fields for additional metadata
    object_repr = models.CharField(max_length=200, blank=True)  # String representation of the object
    user_agent = models.TextField(blank=True, null=True)  # Browser/client info
    
    class Meta:
        ordering = ['-timestamp']
        verbose_name = 'Admin Action Log'
        verbose_name_plural = 'Admin Action Logs'
        
    def __str__(self):
        return f"{self.user} {self.get_action_type_display()} {self.object_repr} at {self.timestamp}"



class VehiclePriceRevision(models.Model):
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name='price_revisions'
    )
    old_price = models.IntegerField()
    new_price = models.IntegerField()
    revised_by = models.ForeignKey(
        User,
        null=True,
        on_delete=models.SET_NULL
    )
    revised_at = models.DateTimeField(auto_now_add=True)


    class Meta:
        abstract = False


    def __str__(self):
        return f"{self.vehicle.registration_no}: {self.old_price:,} → {self.new_price:,}"

class NotificationLog(models.Model):
    PRICE_REVISION = "price_revision"
    BID_AWARDED = "bid_awarded"
    BID_DISQUALIFIED = "bid_disqualified"

    EVENT_CHOICES = [
        (PRICE_REVISION, "Price Revision"),
        (BID_AWARDED, "Bid Awarded"),
        (BID_DISQUALIFIED, "Bid Disqualified"),
    ]

    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name="notification_logs"
    )
    user = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL
    )
    phone_number = models.CharField(max_length=20)

    event_type = models.CharField(
        max_length=50,
        choices=EVENT_CHOICES
    )

    message = models.TextField()
    sent = models.BooleanField(default=False)
    provider_response = models.TextField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        abstract = False

    def __str__(self):
        status = "SUCCESS" if self.sent else "FAILED"
        return f"{self.event_type} → {self.phone_number} ({status})"


from django.db import models
from django.contrib.auth.models import User


class PaymentConfirmation(models.Model):
    """
    Stores payment proof submitted by a user for an awarded bid.
    One confirmation per bid — enforced via OneToOneField.
    """

    CONFIRMATION_TYPE_CHOICES = [
        ('text', 'Text Note'),
        ('image', 'Image'),
        ('pdf', 'PDF'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    bid = models.OneToOneField(
        'Bidding',
        on_delete=models.CASCADE,
        related_name='payment_confirmation',
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='payment_confirmations',
    )
    confirmation_type = models.CharField(
        max_length=10,
        choices=CONFIRMATION_TYPE_CHOICES,
    )

    # ── Submission payload (only one will be set per record) ──
    text_note   = models.TextField(blank=True, null=True)
    image_file  = models.ImageField(upload_to='payment_proofs/images/', blank=True, null=True)
    pdf_file    = models.FileField(upload_to='payment_proofs/pdfs/',   blank=True, null=True)

    # ── Admin review ──
    status      = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    admin_note  = models.TextField(blank=True, null=True, help_text="Internal note visible only to staff")

    # ── Timestamps ──
    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at  = models.DateTimeField(blank=True, null=True)
    reviewed_by  = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='reviewed_confirmations',
    )

    class Meta:
        verbose_name        = 'Payment Confirmation'
        verbose_name_plural = 'Payment Confirmations'
        ordering            = ['-submitted_at']

    def __str__(self):
        return f"{self.user.username} — {self.bid.vehicle.registration_no} ({self.get_status_display()})"

    @property
    def is_approved(self):
        return self.status == 'approved'
   