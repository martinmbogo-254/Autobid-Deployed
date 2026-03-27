from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
from django.db import models
from django.contrib.auth.models import User

class Location(models.Model):
    city = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.city
# # Create your models here.
# class CustomUser(AbstractUser):
#     username = models.CharField(max_length=150, unique=False, blank=True, null=True)
#     email = models.EmailField(unique=True)

#     USERNAME_FIELD = 'email'
#     REQUIRED_FIELDS = ['username']
class Profile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE
    )
    ID_number = models.IntegerField(max_length=10,blank=False,null=True,unique=True)
    phone_number = models.PositiveIntegerField(max_length=10,blank=False,null=True,unique=True)
    location = models.ForeignKey(Location, on_delete=models.SET_NULL, null=True, blank=True)
    full_name = models.CharField(max_length=20, blank=True)
    referred_by = models.CharField(max_length=20, blank=True)

    def get_display_name(self):
        if self.full_name:
            return self.full_name
        return f"{self.user.first_name} {self.user.last_name}".strip()

    def get_date_joined(self):
        return self.user.date_joined
    

    def __str__(self):
        return f"{self.user.username}'s profile"