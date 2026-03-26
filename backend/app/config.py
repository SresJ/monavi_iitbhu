from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables
    """

    # MongoDB Configuration
    MONGODB_URI: str = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "clinical_dashboard"

    # Firebase Configuration
    FIREBASE_SERVICE_ACCOUNT_PATH: Optional[str] = None

    # OpenAI Configuration
    OPENAI_API_KEY: str

    # Application Settings
    APP_NAME: str = "Clinical Dashboard API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # CORS Settings - Allow all origins in development
    CORS_ORIGINS: list = ["*"]

    # File Upload Settings
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB

    # ML Pipeline Settings
    DATA_DIR: str = "data"
    WHISPER_MODEL_PATH: str = "whisper/whisper.cpp/models/ggml-medium.bin"
    WHISPER_CLI_PATH: str = "whisper/whisper.cpp/build/bin/whisper-cli"

    class Config:
        env_file = ".env"
        case_sensitive = True


# Global settings instance
settings = Settings()
