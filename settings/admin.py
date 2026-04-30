from __future__ import annotations

from django import forms
from django.contrib import admin

from .models import SiteSettings


class SiteSettingsAdminForm(forms.ModelForm):
    safaricom_consumer_key = forms.CharField(
        widget=forms.PasswordInput(render_value=True),
        required=False,
        label="Consumer key",
        help_text="Masked for display. The current value is preserved on save.",
    )
    safaricom_consumer_secret = forms.CharField(
        widget=forms.PasswordInput(render_value=True),
        required=False,
        label="Consumer secret",
        help_text="Masked for display. The current value is preserved on save.",
    )
    safaricom_passkey = forms.CharField(
        widget=forms.PasswordInput(render_value=True),
        required=False,
        label="Passkey",
        help_text="Masked for display. The current value is preserved on save.",
    )

    class Meta:
        model = SiteSettings
        fields = [
            "bidding_fee",
            "safaricom_shortcode",
            "safaricom_consumer_key",
            "safaricom_consumer_secret",
            "safaricom_passkey",
        ]

    def save(self, commit: bool = True) -> SiteSettings:
        instance: SiteSettings = super().save(commit=False)

        # If the field was left blank, keep the existing stored value
        for field in ("safaricom_consumer_key", "safaricom_consumer_secret", "safaricom_passkey"):
            submitted = self.cleaned_data.get(field, "").strip()
            if not submitted:
                # Reload from DB so we don't overwrite with an empty string
                try:
                    existing = SiteSettings.objects.get(pk=1)
                    setattr(instance, field, getattr(existing, field))
                except SiteSettings.DoesNotExist:
                    pass

        if commit:
            instance.save()
        return instance


@admin.register(SiteSettings)
class SiteSettingsAdmin(admin.ModelAdmin):
    form = SiteSettingsAdminForm

    fieldsets = (
        (
            "Bidding",
            {
                "fields": ("bidding_fee",),
            },
        ),
        (
            "Safaricom / M-Pesa",
            {
                "fields": (
                    "safaricom_shortcode",
                    "safaricom_consumer_key",
                    "safaricom_consumer_secret",
                    "safaricom_passkey",
                    "safaricom_callback_url",
                ),
            },
        ),
        (
            "Meta",
            {
                "fields": ("updated_at",),
            },
        ),
    )
    readonly_fields = ("updated_at",)

    def has_add_permission(self, request) -> bool:
        return not SiteSettings.objects.filter(pk=1).exists()

    def has_delete_permission(self, request, obj=None) -> bool:
        return False

    def get_object(self, request, object_id, from_field=None):
        return SiteSettings.get()

    def changelist_view(self, request, extra_context=None):
        from django.shortcuts import redirect
        from django.urls import reverse
        opts = self.model._meta
        return redirect(
            reverse(f"admin:{opts.app_label}_{opts.model_name}_change", args=[1])
        )