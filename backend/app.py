from flask import Flask, jsonify
from flask_cors import CORS
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/test', methods=['GET'])
def test_connection():
    return jsonify({
        'status': 'Server is running!'
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 