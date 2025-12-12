import base64
from flask import Flask, request, jsonify
import os
import requests

app = Flask(__name__)

ROBOFLOW_API_URL = os.getenv("ROBOFLOW_API_URL", "[https://serverless.roboflow.com](https://serverless.roboflow.com)")
ROBOFLOW_API_KEY = os.getenv("ROBOFLOW_API_KEY", "rqEUCjFbHaJ6mOCbhOx2")
WORKSPACE_NAME = "grfgf"
WORKFLOW_ID = "blur_faces-2"

ROBOFLOW_ENDPOINT = f"{ROBOFLOW_API_URL}/{WORKSPACE_NAME}/{WORKFLOW_ID}?api_key={ROBOFLOW_API_KEY}"

@app.route('/api/blur_faces', methods=['POST'])
def get_recommendation():
  try:
    data = request.json
    image_b64 = data.get('image_base64')

    if not image_b64:
      return jsonify({"error": "No image_base64 provided"}), 400
    
    json_payload = {
      "image": image_b64
    }

    response = requests.post(
      ROBOFLOW_ENDPOINT,
      json=json_payload,
      headers={'Content-Type': 'application/json'}
    )

    response.raise_for_status()

    return jsonify({
      "status": "success",
      "blur_face_data": response.json()
    })
  
  except requests.exceptions.HTTPError as http_err:
    status_code = response.status_code if 'response' in locals() else 500
    error_detail = response.json() if 'response' in locals() and response.text else str(http_err)
    app.logger.error(f"Roboflow API HTTP Error ({status_code}): {error_detail}")
    return jsonify({"error": f"Roboflow API HTTP Error: {error_detail}"}), status_code
  
  except Exception as e:
    app.logger.error(f"Internal Error during inference: {e}")
    return jsonify({"error": f"Internal Server Error: {e}"}), 500
  
if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000)