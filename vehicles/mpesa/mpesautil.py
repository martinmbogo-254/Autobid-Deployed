# your_app/mpesa/utils.py

import base64
import requests
from datetime import datetime
from django.conf import settings


def get_mpesa_access_token():
    config = settings.MPESA_CONFIG
    url = (
        "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        if config["ENVIRONMENT"] == "sandbox"
        else "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    )
    response = requests.get(url, auth=(config["CONSUMER_KEY"], config["CONSUMER_SECRET"]))
    response.raise_for_status()
    return response.json()["access_token"]


def get_timestamp():
    return datetime.now().strftime("%Y%m%d%H%M%S")


def get_password(shortcode, passkey, timestamp):
    raw = f"{shortcode}{passkey}{timestamp}"
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