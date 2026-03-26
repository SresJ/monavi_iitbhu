from fastapi import APIRouter, Depends, HTTPException, status, Query
from app.middleware.firebase_middleware import verify_firebase_token
from app.database import get_database
from app.services.patient_service import PatientService
from app.schemas.patient import (
    PatientCreateRequest,
    PatientUpdateRequest,
    PatientResponse,
    PatientsListResponse
)
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo.errors import DuplicateKeyError
from typing import Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/patients", tags=["Patients"])


@router.post("", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
async def create_patient(
    request: PatientCreateRequest,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Create a new patient record

    Edge cases handled:
    - Duplicate MRN → 409 Conflict
    - Invalid input data → 422 Validation Error
    - Database errors → 500 with proper message

    - **full_name**: Patient's full name (required)
    - **age**: Patient's age (optional, 0-150)
    - **sex**: Patient's sex (optional)
    - **mrn**: Medical Record Number (optional, must be unique)
    - **contact**: Contact information (optional)
    """
    try:
        # Validate required fields
        if not request.full_name or len(request.full_name.strip()) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Patient full name is required and cannot be empty"
            )

        # Validate age if provided
        if request.age is not None and (request.age < 0 or request.age > 150):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Patient age must be between 0 and 150"
            )

        service = PatientService(db)

        # Check for duplicate MRN if provided
        if request.mrn:
            existing = await db.patients.find_one({"mrn": request.mrn})
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Patient with MRN {request.mrn} already exists"
                )

        patient = await service.create_patient(request)

        # Convert ObjectId to string
        patient["_id"] = str(patient["_id"])

        # Ensure datetime fields are properly serialized
        if "created_at" in patient and hasattr(patient["created_at"], "isoformat"):
            patient["created_at"] = patient["created_at"].isoformat()
        if "updated_at" in patient and hasattr(patient["updated_at"], "isoformat"):
            patient["updated_at"] = patient["updated_at"].isoformat()

        logger.info(f"Created patient: {patient['patient_id']}, Name: {patient['full_name']}")
        return patient

    except HTTPException:
        raise

    except DuplicateKeyError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A patient with this MRN already exists"
        )

    except Exception as e:
        logger.error(f"Error creating patient: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the patient record. Please try again."
        )


@router.get("", response_model=PatientsListResponse)
async def list_patients(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by name or MRN"),
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    List all patients with pagination and search

    Edge cases handled:
    - Invalid page/limit parameters → Validated by Query parameters
    - Database errors → 500 with proper message
    - Empty result set → Returns empty list with total=0

    - **page**: Page number (default: 1, minimum: 1)
    - **limit**: Number of patients per page (default: 20, max: 100)
    - **search**: Search query for patient name or MRN (optional)
    """
    try:
        service = PatientService(db)
        patients, total = await service.list_patients(page, limit, search)

        # Convert ObjectId to string and serialize datetimes for each patient
        for patient in patients:
            patient["_id"] = str(patient["_id"])
            if "created_at" in patient and hasattr(patient["created_at"], "isoformat"):
                patient["created_at"] = patient["created_at"].isoformat()
            if "updated_at" in patient and hasattr(patient["updated_at"], "isoformat"):
                patient["updated_at"] = patient["updated_at"].isoformat()

        logger.info(f"Listed patients: page={page}, limit={limit}, search={search}, total={total}")
        return PatientsListResponse(
            patients=patients,
            total=total,
            page=page,
            limit=limit
        )

    except Exception as e:
        logger.error(f"Error listing patients: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while retrieving patient list. Please try again."
        )


@router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient(
    patient_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get patient details by ID

    Edge cases handled:
    - Patient not found → 404 with clear message
    - Invalid patient_id format → Still searches, returns 404 if not found
    - Database errors → 500 with proper message

    - **patient_id**: Patient ID (e.g., PAT-2025-00001)
    """
    try:
        # Validate patient_id format (basic check)
        if not patient_id or len(patient_id.strip()) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Patient ID is required"
            )

        service = PatientService(db)
        patient = await service.get_patient(patient_id)

        if not patient:
            logger.warning(f"Patient not found: {patient_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )

        patient["_id"] = str(patient["_id"])

        # Ensure datetime fields are properly serialized
        if "created_at" in patient and hasattr(patient["created_at"], "isoformat"):
            patient["created_at"] = patient["created_at"].isoformat()
        if "updated_at" in patient and hasattr(patient["updated_at"], "isoformat"):
            patient["updated_at"] = patient["updated_at"].isoformat()

        logger.info(f"Retrieved patient: {patient_id}")
        return patient

    except HTTPException:
        raise

    except Exception as e:
        logger.error(f"Error retrieving patient {patient_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while retrieving patient details. Please try again."
        )


@router.put("/{patient_id}", response_model=PatientResponse)
async def update_patient(
    patient_id: str,
    request: PatientUpdateRequest,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Update patient information

    Edge cases handled:
    - Patient not found → 404
    - Duplicate MRN (if updating) → 409 Conflict
    - Invalid age → 400 Bad Request
    - Empty update (no fields provided) → Updates updated_at timestamp
    - Database errors → 500 with proper message

    - **patient_id**: Patient ID (e.g., PAT-2025-00001)
    - **All fields are optional**: Only provided fields will be updated
    """
    try:
        # Validate age if provided
        if request.age is not None and (request.age < 0 or request.age > 150):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Patient age must be between 0 and 150"
            )

        # Check for duplicate MRN if updating MRN
        if request.mrn:
            existing = await db.patients.find_one({"mrn": request.mrn, "patient_id": {"$ne": patient_id}})
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Another patient with MRN {request.mrn} already exists"
                )

        service = PatientService(db)
        patient = await service.update_patient(patient_id, request)

        if not patient:
            logger.warning(f"Patient not found for update: {patient_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )

        patient["_id"] = str(patient["_id"])

        # Ensure datetime fields are properly serialized
        if "created_at" in patient and hasattr(patient["created_at"], "isoformat"):
            patient["created_at"] = patient["created_at"].isoformat()
        if "updated_at" in patient and hasattr(patient["updated_at"], "isoformat"):
            patient["updated_at"] = patient["updated_at"].isoformat()

        logger.info(f"Updated patient: {patient_id}")
        return patient

    except HTTPException:
        raise

    except DuplicateKeyError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A patient with this MRN already exists"
        )

    except Exception as e:
        logger.error(f"Error updating patient {patient_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the patient record. Please try again."
        )


@router.delete("/{patient_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_patient(
    patient_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Delete patient record

    Edge cases handled:
    - Patient not found → 404
    - Patient has associated analyses → Still deletes (as per requirements)
    - Database errors → 500 with proper message

    - **patient_id**: Patient ID (e.g., PAT-2025-00001)

    Note: This will also delete all analyses associated with this patient
    """
    try:
        service = PatientService(db)
        deleted = await service.delete_patient(patient_id)

        if not deleted:
            logger.warning(f"Patient not found for deletion: {patient_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with ID {patient_id} not found"
            )

        # Also delete all analyses for this patient
        await db.analyses.delete_many({"patient_id": patient_id})
        logger.info(f"Deleted patient and associated analyses: {patient_id}")

        return None

    except HTTPException:
        raise

    except Exception as e:
        logger.error(f"Error deleting patient {patient_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while deleting the patient record. Please try again."
        )


@router.get("/{patient_id}/analyses")
async def get_patient_analyses(
    patient_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get all analyses for a specific patient

    - **patient_id**: Patient ID (e.g., PAT-2025-00001)

    Returns a list of all analyses ordered by creation date (newest first)
    """
    service = PatientService(db)

    # Verify patient exists
    patient = await service.get_patient(patient_id)
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {patient_id} not found"
        )

    # Get analyses
    analyses = await service.get_patient_analyses(patient_id)

    # Convert ObjectId to string and serialize datetimes for each analysis
    for analysis in analyses:
        analysis["_id"] = str(analysis["_id"])
        if "created_at" in analysis and hasattr(analysis["created_at"], "isoformat"):
            analysis["created_at"] = analysis["created_at"].isoformat()
        if "updated_at" in analysis and hasattr(analysis["updated_at"], "isoformat"):
            analysis["updated_at"] = analysis["updated_at"].isoformat()

    return {
        "patient_id": patient_id,
        "patient_name": patient["full_name"],
        "total_analyses": len(analyses),
        "analyses": analyses
    }
