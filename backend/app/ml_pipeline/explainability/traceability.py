def find_triggering_sentences(diagnosis: str, patient_sentences: list) -> list:
    """
    Finds patient input sentences that likely triggered a diagnosis.
    Deterministic, no ML, no hallucination.
    """
    diagnosis_keywords = diagnosis.lower().split()

    triggers = []
    for sentence in patient_sentences:
        s = sentence.lower()
        if any(word in s for word in diagnosis_keywords):
            triggers.append(sentence)

    return triggers[:2]  # keep concise
