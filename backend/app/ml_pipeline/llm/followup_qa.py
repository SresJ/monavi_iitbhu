from app.ml_pipeline.llm.client import get_llm_client

MODEL_NAME = "gpt-4.1-mini"

FOLLOWUP_QA_PROMPT = """
You are a clinical assistant answering a doctor's follow-up question.

You are given:
1. Clinical summary
2. Differential diagnoses (already generated)
3. Retrieved medical evidence

STRICT RULES:
- Answer ONLY using the provided information
- Do NOT introduce new diagnoses
- Do NOT assume missing data
- If answer is not supported, say:
  "Not enough evidence available to answer this confidently."
- Use bullet points
- Keep answers concise and professional
- Do NOT mention being an AI or language model

FORMAT:
• Short direct answer
• Supporting points (if any)
• Evidence reference (if applicable)
"""

def answer_followup_question(
    question: str,
    summary: str,
    diagnoses: list,
    evidence: list
) -> str:
    """
    Answers doctor follow-up questions using constrained LLM.
    """

    client = get_llm_client()

    context = f"""
CLINICAL SUMMARY:
{summary}

DIFFERENTIAL DIAGNOSES:
{diagnoses}

RETRIEVED EVIDENCE:
{evidence}

DOCTOR QUESTION:
{question}
"""

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": FOLLOWUP_QA_PROMPT},
            {"role": "user", "content": context}
        ],
        temperature=0,
        max_tokens=500
    )

    return response.choices[0].message.content.strip()
