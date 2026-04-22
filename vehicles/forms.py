from .models import Bidding, Auction,Vehicle
from .widgets import CommaSeparatedIntegerWidget
from django import forms
from .models import PaymentConfirmation


class PaymentConfirmationForm(forms.ModelForm):
    """
    Handles all three proof types in a single form.
    Validation logic enforces that only the relevant field
    is required based on the selected confirmation_type.
    """

    class Meta:
        model  = PaymentConfirmation
        fields = ['confirmation_type', 'text_note', 'image_file', 'pdf_file']

    #  Field overrides

    confirmation_type = forms.ChoiceField(
        choices=PaymentConfirmation.CONFIRMATION_TYPE_CHOICES,
        widget=forms.HiddenInput(),   # type is set by the JS tab switcher
    )

    text_note = forms.CharField(
        required=False,
        widget=forms.Textarea(attrs={
            'rows': 5,
            'class': 'pay-textarea',
            'placeholder': (
                'e.g. Transferred KSH 1,200,000 via M-Pesa on 22 Apr 2026. '
                'Transaction ref: QAB12345X...'
            ),
        }),
    )

    # image_file is not a model field — the view saves a ContentFile from
    # the base64 payload; this field is kept for fallback non-JS browsers.
    image_file = forms.ImageField(
        required=False,
        widget=forms.ClearableFileInput(attrs={
            'id': 'imageInput',
            'name': 'image_file',
            'accept': 'image/*',
            'class': 'hidden-input',
        }),
    )

    pdf_file = forms.FileField(
        required=False,
        widget=forms.ClearableFileInput(attrs={
            'id': 'pdfInput',
            'name': 'pdf_file',
            'accept': 'application/pdf',
            'class': 'hidden-input',
        }),
    )

    #  Hidden fields passed from the template

    # Base64-compressed image produced by the Canvas API in JS
    compressed_image_data = forms.CharField(
        required=False,
        widget=forms.HiddenInput(attrs={'id': 'compressedImageData'}),
    )
    compressed_image_name = forms.CharField(
        required=False,
        widget=forms.HiddenInput(attrs={'id': 'compressedImageName'}),
    )

    # The bid this confirmation belongs to
    bid_id = forms.IntegerField(
        widget=forms.HiddenInput(attrs={'id': 'formBidId'}),
    )

    #  Cross-field validation

    def clean(self):
        cleaned = super().clean()
        ctype   = cleaned.get('confirmation_type')

        if ctype == 'text':
            if not cleaned.get('text_note', '').strip():
                self.add_error('text_note', 'Please enter a payment note.')

        elif ctype == 'image':
            has_compressed = bool(cleaned.get('compressed_image_data', '').strip())
            has_raw        = bool(cleaned.get('image_file'))
            if not has_compressed and not has_raw:
                self.add_error(
                    'image_file',
                    'Please select an image to upload.',
                )

        elif ctype == 'pdf':
            pdf = cleaned.get('pdf_file')
            if not pdf:
                self.add_error('pdf_file', 'Please select a PDF file.')
            elif pdf.size > 10 * 1024 * 1024:
                self.add_error('pdf_file', 'PDF must be under 10 MB.')
            elif getattr(pdf, 'content_type', '') != 'application/pdf':
                self.add_error('pdf_file', 'Only PDF files are accepted.')

        return cleaned

class BidForm(forms.ModelForm):
    def __init__(self, *args, existing_bid=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['amount'].widget = CommaSeparatedIntegerWidget(
            attrs={'class': 'form-control'},
            existing_bid=existing_bid
        )

    class Meta:
        model = Bidding
        fields = ['amount', 'referred_by']

    def clean_amount(self):
        amount = self.cleaned_data.get('amount')
        if amount is not None and amount % 1000 != 0:
            raise forms.ValidationError("Bid amount must be a multiple of 1,000.")
        return amount


class AuctionForm(forms.ModelForm):
    vehicles= forms.ModelMultipleChoiceField(
        queryset=Vehicle.objects.filter(status='available'),
        widget=forms.CheckboxSelectMultiple)
    class Meta:
        model = Auction
        fields = ['start_date', 'end_date', 'vehicles', 'approved']
        # widgets = {
        #     'start_date': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
        #     'end_date': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
        # }
    
    
   
class FeedbackForm(forms.Form):
    name = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter your name',
            'required': True
        }),
        label='Name'
    )
    email = forms.EmailField(
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter your email',
            'required': True
        }),
        label='Email'
    )
    feedback = forms.CharField(
        widget=forms.Textarea(attrs={
            'class': 'form-control',
            'placeholder': 'Write your feedback here',
            'rows': 5,
            'required': True
        }),
        label='Feedback'
    )