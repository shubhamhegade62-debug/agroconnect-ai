import os
import json
import random
import shutil
from pathlib import Path

import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.callbacks import (
    EarlyStopping,
    ModelCheckpoint,
    ReduceLROnPlateau
)


# ============================================================
# CONFIGURATION
# ============================================================

SOURCE_DIR = Path(
    r"D:\PlantVillage\PlantVillage-Dataset-master\raw\color"
)

ML_DIR = Path(__file__).resolve().parent

SPLIT_DIR = ML_DIR / "dataset" / "plant_disease"

TRAIN_DIR = SPLIT_DIR / "train"
VAL_DIR = SPLIT_DIR / "val"
TEST_DIR = SPLIT_DIR / "test"

MODEL_DIR = ML_DIR / "models"

MODEL_PATH = MODEL_DIR / "plant_disease_model.keras"

CLASS_NAMES_PATH = MODEL_DIR / "class_names.json"

IMAGE_SIZE = (224, 224)

# 8 GB RAM laptop
BATCH_SIZE = 16

TRAIN_RATIO = 0.80
VAL_RATIO = 0.10
TEST_RATIO = 0.10

SEED = 42

INITIAL_EPOCHS = 12


# ============================================================
# GPU / CPU SETUP
# ============================================================

print("\n============================================")
print(" AgroConnect AI - Plant Disease Training")
print("============================================")

print("\nChecking TensorFlow devices...")

gpus = tf.config.list_physical_devices("GPU")

if gpus:

    print("GPU detected:")

    for gpu in gpus:
        print(" ", gpu)

else:

    print("No dedicated GPU detected.")
    print("Training will use CPU.")

# Control CPU usage for 8 GB RAM system
tf.config.threading.set_inter_op_parallelism_threads(2)
tf.config.threading.set_intra_op_parallelism_threads(4)


# ============================================================
# CHECK SOURCE DATASET
# ============================================================

print("\nChecking dataset...")

if not SOURCE_DIR.exists():

    raise FileNotFoundError(
        f"""
Dataset folder not found:

{SOURCE_DIR}

Please check the dataset path.
"""
    )


print("Dataset found:")
print(SOURCE_DIR)


# ============================================================
# FIND CLASSES
# ============================================================

class_names = sorted(
    [
        folder.name
        for folder in SOURCE_DIR.iterdir()
        if folder.is_dir()
    ]
)


print(
    f"\nClasses found: {len(class_names)}"
)


if len(class_names) == 0:

    raise RuntimeError(
        "No class folders found in dataset."
    )


print("\nClasses:")

for index, class_name in enumerate(class_names):

    print(
        f"{index:02d} -> {class_name}"
    )


# ============================================================
# CREATE OUTPUT DIRECTORIES
# ============================================================

for directory in [

    TRAIN_DIR,
    VAL_DIR,
    TEST_DIR,
    MODEL_DIR

]:

    directory.mkdir(
        parents=True,
        exist_ok=True
    )


# ============================================================
# SAVE CLASS NAMES
# ============================================================

with open(
    CLASS_NAMES_PATH,
    "w",
    encoding="utf-8"
) as file:

    json.dump(
        class_names,
        file,
        indent=4,
        ensure_ascii=False
    )


print(
    f"\nClass names saved to:"
    f"\n{CLASS_NAMES_PATH}"
)


# ============================================================
# CREATE TRAIN / VAL / TEST SPLIT
# ============================================================

split_marker = SPLIT_DIR / ".split_complete"


