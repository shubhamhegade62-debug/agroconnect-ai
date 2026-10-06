
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"
MODEL = "qwen2.5:3b"

SYSTEM_PROMPT = """
तू AgroConnect AI आहेस.
तू भारतीय शेतकऱ्यांचा friendly agriculture assistant आहेस.

नियम:
- शेतकऱ्याशी सोप्या आणि नैसर्गिक मराठीत बोल.
- प्रश्न अपुरा असेल तर योग्य follow-up questions विचार.
- practical आणि उपयोगी उत्तर दे.
- फोटो किंवा AI scan result दिल्यास त्याचा आधार घे.
- रोग निश्चित नसताना खात्रीने रोग सांगू नको.
- औषधाचा अंदाजे dosage बनवू नको.
- शक्य तितके concise उत्तर दे.
"""


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "success": True,
        "message": "AgroConnect AI Server is running",
        "model": MODEL
    })


@app.route("/ai/chat", methods=["POST"])
def chat():

    data = request.get_json()

    if data is None:
        return jsonify({
            "success": False,
            "error": "Invalid JSON"
        }), 400

    message = data.get("message")

    if not message:
        return jsonify({
            "success": False,
            "error": "message is required"
        }), 400

    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "system",
                "content": SYSTEM_PROMPT
            },
            {
                "role": "user",
                "content": message
            }
        ],
        "stream": False
    }

    try:

        response = requests.post(
            OLLAMA_URL,
            json=payload,
            timeout=120
        )

        response.raise_for_status()

        result = response.json()

        answer = result["message"]["content"]

        return jsonify({
            "success": True,
            "reply": answer
        })

    except requests.exceptions.ConnectionError:

        return jsonify({
            "success": False,
            "error": "Ollama server चालू नाही."
        }), 500

    except requests.exceptions.Timeout:

        return jsonify({
            "success": False,
            "error": "AI response timeout झाला."
        }), 500

    except Exception as e:

        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


if __name__ == "__main__":

    print("====================================")
    print("     AgroConnect AI Server")
    print("     Ollama + Qwen 2.5 3B")
    print("====================================")
    print("Server: http://10.100.96.4:5001")
    print("")

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=False
    )

