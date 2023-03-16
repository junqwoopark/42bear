import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

db_url = 'https://bear-79eaf-default-rtdb.firebaseio.com/'

cred = credentials.Certificate("api/bear_admin.json")
firebase_admin.initialize_app(cred, {
    'databaseURL' : db_url
})

def add_user(intra_id):
    user_info = db.reference('User/'+intra_id) #기본 위치 지정
    user_info.update({'intra_id' : intra_id})
    user_info.update({'target_time' : 0})
    user_info.update({'avatar' : 0})
    user_info.update({'pet': 0})
    return (user_info.get())

def get_user(intra_id):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    if user_info.get() is None: #user 정보가 없을 경우 생성
        return (add_user(intra_id))
    return (user_info.get())

def update_time(intra_id, target_time):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    user_info.update({'target_time' : target_time})
    return (user_info.get())

def update_avatar(intra_id, avatar):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    user_info.update({'avatar' : avatar})
    return (user_info.get())

def update_pet(intra_id, pet):
    dir = db.reference()
    user_info = dir.child('User').child(intra_id)
    user_info.update({'pet' : pet})
    return (user_info.get())


if __name__ == '__main__':
    update_avatar('junkpark', 'gunbear')
    print(get_user('junkpark'))
    # update_user('junkpark', 100)
    # print(get_user('junkpark'))
