from django.urls import path
from .views import login
from .views import get_my_info
from .views import get_locations, get_locations_stats, get_user_status
from .views import get_bears_user_info

urlpatterns = [
    path('login/', login),
    path('user/', get_my_info),
    path('user/bear', get_bears_user_info),
    path('locations/', get_locations),
    path('locations_stats/', get_locations_stats),
    path('locations/status', get_user_status),
]
