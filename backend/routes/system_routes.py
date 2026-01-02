"""
System management routes for CRUD operations on solar pump systems
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from firebase_admin import auth, firestore
from datetime import datetime
from typing import List, Optional

router = APIRouter()
db = firestore.client()


class SystemCreate(BaseModel):
    name: str
    description: Optional[str] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class SystemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class SystemResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: str
    updated_at: str
    owner_id: str


def verify_token(token: str) -> dict:
    """Verify Firebase ID token and return decoded token"""
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")


def get_current_user(token: str = Depends(lambda: None)) -> dict:
    """Dependency to get current user from token"""
    # In a real implementation, extract token from Authorization header
    # For now, this is a placeholder
    if not token:
        raise HTTPException(status_code=401, detail="Authentication required")
    return verify_token(token)


@router.get("/", response_model=List[SystemResponse])
async def get_user_systems(user_id: str):
    """
    Get all systems for a user
    """
    try:
        systems_ref = db.collection("systems").where("owner_id", "==", user_id)
        systems = systems_ref.stream()

        systems_list = []
        for system in systems:
            system_data = system.to_dict()
            system_data["id"] = system.id
            systems_list.append(system_data)

        return systems_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching systems: {str(e)}")


@router.get("/{system_id}", response_model=SystemResponse)
async def get_system(system_id: str):
    """
    Get a specific system by ID
    """
    try:
        system_doc = db.collection("systems").document(system_id).get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()
        system_data["id"] = system_doc.id
        return system_data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching system: {str(e)}")


@router.post("/", response_model=SystemResponse)
async def create_system(system: SystemCreate, user_id: str):
    """
    Create a new system
    """
    try:
        system_data = {
            "name": system.name,
            "description": system.description,
            "location": system.location,
            "latitude": system.latitude,
            "longitude": system.longitude,
            "owner_id": user_id,
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
            "status": "active",
            "metrics": {
                "current_power": "0 W",
                "daily_energy": "0 kWh",
                "efficiency": "0%",
                "total_flow": "0 L/min"
            }
        }

        # Create system document
        system_ref = db.collection("systems").document()
        system_ref.set(system_data)

        # Add system ID to user's systems list
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            systems_list = user_data.get("systems", [])
            systems_list.append(system_ref.id)
            user_ref.update({"systems": systems_list})

        system_data["id"] = system_ref.id
        return system_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating system: {str(e)}")


@router.put("/{system_id}", response_model=SystemResponse)
async def update_system(system_id: str, system_update: SystemUpdate, user_id: str):
    """
    Update a system
    """
    try:
        system_ref = db.collection("systems").document(system_id)
        system_doc = system_ref.get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()

        # Check ownership
        if system_data.get("owner_id") != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to update this system")

        # Prepare update data
        update_data = {"updated_at": datetime.utcnow().isoformat()}
        if system_update.name is not None:
            update_data["name"] = system_update.name
        if system_update.description is not None:
            update_data["description"] = system_update.description
        if system_update.location is not None:
            update_data["location"] = system_update.location
        if system_update.latitude is not None:
            update_data["latitude"] = system_update.latitude
        if system_update.longitude is not None:
            update_data["longitude"] = system_update.longitude

        # Update system
        system_ref.update(update_data)

        # Get updated system
        updated_doc = system_ref.get()
        updated_data = updated_doc.to_dict()
        updated_data["id"] = system_id

        return updated_data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating system: {str(e)}")


@router.delete("/{system_id}")
async def delete_system(system_id: str, user_id: str):
    """
    Delete a system
    """
    try:
        system_ref = db.collection("systems").document(system_id)
        system_doc = system_ref.get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()

        # Check ownership
        if system_data.get("owner_id") != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to delete this system")

        # Delete system
        system_ref.delete()

        # Remove system ID from user's systems list
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            systems_list = user_data.get("systems", [])
            if system_id in systems_list:
                systems_list.remove(system_id)
                user_ref.update({"systems": systems_list})

        return {"success": True, "message": "System deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting system: {str(e)}")

