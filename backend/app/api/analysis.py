from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from app.middleware.firebase_middleware import verify_firebase_token
from app.database import get_database
from app.services.analysis_service import AnalysisService
from app.services.patient_service import PatientService
from app.utils.file_handler import FileHandler
from app.schemas.analysis import AnalysisCreateResponse, DashboardStatsResponse
from motor.motor_asyncio import AsyncIOMotorDatabase
from typing import List, Optional
from datetime import datetime


router = APIRouter(prefix="/analysis", tags=["Analysis"])


@router.post("/create", response_model=AnalysisCreateResponse, status_code=status.HTTP_201_CREATED)
async def create_analysis(
    patient_id: str = Form(..., description="Patient ID"),
    typed_text: str = Form("", description="Clinical notes typed by doctor"),
    audio_files: Optional[List[UploadFile]] = File(None, description="Audio files"),
    pdf_files: Optional[List[UploadFile]] = File(None, description="PDF documents"),
    image_files: Optional[List[UploadFile]] = File(None, description="Medical images"),
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Create new clinical analysis with ML pipeline processing

    This endpoint processes multimodal input through the ML pipeline:
    1. Ingests text, audio, PDF, and image inputs
    2. Cleans and de-identifies patient data
    3. Generates clinical summary
    4. Retrieves evidence using RAG system
    5. Generates differential diagnoses with confidence scores
    6. Provides explainability (triggering symptoms, confidence rationale)

    - **patient_id**: ID of the patient (required)
    - **typed_text**: Clinical notes typed by doctor
    - **audio_files**: Audio recordings (WAV, MP3, FLAC)
    - **pdf_files**: PDF documents (lab reports, previous notes)
    - **image_files**: Medical images (scans, charts)
    """
    # Verify patient exists
    patient_service = PatientService(db)
    patient = await patient_service.get_patient(patient_id)
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {patient_id} not found"
        )

    # Save uploaded files
    uploaded_files = []

    if audio_files:
        audio_metadata = await FileHandler.save_files(audio_files, "audio")
        uploaded_files.extend(audio_metadata)

    if pdf_files:
        pdf_metadata = await FileHandler.save_files(pdf_files, "pdf")
        uploaded_files.extend(pdf_metadata)

    if image_files:
        image_metadata = await FileHandler.save_files(image_files, "image")
        uploaded_files.extend(image_metadata)

    # Create analysis using ML pipeline
    analysis_service = AnalysisService(db)

    try:
        analysis = await analysis_service.create_analysis(
            patient_id=patient_id,
            doctor_firebase_uid=firebase_uid,
            typed_text=typed_text,
            uploaded_files=uploaded_files
        )
    except Exception as e:
        # Clean up uploaded files if analysis fails
        for file_meta in uploaded_files:
            FileHandler.delete_file(file_meta["stored_path"])

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create analysis: {str(e)}"
        )

    # Convert ObjectId to string
    analysis["_id"] = str(analysis["_id"])

    # Ensure datetime fields are properly serialized
    if "created_at" in analysis and hasattr(analysis["created_at"], "isoformat"):
        analysis["created_at"] = analysis["created_at"].isoformat()
    if "updated_at" in analysis and hasattr(analysis["updated_at"], "isoformat"):
        analysis["updated_at"] = analysis["updated_at"].isoformat()

    return AnalysisCreateResponse(
        analysis_id=analysis["analysis_id"],
        summary=analysis["summary"],
        diagnoses=analysis["diagnoses"],
        diagnostic_tests=analysis["diagnostic_tests"],
        missing_info=analysis["missing_info"]
    )


@router.get("/{analysis_id}")
async def get_analysis(
    analysis_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get complete analysis results by ID

    - **analysis_id**: Analysis ID (e.g., ANA-2025-00001)

    Returns the complete analysis document including:
    - Clinical summary
    - Differential diagnoses with confidence scores
    - Evidence supporting each diagnosis
    - Suggested diagnostic tests
    - Missing information
    """
    service = AnalysisService(db)
    analysis = await service.get_analysis(analysis_id)

    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Analysis with ID {analysis_id} not found"
        )

    # Convert ObjectId to string
    analysis["_id"] = str(analysis["_id"])

    # Ensure datetime fields are properly serialized
    if "created_at" in analysis and hasattr(analysis["created_at"], "isoformat"):
        analysis["created_at"] = analysis["created_at"].isoformat()
    if "updated_at" in analysis and hasattr(analysis["updated_at"], "isoformat"):
        analysis["updated_at"] = analysis["updated_at"].isoformat()

    return analysis


@router.get("/dashboard/stats", response_model=DashboardStatsResponse)
async def get_dashboard_stats(
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get dashboard statistics for the current doctor

    Returns:
    - Total number of patients
    - Total number of analyses by this doctor
    - Number of analyses created in the last 7 days
    """
    service = AnalysisService(db)
    stats = await service.get_dashboard_stats(firebase_uid)

    return DashboardStatsResponse(**stats)
