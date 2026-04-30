# your_app/mpesa/service.py

import logging

import requests

from settings.models import SiteSettings
from .mpesautil import format_phone_number, get_mpesa_access_token, get_password, get_timestamp

logger = logging.getLogger(__name__)


def initiate_stk_push(phone_number, amount, account_reference, transaction_desc):
    cfg = SiteSettings.get()

    timestamp = get_timestamp()
    password = get_password(timestamp)
    token = get_mpesa_access_token()

    url = (
        "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
        if cfg.safaricom_shortcode.startswith("174")
        else "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    )

    headers = {"Authorization": f"Bearer {token}"}
    payload = {
        "BusinessShortCode": cfg.safaricom_shortcode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": int(amount),
        "PartyA": format_phone_number(phone_number),
        "PartyB": cfg.safaricom_shortcode,
        "PhoneNumber": format_phone_number(phone_number),
        "CallBackURL": cfg.safaricom_callback_url,
        "AccountReference": account_reference,
        "TransactionDesc": transaction_desc,
    }

    response = requests.post(url, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    data = response.json()
    logger.info("STK Push response: %s", data)

    if data.get("ResponseCode") != "0":
        raise ValueError(data.get("ResponseDescription", "STK Push failed"))

    return data