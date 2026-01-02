"""
Authentication utilities
"""
from fastapi import HTTPException, Header
from firebase_admin import auth
from typing import Optional


async def verify_firebase_token(authorization: Optional[str] = Header(None)) -> dict:
    """
    Extract and verify Firebase ID token from Authorization header
    """
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    try:
        # Extract token from "Bearer <token>"
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")

        # Verify token
        decoded_token = auth.verify_id_token(token)
        return decoded_token

    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid authorization header format")
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")


def get_user_id_from_token(decoded_token: dict) -> str:
    """
    Extract user ID from decoded Firebase token
    """
    return decoded_token.get("uid")

