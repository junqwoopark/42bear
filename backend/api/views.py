from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.decorators import api_view


# Create your views here.
@api_view(['GET'])
def login(request, ):
    return Response({'message': 'Hello, World!'})
