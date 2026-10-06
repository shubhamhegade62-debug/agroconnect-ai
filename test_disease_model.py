import json
import numpy as np
import tensorflow as tf
from PIL import Image


# ============================================================
# PATHS
# ============================================================

MODEL_PATH = "models/plant_disease_model.keras"

CLASS_NAMES_PATH = "models/class_names.json"

IMAGE_PATH = r"D:\PlantVillage\PlantVillage-Dataset-master\raw\color\Apple___Apple_scab\00075aa8-d81a-4184-8541-b692b78d398a___FREC_Scab 3335.JPG"


# ============================================================
# LOAD MODEL
# ============================================================

print("\nLoading disease model...")

model = tf.keras.models.load_model(
    MODEL_PATH
)

print("Model loaded successfully!")


# ============================================================
# LOAD CLASS NAMES
# ============================================================

with open(
    CLASS_NAMES_PATH,
    "r",
    encoding="utf-8"
) as file:

    class_names = json.load(file)


print(
    f"Classes loaded: {len(class_names)}"
)


# ============================================================
# LOAD IMAGE
# ============================================================

print("\nLoading image...")

image = Image.open(
    IMAGE_PATH
).convert("RGB")


print(
    "Original image size:",
    image.size
)


# ============================================================
# RESIZE
# ============================================================

image = image.resize(
    (224, 224)
)


# ============================================================
# NUMPY
# ============================================================

image_array = np.array(
    image,
    dtype=np.float32
)


# ============================================================
# MOBILENETV2 PREPROCESSING
# ============================================================

image_array = (
    image_array / 127.5
) - 1.0


# ============================================================
# BATCH DIMENSION
# ============================================================

image_array = np.expand_dims(
    image_array,
    axis=0
)


# ============================================================
# PREDICTION
# ============================================================

print("\nRunning prediction...")

predictions = model.predict(
    image_array,
    verbose=0
)[0]


# ============================================================
# TOP 5
# ============================================================

top_indices = np.argsort(
    predictions
)[-5:][::-1]


print("\n============================================")
print(" TOP 5 DISEASE PREDICTIONS")
print("============================================")


for rank, index in enumerate(
    top_indices,
    start=1
):

    confidence = (
        predictions[index] * 100
    )

    print(
        f"{rank}. "
        f"{class_names[index]} "
        f"-> "
        f"{confidence:.2f}%"
    )


print("============================================")


# ============================================================
# EXPECTED CLASS
# ============================================================

expected_class = "Apple___Apple_scab"

expected_index = (
    class_names.index(
        expected_class
    )
)


print(
    "\nExpected class:"
)

print(
    expected_class
)

print(
    "Expected class index:",
    expected_index
)

print(
    "Expected class probability:",
    f"{predictions[expected_index] * 100:.4f}%"
)

print(
    "\nDiagnostic completed."
)