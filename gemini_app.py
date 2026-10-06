import os
import requests
from flask import Flask, request, jsonify

API_KEY = os.environ["GEMINI_API_KEY"]
MODEL = "gemini-2.5-flash"   # 404 aala tar AI Studio madhe dakhavlele Flash model cha nav vapra
URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent"

SYSTEM = (
    "तू शेतकऱ्याशी फोनवर बोलणारा मित्र आहेस. "
    "फक्त मराठीत, साध्या बोली भाषेत उत्तर दे. "
    "जास्तीत जास्त २ छोटी वाक्ये. यादी, चिन्हे किंवा इमोजी वापरू नको. "
    "खात्री नसेल तर तसे प्रामाणिकपणे सांग आणि जवळच्या कृषी अधिकाऱ्याला विचारायला सांग."
)

app = Flask(__name__)
app.json.ensure_ascii = False


@app.post("/ai/chat")
def chat():
    msg = (request.get_json(silent=True) or {}).get("message", "").strip()
    if not msg:
        return jsonify(success=False, error="message रिकामा आहे"), 400
    try:
        r = requests.post(
            URL,
            headers={"x-goog-api-key": API_KEY, "Content-Type": "application/json"},
            json={
                "systemInstruction": {"parts": [{"text": SYSTEM}]},
                "contents": [{"role": "user", "parts": [{"text": msg}]}],
                "generationConfig": {"maxOutputTokens": 200, "temperature": 0.5, "thinkingConfig": {"thinkingBudget": 0}},
            },
            timeout=30,
        )
        r.raise_for_status()
        parts = r.json()["candidates"][0]["content"]["parts"]
        reply = "".join(p.get("text", "") for p in parts).strip()
        return jsonify(success=True, reply=reply)
    except Exception as e:
        return jsonify(success=False, error=str(e)), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, threaded=True)