from pydantic import BaseModel, EmailStr, Field
from typing import Optional


class DoctorVerifyRequest(BaseModel):
    """
    Request schema for verifying Firebase UID and creating/updating doctor
    """
    email: EmailStr = Field(..., description="Doctor's email address")
    full_name: str = Field(..., min_length=1, description="Doctor's full name")
    specialty: Optional[str] = Field(None, description="Medical specialty")

    class Config:
        json_schema_extra = {
            "example": {
                "email": "dr.smith@hospital.com",
                "full_name": "Dr. John Smith",
                "specialty": "Cardiology"
            }
        }


class DoctorVerifyResponse(BaseModel):
    """
    Response schema for doctor verification
    """
    doctor_id: str = Field(..., description="MongoDB _id of doctor document")
    message: str = Field(..., description="Success message")
    is_new: bool = Field(..., description="True if this is a new doctor, False if existing")

    class Config:
        json_schema_extra = {
            "example": {
                "doctor_id": "6789abcdef123456",
                "message": "Doctor verified successfully",
                "is_new": False
            }
        }
