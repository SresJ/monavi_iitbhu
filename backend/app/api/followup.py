from fastapi import APIRouter, Depends, HTTPException, status
from app.middleware.firebase_middleware import verify_firebase_token
from app.database import get_database
from app.services.analysis_service import AnalysisService
from app.schemas.analysis import FollowupQuestionRequest, FollowupQuestionResponse
from motor.motor_asyncio import AsyncIOMotorDatabase
from datetime import datetime


router = APIRouter(prefix="/analysis", tags=["Follow-up Q&A"])


@router.post("/{analysis_id}/followup", response_model=FollowupQuestionResponse)
async def ask_followup_question(
    analysis_id: str,
    request: FollowupQuestionRequest,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Ask a follow-up question about a clinical analysis

    This endpoint uses the ML pipeline to answer questions based on:
    - Clinical summary
    - Differential diagnoses
    - Retrieved evidence from medical literature

    The system provides context-aware answers constrained to the available
    evidence and does not introduce new diagnoses or unsupported claims.

    - **analysis_id**: Analysis ID (e.g., ANA-2025-00001)
    - **question**: Follow-up question about the analysis

    Example questions:
    - "What are the risk factors for this diagnosis?"
    - "What additional tests should be ordered?"
    - "How should this condition be treated?"
    """
    service = AnalysisService(db)

    # Verify analysis exists
    analysis = await service.get_analysis(analysis_id)
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Analysis with ID {analysis_id} not found"
        )

    try:
        answer, asked_at = await service.ask_followup_question(
            analysis_id=analysis_id,
            question=request.question
        )

        return FollowupQuestionResponse(
            answer=answer,
            asked_at=asked_at
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process question: {str(e)}"
        )


@router.get("/{analysis_id}/followup")
async def get_followup_history(
    analysis_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get all follow-up questions and answers for an analysis

    - **analysis_id**: Analysis ID (e.g., ANA-2025-00001)

    Returns the complete conversation history with timestamps
    """
    service = AnalysisService(db)

    # Verify analysis exists
    analysis = await service.get_analysis(analysis_id)
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Analysis with ID {analysis_id} not found"
        )

    # Get conversation history
    conversation = await service.followup_collection.find_one({"analysis_id": analysis_id})

    if not conversation:
        return {
            "analysis_id": analysis_id,
            "total_questions": 0,
            "qa_pairs": []
        }

    # Convert ObjectId to string
    conversation["_id"] = str(conversation["_id"])

    # Ensure datetime fields are properly serialized in qa_pairs
    for qa_pair in conversation.get("qa_pairs", []):
        if "asked_at" in qa_pair and hasattr(qa_pair["asked_at"], "isoformat"):
            qa_pair["asked_at"] = qa_pair["asked_at"].isoformat()

    return {
        "analysis_id": analysis_id,
        "total_questions": len(conversation["qa_pairs"]),
        "qa_pairs": conversation["qa_pairs"]
    }
