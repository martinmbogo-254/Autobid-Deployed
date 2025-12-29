from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from .models import Vehicle  # Adjust based on your model

class VehicleSitemap(Sitemap):
    changefreq = "daily"
    priority = 1

    def items(self):
        return Vehicle.objects.all()

    

class StaticSitemap(Sitemap):
    priority = 1
    changefreq = "monthly"

    def items(self):
        return ['homepage', 'available_vehicles', 'aboutus', 'contactus']  # Add your static views

    
