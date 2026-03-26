from fastapi import Header, HTTPException, status
from typing import Optional
import firebase_admin
from firebase_admin import credentials, auth
from app.config import settings
import os


# Initialize Firebase Admin SDK
def initialize_firebase():
    """
    Initialize Firebase Admin SDK with service account credentials
    """
    if not firebase_admin._apps:
        if settings.FIREBASE_SERVICE_ACCOUNT_PATH and os.path.exists(settings.FIREBASE_SERVICE_ACCOUNT_PATH):
            cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_PATH)
            firebase_admin.initialize_app(cred)
            print("Firebase Admin SDK initialized successfully")
        else:
            print("WARNING: Firebase service account not found. Authentication will not work.")


async def verify_firebase_token(authorization: Optional[str] = Header(None)) -> str:
    """
    Verify Firebase UID from Authorization header

    Args:
        authorization: Authorization header containing Firebase UID

    Returns:
        str: Firebase UID if valid

    Raises:
        HTTPException: If authorization header is missing or invalid
    """
    # Allow missing authorization for OPTIONS preflight requests
    # (CORS middleware handles OPTIONS, but dependency is still called)
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )

    # Extract token from "Bearer <token>" format
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication scheme"
            )
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format"
        )

    # For development: If Firebase is not initialized, skip verification
    if not firebase_admin._apps:
        print(f"WARNING: Firebase not initialized, using token as-is: {token}")
        return token

    # Verify Firebase UID (Note: In production, you'd verify the ID token)
    # For now, we're using UID directly as per user requirement
    try:
        # In production, you should verify the ID token like this:
        # decoded_token = auth.verify_id_token(token)
        # return decoded_token['uid']

        # For now, we'll just return the token as Firebase UID
        # You can add actual Firebase token verification here
        return token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Firebase token: {str(e)}"
        )
