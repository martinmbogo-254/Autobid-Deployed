# your_app/mpesa/utils.py

import base64
import requests
from datetime import datetime
from django.conf import settings
from settings.models import SiteSettings



def get_mpesa_access_token():
    # config = settings.MPESA_CONFIG
    config = SiteSettings.get()
    consumer_key = config.safaricom_consumer_key
    consumer_secret = config.safaricom_consumer_secret

    url = (
        "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        if not config.safaricom_shortcode.startswith("5")
        else "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    )
    response = requests.get(url, auth=(consumer_key, consumer_secret))
    response.raise_for_status()
    return response.json()["access_token"]


def get_timestamp():
    return datetime.now().strftime("%Y%m%d%H%M%S")


def get_password(timestamp):
    cfg = SiteSettings.get()
    raw = f"{cfg.safaricom_shortcode}{cfg.safaricom_passkey}{timestamp}"
    return base64.b64encode(raw.encode()).decode()


def format_phone_number(phone):
    """Normalize to 254XXXXXXXXX. Accepts 07..., +254..., 254..."""
    phone = str(phone).strip().replace(" ", "").replace("-", "")
    if phone.startswith("+"):
        phone = phone[1:]
    if phone.startswith("0"):
        phone = "254" + phone[1:]
    if not phone.startswith("254"):
        phone = "254" + phone
    return phone