"""
Multimodal patient input ingestion.

Combines:
- Typed clinical text
- Audio input (via whisper.cpp)
- PDF reports (via pdfminer)
- Image reports (via pytesseract)

Returns a single merged text blob for downstream processing.
"""

import logging
from typing import List, Optional

from app.ml_pipeline.multimodal.audio_loader import transcribe_audio
from app.ml_pipeline.multimodal.pdf_loader import extract_text_from_pdf
from app.ml_pipeline.multimodal.image_loader import extract_text_from_image

logger = logging.getLogger(__name__)


def ingest_patient_inputs(
    typed_text: str,
    pdf_paths: Optional[List[str]] = None,
    image_paths: Optional[List[str]] = None,
    audio_paths: Optional[List[str]] = None
) -> str:
    """
    Merge all patient inputs into one text string.

    Parameters:
    - typed_text: Doctor-typed notes
    - pdf_paths: List of PDF file paths
    - image_paths: List of image file paths
    - audio_paths: List of audio file paths

    Returns:
    - Combined text string
    """

    combined_parts: List[str] = []

    # -----------------------------
    # Typed clinical text
    # -----------------------------
    if typed_text and typed_text.strip():
        combined_parts.append(typed_text.strip())

    # -----------------------------
    # Audio input (Whisper)
    # -----------------------------
    for audio_path in audio_paths or []:
        logger.info(f"Processing audio file: {audio_path}")
        try:
            audio_text = transcribe_audio(audio_path)
            if audio_text and audio_text.strip():
                logger.info(f"Audio transcription successful: {len(audio_text)} chars")
                combined_parts.append(f"[Transcribed Audio]\n{audio_text.strip()}")
            else:
                logger.warning(f"Empty transcription for: {audio_path}")
        except Exception as e:
            logger.error(f"Audio transcription failed for {audio_path}: {e}")
            # Don't silently fail - raise to alert user
            raise RuntimeError(f"Audio transcription failed: {e}")

    # -----------------------------
    # PDF reports
    # -----------------------------
    for pdf_path in pdf_paths or []:
        logger.info(f"Processing PDF: {pdf_path}")
        try:
            pdf_text = extract_text_from_pdf(pdf_path)
            if pdf_text and pdf_text.strip():
                combined_parts.append(f"[PDF Document]\n{pdf_text.strip()}")
        except Exception as e:
            logger.error(f"PDF extraction failed for {pdf_path}: {e}")

    # -----------------------------
    # Image reports
    # -----------------------------
    for image_path in image_paths or []:
        logger.info(f"Processing image: {image_path}")
        try:
            image_text = extract_text_from_image(image_path)
            if image_text and image_text.strip():
                combined_parts.append(f"[Image OCR]\n{image_text.strip()}")
        except Exception as e:
            logger.error(f"Image OCR failed for {image_path}: {e}")

    # -----------------------------
    # Final merged text
    # -----------------------------
    result = "\n\n".join(combined_parts).strip()
    logger.info(f"Combined text length: {len(result)} chars")
    return result
