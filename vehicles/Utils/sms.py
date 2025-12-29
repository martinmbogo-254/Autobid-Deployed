import sys
sys.path.append('C:\\inetpub\\wwwroot\\Auto-auction\\myenv\\Lib\\site-packages')
import requests
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

TIARA_API_URL = settings.TIARA_API_URL
AUTH_TOKEN = settings.AUTH_TOKEN


def send_sms(phone_number: str, message: str) -> bool | tuple[bool, str]:
    """
    Send an SMS using the Tiara API.

    Returns True if successful, False otherwise.
    """

    if not phone_number:
        logger.warning("SMS not sent: missing phone number")
        return False

    payload = {
        "from": "Riverlong",
        "to": phone_number,
        "message": message,
    }

    headers = {
        "Authorization": AUTH_TOKEN,
        "Content-Type": "application/json",
    }

    try:
        response = requests.post(
            TIARA_API_URL,
            json=payload,
            headers=headers,
            timeout=10
        )

        if response.status_code == 200:
            return True, response.text

        return False, response.text

    except requests.RequestException as e:
        return False, str(e)




