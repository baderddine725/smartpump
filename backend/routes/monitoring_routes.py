"""
System monitoring routes for metrics and real-time data
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from firebase_admin import firestore
from datetime import datetime
from typing import Optional

router = APIRouter()
db = firestore.client()


class MetricsUpdate(BaseModel):
    current_power: Optional[str] = None
    daily_energy: Optional[str] = None
    efficiency: Optional[str] = None
    total_flow: Optional[str] = None
    voltage: Optional[float] = None
    current: Optional[float] = None
    temperature: Optional[float] = None
    pressure: Optional[float] = None


class SystemMetricsResponse(BaseModel):
    system_id: str
    metrics: dict
    timestamp: str
    updated_at: str


@router.get("/{system_id}/metrics")
async def get_system_metrics(system_id: str):
    """
    Get current metrics for a system
    """
    try:
        system_doc = db.collection("systems").document(system_id).get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()
        metrics = system_data.get("metrics", {})

        return {
            "system_id": system_id,
            "metrics": metrics,
            "updated_at": system_data.get("updated_at", "")
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching metrics: {str(e)}")


@router.put("/{system_id}/metrics")
async def update_system_metrics(system_id: str, metrics_update: MetricsUpdate):
    """
    Update system metrics (typically called by IoT devices)
    """
    try:
        system_ref = db.collection("systems").document(system_id)
        system_doc = system_ref.get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()
        current_metrics = system_data.get("metrics", {})

        # Update metrics
        if metrics_update.current_power is not None:
            current_metrics["current_power"] = metrics_update.current_power
        if metrics_update.daily_energy is not None:
            current_metrics["daily_energy"] = metrics_update.daily_energy
        if metrics_update.efficiency is not None:
            current_metrics["efficiency"] = metrics_update.efficiency
        if metrics_update.total_flow is not None:
            current_metrics["total_flow"] = metrics_update.total_flow
        if metrics_update.voltage is not None:
            current_metrics["voltage"] = metrics_update.voltage
        if metrics_update.current is not None:
            current_metrics["current"] = metrics_update.current
        if metrics_update.temperature is not None:
            current_metrics["temperature"] = metrics_update.temperature
        if metrics_update.pressure is not None:
            current_metrics["pressure"] = metrics_update.pressure

        # Update system document
        system_ref.update({
            "metrics": current_metrics,
            "updated_at": datetime.utcnow().isoformat(),
            "last_metrics_update": datetime.utcnow().isoformat()
        })

        # Store metrics history
        metrics_history = {
            "system_id": system_id,
            "metrics": current_metrics,
            "timestamp": datetime.utcnow().isoformat()
        }
        db.collection("metrics_history").add(metrics_history)

        return {
            "success": True,
            "message": "Metrics updated successfully",
            "metrics": current_metrics
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating metrics: {str(e)}")


@router.get("/{system_id}/history")
async def get_metrics_history(system_id: str, limit: int = 100):
    """
    Get historical metrics data for a system
    """
    try:
        history_ref = db.collection("metrics_history").where("system_id", "==", system_id)
        history = history_ref.order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()

        history_list = []
        for record in history:
            record_data = record.to_dict()
            record_data["id"] = record.id
            history_list.append(record_data)

        return history_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching history: {str(e)}")


@router.get("/{system_id}/status")
async def get_system_status(system_id: str):
    """
    Get overall system status and health
    """
    try:
        system_doc = db.collection("systems").document(system_id).get()

        if not system_doc.exists:
            raise HTTPException(status_code=404, detail="System not found")

        system_data = system_doc.to_dict()

        # Get active alerts count
        alerts_ref = db.collection("alerts").where("system_id", "==", system_id).where("resolved", "==", False)
        active_alerts = len(list(alerts_ref.stream()))

        # Get last metrics update time
        last_update = system_data.get("last_metrics_update")
        is_online = False
        if last_update:
            last_update_time = datetime.fromisoformat(last_update)
            time_diff = (datetime.utcnow() - last_update_time).total_seconds()
            is_online = time_diff < 300  # Online if updated within last 5 minutes

        return {
            "system_id": system_id,
            "status": system_data.get("status", "unknown"),
            "is_online": is_online,
            "active_alerts": active_alerts,
            "last_update": last_update,
            "metrics": system_data.get("metrics", {})
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching status: {str(e)}")

