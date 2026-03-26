from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.doctor import Doctor
from datetime import datetime
from typing import Optional
from app.utils import get_ist_now


class FirebaseService:
    """
    Service for managing doctors with Firebase authentication
    """

    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.doctors

    async def verify_and_create_doctor(
        self,
        firebase_uid: str,
        email: str,
        full_name: str,
        specialty: Optional[str] = None
    ) -> tuple[str, bool]:
        """
        Verify Firebase UID and create or update doctor record

        Args:
            firebase_uid: Firebase UID from authentication
            email: Doctor's email address
            full_name: Doctor's full name
            specialty: Medical specialty (optional)

        Returns:
            tuple: (doctor_id, is_new) - MongoDB _id and whether doctor is new
        """
        # Check if doctor already exists
        existing_doctor = await self.collection.find_one({"firebase_uid": firebase_uid})

        if existing_doctor:
            # Update existing doctor
            update_data = {
                "email": email,
                "full_name": full_name,
                "updated_at": get_ist_now()
            }
            if specialty:
                update_data["specialty"] = specialty

            await self.collection.update_one(
                {"firebase_uid": firebase_uid},
                {"$set": update_data}
            )
            return str(existing_doctor["_id"]), False
        else:
            # Create new doctor
            doctor = Doctor(
                firebase_uid=firebase_uid,
                email=email,
                full_name=full_name,
                specialty=specialty
            )
            result = await self.collection.insert_one(doctor.model_dump())
            return str(result.inserted_id), True

    async def get_doctor_by_uid(self, firebase_uid: str) -> Optional[dict]:
        """
        Get doctor by Firebase UID

        Args:
            firebase_uid: Firebase UID

        Returns:
            dict: Doctor document or None if not found
        """
        return await self.collection.find_one({"firebase_uid": firebase_uid})

    async def get_doctor_by_email(self, email: str) -> Optional[dict]:
        """
        Get doctor by email address

        Args:
            email: Doctor's email

        Returns:
            dict: Doctor document or None if not found
        """
        return await self.collection.find_one({"email": email})
