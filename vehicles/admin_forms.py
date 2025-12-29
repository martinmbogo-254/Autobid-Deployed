from django import forms

class ReviseVehiclePriceForm(forms.Form):
    _selected_action = forms.CharField(widget=forms.MultipleHiddenInput)

    new_price = forms.IntegerField(
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter New Revised Price',
            'required': True
        }),


    )


