import os
import uuid
from pathlib import Path
from typing import List
from fastapi import UploadFile
from app.config import settings


class FileHandler:
    """
    Utility class for handling file uploads
    """

    @staticmethod
    def get_upload_path(file_type: str) -> Path:
        """
        Get upload directory path for specific file type

        Args:
            file_type: Type of file (audio/pdf/image)

        Returns:
            Path: Upload directory path
        """
        base_path = Path(settings.UPLOAD_DIR)
        upload_path = base_path / file_type

        # Create directory if it doesn't exist
        upload_path.mkdir(parents=True, exist_ok=True)

        return upload_path

    @staticmethod
    async def save_file(file: UploadFile, file_type: str) -> tuple[str, int]:
        """
        Save uploaded file to disk

        Args:
            file: UploadFile from FastAPI
            file_type: Type of file (audio/pdf/image)

        Returns:
            tuple: (stored_path, file_size)
        """
        # Generate unique filename
        file_extension = Path(file.filename).suffix if file.filename else ""
        unique_filename = f"{uuid.uuid4()}{file_extension}"

        # Get upload path
        upload_path = FileHandler.get_upload_path(file_type)
        file_path = upload_path / unique_filename

        # Reset file stream position before reading
        await file.seek(0)

        # Save file
        content = await file.read()

        if not content:
            raise ValueError(f"Empty file received: {file.filename}")

        with open(file_path, "wb") as f:
            f.write(content)

        # Get file size
        file_size = len(content)

        # Return absolute path for ML pipeline
        return str(file_path.resolve()), file_size

    @staticmethod
    async def save_files(files: List[UploadFile], file_type: str) -> List[dict]:
        """
        Save multiple files

        Args:
            files: List of UploadFile objects
            file_type: Type of files (audio/pdf/image)

        Returns:
            list: List of file metadata dicts
        """
        saved_files = []

        for file in files:
            stored_path, file_size = await FileHandler.save_file(file, file_type)
            saved_files.append({
                "file_type": file_type,
                "original_filename": file.filename,
                "stored_path": stored_path,
                "file_size": file_size
            })

        return saved_files

    @staticmethod
    def delete_file(file_path: str) -> bool:
        """
        Delete file from disk

        Args:
            file_path: Path to file

        Returns:
            bool: True if deleted, False if not found
        """
        try:
            Path(file_path).unlink()
            return True
        except FileNotFoundError:
            return False
