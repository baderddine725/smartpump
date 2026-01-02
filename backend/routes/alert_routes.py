"""
Alert management routes for system alerts and notifications
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from firebase_admin import firestore
from datetime import datetime
from typing import List, Optional

router = APIRouter()
db = firestore.client()


class AlertResponse(BaseModel):
    id: str
    system_id: str
    title: str
    subtitle: str
    severity: str
    created_at: str
    resolved: bool
    resolved_at: Optional[str] = None


@router.get("/system/{system_id}")
async def get_system_alerts(system_id: str, resolved: Optional[bool] = None):
    """
    Get all alerts for a specific system
    """
    try:
        alerts_ref = db.collection("alerts").where("system_id", "==", system_id)

        if resolved is not None:
            alerts_ref = alerts_ref.where("resolved", "==", resolved)

        alerts = alerts_ref.order_by("created_at", direction=firestore.Query.DESCENDING).stream()

        alerts_list = []
        for alert in alerts:
            alert_data = alert.to_dict()
            alert_data["id"] = alert.id
            alerts_list.append(alert_data)

        return alerts_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching alerts: {str(e)}")


@router.get("/user/{user_id}")
async def get_user_alerts(user_id: str, resolved: Optional[bool] = None):
    """
    Get all alerts for all systems owned by a user
    """
    try:
        # Get user's systems
        user_doc = db.collection("users").document(user_id).get()
        if not user_doc.exists:
            raise HTTPException(status_code=404, detail="User not found")

        user_data = user_doc.to_dict()
        system_ids = user_data.get("systems", [])

        if not system_ids:
            return []

        # Get alerts for all systems
        all_alerts = []
        for system_id in system_ids:
            alerts_ref = db.collection("alerts").where("system_id", "==", system_id)
            if resolved is not None:
                alerts_ref = alerts_ref.where("resolved", "==", resolved)

            alerts = alerts_ref.stream()
            for alert in alerts:
                alert_data = alert.to_dict()
                alert_data["id"] = alert.id
                all_alerts.append(alert_data)

        # Sort by created_at descending
        all_alerts.sort(key=lambda x: x.get("created_at", ""), reverse=True)

        return all_alerts

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching alerts: {str(e)}")


@router.post("/{alert_id}/resolve")
async def resolve_alert(alert_id: str):
    """
    Mark an alert as resolved
    """
    try:
        alert_ref = db.collection("alerts").document(alert_id)
        alert_doc = alert_ref.get()

        if not alert_doc.exists:
            raise HTTPException(status_code=404, detail="Alert not found")

        alert_ref.update({
            "resolved": True,
            "resolved_at": datetime.utcnow().isoformat()
        })

        return {"success": True, "message": "Alert resolved successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error resolving alert: {str(e)}")


@router.delete("/{alert_id}")
async def delete_alert(alert_id: str):
    """
    Delete an alert
    """
    try:
        alert_ref = db.collection("alerts").document(alert_id)
        alert_doc = alert_ref.get()

        if not alert_doc.exists:
            raise HTTPException(status_code=404, detail="Alert not found")

        alert_ref.delete()

        return {"success": True, "message": "Alert deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting alert: {str(e)}")


@router.post("/create")
async def create_alert(system_id: str, title: str, subtitle: str, severity: str = "medium"):
    """
    Create a new alert (typically called by monitoring system)
    """
    try:
        alert_data = {
            "system_id": system_id,
            "title": title,
            "subtitle": subtitle,
            "severity": severity,  # low, medium, high, critical
            "created_at": datetime.utcnow().isoformat(),
            "resolved": False
        }

        alert_ref = db.collection("alerts").document()
        alert_ref.set(alert_data)

        alert_data["id"] = alert_ref.id
        return alert_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating alert: {str(e)}")

