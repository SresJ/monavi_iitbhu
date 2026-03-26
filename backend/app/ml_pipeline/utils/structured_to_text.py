def structured_to_text(data: dict) -> str:
    """
    Converts structured JSON into rule-friendly text.
    """

    parts = []

    if data.get("age") and data.get("sex"):
        parts.append(f"{data['age']} year old {data['sex']}")

    if data.get("chief_complaint"):
        parts.append(f"with {data['chief_complaint']}")

    if data.get("associated_symptoms"):
        parts.append(
            "associated with " + ", ".join(data["associated_symptoms"])
        )

    if data.get("duration"):
        parts.append(f"for {data['duration']}")

    if data.get("known_conditions"):
        parts.append(
            "known history of " + ", ".join(data["known_conditions"])
        )

    return " ".join(parts)
