from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from app.utils import get_ist_now


class Doctor(BaseModel):
    """
    Doctor document model for MongoDB
    """
    firebase_uid: str = Field(..., description="Firebase UID (unique identifier)")
    email: EmailStr = Field(..., description="Doctor's email address")
    full_name: str = Field(..., min_length=1, description="Doctor's full name")
    specialty: Optional[str] = Field(None, description="Medical specialty")
    created_at: datetime = Field(default_factory=get_ist_now)
    updated_at: datetime = Field(default_factory=get_ist_now)

    class Config:
        json_schema_extra = {
            "example": {
                "firebase_uid": "xG7kP9mN2ABC123",
                "email": "dr.smith@hospital.com",
                "full_name": "Dr. John Smith",
                "specialty": "Cardiology"
            }
        }
