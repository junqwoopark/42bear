import requests
import os
import jwt

from dotenv import load_dotenv
from .my_db import add_user, get_user

from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view

load_dotenv()

def decode_token(token):
    decoded = jwt.decode(token, os.getenv('CLIENT_SECRET'), algorithms=['HS256'])
    return decoded['access_token'], decoded['refresh_token']

def get_new_token(refresh_token):
    data = {
        'grant_type': 'refresh_token',
        'client_id': os.getenv('CLIENT_ID'),
        'client_secret': os.getenv('CLIENT_SECRET'),
        'refresh_token': refresh_token,
    }
    response = requests.post('https://api.intra.42.fr/oauth/token', data=data)
    if response.status_code == 200:
        return response.json()
    else:
        return None

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
    }
    response = requests.post('https://api.intra.42.fr/oauth/token', data=data)

    if response.status_code != 200:
        return Response(status=response.status_code, data=response.json())
    else:
        token = jwt.encode(response.json(), client_secret, algorithm='HS256')
        return Response({'token': token})

# 유저 정보!!!
@api_view(['GET'])
def get_my_info(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    # API 요청
    response = requests.get('https://api.intra.42.fr/v2/me', headers={'Authorization': f'Bearer {access_token}'})

    # 만약 response.status_code가 200이 아니면, access_token이 만료되었을 것임.
    if response.status_code != 200:
        new_token = get_new_token(refresh_token)

        if new_token:
            access_token = new_token['access_token']
            data = requests.get('https://api.intra.42.fr/v2/me', headers={'Authorization': f'Bearer {access_token}'}).json()
            data['token'] = jwt.encode(new_token, os.getenv('CLIENT_SECRET'), algorithm='HS256')
            return Response(status=200, data=data)
        else:
            return Response(status=501, data={'error': 'access_token 갱신 실패', 'message': '로그인을 다시 해주세요.'})
    else:
        return Response(status=response.status_code, data=response.json())

@api_view(['GET'])
def get_locations_stats(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    client_id = os.getenv('CLIENT_ID')
    client_secret = os.getenv('CLIENT_SECRET')
    response  = requests.post("https://api.intra.42.fr/oauth/token", data={
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret})
    access_token = response.json()['access_token']

    response = requests.get(f'https://api.intra.42.fr/v2/users/junkpark/locations_stats', headers={'Authorization': f'Bearer {access_token}'})
    return Response(response.json())

@api_view(['GET'])
def get_locations(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    # API 요청
    response = requests.get('https://api.intra.42.fr/v2/users/junkpark/locations', headers={'Authorization': f'Bearer {access_token}'})

    # 만약 response.status_code가 200이 아니면, access_token이 만료되었을 것임.
    if response.status_code != 200:
        new_token = get_new_token(refresh_token)

        if new_token:
            access_token = new_token['access_token']
            data = requests.get('https://api.intra.42.fr/v2/users/junkpark/locations', headers={'Authorization': f'Bearer {access_token}'}).json()
            data['token'] = jwt.encode(new_token, os.getenv('CLIENT_SECRET'), algorithm='HS256')
            return Response(status=200, data=data)
        else:
            return Response(status=501, data={'error': 'access_token 갱신 실패', 'message': '로그인을 다시 해주세요.'})
    else:
        return Response(status=response.status_code, data=response.json())

@api_view(['GET'])
def get_bears_user_info(request):
    intra_id = request.GET.get('id', None)
