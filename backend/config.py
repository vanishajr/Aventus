import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB Configuration
MONGODB_URI = os.getenv('MONGODB_URI', 'mongodb://localhost:27017/')
DB_NAME = os.getenv('DB_NAME', 'disaster_management')

# Collections
USERS_COLLECTION = 'users'
DISASTERS_COLLECTION = 'disasters'
EMERGENCY_CONTACTS_COLLECTION = 'emergency_contacts' 