if not split_marker.exists():

    print(
        "\nCreating train / validation / test split..."
    )

    print(
        "This may take some time because there are"
        " approximately 54,305 images."
    )

    random.seed(SEED)

    total_images = 0

    for class_name in class_names:

        source_class_dir = (
            SOURCE_DIR / class_name
        )

        image_files = [

            file

            for file in source_class_dir.iterdir()

            if file.is_file()

            and file.suffix.lower()
            in [".jpg", ".jpeg", ".png"]

        ]

        random.shuffle(image_files)

        total = len(image_files)

        train_count = int(
            total * TRAIN_RATIO
        )

        val_count = int(
            total * VAL_RATIO
        )

        train_files = image_files[
            :train_count
        ]

        val_files = image_files[
            train_count:
            train_count + val_count
        ]

        test_files = image_files[
            train_count + val_count:
        ]


        print(
            f"\n{class_name}"
        )

        print(
            f"Total: {total}"
            f" | Train: {len(train_files)}"
            f" | Val: {len(val_files)}"
            f" | Test: {len(test_files)}"
        )


        destination_dirs = {

            "train":
                TRAIN_DIR / class_name,

            "val":
                VAL_DIR / class_name,

            "test":
                TEST_DIR / class_name

        }


        for destination in (
            destination_dirs.values()
        ):

            destination.mkdir(
                parents=True,
                exist_ok=True
            )


        # Copy training images

        for file in train_files:

            destination = (
                destination_dirs["train"]
                / file.name
            )

            if not destination.exists():

                shutil.copy2(
                    file,
                    destination
                )


        # Copy validation images

        for file in val_files:

            destination = (
                destination_dirs["val"]
                / file.name
            )

            if not destination.exists():

                shutil.copy2(
                    file,
                    destination
                )


        # Copy test images

        for file in test_files:

            destination = (
                destination_dirs["test"]
                / file.name
            )

            if not destination.exists():

                shutil.copy2(
                    file,
                    destination
                )


        total_images += total


    split_marker.write_text(
        "Dataset split completed.",
        encoding="utf-8"
    )


    print(
        "\n============================================"
    )

    print(
        f"Total images processed: {total_images}"
    )

    print(
        "Dataset split completed successfully."
    )

    print(
        "============================================"
    )


else:

    print(
        "\nExisting dataset split found."
    )

    print(
        "Skipping dataset copy."
    )


# ============================================================
# LOAD TRAIN DATASET
# ============================================================

print("\nLoading training dataset...")

train_dataset = tf.keras.utils.image_dataset_from_directory(

    TRAIN_DIR,

    labels="inferred",

    label_mode="int",

    image_size=IMAGE_SIZE,

    batch_size=BATCH_SIZE,

    shuffle=True,

    seed=SEED

)


# ============================================================
# LOAD VALIDATION DATASET
# ============================================================

print("\nLoading validation dataset...")

val_dataset = tf.keras.utils.image_dataset_from_directory(

    VAL_DIR,

    labels="inferred",

    label_mode="int",

    image_size=IMAGE_SIZE,

    batch_size=BATCH_SIZE,

    shuffle=False

)


# ============================================================
# LOAD TEST DATASET
# ============================================================

print("\nLoading test dataset...")

test_dataset = tf.keras.utils.image_dataset_from_directory(

    TEST_DIR,

    labels="inferred",

    label_mode="int",

    image_size=IMAGE_SIZE,

    batch_size=BATCH_SIZE,

    shuffle=False

)


# ============================================================
# VERIFY CLASS ORDER
# ============================================================

dataset_class_names = (
    train_dataset.class_names
)


print(
    "\nDataset class order:"
)

for index, name in enumerate(
    dataset_class_names
):

    print(
        f"{index:02d} -> {name}"
    )


# Save exact class order used by TensorFlow

with open(
    CLASS_NAMES_PATH,
    "w",
    encoding="utf-8"
) as file:

    json.dump(
        dataset_class_names,
        file,
        indent=4,
        ensure_ascii=False
    )


# ============================================================
# PERFORMANCE SETTINGS
# ============================================================

AUTOTUNE = (
    tf.data.AUTOTUNE
)


train_dataset = train_dataset.prefetch(
    AUTOTUNE
)

val_dataset = val_dataset.prefetch(
    AUTOTUNE
)

test_dataset = test_dataset.prefetch(
    AUTOTUNE
)


# ============================================================
# DATA AUGMENTATION
# ============================================================

