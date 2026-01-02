"""
File upload routes for profile photos and other images
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Query
from fastapi.responses import JSONResponse
from firebase_admin import storage
import firebase_admin
import os
import uuid
from datetime import datetime

router = APIRouter()

# Initialize Firebase Storage bucket
try:
    if firebase_admin._apps:
        bucket = storage.bucket()
    else:
        bucket = None
except Exception as e:
    print(f"Warning: Firebase Storage not initialized: {e}")
    bucket = None


@router.post("/upload/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    user_id: str = Query(None, description="User ID for the avatar")
):
    """
    Upload a profile avatar image
    Returns the public URL of the uploaded image
    """
    try:
        if bucket is None:
            # Fallback: save to local directory if Firebase Storage not available
            upload_dir = "uploads/avatars"
            os.makedirs(upload_dir, exist_ok=True)
            
            # Generate unique filename
            file_ext = os.path.splitext(file.filename)[1] or ".jpg"
            filename = f"{user_id or uuid.uuid4()}_{datetime.now().timestamp()}{file_ext}"
            filepath = os.path.join(upload_dir, filename)
            
            # Save file
            with open(filepath, "wb") as buffer:
                content = await file.read()
                buffer.write(content)
            
            # Return full URL for local file (in production, this would be a public URL)
            # For local development, return a URL that can be accessed
            base_url = "http://localhost:8000"  # You might want to make this configurable
            return {
                "success": True,
                "avatar_url": f"{base_url}/uploads/avatars/{filename}",
                "message": "Image uploaded successfully"
            }
        
        # Use Firebase Storage
        file_ext = os.path.splitext(file.filename)[1] or ".jpg"
        filename = f"avatars/{user_id or uuid.uuid4()}_{datetime.now().timestamp()}{file_ext}"
        blob = bucket.blob(filename)
        
        # Upload file
        content = await file.read()
        blob.upload_from_string(content, content_type=file.content_type or "image/jpeg")
        
        # Make blob publicly accessible
        blob.make_public()
        
        # Get public URL
        avatar_url = blob.public_url
        
        return {
            "success": True,
            "avatar_url": avatar_url,
            "message": "Image uploaded successfully"
        }
    
    except Exception as e:
        print(f"Error in upload_avatar: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error uploading image: {str(e)}")


@router.get("/upload/test")
async def test_upload_endpoint():
    """Test endpoint to verify upload route is accessible"""
    return {"message": "Upload endpoint is accessible", "status": "ok"}

