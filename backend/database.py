from pymongo import MongoClient
from config import MONGODB_URI, DB_NAME

class MongoDB:
    def __init__(self):
        self.client = None
        self.db = None
        self.connect()

    def connect(self):
        try:
            self.client = MongoClient(MONGODB_URI)
            self.db = self.client[DB_NAME]
            print(f"Connected to MongoDB: {DB_NAME}")
        except Exception as e:
            print(f"Error connecting to MongoDB: {e}")
            raise

    def close(self):
        if self.client:
            self.client.close()
            print("MongoDB connection closed")

    def get_collection(self, collection_name):
        return self.db[collection_name]

# Create a global database instance
db = MongoDB() 