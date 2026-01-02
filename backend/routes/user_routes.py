"""
User profile management routes
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from firebase_admin import auth, firestore
from google.cloud.firestore_v1.base_query import FieldFilter
from datetime import datetime
from typing import Optional

router = APIRouter()
db = firestore.client()


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    address: Optional[str] = None
    city: Optional[str] = None
    country: Optional[str] = None
    avatar_url: Optional[str] = None


class UserProfileResponse(BaseModel):
    uid: str
    name: str
    phone: str
    email: Optional[str] = None
    created_at: str
    updated_at: str
    profile: dict


@router.get("/{user_id}/profile")
async def get_user_profile(user_id: str):
    """
    Get user profile information
    """
    try:
        user_doc = db.collection("users").document(user_id).get()

        if not user_doc.exists:
            raise HTTPException(status_code=404, detail="User not found")

        user_data = user_doc.to_dict()
        return user_data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching profile: {str(e)}")


@router.put("/{user_id}/profile")
async def update_user_profile(user_id: str, profile_update: ProfileUpdate):
    """
    Update user profile information
    """
    try:
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()

        if not user_doc.exists:
            raise HTTPException(status_code=404, detail="User not found")

        # Prepare update data
        update_data = {"updated_at": datetime.utcnow().isoformat()}

        # Update Firestore user document
        if profile_update.name is not None:
            update_data["name"] = profile_update.name
            # Also update Firebase Auth display name
            try:
                auth.update_user(user_id, display_name=profile_update.name)
            except Exception:
                pass  # Continue even if Auth update fails

        if profile_update.email is not None:
            update_data["email"] = profile_update.email
            # Also update Firebase Auth email
            try:
                auth.update_user(user_id, email=profile_update.email)
            except Exception:
                pass

        # Update profile subdocument
        profile_updates = {}
        if profile_update.address is not None:
            profile_updates["address"] = profile_update.address
        if profile_update.city is not None:
            profile_updates["city"] = profile_update.city
        if profile_update.country is not None:
            profile_updates["country"] = profile_update.country
        if profile_update.avatar_url is not None:
            profile_updates["avatar_url"] = profile_update.avatar_url

        if profile_updates:
            # Get current profile or create new
            user_data = user_doc.to_dict()
            current_profile = user_data.get("profile", {})
            current_profile.update(profile_updates)
            update_data["profile"] = current_profile

        # Update user document
        user_ref.update(update_data)

        # Get updated user data
        updated_doc = user_ref.get()
        return updated_doc.to_dict()

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating profile: {str(e)}")


@router.delete("/{user_id}")
async def delete_user_account(user_id: str):
    """
    Delete user account (soft delete - mark as disabled)
    """
    try:
        # Disable user in Firebase Auth
        auth.update_user(user_id, disabled=True)

        # Mark as deleted in Firestore
        db.collection("users").document(user_id).update({
            "deleted": True,
            "deleted_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        })

        return {"success": True, "message": "Account deleted successfully"}

    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting account: {str(e)}")

