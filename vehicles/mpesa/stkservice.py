# your_app/mpesa/service.py

import requests
import logging
from django.conf import settings
from .mpesautil import get_mpesa_access_token, get_timestamp, get_password

logger = logging.getLogger(__name__)


def initiate_stk_push(phone_number, amount, account_reference, transaction_desc):
    config = settings.MPESA_CONFIG
    url = (
        "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
        if config["ENVIRONMENT"] == "sandbox"
        else "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    )

    token = get_mpesa_access_token()
    timestamp = get_timestamp()
    password = get_password(config["SHORTCODE"], config["PASSKEY"], timestamp)

    headers = {"Authorization": f"Bearer {token}"}
    payload = {
        "BusinessShortCode": config["SHORTCODE"],
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": int(amount),
        "PartyA": phone_number,
        "PartyB": config["SHORTCODE"],
        "PhoneNumber": phone_number,
        "CallBackURL": config["CALLBACK_URL"],
        "AccountReference": account_reference,
        "TransactionDesc": transaction_desc,
    }

    response = requests.post(url, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    data = response.json()
    logger.info(f"STK Push response: {data}")

    if data.get("ResponseCode") != "0":
        raise ValueError(data.get("ResponseDescription", "STK Push failed"))

    return data