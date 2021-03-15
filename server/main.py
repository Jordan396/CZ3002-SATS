from flask import Flask, request, jsonify
import os
from config import config
import shutil
import logging
import requests
import face_recognition
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud import storage

# TODO: Indicate execution environment
# Local: 0
# Google Cloud Platform: 1
execution_environment = 0

# Create logger
logging.basicConfig(filename='./main.log', level=logging.INFO)

# Load application credentials
logging.info("Execution environment: %d" % execution_environment)
if (execution_environment == 0):
    # Use a service account
    cred = credentials.Certificate(config.SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred)
    # Set google application credentials for google client api
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = config.SERVICE_ACCOUNT_FILE
    logging.info(
        "Firebase admin app initialization successful: From service account.")
elif (execution_environment == 1):
    # Use the application default credentials
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {'projectId': project_id})
    logging.info(
        "Firebase admin app initialization successful: From default credentials."
    )
else:
    logging.info("Invalid execution environment.")
    sys.exit()

# Instantiate firestore client
logging.info("Creating firestore clients...")
db = firestore.client()
bucket = storage.Client().get_bucket(config.BUCKET_NAME)
logging.info("Firestore clients created.")

# Clear file storage
path = "./tmp"
logging.info("Clearing file storage...")
try:
    shutil.rmtree(path, ignore_errors=False)
except:
    pass
logging.info("Creating directory: %s" % path)
os.mkdir(path)
os.mkdir(path + "/classes")
os.mkdir(path + "/uploads")
logging.info("Directory created.")

# Start flask web server
logging.info("Creating instance of Flask app...")
app = Flask(__name__)


def create_directory_for_images(path):
    logging.info("Clearing directory if exists...")
    try:
        shutil.rmtree(path, ignore_errors=False)
    except:
        pass
    logging.info("Creating directory: %s" % path)
    os.mkdir(path)
    logging.info("Directory created.")
    return path


def delete_directory_for_images(path):
    logging.info("Clearing directory if exists...")
    try:
        shutil.rmtree(path, ignore_errors=False)
    except:
        pass
    return path


def download_images_from_gcs(students, path):
    logging.info("Commencing download of images...")
    for idx, val in enumerate(students):
        # Create a blob object from the filepath
        blob = bucket.blob(val["image"])
        # Download the file to a destination
        blob.download_to_filename(path + "/" + val["matric"] + ".jpeg")
    logging.info("Images downloaded.")


def compare_images(unverified_image, class_path):
    class_files = [
        f for f in os.listdir(class_path)
        if os.path.isfile(os.path.join(class_path, f))
    ]
    unknown_image = face_recognition.load_image_file(unverified_image)
    unknown_encoding = face_recognition.face_encodings(unknown_image)
    # Note that we only compare the first element in unknown_encoding and known_encoding
    # This means that images must only contain ONE face 
    if unknown_encoding:
        for file in class_files:
            known_image = face_recognition.load_image_file(class_path + "/" + file)
            known_encoding = face_recognition.face_encodings(known_image)
            if known_encoding:
                results = face_recognition.compare_faces([known_encoding[0]],
                                                    unknown_encoding[0])
                if results[0]:
                    return True, file
    return False, None


@app.route('/classes/init', methods=['POST'])
def initialize_class_handler():
    content = request.json
    class_id = request.args.get('class')
    class_path = "./tmp/classes/" + class_id
    create_directory_for_images(class_path)
    download_images_from_gcs(content["students"], class_path)
    return jsonify(result=True)


@app.route('/attendance/submit', methods=['POST'])
def submit_attendance_handler():
    content = request.json
    class_id = request.args.get('class')
    class_path = "./tmp/classes/" + class_id
    # Check if path exists
    if os.path.isdir(class_path):
        # check if the post request has the file part
        if 'image' not in request.files:
            logging.info("No image file attached.")
            return "No image file attached."
        uploaded_file = request.files["image"]
        if uploaded_file:
            unverified_image = "./tmp/uploads/" + uploaded_file.filename
            uploaded_file.save(unverified_image)
            is_match_found, verified_image = compare_images(
                unverified_image, class_path)
            if is_match_found:
                if verified_image.endswith('.jpeg'):
                    verified_image_matric = verified_image[:-5]
                    return jsonify(status="Success",
                                match=True,
                                matric=verified_image_matric)
            else:
                return jsonify(status="Success", match=False)
        else:
            logging.info("No image file attached.")
            return jsonify(status="Failed", messege="No image file attached.")
    else:
        logging.info("Directory not initialized.")
        return jsonify(status="Failed", messege="Class not initialized.")


@app.route('/classes/terminate', methods=['POST'])
def terminate_class_handler():
    content = request.json
    class_id = request.args.get('class')
    class_path = "./tmp/classes/" + class_id
    delete_directory_for_images(class_path)
    return jsonify(result=True)


app.run(host='0.0.0.0', debug=True)
