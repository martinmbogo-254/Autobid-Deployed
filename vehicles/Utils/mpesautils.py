# mpesa/utils.py
import requests
import base64
from datetime import datetime
from django.conf import settings

def get_mpesa_access_token():
    """Generate OAuth access token"""
    consumer_key = settings.MPESA_CONSUMER_KEY
    consumer_secret = settings.MPESA_CONSUMER_SECRET
    api_URL = f"{settings.MPESA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials"

    try:
        r = requests.get(api_URL, auth=(consumer_key, consumer_secret))
        r.raise_for_status()
        mpesa_access_token = r.json()['access_token']
        return mpesa_access_token
    except Exception as e:
        raise Exception(f"Failed to get access token: {str(e)}")


def get_password():
    """Generate Lipa na M-Pesa password"""
    shortcode = settings.MPESA_SHORTCODE
    passkey = settings.MPESA_PASSKEY
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    data_to_encode = shortcode + passkey + timestamp
    encoded_string = base64.b64encode(data_to_encode.encode()).decode('utf-8')
    return encoded_string, timestamp


def initiate_bidding_fee_payment(phone_number, amount, account_reference,
                               transaction_desc, callback_url, payment_instance=None):
    """Initiate STK Push - Pure requests version"""
    try:
        access_token = get_mpesa_access_token()
        password, timestamp = get_password()

        api_url = f"{settings.MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest"

        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json',
        }

        payload = {
            "BusinessShortCode": settings.MPESA_SHORTCODE,
            "Password": password,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": amount,
            "PartyA": phone_number,
            "PartyB": settings.MPESA_SHORTCODE,
            "PhoneNumber": phone_number,
            "CallBackURL": callback_url,
            "AccountReference": account_reference,
            "TransactionDesc": transaction_desc
        }

        response = requests.post(api_url, json=payload, headers=headers)
        response.raise_for_status()
        resp_data = response.json()

        if resp_data.get('ResponseCode') == '0':
            if payment_instance:
                payment_instance.merchant_request_id = resp_data.get('MerchantRequestID')
                payment_instance.checkout_request_id = resp_data.get('CheckoutRequestID')
                payment_instance.save()
            return True, resp_data.get('CustomerMessage', 'Check your phone for M-Pesa prompt')
        else:
            return False, resp_data.get('ResponseDescription', 'Unknown error')

    except requests.exceptions.RequestException as e:
        return False, f"Network error: {str(e)}"
    except Exception as e:
        return False, f"Failed to initiate payment: {str(e)}"