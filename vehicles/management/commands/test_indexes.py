from django.core.management.base import BaseCommand
from django.db import connection
from django.utils import timezone
from vehicles.models import Vehicle
import time


class Command(BaseCommand):
    help = 'Test database query performance'

    def handle(self, *args, **options):
        # Test 1: Approved vehicles listing
        self.stdout.write("\n=== Test 1: Main listing query ===")
        start = time.time()

        vehicles = list(Vehicle.objects.filter(
            is_approved=True,
            status__in=['available', 'on_auction']
        ).select_related('make', 'model').order_by('-created_at')[:24])

        elapsed = time.time() - start
        self.stdout.write(f"Found {len(vehicles)} vehicles in {elapsed:.4f} seconds")

        # Show query plan
        with connection.cursor() as cursor:
            cursor.execute("""
                EXPLAIN QUERY PLAN
                SELECT * FROM vehicles_vehicle
                WHERE is_approved=1 AND status IN ('available', 'on_auction')
                ORDER BY created_at DESC LIMIT 24
            """)
            plan = cursor.fetchall()
            self.stdout.write("\nQuery Plan:")
            for row in plan:
                self.stdout.write(str(row))

        # Test 2: Filter by make
        self.stdout.write("\n\n=== Test 2: Filter by make ===")
        start = time.time()

        vehicles = list(Vehicle.objects.filter(
            make_id=1,
            is_approved=True
        ).order_by('-created_at')[:24])

        elapsed = time.time() - start
        self.stdout.write(f"Found {len(vehicles)} vehicles in {elapsed:.4f} seconds")

        # Test 3: Hot sale vehicles
        self.stdout.write("\n\n=== Test 3: Hot sale vehicles ===")
        start = time.time()

        vehicles = list(Vehicle.objects.filter(
            is_hotsale=True,
            is_approved=True
        ).order_by('-created_at')[:20])

        elapsed = time.time() - start
        self.stdout.write(f"Found {len(vehicles)} vehicles in {elapsed:.4f} seconds")

        self.stdout.write(self.style.SUCCESS('\n✓ Performance tests completed!'))