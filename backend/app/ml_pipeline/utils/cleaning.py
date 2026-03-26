import re

def clean_patient_text(text: str) -> str:
    """
    Basic patient de-identification.
    Removes phone numbers and simple name patterns.
    """

    # Remove phone numbers / long numeric IDs
    text = re.sub(r"\b\d{10,}\b", "[REDACTED]", text)

    # Remove simple Firstname Lastname patterns
    text = re.sub(r"\b[A-Z][a-z]+ [A-Z][a-z]+\b", "[REDACTED]", text)

    return text.strip()
