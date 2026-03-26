from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from app.models.analysis import Summary, Diagnosis, DiagnosticTest


class AnalysisCreateResponse(BaseModel):
    """
    Response schema for analysis creation
    """
    analysis_id: str
    summary: Summary
    diagnoses: List[Diagnosis]
    diagnostic_tests: List[DiagnosticTest]
    missing_info: List[str]

    class Config:
        json_schema_extra = {
            "example": {
                "analysis_id": "ANA-2025-00001",
                "summary": {
                    "age": 45,
                    "sex": "female",
                    "chief_complaint": "Chest pain",
                    "associated_symptoms": ["shortness of breath"],
                    "duration": "2 hours",
                    "formatted_summary": "Clinical summary text..."
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
                        "rationale": "Detect abnormalities"
                    }
                ],
                "missing_info": ["vital signs"]
            }
        }


class FollowupQuestionRequest(BaseModel):
    """
    Request schema for follow-up question
    """
    question: str = Field(..., min_length=1, description="Follow-up question about the analysis")

    class Config:
        json_schema_extra = {
            "example": {
                "question": "What are the risk factors for this diagnosis?"
            }
        }


class FollowupQuestionResponse(BaseModel):
    """
    Response schema for follow-up question
    """
    answer: str = Field(..., description="Answer to the follow-up question")
    asked_at: datetime = Field(..., description="Timestamp when question was asked")

    class Config:
        json_schema_extra = {
            "example": {
                "answer": "Based on the provided evidence, risk factors include...",
                "asked_at": "2025-01-11T12:00:00"
            }
        }


class DashboardStatsResponse(BaseModel):
    """
    Response schema for dashboard statistics
    """
    total_patients: int = Field(..., description="Total number of patients")
    total_analyses: int = Field(..., description="Total number of analyses")
    recent_analyses_count: int = Field(..., description="Number of analyses in last 7 days")

    class Config:
        json_schema_extra = {
            "example": {
                "total_patients": 150,
                "total_analyses": 342,
                "recent_analyses_count": 12
            }
        }