data_augmentation = tf.keras.Sequential(

    [

        layers.RandomFlip(
            "horizontal"
        ),

        layers.RandomRotation(
            0.08
        ),

        layers.RandomZoom(
            0.10
        ),

        layers.RandomContrast(
            0.10
        )

    ],

    name="data_augmentation"

)


# ============================================================
# BUILD MOBILE NET V2 MODEL
# ============================================================

print(
    "\nBuilding MobileNetV2 model..."
)


base_model = MobileNetV2(

    input_shape=(
        IMAGE_SIZE[0],
        IMAGE_SIZE[1],
        3
    ),

    include_top=False,

    weights="imagenet"

)


# Freeze pretrained layers

base_model.trainable = False


# ============================================================
# MODEL
# ============================================================

inputs = layers.Input(

    shape=(
        IMAGE_SIZE[0],
        IMAGE_SIZE[1],
        3
    )

)


x = data_augmentation(
    inputs
)


# MobileNetV2 preprocessing

x = tf.keras.applications.mobilenet_v2.preprocess_input(
    x
)


x = base_model(
    x,
    training=False
)


x = layers.GlobalAveragePooling2D()(x)


x = layers.Dropout(
    0.30
)(x)


outputs = layers.Dense(

    len(dataset_class_names),

    activation="softmax"

)(x)


model = models.Model(

    inputs=inputs,

    outputs=outputs

)


# ============================================================
# COMPILE MODEL
# ============================================================

model.compile(

    optimizer=tf.keras.optimizers.Adam(
        learning_rate=0.0001
    ),

    loss=(
        "sparse_categorical_crossentropy"
    ),

    metrics=[
        "accuracy"
    ]

)


# ============================================================
# MODEL SUMMARY
# ============================================================

print(
    "\nModel summary:"
)

model.summary()


# ============================================================
# CALLBACKS
# ============================================================

checkpoint = ModelCheckpoint(

    MODEL_PATH,

    monitor="val_accuracy",

    save_best_only=True,

    save_weights_only=False,

    verbose=1

)


early_stopping = EarlyStopping(

    monitor="val_loss",

    patience=3,

    restore_best_weights=True,

    verbose=1

)


reduce_lr = ReduceLROnPlateau(

    monitor="val_loss",

    factor=0.5,

    patience=2,

    min_lr=0.000001,

    verbose=1

)


# ============================================================
# TRAIN MODEL
# ============================================================

print(
    "\n============================================"
)

print(
    "Starting disease model training..."
)

print(
    f"Epochs: {INITIAL_EPOCHS}"
)

print(
    f"Batch size: {BATCH_SIZE}"
)

print(
    f"Classes: {len(dataset_class_names)}"
)

print(
    "============================================\n"
)


history = model.fit(

    train_dataset,

    validation_data=val_dataset,

    epochs=INITIAL_EPOCHS,

    callbacks=[

        checkpoint,

        early_stopping,

        reduce_lr

    ]

)


# ============================================================
# LOAD BEST MODEL
# ============================================================

print(
    "\nLoading best saved model..."
)

best_model = tf.keras.models.load_model(
    MODEL_PATH
)


# ============================================================
# TEST MODEL
# ============================================================

print(
    "\n============================================"
)

print(
    "Evaluating model on test dataset..."
)

print(
    "============================================"
)


test_loss, test_accuracy = (
    best_model.evaluate(
        test_dataset,
        verbose=1
    )
)


print(
    "\n============================================"
)

print(
    f"Test Loss: {test_loss:.4f}"
)

print(
    f"Test Accuracy: {test_accuracy * 100:.2f}%"
)

print(
    "============================================"
)


# ============================================================
# SAVE FINAL MODEL
# ============================================================

best_model.save(
    MODEL_PATH
)


print(
    "\nModel saved successfully:"
)

print(
    MODEL_PATH
)


print(
    "\nClass names saved successfully:"
)

print(
    CLASS_NAMES_PATH
)


print(
    "\n============================================"
)

print(
    "TRAINING COMPLETED"
)

print(
    "============================================"
)