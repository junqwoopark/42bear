from django.urls import path
from .views import login
from .views import get_my_info
from .views import get_user_time
from .views import get_bears_user_info
from .views import get_user

urlpatterns = [
    path('login/', login),
    path('user/', get_bears_user_info),
    path('user/time/', get_user_time),
    # path('locations_stats/', get_locations_stats),
    # path('locations/status', get_user_status),
]
