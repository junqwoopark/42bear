import requests
import os
import jwt

from dotenv import load_dotenv
from .my_db import add_user, get_user

from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view

load_dotenv()

# Create your views here.
@api_view(['GET'])
def login(request):
    code = request.GET.get('code')

    # 42 API 애플리케이션 정보
    client_id = os.getenv('CLIENT_ID')
    client_secret = os.getenv('CLIENT_SECRET')

    data = {
        'grant_type': 'authorization_code',
        'client_id': client_id,
        'client_secret': client_secret,
        'code': code,
        'redirect_uri': 'http://localhost:8000/api/login/',
        'scope': 'public'
    }
    response = requests.post('https://api.intra.42.fr/oauth/token', data=data)

    # 토큰 정보
    token = jwt.encode(response.json(), client_secret, algorithm='HS256')

    # 디코드
    decoded = jwt.decode(token, client_secret, algorithms=['HS256'])

    return Response({'token': token, 'decode': decoded})

@api_view(['GET'])
def get_my_info(request):
    token = request.GET.get('token')
    decoded = jwt.decode(token, os.getenv('CLIENT_SECRET'), algorithms=['HS256'])

    access_token = decoded['access_token']

    response = requests.get('https://api.intra.42.fr/v2/me', headers={'Authorization': f'Bearer {access_token}'})

    return Response(response.json())

@api_view(['GET'])
def get_user_info(request, login):
    token = request.GET.get('token')
    decoded = jwt.decode(token, os.getenv('CLIENT_SECRET'), algorithms=['HS256'])

    access_token = decoded['access_token']
    response = requests.get(f'https://api.intra.42.fr/v2/users/{login}', headers={'Authorization': f'Bearer {access_token}'})
    return Response(response.json())

@api_view(['GET'])
def get_log(request):
    token = request.GET.get('token')
    decoded = jwt.decode(token, os.getenv('CLIENT_SECRET'), algorithms=['HS256'])

    access_token = decoded['access_token']
    # response = requests.get(f'https://api.intra.42.fr/v2/users/junkpark/locations_stats', headers={'Authorization': f'Bearer {access_token}'})
    # location stats
    response = requests.get(f'https://api.intra.42.fr/v2/users/junkpark/locations_stats', headers={'Authorization': f'Bearer {access_token}'})
    return Response(response.json())

@api_view(['GET'])
def get_bears_user_info(request):
    intra_id = request.GET.get('id', None)
    return Response(get_user(intra_id))

