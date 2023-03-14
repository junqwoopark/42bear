from django.urls import path
from .views import login
from .views import get_my_info
from .views import get_user_info
from .views import get_log
from .views import user

urlpatterns = [
    path('login/', login),
    path('user/', get_my_info),
    path('user/bear', get_bears_user_info)
    path('user/<str:login>/', get_user_info),
    path('log/', get_log),
]
