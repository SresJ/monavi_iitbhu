from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import FileResponse
from app.middleware.firebase_middleware import verify_firebase_token
from app.database import get_database
from app.services.analysis_service import AnalysisService
from motor.motor_asyncio import AsyncIOMotorDatabase
import os
from pathlib import Path

# Import PDF exporter from ML pipeline
from app.ml_pipeline.export.pdf_exporter import export_summary_to_pdf


router = APIRouter(prefix="/export", tags=["Export"])


@router.get("/pdf/{analysis_id}")
async def export_analysis_to_pdf(
    analysis_id: str,
    firebase_uid: str = Depends(verify_firebase_token),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Export clinical analysis to PDF format

    - **analysis_id**: Analysis ID (e.g., ANA-2025-00001)

    Returns a PDF file containing:
    - Patient summary
    - Differential diagnoses with confidence scores
    - Supporting evidence
    - Suggested diagnostic tests
    - Missing information alerts

    The PDF can be saved, printed, or shared with the patient or referring physicians.
    """
    service = AnalysisService(db)

    # Get analysis
    analysis = await service.get_analysis(analysis_id)
    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Analysis with ID {analysis_id} not found"
        )

    # Prepare summary text for PDF
    summary_text = analysis["summary"]["formatted_summary"]

    # Add diagnoses section
    summary_text += "\n\n" + "="*60 + "\n"
    summary_text += "DIFFERENTIAL DIAGNOSES\n"
    summary_text += "="*60 + "\n\n"

    for i, diag in enumerate(analysis["diagnoses"], 1):
        summary_text += f"{i}. {diag['diagnosis_name']}\n"
        summary_text += f"   Confidence: {diag['confidence']:.2f} ({diag['confidence_level'].upper()})\n"

        if diag.get('triggering_symptoms'):
            summary_text += f"   Triggering Symptoms: {', '.join(diag['triggering_symptoms'])}\n"

        if diag.get('confidence_rationale'):
            summary_text += "   Rationale:\n"
            for rationale in diag['confidence_rationale']:
                summary_text += f"     • {rationale}\n"

        if diag.get('evidence'):
            summary_text += "   Evidence:\n"
            for ev in diag['evidence'][:2]:  # Limit to top 2 evidence items
                summary_text += f"     • {ev['evidence_text'][:100]}...\n"
                summary_text += f"       Source: {ev['source_url']}\n"

        summary_text += "\n"

    # Add diagnostic tests section
    if analysis["diagnostic_tests"]:
        summary_text += "\n" + "="*60 + "\n"
        summary_text += "SUGGESTED DIAGNOSTIC TESTS\n"
        summary_text += "="*60 + "\n\n"

        for test in analysis["diagnostic_tests"]:
            summary_text += f"• {test['test_name']}\n"
            summary_text += f"  Rationale: {test['rationale']}\n\n"

    # Add missing information section
    if analysis["missing_info"]:
        summary_text += "\n" + "="*60 + "\n"
        summary_text += "MISSING / UNCLEAR INFORMATION\n"
        summary_text += "="*60 + "\n\n"

        for info in analysis["missing_info"]:
            summary_text += f"• {info}\n"

    # Generate PDF filename
    pdf_filename = f"clinical_analysis_{analysis_id}.pdf"
    pdf_path = Path("uploads") / pdf_filename

    # Ensure uploads directory exists
    Path("uploads").mkdir(exist_ok=True)

    try:
        # Export to PDF using ML pipeline
        export_summary_to_pdf(summary_text, str(pdf_path))

        # Return PDF file
        return FileResponse(
            path=str(pdf_path),
            media_type="application/pdf",
            filename=pdf_filename,
            headers={
                "Content-Disposition": f"attachment; filename={pdf_filename}"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate PDF: {str(e)}"
        )
