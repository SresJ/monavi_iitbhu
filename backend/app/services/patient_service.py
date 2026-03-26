from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.patient import Patient, PatientContact
from app.schemas.patient import PatientCreateRequest, PatientUpdateRequest
from datetime import datetime
from typing import Optional, List
import re
from app.utils import get_ist_now


class PatientService:
    """
    Service for managing patient records
    """

    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.patients

    async def generate_patient_id(self) -> str:
        """
        Generate unique patient ID in format PAT-YYYY-NNNNN

        Returns:
            str: Unique patient ID
        """
        year = get_ist_now().year

        # Find the highest patient number for this year
        pattern = f"PAT-{year}-"
        last_patient = await self.collection.find_one(
            {"patient_id": {"$regex": f"^{pattern}"}},
            sort=[("patient_id", -1)]
        )

        if last_patient:
            # Extract number from last patient ID
            match = re.search(r'-(\d+)$', last_patient["patient_id"])
            if match:
                next_num = int(match.group(1)) + 1
            else:
                next_num = 1
        else:
            next_num = 1

        return f"PAT-{year}-{next_num:05d}"

    async def create_patient(self, patient_data: PatientCreateRequest) -> dict:
        """
        Create new patient record

        Args:
            patient_data: Patient creation request data

        Returns:
            dict: Created patient document
        """
        patient_id = await self.generate_patient_id()

        # Convert PatientContactRequest to PatientContact if provided
        contact = None
        if patient_data.contact is not None:
            contact = PatientContact(
                email=patient_data.contact.email,
                phone=patient_data.contact.phone
            )

        patient = Patient(
            patient_id=patient_id,
            full_name=patient_data.full_name,
            age=patient_data.age,
            sex=patient_data.sex,
            mrn=patient_data.mrn,
            contact=contact
        )

        await self.collection.insert_one(patient.model_dump())
        return await self.collection.find_one({"patient_id": patient_id})

    async def get_patient(self, patient_id: str) -> Optional[dict]:
        """
        Get patient by patient_id

        Args:
            patient_id: Patient ID

        Returns:
            dict: Patient document or None if not found
        """
        return await self.collection.find_one({"patient_id": patient_id})

    async def list_patients(
        self,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None
    ) -> tuple[List[dict], int]:
        """
        List patients with pagination and search

        Args:
            page: Page number (1-indexed)
            limit: Number of patients per page
            search: Search query for patient name or MRN

        Returns:
            tuple: (list of patients, total count)
        """
        skip = (page - 1) * limit
        query = {}

        if search:
            # Search in full_name or mrn
            query = {
                "$or": [
                    {"full_name": {"$regex": search, "$options": "i"}},
                    {"mrn": {"$regex": search, "$options": "i"}}
                ]
            }

        total = await self.collection.count_documents(query)
        patients = await self.collection.find(query).skip(skip).limit(limit).sort("created_at", -1).to_list(length=limit)

        return patients, total

    async def update_patient(
        self,
        patient_id: str,
        patient_data: PatientUpdateRequest
    ) -> Optional[dict]:
        """
        Update patient record

        Args:
            patient_id: Patient ID
            patient_data: Patient update data

        Returns:
            dict: Updated patient document or None if not found
        """
        # Build update dict only with provided fields
        update_data = {
            "updated_at": get_ist_now()
        }

        if patient_data.full_name is not None:
            update_data["full_name"] = patient_data.full_name
        if patient_data.age is not None:
            update_data["age"] = patient_data.age
        if patient_data.sex is not None:
            update_data["sex"] = patient_data.sex
        if patient_data.mrn is not None:
            update_data["mrn"] = patient_data.mrn
        if patient_data.contact is not None:
            # Convert PatientContactRequest to PatientContact
            contact = PatientContact(
                email=patient_data.contact.email,
                phone=patient_data.contact.phone
            )
            update_data["contact"] = contact.model_dump()

        result = await self.collection.update_one(
            {"patient_id": patient_id},
            {"$set": update_data}
        )

        if result.matched_count == 0:
            return None

        return await self.collection.find_one({"patient_id": patient_id})

    async def delete_patient(self, patient_id: str) -> bool:
        """
        Delete patient record

        Args:
            patient_id: Patient ID

        Returns:
            bool: True if deleted, False if not found
        """
        result = await self.collection.delete_one({"patient_id": patient_id})
        return result.deleted_count > 0

    async def get_patient_analyses(self, patient_id: str) -> List[dict]:
        """
        Get all analyses for a patient

        Args:
            patient_id: Patient ID

        Returns:
            list: List of analysis documents
        """
        analyses = await self.db.analyses.find(
            {"patient_id": patient_id}
        ).sort("created_at", -1).to_list(length=None)

        return analyses
