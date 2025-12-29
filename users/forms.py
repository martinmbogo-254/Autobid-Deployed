
from django import forms
from django.contrib.auth.models import User
from .models import Location, Profile
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm
from django.core.validators import MinLengthValidator, RegexValidator


class CustomLoginForm(forms.Form):
    username = forms.EmailField(
        label="Email",
        widget=forms.TextInput(attrs={
            'placeholder': 'Enter your email address',
            'class': 'form-control'
        })
    )
 
    password = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'placeholder': 'Enter your password',
            'class': 'form-control'
        })
    )
    class Meta:
        fields = ['username', 'password']

class UserRegistrationForm(UserCreationForm):
    class Meta:
        model = User
        fields = ['username', 'password1', 'password2','accept_terms']
      
        
    accept_terms = forms.BooleanField(
        required=True,
        label="I accept the Terms and Conditions",
        error_messages={'required': "You must accept the Terms and Conditions to register."}
    )

    password1 = forms.CharField(
        label="PIN",
    widget=forms.PasswordInput(attrs={
        'placeholder': 'Enter 4-digit PIN',
        'class': 'form-control',
        'maxlength': '4',
        'inputmode': 'numeric',
        'pattern': '\\d{4}',
    })
    )

    password2 = forms.CharField(
        label="Confirm PIN",
        widget=forms.PasswordInput(attrs={
            'placeholder': 'Confirm 4-digit PIN',
            'class': 'form-control',
            'maxlength': '4',
            'inputmode': 'numeric',
            'pattern': '\\d{4}',
        })
    )

    # first_name = forms.CharField(
    #     max_length=30,
    #     required=True,
    #     widget=forms.TextInput(attrs={
    #         'placeholder': 'Enter your first name',
    #         'class': 'form-control'
    #     })
    # )
    # last_name = forms.CharField(
    #     max_length=30,
    #     required=True,
    #     widget=forms.TextInput(attrs={
    #         'placeholder': 'Enter your last name',
    #         'class': 'form-control'
    #     })
    # )
 
    username = forms.EmailField(  # Changed to EmailField
        label="Email",
        widget=forms.EmailInput(attrs={
            'placeholder': 'Enter your email',
            'class': 'form-control'
        })
    )


    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data['username']  # Set email same as username
        if commit:
            user.save()
        return user


class ProfileForm(forms.ModelForm):

    class Meta:
        model = Profile
        fields = ['phone_number', 'ID_number', 'location', 'full_name']
         
        widgets = {
            'phone_number': forms.TextInput(attrs={
                'maxlength': '10',
                'pattern': '\\d{10}',
                'inputmode': 'numeric',
                'placeholder': 'Enter valid phone number',
                'class': 'form-control'
            }),
            'ID_number': forms.TextInput(attrs={
                'maxlength': '12',
                # 'pattern': '\\d{12}',
                'inputmode': 'numeric',
                'placeholder': 'Enter valid ID number',
                'class': 'form-control'
            }),
            'full_name': forms.TextInput(attrs={
                'maxlength': '20',
                
                'placeholder': 'Enter your name',
                'class': 'form-control'
            }),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['location'].queryset = Location.objects.all().order_by('city')
   

class UserUpdateForm(forms.ModelForm):
    email = forms.EmailField()

    class Meta:
        model = User
        fields = ['username', 'email']