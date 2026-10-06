import os
import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


# Project folder
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Dataset path
DATASET_PATH = os.path.join(
    BASE_DIR,
    "dataset",
    "crop_data.csv"
)

# Model save path
MODEL_PATH = os.path.join(
    BASE_DIR,
    "crop_model.pkl"
)


print("Loading dataset...")

# Load CSV
df = pd.read_csv(DATASET_PATH)

print("Dataset loaded successfully!")
print("Rows:", len(df))
print("Columns:", list(df.columns))


# Input columns
features = [
    "N",
    "P",
    "K",
    "temperature",
    "humidity",
    "ph",
    "rainfall"
]

# X = input data
X = df[features]

# y = crop name
y = df["label"]


# Split dataset
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)


print("Training model...")





# Random Forest model
model = RandomForestClassifier(
    n_estimators=200,
    random_state=42
)

# Train
model.fit(X_train, y_train)


# Test
predictions = model.predict(X_test)

accuracy = accuracy_score(
    y_test,
    predictions
)


print()
print("================================")
print("MODEL TRAINED SUCCESSFULLY")
print("================================")
print("Accuracy:", round(accuracy * 100, 2), "%")


# Save model
joblib.dump(model, MODEL_PATH)

print()
print("Model saved successfully!")
print("File:", MODEL_PATH)