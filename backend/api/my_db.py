import firebase_admin
from firebase_admin import credentials
import os
from firebase_admin import db

db_url = 'https://bear-79eaf-default-rtdb.firebaseio.com/'

if __name__ != '__main__':
    cred = credentials.Certificate("api/bear_admin.json")
else:
    path = os.path.join(os.path.dirname(__file__), 'bear_admin.json')
    cred = credentials.Certificate(path)
firebase_admin.initialize_app(cred, {
    'databaseURL' : db_url
})

def add_user(intra_id):
    user_info = db.reference('User/'+intra_id) #기본 위치 지정
    user_info.set({'intra_id': intra_id,
                   'target_time' : 0,
                   'avatar' : 'polar',
                   'pet' : 'default'})
    return (user_info.get())

def get_user(intra_id):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    if user_info.get() is None:
        return (add_user(intra_id))
    return (user_info.get())

def update_user(intra_id,  avatar = None, target_time = None,pet = None):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    if target_time:
        user_info.update({'target_time' : target_time})
    if avatar:
        user_info.update({'avatar' : avatar})
    if pet:
        user_info.update({'pet' : pet})
    return user_info.get()


if __name__ == '__main__':
    print(get_user('subcho'))
