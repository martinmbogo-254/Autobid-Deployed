# your_app/decorators.py

from functools import wraps
from django.shortcuts import redirect
from django.contrib import messages
from .models import BiddingFeePayment,Vehicle


def requires_bidding_fee(view_func):
    """
    Decorator for bid-related views.
    Expects the view to receive a `vehicle_id` kwarg.
    Redirects to payment page if fee not paid.
    """
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect("login")

        vehicle_id = kwargs.get("vehicle_id") or kwargs.get("pk")
        if not vehicle_id:
            return redirect("home")

        # Try to get vehicle

        try:
            vehicle = Vehicle.objects.get(pk=vehicle_id)
        except Vehicle.DoesNotExist:
            return redirect("home")

        if not BiddingFeePayment.has_paid(request.user, vehicle):
            messages.warning(
                request,
                f"You need to pay the bidding fee for '{vehicle}' before placing a bid."
            )
            return redirect("pay_bidding_fee", vehicle_id=vehicle_id)

        return view_func(request, *args, **kwargs)
    return wrapper