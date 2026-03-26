def explain_confidence(confidence: float, evidence_count: int) -> list:
    """
    Explains why a diagnosis has a given confidence score.
    Confidence is numeric (0–1).
    """
    notes = []

    # Convert numeric confidence to level
    if confidence >= 0.75:
        level = "high"
    elif confidence >= 0.45:
        level = "medium"
    else:
        level = "low"

    if level == "high":
        notes.append("Strong alignment between patient symptoms and diagnosis")
        notes.append("Multiple supporting medical evidence sources identified")

    elif level == "medium":
        notes.append("Partial symptom overlap with diagnosis")
        notes.append("Limited or indirect supporting evidence")

    else:
        notes.append("Weak or nonspecific symptom association")
        notes.append("Insufficient strong supporting evidence")

    notes.append(f"Evidence snippets used: {evidence_count}")

    return notes
