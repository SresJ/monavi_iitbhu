import re

# -------------------------------------------------
# Symptom → Diagnostic tests mapping
# -------------------------------------------------
DIAGNOSTIC_TEST_MAP = {
    "chest pain": [
        "Vital signs (BP, HR, SpO₂)",
        "ECG",
        "Cardiac enzymes (Troponin)",
        "Blood glucose"
    ],
    "shortness of breath": [
        "Pulse oximetry",
        "Chest X-ray",
        "Arterial blood gas (if severe)"
    ],
    "fever": [
        "Temperature",
        "Complete blood count (CBC)",
        "C-reactive protein (CRP)"
    ],
    "cough": [
        "Chest X-ray",
        "Sputum examination (if productive)"
    ],
    "nausea": [
        "Electrolyte panel",
        "Liver function tests"
    ],
    "vomiting": [
        "Electrolytes",
        "Renal function tests"
    ],
    "abdominal pain": [
        "Abdominal examination",
        "Ultrasound abdomen",
        "Liver function tests"
    ],
    "burning pain": [
        "Upper GI endoscopy (if persistent)",
        "H. pylori testing"
    ],
    "painful urination": [
        "Urinalysis",
        "Urine culture"
    ],
    "headache": [
        "Blood pressure measurement",
        "Neurological examination"
    ],
    "sweating": [
        "Blood glucose",
        "ECG (if cardiac symptoms present)"
    ],
    "fatigue": [
        "Complete blood count (CBC)",
        "Thyroid function tests"
    ]
}

# -------------------------------------------------
# Symptom → Clinical considerations mapping
# -------------------------------------------------
CLINICAL_CONSIDERATION_MAP = {
    "chest pain": [
        "Rule out acute coronary syndrome",
        "Assess hemodynamic stability"
    ],
    "shortness of breath": [
        "Assess oxygenation",
        "Consider respiratory or cardiac causes"
    ],
    "fever": [
        "Evaluate for infectious causes",
        "Assess severity and source"
    ],
    "abdominal pain": [
        "Differentiate surgical vs medical causes"
    ],
    "painful urination": [
        "Consider urinary tract infection",
        "Assess for complications"
    ],
    "headache": [
        "Rule out secondary causes if severe or sudden"
    ],
    "vomiting": [
        "Assess hydration status"
    ],
    "fatigue": [
        "Evaluate for metabolic or systemic causes"
    ]
}

# -------------------------------------------------
# Helper functions
# -------------------------------------------------
def extract_age_sex(text: str):
    text = text.lower()

    age = None
    sex = None

    age_patterns = [
        r"(\d{1,3})\s*year\s*old",
        r"(\d{1,3})\s*years?\s*old",
        r"(\d{1,3})\s*yr",
        r"(\d{1,3})\s*y/o",
        r"(\d{1,3})\s*yo",
        r"(\d{1,3})\s*year"
    ]

    for p in age_patterns:
        m = re.search(p, text)
        if m:
            age = m.group(1)
            break

    if any(w in text for w in ["male", "man", "boy", "gentleman", "guy"]):
        sex = "Male"
    elif any(w in text for w in ["female", "woman", "girl", "lady"]):
        sex = "Female"

    return age, sex


def detect_presentation(text: str):
    text = text.lower()

    acute_markers = [
        "acute", "sudden", "severe", "intense", "worsening",
        "chest pain", "shortness of breath", "sweating",
        "vomiting", "fainting"
    ]

    duration_markers = ["hour", "hours", "day", "days", "since"]

    if any(k in text for k in acute_markers):
        return "Acute"

    if any(k in text for k in duration_markers):
        return "Subacute / Ongoing"

    return "Unclear"


def is_negated(symptom: str, text: str) -> bool:
    neg_patterns = [
        f"no {symptom}",
        f"denies {symptom}",
        f"without {symptom}"
    ]
    return any(p in text for p in neg_patterns)


def detect_chief_complaint(text: str, symptoms: list):
    text = text.lower()

    high_priority = [
        "chest pain",
        "shortness of breath",
        "loss of consciousness",
        "seizure",
        "weakness",
        "paralysis"
    ]

    medium_priority = [
        "vomiting",
        "nausea",
        "fever",
        "headache",
        "dizziness",
        "sweating"
    ]

    for hp in high_priority:
        if hp in text:
            return hp

    for mp in medium_priority:
        if mp in text:
            return mp

    return symptoms[0] if symptoms else "Not clearly stated"

# -------------------------------------------------
# Main summarizer
# -------------------------------------------------
def summarize_case(text: str) -> str:
    raw = text.strip()
    lower = raw.lower()

    # Age & sex
    age, sex = extract_age_sex(lower)
    age_sex = f"{age}-year-old {sex}" if age and sex else "Not specified"

    # Duration
    duration_match = re.search(r"(\d+\s*(hours?|days?|weeks?))", lower)
    duration = duration_match.group(1) if duration_match else "Not specified"

    # Presentation
    presentation = detect_presentation(lower)

    # Symptoms
    detected_symptoms = [
        s for s in DIAGNOSTIC_TEST_MAP.keys()
        if s in lower and not is_negated(s, lower)
    ]

    chief = detect_chief_complaint(lower, detected_symptoms)
    associated = [s for s in detected_symptoms if s != chief]

    # Diagnostic tests
    suggested_tests = set()
    for symptom in detected_symptoms:
        suggested_tests.update(DIAGNOSTIC_TEST_MAP.get(symptom, []))

    # Clinical considerations
    considerations = set()
    for symptom in detected_symptoms:
        considerations.update(CLINICAL_CONSIDERATION_MAP.get(symptom, []))

    summary = f"""
🩺 Patient Snapshot
• Age / Sex: {age_sex}
• Presentation: {presentation}

🚨 Chief Complaint
• {chief}

📋 Associated Symptoms
• {', '.join(associated) if associated else 'None clearly stated'}

⏱ Duration
• {duration}

🧠 Clinical Notes
• {raw}

🧪 Suggested Diagnostic Tests
• {chr(10)+'• '.join(sorted(suggested_tests)) if suggested_tests else 'Based on clinician judgment'}

⚠️ Immediate Clinical Considerations
• {chr(10)+'• '.join(sorted(considerations)) if considerations else 'Requires further clinical assessment'}

⚠️ Missing / Unknown
• Vital signs
• Physical examination findings
• Relevant past medical history
"""

    return summary.strip()
