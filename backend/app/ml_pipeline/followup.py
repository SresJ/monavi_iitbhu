def generate_followup_questions(summary: str, diagnoses: list, max_questions: int = 5):
    """
    Generate follow-up clinical questions to reduce diagnostic uncertainty.
    Rule-based, safe, LLM-free.
    """

    questions = []

    summary_lower = summary.lower()

    # -----------------------------
    # Generic missing info checks
    # -----------------------------
    if "vital signs" in summary_lower or "missing" in summary_lower:
        questions.append("What are the patient’s vital signs (BP, HR, SpO₂, temperature)?")

    if "medical history" in summary_lower:
        questions.append("Does the patient have any known past medical conditions (e.g., hypertension, diabetes)?")

    if "medications" not in summary_lower:
        questions.append("Is the patient currently taking any medications?")

    if "smoking" not in summary_lower:
        questions.append("Does the patient smoke or use tobacco products?")

    # -----------------------------
    # Diagnosis-specific questions
    # -----------------------------
    top_diagnoses = [d["diagnosis"].lower() for d in diagnoses[:2]]

    if any("heart" in d or "angina" in d for d in top_diagnoses):
        questions.append("Is the chest pain radiating to the left arm, jaw, or back?")
        questions.append("Did the pain start with exertion or at rest?")

    if any("infection" in d or "pneumonia" in d for d in top_diagnoses):
        questions.append("Has the patient had fever, chills, or recent infection?")
        questions.append("Is there any cough or shortness of breath?")

    if any("stroke" in d for d in top_diagnoses):
        questions.append("Is there any weakness, speech difficulty, or facial drooping?")

    # -----------------------------
    # Final cleanup
    # -----------------------------
    # Remove duplicates, keep order
    seen = set()
    final_questions = []
    for q in questions:
        if q not in seen:
            final_questions.append(q)
            seen.add(q)

    return final_questions[:max_questions]
