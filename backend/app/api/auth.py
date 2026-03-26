from fastapi import APIRouter, Depends, HTTPException, status
from app.middleware.firebase_middleware import verify_firebase_token
from app.database import get_database
from app.services.firebase_service import FirebaseService
from app.schemas.auth import DoctorVerifyRequest, DoctorVerifyResponse
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo.errors import DuplicateKeyError
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/verify", response_model=DoctorVerifyResponse)
async def verify_doctor(
    request: DoctorVerifyRequest,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Verify Firebase UID and create/update doctor record

    Edge cases handled:
    - New Firebase user → Create doctor record
    - Existing Firebase user → Update doctor information
    - Duplicate email → Return error
    - Database errors → Proper error handling
    - Invalid input → Validation errors

    - **firebase_uid**: Automatically extracted from Authorization header
    - **email**: Doctor's email address
    - **full_name**: Doctor's full name
    - **specialty**: Medical specialty (optional)

    Returns doctor_id and whether this is a new registration
    """
    try:
        # Validate Firebase UID format (basic check)
        if not firebase_uid or len(firebase_uid) < 10:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid Firebase UID format"
            )

        # Validate email and full_name are provided
        if not request.email or not request.full_name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email and full name are required"
            )

        service = FirebaseService(db)

        # Check for email conflicts (different Firebase UID, same email)
        existing_doctor_by_email = await service.get_doctor_by_email(request.email)
        if existing_doctor_by_email and existing_doctor_by_email["firebase_uid"] != firebase_uid:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Email {request.email} is already registered to another account"
            )

        # Create or update doctor
        doctor_id, is_new = await service.verify_and_create_doctor(
            firebase_uid=firebase_uid,
            email=request.email,
            full_name=request.full_name,
            specialty=request.specialty
        )

        message = "Doctor created successfully" if is_new else "Doctor verified successfully"
        logger.info(f"{'Created' if is_new else 'Updated'} doctor: {doctor_id}, UID: {firebase_uid}")

        return DoctorVerifyResponse(
            doctor_id=doctor_id,
            message=message,
            is_new=is_new
        )

    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise

    except DuplicateKeyError as e:
        # Handle MongoDB unique constraint violations
        logger.error(f"Duplicate key error during doctor verification: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This email or Firebase UID is already registered"
        )

    except Exception as e:
        # Log unexpected errors
        logger.error(f"Unexpected error during doctor verification: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while verifying your account. Please try again."
        )


@router.get("/me")
async def get_current_doctor(
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get current doctor information

    Edge cases handled:
    - Doctor not found → 404 with helpful message
    - Database errors → Proper error handling
    - Invalid Firebase UID → 401 from middleware

    Returns the doctor profile for the authenticated user
    """
    try:
        # Validate Firebase UID
        if not firebase_uid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )

        service = FirebaseService(db)
        doctor = await service.get_doctor_by_uid(firebase_uid)

        if not doctor:
            logger.warning(f"Doctor profile not found for Firebase UID: {firebase_uid}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Doctor profile not found. Please complete registration by calling /api/auth/verify first."
            )

        # Convert ObjectId to string and rename _id to doctor_id for frontend compatibility
        doctor_response = {
            "doctor_id": str(doctor["_id"]),
            "firebase_uid": doctor["firebase_uid"],
            "email": doctor["email"],
            "full_name": doctor["full_name"],
            "specialty": doctor.get("specialty"),  # Can be None
            "created_at": doctor["created_at"].isoformat() if isinstance(doctor.get("created_at"), datetime) else doctor.get("created_at"),
            "updated_at": doctor["updated_at"].isoformat() if isinstance(doctor.get("updated_at"), datetime) else doctor.get("updated_at")
        }

        logger.info(f"Retrieved doctor profile: {doctor['firebase_uid']}")
        return doctor_response

    except HTTPException:
        # Re-raise HTTP exceptions
        raise

    except Exception as e:
        # Log unexpected errors
        logger.error(f"Error retrieving doctor profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while retrieving your profile. Please try again."
        )
