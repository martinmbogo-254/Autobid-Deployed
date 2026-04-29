from __future__ import annotations

from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models


class SingletonManager(models.Manager):
    def get_or_create_singleton(self) -> "SiteSettings":
        obj, _ = self.get_or_create(pk=1)
        return obj


class SiteSettings(models.Model):

    # Bidding
    bidding_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal("0.00"),
        validators=[MinValueValidator(Decimal("0.00"))],
        help_text="Platform fee charged per bid (in KES).",
    )

    # Safaricom / M-PESA
    safaricom_consumer_key = models.CharField(
        max_length=255,
        blank=True,
        default="",
        verbose_name="Consumer key",
        help_text="Daraja API consumer key.",
    )
    safaricom_consumer_secret = models.CharField(
        max_length=255,
        blank=True,
        default="",
        verbose_name="Consumer secret",
        help_text="Daraja API consumer secret.",
    )
    safaricom_passkey = models.CharField(
        max_length=255,
        blank=True,
        default="",
        verbose_name="Lipa Na M-Pesa passkey",
        help_text="LNM online passkey from Daraja portal.",
    )
    safaricom_shortcode = models.CharField(
        max_length=20,
        blank=True,
        default="",
        verbose_name="Shortcode",
        help_text="M-Pesa till / paybill shortcode (e.g. 174379 for sandbox).",
    )
    safaricom_callback_url = models.URLField(
        max_length=500,
        blank=True,
        default="",
        verbose_name="Callback URL",
        help_text="M-Pesa callback URL for STK push results (e.g. https://yourdomain.com/api/mpesa/callback/).",
    )

    # Metadata
    updated_at = models.DateTimeField(auto_now=True)

    objects = SingletonManager()

    class Meta:
        verbose_name = "Site Settings"
        verbose_name_plural = "Site Settings"

    def __str__(self) -> str:
        return "Site Settings"

    # Singleton enforcement

    def save(self, *args, **kwargs) -> None:
        self.pk = 1
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        raise RuntimeError("SiteSettings cannot be deleted.")

    @classmethod
    def get(cls) -> "SiteSettings":
        """Primary access point — creates the row with defaults on first call."""
        return cls.objects.get_or_create_singleton()

    # Convenience

    def get_safaricom_config(self) -> dict:
        """Return all Safaricom credentials as a dict."""
        return {
            "consumer_key": self.safaricom_consumer_key,
            "consumer_secret": self.safaricom_consumer_secret,
            "passkey": self.safaricom_passkey,
            "shortcode": self.safaricom_shortcode,
        }