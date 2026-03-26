from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from app.utils import get_ist_now


class PatientContact(BaseModel):
    """
    Patient contact information
    """
    email: Optional[EmailStr] = None
    phone: Optional[str] = None


class Patient(BaseModel):
    """
    Patient document model for MongoDB
    """
    patient_id: str = Field(..., description="Auto-generated unique patient ID")
    mrn: Optional[str] = Field(None, description="Medical Record Number")
    full_name: str = Field(..., min_length=1, description="Patient's full name")
    age: Optional[int] = Field(None, ge=0, le=150, description="Patient's age")
    sex: Optional[str] = Field(None, description="Patient's sex (male/female/other)")
    contact: Optional[PatientContact] = Field(None, description="Contact information")
    created_at: datetime = Field(default_factory=get_ist_now)
    updated_at: datetime = Field(default_factory=get_ist_now)

    class Config:
        json_schema_extra = {
            "example": {
                "patient_id": "PAT-2025-00001",
                "mrn": "MRN123456",
                "full_name": "Jane Doe",
                "age": 45,
                "sex": "female",
                "contact": {
                    "email": "jane.doe@example.com",
                    "phone": "+1-555-0123"
                }
            }
        }
