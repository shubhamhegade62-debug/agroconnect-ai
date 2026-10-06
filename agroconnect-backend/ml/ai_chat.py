import os
from openai import OpenAI

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise RuntimeError("OPENAI_API_KEY is not set")

client = OpenAI(api_key=api_key)


SYSTEM_PROMPT = """
You are AgroConnect AI, a friendly agriculture assistant for Indian farmers.

Your job is to help farmers understand crop problems in simple Marathi.

Rules:
- Speak naturally in Marathi.
- Keep answers simple and farmer-friendly.
- Do not use unnecessarily technical language.
- If the farmer's information is insufficient, ask a useful follow-up question.
- Never pretend that a disease is confirmed without sufficient evidence.
- When a plant image/model result is provided, explain that result clearly.
- Give practical farming guidance.
- For pesticide, fungicide, insecticide or chemical recommendations,
  advise the farmer to follow the product label and local agricultural expert guidance.
- Do not invent medicine names, dosages or guaranteed cures.
"""


def ask_ai(message: str) -> str:

    response = client.responses.create(
        model="gpt-5.6-luna",
        instructions=SYSTEM_PROMPT,
        input=message
    )

    return response.output_text


if __name__ == "__main__":

    print("AgroConnect AI Test")
    print("-------------------")

    question = input("Farmer: ")

    answer = ask_ai(question)

    print("\nAgroConnect AI:")
    print(answer)