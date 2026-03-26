from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class PatientContactRequest(BaseModel):
    """
    Patient contact information for requests
    """
    email: Optional[EmailStr] = None
    phone: Optional[str] = None


class PatientCreateRequest(BaseModel):
    """
    Request schema for creating a new patient
    """
    full_name: str = Field(..., min_length=1, description="Patient's full name")
    age: Optional[int] = Field(None, ge=0, le=150, description="Patient's age")
    sex: Optional[str] = Field(None, description="Patient's sex")
    mrn: Optional[str] = Field(None, description="Medical Record Number")
    contact: Optional[PatientContactRequest] = None

    class Config:
        json_schema_extra = {
            "example": {
                "full_name": "Jane Doe",
                "age": 45,
                "sex": "female",
                "mrn": "MRN123456",
                "contact": {
                    "email": "jane.doe@example.com",
                    "phone": "+1-555-0123"
                }
            }
        }


class PatientUpdateRequest(BaseModel):
    """
    Request schema for updating a patient
    """
    full_name: Optional[str] = Field(None, min_length=1)
    age: Optional[int] = Field(None, ge=0, le=150)
    sex: Optional[str] = None
    mrn: Optional[str] = None
    contact: Optional[PatientContactRequest] = None


class PatientResponse(BaseModel):
    """
    Response schema for patient data
    """
    patient_id: str
    full_name: str
    age: Optional[int] = None
    sex: Optional[str] = None
    mrn: Optional[str] = None
    contact: Optional[PatientContactRequest] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        json_schema_extra = {
            "example": {
                "patient_id": "PAT-2025-00001",
                "full_name": "Jane Doe",
                "age": 45,
                "sex": "female",
                "mrn": "MRN123456",
                "contact": {
                    "email": "jane.doe@example.com",
                    "phone": "+1-555-0123"
                },
                "created_at": "2025-01-11T12:00:00",
                "updated_at": "2025-01-11T12:00:00"
            }
        }


class PatientsListResponse(BaseModel):
    """
    Response schema for paginated patient list
    """
    patients: list[PatientResponse]
    total: int
    page: int
    limit: int
