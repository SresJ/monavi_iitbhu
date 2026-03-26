import logging
from pathlib import Path
from openai import OpenAI
from app.config import settings

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.OPENAI_API_KEY)


def transcribe_audio(audio_path: str) -> str:
    """
    Transcribe audio using OpenAI Whisper API
    """
    audio_path = Path(audio_path)
    logger.info(f"Transcribing audio: {audio_path}")

    if not audio_path.exists():
        raise FileNotFoundError(f"Audio file not found: {audio_path}")

    try:
        with open(audio_path, "rb") as audio_file:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                response_format="text"
            )

        transcription = response.strip() if isinstance(response, str) else str(response).strip()
        logger.info(f"Transcription successful ({len(transcription)} chars): {transcription[:100]}...")

        return transcription

    except Exception as e:
        logger.error(f"OpenAI Whisper transcription failed: {e}")
        raise RuntimeError(f"Audio transcription failed: {e}")
