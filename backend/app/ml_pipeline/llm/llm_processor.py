from app.ml_pipeline.llm.client import get_llm_client
from app.ml_pipeline.llm.prompts import CLEAN_INPUT_PROMPT, FORMAT_OUTPUT_PROMPT


MODEL_NAME = "gpt-4.1-mini"


def clean_input_with_llm(raw_text: str) -> str:
    """
    Cleans multimodal text BEFORE RAG.
    """
    client = get_llm_client()

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": CLEAN_INPUT_PROMPT},
            {"role": "user", "content": raw_text}
        ],
        temperature=0,
        max_tokens=800
    )

    return response.choices[0].message.content.strip()


def format_output_with_llm(raw_output: str) -> str:
    """
    Beautifies FINAL output AFTER RAG.
    """
    client = get_llm_client()

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": FORMAT_OUTPUT_PROMPT},
            {"role": "user", "content": raw_output}
        ],
        temperature=0,
        max_tokens=1200
    )

    return response.choices[0].message.content.strip()
