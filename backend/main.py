"""
Main FastAPI application for Smart Solar Pump backend
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import firebase_admin
from firebase_admin import credentials, firestore, auth
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="Smart Solar Pump API",
    description="Backend API for Smart Solar Pump mobile application",
    version="1.0.0"
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase Admin SDK
try:
    # Check if Firebase is already initialized
    if not firebase_admin._apps:
        # Initialize with service account key file path or credentials dict
        cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-service-account.json")
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        else:
            # Try to initialize with environment variables
            cred_dict = {
                "type": "service_account",
                "project_id": os.getenv("FIREBASE_PROJECT_ID"),
                "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
                "private_key": os.getenv("FIREBASE_PRIVATE_KEY", "").replace("\\n", "\n"),
                "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
                "client_id": os.getenv("FIREBASE_CLIENT_ID"),
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            }
            if cred_dict["project_id"]:
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
            else:
                print("Warning: Firebase not initialized. Please configure Firebase credentials.")
except Exception as e:
    print(f"Firebase initialization error: {e}")

# Get Firestore database
db = firestore.client() if firebase_admin._apps else None

# Import routers
from routes import auth_routes, system_routes, user_routes, alert_routes, monitoring_routes, weather_routes, upload_routes

# Include routers
app.include_router(auth_routes.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(system_routes.router, prefix="/api/systems", tags=["Systems"])
app.include_router(user_routes.router, prefix="/api/users", tags=["Users"])
app.include_router(alert_routes.router, prefix="/api/alerts", tags=["Alerts"])
app.include_router(monitoring_routes.router, prefix="/api/monitoring", tags=["Monitoring"])
app.include_router(weather_routes.router, prefix="/api", tags=["Weather"])
app.include_router(upload_routes.router, prefix="/api", tags=["Upload"])

# Mount static files for serving uploaded images
if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Smart Solar Pump API",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "firebase_connected": db is not None
    }


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    return JSONResponse(
        status_code=500,
        content={"error": "Internal server error", "detail": str(exc)}
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

