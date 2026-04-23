from django.urls import path
from . import views
from users.views import ResetPasswordView
from django.contrib.auth import views as auth_views
from django.contrib.sitemaps.views import sitemap
from .sitemaps import VehicleSitemap, StaticSitemap

sitemaps = {
    'vehicles': VehicleSitemap(),
    'static': StaticSitemap(),
}

urlpatterns = [
    path('',views.homepage, name='homepage' ),
    # path('vehicles/',views.vehiclespage, name='vehicles'),
    path('available_vehicles/',views.allvehiclespage, name='available_vehicles'),
    path('logout/', views.logout_view, name='logout'),
    path('vehicle/<int:pk>/',views.vehicledetail, name='detail' ),
    path('place_bid/<int:pk>/', views.place_bid, name='place_bid'),
    path('add-auction/', views.auction_add, name='auction_add'),
    path('auctions/', views.auction_list, name='auction_list'),
    path('auction/<int:pk>/', views.auction_detail, name='auction_detail'),
    # path('administration/',views.admin_dash, name='administration'),
    path('admin/auction-status/', views.auction_status_update, name='auction_status_update'),
    path('reports/', views.reports, name='reports'),
    path('terms/',views.terms, name='terms'),
    path('privacy-policy/',views.privacy_policy, name='privacy_policy'),
    path('aboutus/',views.aboutus, name='aboutus'),
    path('contactus/',views.feedback_view, name='contactus'),
    path('password-reset/', ResetPasswordView.as_view(), name='password_reset'),
    path('password-reset-confirm/<uidb64>/<token>/',
         auth_views.PasswordResetConfirmView.as_view(template_name='users/password/password_reset_confirm.html'),
         name='password_reset_confirm'),
     path('password-reset-complete/',
         auth_views.PasswordResetCompleteView.as_view(template_name='users/password/password_reset_complete.html'),
         name='password_reset_complete'),
     path('sitemap.xml', sitemap, {'sitemaps': sitemaps}, name='sitemap'),
     path("robots.txt", views.robots_txt, name="robots_txt"),
     path('dashboard/', views.dashboard_view, name='dashboard'),

    # Payments URL's
    path('payments/pay/<int:vehicle_id>/', views.pay_bidding_fee, name='pay_bidding_fee'),
    path('payments/pending/<int:payment_id>/', views.payment_pending, name='payment_pending'),
    path('payments/status/<int:payment_id>/', views.check_payment_status, name='check_payment_status'),
    path('payments/mpesa/callback/', views.mpesa_callback, name='mpesa_callback'),
    path('my-bids/',views.awarded_bids,name='awarded_bids'),
    path('payment-confirmation/submit/',views.submit_payment_confirmation, name='submit_payment_confirmation'),



]