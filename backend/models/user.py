from datetime import datetime
from bson import ObjectId
from database import db
from config import USERS_COLLECTION

class User:
    def __init__(self, name, phone, email, location, role="citizen"):
        self.name = name
        self.phone = phone
        self.email = email
        self.location = location
        self.role = role
        self.created_at = datetime.utcnow()

    def to_dict(self):
        return {
            "name": self.name,
            "phone": self.phone,
            "email": self.email,
            "location": self.location,
            "role": self.role,
            "created_at": self.created_at
        }

    @staticmethod
    def create(user_data):
        collection = db.get_collection(USERS_COLLECTION)
        result = collection.insert_one(user_data)
        return str(result.inserted_id)

    @staticmethod
    def find_by_id(user_id):
        collection = db.get_collection(USERS_COLLECTION)
        user = collection.find_one({"_id": ObjectId(user_id)})
        return user

    @staticmethod
    def find_by_phone(phone):
        collection = db.get_collection(USERS_COLLECTION)
        return collection.find_one({"phone": phone})

    @staticmethod
    def update(user_id, update_data):
        collection = db.get_collection(USERS_COLLECTION)
        result = collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": update_data}
        )
        return result.modified_count > 0 