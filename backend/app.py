from flask import Flask, jsonify, request
from flask_cors import CORS
import logging
from database import db
from models.user import User

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/test', methods=['GET'])
def test_connection():
    return jsonify({
        'status': 'Server is running!',
        'database': 'Connected' if db.client else 'Not connected'
    })

@app.route('/users', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        required_fields = ['name', 'phone', 'email', 'location']
        
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400
        
        user = User(
            name=data['name'],
            phone=data['phone'],
            email=data['email'],
            location=data['location'],
            role=data.get('role', 'citizen')
        )
        
        user_id = User.create(user.to_dict())
        return jsonify({'message': 'User created successfully', 'user_id': user_id}), 201
    
    except Exception as e:
        logger.error(f"Error creating user: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    try:
        user = User.find_by_id(user_id)
        if user:
            return jsonify(user), 200
        return jsonify({'error': 'User not found'}), 404
    
    except Exception as e:
        logger.error(f"Error fetching user: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/users/phone/<phone>', methods=['GET'])
def get_user_by_phone(phone):
    try:
        user = User.find_by_phone(phone)
        if user:
            return jsonify(user), 200
        return jsonify({'error': 'User not found'}), 404
    
    except Exception as e:
        logger.error(f"Error fetching user: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/users/<user_id>', methods=['PUT'])
def update_user(user_id):
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No update data provided'}), 400
        
        success = User.update(user_id, data)
        if success:
            return jsonify({'message': 'User updated successfully'}), 200
        return jsonify({'error': 'User not found'}), 404
    
    except Exception as e:
        logger.error(f"Error updating user: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 