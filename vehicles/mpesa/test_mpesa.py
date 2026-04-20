"""
M-Pesa STK Push Debug Script
Run with: python test_mpesa.py
"""

import requests
import base64
from datetime import datetime

# ─── CONFIG ──────────────────────────────────────────────────────────────────
# Paste your sandbox credentials directly here to test
CONSUMER_KEY = 'GepnBTJcPLkodEQ98BjML7xbsNPsXzFFTprkBMryXADJq8jR'
CONSUMER_SECRET ='NHar7I9Z0rzTWcqlhCQWFDnPxGVyKcA373DbBA0nq0D5tLSq4UUHqC5GPdxECA6J'
SHORTCODE = "174379"
PASSKEY = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919'
CALLBACK_URL = "https://c945-197-237-29-119.ngrok-free.app/payments/mpesa/callback/"
TEST_PHONE = "254745499838"   #  sandbox test number
AMOUNT = 1
# ─────────────────────────────────────────────────────────────────────────────


def test_token():
    print("\n" + "="*50)
    print("STEP 1: Fetching access token...")
    print("="*50)
    url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    try:
        r = requests.get(url, auth=(CONSUMER_KEY, CONSUMER_SECRET), timeout=15)
        print(f"Status Code : {r.status_code}")
        print(f"Response    : {r.text}")
        if r.status_code == 200:
            token = r.json().get("access_token")
            print(f"✅ Token OK : {token[:20]}...")
            return token
        else:
            print("❌ Token fetch failed — check CONSUMER_KEY and CONSUMER_SECRET")
            return None
    except Exception as e:
        print(f"❌ Request error: {e}")
        return None


def test_stk_push(token):
    print("\n" + "="*50)
    print("STEP 2: Initiating STK Push...")
    print("="*50)

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    raw = f"{SHORTCODE}{PASSKEY}{timestamp}"
    password = base64.b64encode(raw.encode()).decode()

    payload = {
        "BusinessShortCode": SHORTCODE,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": AMOUNT,
        "PartyA": TEST_PHONE,
        "PartyB": SHORTCODE,
        "PhoneNumber": TEST_PHONE,
        "CallBackURL": CALLBACK_URL,
        "AccountReference": "TEST-001",
        "TransactionDesc": "Test bidding fee",
    }

    print(f"\nPayload being sent:")
    for k, v in payload.items():
        # Mask password in output
        print(f"  {k:20}: {v[:10] + '...' if k == 'Password' else v}")

    try:
        r = requests.post(
            "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
            json=payload,
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        print(f"\nStatus Code : {r.status_code}")
        print(f"Response    : {r.text}")

        if r.status_code == 200 and r.json().get("ResponseCode") == "0":
            print("\n✅ STK Push successful! Check the test phone for the prompt.")
            print(f"   CheckoutRequestID : {r.json().get('CheckoutRequestID')}")
            print(f"   MerchantRequestID : {r.json().get('MerchantRequestID')}")
        else:
            print("\n❌ STK Push failed — see response above for details")

    except Exception as e:
        print(f"❌ Request error: {e}")


if __name__ == "__main__":
    print("\n🔍 M-Pesa Sandbox Debug Script")
    print(f"   Shortcode   : {SHORTCODE}")
    print(f"   Phone       : {TEST_PHONE}")
    print(f"   Amount      : KES {AMOUNT}")
    print(f"   Callback    : {CALLBACK_URL}")

    token = test_token()
    if token:
        test_stk_push(token)
    else:
        print("\n⛔ Aborting — could not get access token.")