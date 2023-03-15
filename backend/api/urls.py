from django.urls import path
from .views import login
from .views import get_my_info
from .views import get_locations, get_locations_stats
from .views import get_bears_user_info

urlpatterns = [
    path('login/', login),
    path('user/', get_my_info),
    path('user/bear', get_bears_user_info),
    path('locations/', get_locations),
    path('locations_stats/', get_locations_stats),
]
