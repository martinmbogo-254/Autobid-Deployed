import django_filters
from django_filters import CharFilter
from django.db.models import Q
from .models import Vehicle


class VehicleFilter(django_filters.FilterSet):

    # GLOBAL SEARCH FIELD
    q = CharFilter(method="global_search", label="Search")

    # Price range filter (unchanged)
    price_range = django_filters.ChoiceFilter(
        field_name='reserve_price',
        label='Price Range',
        choices=(
            ('0-500000', '0 - 500k'),
            ('500001-1000000', '500k - 1M'),
            ('1000001-2000000', '1M - 2M'),
            ('2000001-5000000', '2M - 5M'),
            ('5000001-999999999', 'Above 5M'),
        ),
        method='filter_by_price_range'
    )

    class Meta:
        model = Vehicle
        fields = {
            'make', 'model', 'YOM', 'transmission', 'body_type',
            'engine_cc', 'fuel_type', 'registration_no', 'Financier'
        }

    # PRICE RANGE HANDLER
    def filter_by_price_range(self, queryset, name, value):
        if value:
            min_price, max_price = map(int, value.split('-'))
            return queryset.filter(reserve_price__gte=min_price, reserve_price__lt=max_price)
        return queryset

    # GLOBAL SEARCH HANDLER
    def global_search(self, queryset, name, value):
        if not value:
            return queryset

        return queryset.filter(
            Q(make__name__icontains=value) |
            Q(model__name__icontains=value) |
            Q(YOM__year__icontains=value) |
            Q(transmission__icontains=value) |
            Q(body_type__name__icontains=value) |
            Q(engine_cc__icontains=value) |
            Q(fuel_type__name__icontains=value) |
            Q(registration_no__icontains=value) |
            Q(Financier__name__icontains=value) |
            Q(reserve_price__icontains=value) |
            Q(color__icontains=value) |
            Q(seats__icontains=value) |
            Q(yard__name__icontains=value) |
            Q(status__icontains=value)
        )

    # STYLE THE WIDGETS
    def __init__(self, *args, **kwargs):
        super(VehicleFilter, self).__init__(*args, **kwargs)

        for field_name, field in self.filters.items():             
            field.field.widget.attrs.update({'class': 'form-control'})
