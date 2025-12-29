from django.core.exceptions import ValidationError
import re

class FourDigitPinValidator:
    def validate(self, password, user=None):
        if not re.fullmatch(r"\d{4}", password):
            raise ValidationError(
                "Password must be exactly 4 digits (0–9)."
            )

    def get_help_text(self):
        return "Your password must contain exactly 4 digits."
