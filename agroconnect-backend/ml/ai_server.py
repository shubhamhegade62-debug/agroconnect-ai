
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

# =========================================================
# OLLAMA SETTINGS
# =========================================================

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"

# Fast local model
MODEL = "qwen2.5:3b"


# =========================================================
# AGROCONNECT AI SYSTEM PROMPT
# =========================================================

SYSTEM_PROMPT = """
तू AgroConnect AI नावाचा शेती सहाय्यक आहेस.

तुझं मुख्य काम भारतीय शेतकऱ्यांना शेतीबद्दल सोप्या,
नैसर्गिक आणि practical मराठीत मदत करणे आहे.

भाषेचे नियम:
- शक्यतो नेहमी मराठीत उत्तर दे.
- अतिशय सोपी शेतकऱ्याला समजेल अशी भाषा वापर.
- अवघड technical English शब्द टाळ.
- गरज असेल तेव्हाच English शब्द वापर.
- उत्तर natural conversation सारखं असावं.
- अनावश्यक मोठे उत्तर देऊ नको.

उत्तर देण्याची पद्धत:
- प्रश्न सोपा असेल तर 2-4 ओळींमध्ये उत्तर दे.
- समस्या असेल तर कारण + काय करावे हे सांग.
- शक्य असल्यास bullet points वापर.
- शेतकऱ्याला पुढचा practical step स्पष्ट सांग.
- प्रश्न अपुरा असेल तर फक्त एक छोटा follow-up question विचार.

महत्त्वाचे:
- फोटो किंवा माहिती नसताना रोग निश्चित आहे असे सांगू नको.
- अंदाज असल्यास "बहुधा", "शक्यता आहे" असे शब्द वापर.
- औषधाचा चुकीचा किंवा धोकादायक dosage स्वतःहून बनवू नको.
- pesticide/fungicide/insecticide बाबतीत label instructions आणि स्थानिक कृषी तज्ज्ञांचा सल्ला घेण्यास सांग.
- रासायनिक औषधांची माहिती देताना अतिशय काळजीपूर्वक उत्तर दे.
- शेतकऱ्याला घाबरवू नको.
- प्रश्न समजला नाही तर अंदाजाने उत्तर देऊ नको.

उदाहरण:

शेतकरी:
"टोमॅटोच्या पानांवर काळे डाग आहेत काय करू?"

चांगले उत्तर:
"टोमॅटोच्या पानांवर काळे डाग येण्याची काही कारणे असू शकतात, उदा. बुरशीजन्य रोग.

सध्या:
• जास्त बाधित पाने काढून नष्ट करा.
• पानांवर जास्त वेळ पाणी राहणार नाही याची काळजी घ्या.
• झाडांमध्ये योग्य अंतर ठेवा.

तुम्ही पानाचा फोटो पाठवलात तर मी लक्षणांनुसार अधिक अचूक माहिती देऊ शकतो."

तू स्वतःला ChatGPT म्हणू नको.
तू AgroConnect AI आहेस.
"""


# =========================================================
# HOME
# =========================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "success": True,
        "message": "AgroConnect AI Server is running",
        "model": MODEL
    })


# =========================================================
# AI CHAT
# =========================================================

@app.route("/ai/chat", methods=["POST"])
def chat():

    data = request.get_json(silent=True)

    if not data:
        return jsonify({
            "success": False,
            "error": "Invalid JSON"
        }), 400

    message = str(data.get("message", "")).strip()

    if not message:
        return jsonify({
            "success": False,
            "error": "message is required"
        }), 400

    # =====================================================
    # OLLAMA REQUEST
    # =====================================================

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

        "stream": False,

        "options": {

            # Response length
            "num_predict": 120,

            # Lower = more controlled answer
            "temperature": 0.25,

            "top_p": 0.85

        }
    }

    try:

        print("")
        print("====================================")
        print("USER:")
        print(message)
        print("")
        print("AI thinking...")

        response = requests.post(
            OLLAMA_URL,
            json=payload,
            timeout=120
        )

        response.raise_for_status()

        result = response.json()

        answer = (
            result
            .get("message", {})
            .get("content", "")
            .strip()
        )

        # =================================================
        # EMPTY RESPONSE
        # =================================================

        if not answer:

            return jsonify({
                "success": False,
                "error": "AI ने रिकामे उत्तर दिले."
            }), 500

        print("")
        print("AI:")
        print(answer)
        print("====================================")

        # =================================================
        # RESPONSE TO FLUTTER
        # =================================================

        return jsonify({

            "success": True,

            "reply": answer,

            "model": MODEL

        })


    # =====================================================
    # OLLAMA CONNECTION ERROR
    # =====================================================

    except requests.exceptions.ConnectionError:

        print("ERROR: Ollama server is not running.")

        return jsonify({

            "success": False,

            "error": "Ollama server चालू नाही. Ollama सुरू करा."

        }), 500


    # =====================================================
    # TIMEOUT
    # =====================================================

    except requests.exceptions.Timeout:

        print("ERROR: Ollama timeout.")

        return jsonify({

            "success": False,

            "error": "AI response timeout झाला. पुन्हा प्रयत्न करा."

        }), 504


    # =====================================================
    # OTHER ERROR
    # =====================================================

    except Exception as e:

        print("ERROR:", e)

        return jsonify({

            "success": False,

            "error": str(e)

        }), 500


# =========================================================
# START SERVER
# =========================================================

if __name__ == "__main__":

    print("")
    print("====================================")
    print("       AgroConnect AI Server")
    print("       Ollama + Qwen 1.5B")
    print("====================================")
    print("")
    print("Ollama:", OLLAMA_URL)
    print("Model:", MODEL)
    print("")
    print("PC:")
    print("http://127.0.0.1:5001")
    print("")
    print("Phone:")
    print("http://10.100.96.4:5001")
    print("")
    print("====================================")
    print("Server starting...")
    print("====================================")
    print("")

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=False
    )

