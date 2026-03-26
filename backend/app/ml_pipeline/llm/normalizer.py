import json
from app.ml_pipeline.llm.client import get_llm_client

MODEL_NAME = "gpt-4.1-mini"


NORMALIZE_PROMPT = """
You are a medical input normalizer.

TASK:
Convert raw clinical text into a STRICT JSON structure.

RULES:
- Use numbers, not words (2 hours, not two hours)
- Do NOT invent symptoms
- Do NOT infer duration
- Do NOT diagnose
- If something is not explicitly stated, use null or empty list
- Output VALID JSON ONLY (no text outside JSON)

JSON SCHEMA:
{
  "age": number | null,
  "sex": "male" | "female" | null,
  "chief_complaint": string | null,
  "associated_symptoms": [string],
  "duration": string | null,
  "known_conditions": [string]
}
"""


def normalize_patient_input(raw_text: str) -> dict:
    """
    Uses LLM to normalize raw input into structured JSON.
    Safe fallback if parsing fails.
    """
    client = get_llm_client()

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": NORMALIZE_PROMPT},
            {"role": "user", "content": raw_text}
        ],
        temperature=0,
        max_tokens=300
    )

    content = response.choices[0].message.content.strip()

    try:
        return json.loads(content)
    except Exception:
        # 🔐 SAFETY FALLBACK
        return {
            "age": None,
            "sex": None,
            "chief_complaint": None,
            "associated_symptoms": [],
            "duration": None,
            "known_conditions": []
        }
