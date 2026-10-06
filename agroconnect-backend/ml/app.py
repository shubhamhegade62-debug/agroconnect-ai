from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import os
import json
import numpy as np
from PIL import Image
import tensorflow as tf

app = Flask(__name__)
CORS(app)

# ============================================================
# PATHS
# ============================================================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

CROP_MODEL_PATH = os.path.join(
    BASE_DIR, "crop_model.pkl"
)

DISEASE_MODEL_PATH = os.path.join(
    BASE_DIR, "models", "plant_disease_model.keras"
)

CLASS_NAMES_PATH = os.path.join(
    BASE_DIR, "models", "class_names.json"
)


# ============================================================
# LOAD CROP MODEL
# ============================================================

crop_model = joblib.load(CROP_MODEL_PATH)

print("Crop recommendation model loaded successfully!")


# ============================================================
# LOAD DISEASE MODEL
# ============================================================

disease_model = None
class_names = []

if os.path.exists(DISEASE_MODEL_PATH):

    print("Loading plant disease model...")

    disease_model = tf.keras.models.load_model(
        DISEASE_MODEL_PATH
    )

    print("Plant disease model loaded successfully!")

else:

    print("WARNING: Disease model not found!")


# ============================================================
# LOAD CLASS NAMES
# ============================================================

if os.path.exists(CLASS_NAMES_PATH):

    with open(
        CLASS_NAMES_PATH,
        "r",
        encoding="utf-8"
    ) as file:

        class_names = json.load(file)

    print(
        f"Plant disease classes loaded: {len(class_names)}"
    )

else:

    print("WARNING: class_names.json not found!")


# ============================================================
# HOME
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "success": True,
        "message": "AgroConnect AI API is running",
        "crop_model": True,
        "disease_model": disease_model is not None,
        "disease_classes": len(class_names)
    })


# ============================================================
# CROP RECOMMENDATION
# ============================================================

@app.route("/predict", methods=["POST"])
def predict():

    try:

        data = request.get_json()

        N = float(data["N"])
        P = float(data["P"])
        K = float(data["K"])
        temperature = float(data["temperature"])
        humidity = float(data["humidity"])
        ph = float(data["ph"])
        rainfall = float(data["rainfall"])

        input_data = [[
            N,
            P,
            K,
            temperature,
            humidity,
            ph,
            rainfall
        ]]

        prediction = crop_model.predict(
            input_data
        )[0]

        return jsonify({
            "success": True,
            "recommended_crop": str(prediction)
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "error": str(e)
        }), 400


# ============================================================
# PLANT DISEASE PREDICTION
# ============================================================

@app.route("/predict-disease", methods=["POST"])
def predict_disease():

    try:

        if disease_model is None:

            return jsonify({
                "success": False,
                "error": "Plant disease model is not loaded."
            }), 500

        if "image" not in request.files:

            return jsonify({
                "success": False,
                "error": "No image uploaded. Use field name 'image'."
            }), 400

        file = request.files["image"]

        if file.filename == "":

            return jsonify({
                "success": False,
                "error": "No image selected."
            }), 400

        # Open image
        image = Image.open(
            file.stream
        ).convert("RGB")

        # Resize
        image = image.resize(
            (224, 224)
        )

        # Convert to NumPy
        image_array = np.array(
            image,
            dtype=np.float32
        )

        # MobileNetV2 preprocessing
        image_array = (
            image_array / 127.5
        ) - 1.0

        # Add batch dimension
        image_array = np.expand_dims(
            image_array,
            axis=0
        )

        # Prediction
        predictions = disease_model.predict(
            image_array,
            verbose=0
        )

        probabilities = predictions[0]

        predicted_index = int(
            np.argmax(probabilities)
        )

        confidence = float(
            probabilities[predicted_index]
        )

        # Get class
        if predicted_index < len(class_names):

            predicted_class = class_names[
                predicted_index
            ]

        else:

            predicted_class = (
                f"class_{predicted_index}"
            )

        # Separate plant and disease
        if "___" in predicted_class:

            plant_name, disease_name = (
                predicted_class.split(
                    "___",
                    1
                )
            )

        else:

            plant_name = predicted_class
            disease_name = "Unknown"

        return jsonify({

            "success": True,

            "plant": plant_name,

            "disease": disease_name,

            "class_name": predicted_class,

            "confidence": round(
                confidence * 100,
                2
            )
        })

    except Exception as e:

        return jsonify({

            "success": False,

            "error": str(e)

        }), 400


# ============================================================
# START SERVER
# ============================================================

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )