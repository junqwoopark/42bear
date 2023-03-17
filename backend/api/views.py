import requests
import os
import jwt
from datetime import datetime, timedelta
import json
import dateutil.parser

from dotenv import load_dotenv
from .my_db import add_user, get_user, update_user

from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.renderers import JSONRenderer
from rest_framework.decorators import renderer_classes

load_dotenv()

def decode_token(token):
    decoded = jwt.decode(token, os.getenv('CLIENT_SECRET'), algorithms=['HS256'])
    return decoded['access_token'], decoded['refresh_token'], decoded['login']

def get_new_token(refresh_token, login):
    data = {
        'grant_type': 'refresh_token',
        'client_id': os.getenv('CLIENT_ID'),
        'client_secret': os.getenv('CLIENT_SECRET'),
        'refresh_token': refresh_token,
    }
    response = requests.post('https://api.intra.42.fr/oauth/token', data=data)
    data = response.json()
    data['login'] = login
    if response.status_code == 200:
        return data
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
        'redirect_uri': 'bear://callback',
    }
    print(code)
    response = requests.post('https://api.intra.42.fr/oauth/token', data=data)
    print("HERE", response.json())
    data = response.json()
    if response.status_code != 200:
        return Response(status=response.status_code, data=response.json())
    else:
        data = response.json()
        data['login'] = requests.get(
            'https://api.intra.42.fr/v2/me', headers={'Authorization': f'Bearer {data["access_token"]}'}).json()['login']
        token = jwt.encode(data, client_secret, algorithm='HS256')
        return Response({'token': token, 'login': data['login']})

# 유저 정보!!!
@api_view(['GET'])
def get_my_info(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
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
            return Response(status=201, data=data)
        else:
            return Response(status=501, data={'error': 'access_token 갱신 실패', 'message': '로그인을 다시 해주세요.'})
    else:
        return Response(status=response.status_code, data=response.json())

@api_view(['GET'])
def get_locations_stats(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    client_id = os.getenv('CLIENT_ID')
    client_secret = os.getenv('CLIENT_SECRET')
    response  = requests.post("https://api.intra.42.fr/oauth/token", data={
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret})
    access_token = response.json()['access_token']

    response = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations_stats', headers={'Authorization': f'Bearer {access_token}'})
    return Response(response.json())

@api_view(['GET'])
def get_user_time(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
        print(access_token, refresh_token, login)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    # API 요청
    response = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations', headers={'Authorization': f'Bearer {access_token}'})
    if response.status_code != 200:
        new_token = get_new_token(refresh_token, login)

        if new_token:
            access_token = new_token['access_token']
            response = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations', headers={'Authorization': f'Bearer {access_token}'})
            time = get_today_intra_time(response.json())

            token = jwt.encode(new_token, os.getenv('CLIENT_SECRET'), algorithm='HS256')
            return Response(status=201, data={'time': str(time), 'second': time.seconds , 'token': token})
        else:
            return Response(status=501, data={'error': 'access_token 갱신 실패', 'message': '로그인을 다시 해주세요.'})
    else:
        time = get_today_intra_time(response.json())
        return Response(status=200, data={'time': str(time), 'second': time.seconds})

@api_view(['GET', 'PATCH'])
def get_bears_user_info(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})
    if (request.method == 'GET'):
        print("GETTTTTTTTTTTTTTT")
        return Response(status=200, data=get_user(login))
    elif request.method == 'PATCH':
        data = json.loads(request.body.decode('utf-8'))

        login = data.get('login', None)
        avatar = data.get('avatar', None)
        target_time = data.get('target_time', None)
        pet = data.get('pet', None)
        # print type(login), type(avatar), type(target_time), type(pet)
        print(type(login), type(avatar), type(target_time), type(pet))
        print(login, avatar, target_time, pet)
        update_user(login, avatar, target_time, pet)
        return Response(status=200, data=get_user(login))

# @api_view(['FETCH'])
# def get_bears_user_info(request):
#     print("fetch_bears_user_info")
#     try:
#         token = request.GET.get('token')
#         access_token, refresh_token, login = decode_token(token)
#     except Exception:
#         return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})
#     # body에서 login, avartar, target_time, pet 가져 오기
#     login = request.data['login']
#     avatar = request.data['avatar']
#     target_time = request.data['target_time']
#     pet = request.data['pet']
#     update_user(login, avatar, target_time, pet)
#     return Response(status=200, data={get_user(login)})

@api_view(['GET'])
def get_locations_stats(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    client_id = os.getenv('CLIENT_ID')
    client_secret = os.getenv('CLIENT_SECRET')
    response  = requests.post("https://api.intra.42.fr/oauth/token", data={
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret})
    access_token = response.json()['access_token']

    response = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations_stats', headers={'Authorization': f'Bearer {access_token}'})
    return Response(response.json())

@api_view(['GET'])
def get_user_status(request):
    try:
        token = request.GET.get('token')
        access_token, refresh_token, login = decode_token(token)
    except Exception:
        return Response(status=401, data={'error': 'decode_token error.', 'message': '토큰이 잘못되었습니다.'})

    # API 요청
    response = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations', headers={'Authorization': f'Bearer {access_token}'})

    # 만약 response.status_code가 200이 아니면, access_token이 만료되었을 것임.
    if response.status_code != 200:
        new_token = get_new_token(refresh_token)

        if new_token:
            access_token = new_token['access_token']
            data = requests.get(f'https://api.intra.42.fr/v2/users/{login}/locations', headers={'Authorization': f'Bearer {access_token}'}).json()
            data['token'] = jwt.encode(new_token, os.getenv('CLIENT_SECRET'), algorithm='HS256')
            return Response(status=200, data=data)
        else:
            return Response(status=501, data={'error': 'access_token 갱신 실패', 'message': '로그인을 다시 해주세요.'})
    else:
        status = False
        if response.json()[0]['end_at'] == None:
            status = True
        return Response(status=response.status_code, data={'status': status})


def get_today_intra_time(locations):
    i = 0
    get_items = locations
    # seoul 시간 가져와줘
    today = datetime.now()
    time = datetime(today.date().year, today.date().month, today.date().day)
    total_time = time

    while 1:
        end_time = get_items[i]['end_at']
        begin_time = dateutil.parser.isoparse(get_items[i]['begin_at']).replace(tzinfo=None) + timedelta(hours=9)
        if end_time == None:
            # 현재 자리에 있음!
            # begin_at이 오늘 날짜일 경우 더해주고 i++
            if begin_time.date() == today.date():
                total_time += (today - begin_time)
            # begin_at이 어제일 경우 현재 시간 더해주고 break
            elif begin_time.date() == today.date() - timedelta(days = 1):
                total_time += today.time()
                break
        else:
            end_time = dateutil.parser.isoparse(get_items[i]['end_at']).replace(tzinfo=None) + timedelta(hours=9)
            if end_time.date() != today.date():
                # end_time이 오늘 날짜가 아니면 break
                break
            else:
                if begin_time.date() == today.date() - timedelta(days = 1):
                    total_time += (end_time - time)
                    break
                else:
                    total_time += (end_time - begin_time)
        i += 1
    return (total_time - time)

