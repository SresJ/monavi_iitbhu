from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from app.utils import get_ist_now


class UploadedFile(BaseModel):
    """
    Metadata for uploaded files
    """
    file_type: str = Field(..., description="Type of file (audio/pdf/image)")
    original_filename: str = Field(..., description="Original filename")
    stored_path: str = Field(..., description="Path where file is stored")
    file_size: int = Field(..., description="File size in bytes")


class RawInput(BaseModel):
    """
    Raw input data for analysis
    """
    typed_text: Optional[str] = Field(None, description="Clinical notes typed by doctor")
    files: List[UploadedFile] = Field(default_factory=list, description="Uploaded files")


class Summary(BaseModel):
    """
    Clinical summary extracted from patient input
    """
    age: Optional[int] = None
    sex: Optional[str] = None
    chief_complaint: Optional[str] = None
    associated_symptoms: List[str] = Field(default_factory=list)
    duration: Optional[str] = None
    formatted_summary: str = Field(..., description="Formatted clinical summary text")


class Evidence(BaseModel):
    """
    Evidence supporting a diagnosis
    """
    evidence_text: str = Field(..., description="Evidence text from medical literature")
    source_url: str = Field(..., description="URL to source")
    source_name: str = Field(..., description="Name of source (e.g., MedlinePlus)")


class Diagnosis(BaseModel):
    """
    Differential diagnosis with confidence and evidence
    """
    diagnosis_name: str = Field(..., description="Name of the diagnosis")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence score (0-1)")
    confidence_level: str = Field(..., description="Confidence level (high/medium/low)")
    triggering_symptoms: List[str] = Field(default_factory=list, description="Symptoms that triggered this diagnosis")
    confidence_rationale: List[str] = Field(default_factory=list, description="Rationale for confidence level")
    evidence: List[Evidence] = Field(default_factory=list, description="Supporting evidence")


class DiagnosticTest(BaseModel):
    """
    Suggested diagnostic test
    """
    test_name: str = Field(..., description="Name of the diagnostic test")
    rationale: str = Field(..., description="Rationale for suggesting this test")


class Analysis(BaseModel):
    """
    Analysis document model for MongoDB (contains embedded diagnoses)
    """
    analysis_id: str = Field(..., description="Auto-generated unique analysis ID")
    patient_id: str = Field(..., description="Reference to patient")
    doctor_firebase_uid: str = Field(..., description="Firebase UID of doctor who created analysis")
    raw_input: RawInput = Field(..., description="Raw input data")
    summary: Summary = Field(..., description="Clinical summary")
    diagnoses: List[Diagnosis] = Field(default_factory=list, description="Differential diagnoses")
    diagnostic_tests: List[DiagnosticTest] = Field(default_factory=list, description="Suggested diagnostic tests")
    missing_info: List[str] = Field(default_factory=list, description="Missing or unclear information")
    created_at: datetime = Field(default_factory=get_ist_now)
    updated_at: datetime = Field(default_factory=get_ist_now)

    class Config:
        json_schema_extra = {
            "example": {
                "analysis_id": "ANA-2025-00001",
                "patient_id": "PAT-2025-00001",
                "doctor_firebase_uid": "xG7kP9mN2ABC123",
                "raw_input": {
                    "typed_text": "Patient presents with chest pain...",
                    "files": []
                },
                "summary": {
                    "age": 45,
                    "sex": "female",
                    "chief_complaint": "Chest pain",
                    "associated_symptoms": ["shortness of breath"],
                    "duration": "2 hours",
                    "formatted_summary": "Patient Snapshot..."
                },
                "diagnoses": [
                    {
                        "diagnosis_name": "Acute Coronary Syndrome",
                        "confidence": 0.85,
                        "confidence_level": "high",
                        "triggering_symptoms": ["chest pain"],
                        "confidence_rationale": ["Strong evidence"],
                        "evidence": []
                    }
                ],
                "diagnostic_tests": [
                    {
                        "test_name": "ECG",
                        "rationale": "Detect cardiac abnormalities"
                    }
                ],
                "missing_info": ["vital signs"]
            }
        }


class FollowupQA(BaseModel):
    """
    Question and answer pair for follow-up conversations
    """
    question: str = Field(..., description="Question asked by doctor")
    answer: str = Field(..., description="Answer generated by system")
    asked_at: datetime = Field(default_factory=get_ist_now)


class FollowupConversation(BaseModel):
    """
    Follow-up conversation document for MongoDB
    """
    analysis_id: str = Field(..., description="Reference to analysis")
    qa_pairs: List[FollowupQA] = Field(default_factory=list, description="Question-answer pairs")
    created_at: datetime = Field(default_factory=get_ist_now)
    updated_at: datetime = Field(default_factory=get_ist_now)
