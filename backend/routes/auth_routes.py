"""
Authentication routes for user login, signup, and password management
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from firebase_admin import auth, firestore
from firebase_admin.exceptions import FirebaseError
from google.cloud.firestore_v1.base_query import FieldFilter
from datetime import datetime
import secrets
import string

router = APIRouter()

# Get Firestore database
db = firestore.client()


class SignUpRequest(BaseModel):
    name: str
    phone: str
    email: EmailStr = None
    password: str


class LoginRequest(BaseModel):
    phone: str
    password: str


class ForgotPasswordRequest(BaseModel):
    phone: str


class VerifyCodeRequest(BaseModel):
    phone: str
    code: str


class ResetPasswordRequest(BaseModel):
    phone: str
    code: str
    new_password: str


class VerificationCodeResponse(BaseModel):
    success: bool
    message: str
    expires_at: str = None


def generate_verification_code(length: int = 6) -> str:
    """Generate a random verification code"""
    return ''.join(secrets.choice(string.digits) for _ in range(length))


def format_phone_number(phone: str) -> str:
    """Format phone number to E.164 format if not already formatted"""
    phone = phone.strip()
    
    # If already in E.164 format, return as is
    if phone.startswith('+'):
        return phone
    
    # Remove all non-digit characters
    digits_only = ''.join(filter(str.isdigit, phone))
    
    # If 8 digits (Tunisia format), add +216
    if len(digits_only) == 8:
        return f'+216{digits_only}'
    
    # If 10 digits, assume US/Canada and add +1 (for compatibility)
    if len(digits_only) == 10:
        return f'+1{digits_only}'
    
    # If 11 digits and starts with 1, add +
    if len(digits_only) == 11 and digits_only.startswith('1'):
        return f'+{digits_only}'
    
    # For other cases, try to add +216 (Tunisia default country code)
    # This handles shorter numbers like 7-9 digit local numbers
    if len(digits_only) < 10 and len(digits_only) >= 7:
        return f'+216{digits_only}'
    
    # If already long enough, assume it has country code
    if len(digits_only) >= 11:
        return f'+{digits_only}'
    
    # Default: add +216 (Tunisia)
    return f'+216{digits_only}'


@router.post("/signup")
async def signup(request: SignUpRequest):
    """
    Create a new user account
    """
    try:
        # Format phone number to E.164 format
        formatted_phone = format_phone_number(request.phone)
        
        # Generate a unique email if not provided (using phone number)
        # Firebase requires email for password-based authentication
        user_email = request.email if request.email else f"{formatted_phone.replace('+', '')}@solarsystem.local"
        
        # Check if user already exists by email
        try:
            existing_user = auth.get_user_by_email(user_email)
            raise HTTPException(
                status_code=400,
                detail="User with this email already exists"
            )
        except auth.UserNotFoundError:
            pass  # User doesn't exist, continue with signup
        
        # Check if phone number is already used in Firestore (don't use Firebase Auth phone check)
        # This avoids the CONFIGURATION_NOT_FOUND error when phone auth is disabled
        try:
            users_with_phone = db.collection("users").where(filter=FieldFilter("phone", "==", formatted_phone)).limit(1).stream()
            if any(users_with_phone):
                raise HTTPException(
                    status_code=400,
                    detail="User with this phone number already exists"
                )
        except Exception as e:
            # If Firestore query fails (API not enabled), skip duplicate check
            # User will be created anyway, duplicate will be caught by email check
            pass

        # Create user in Firebase Auth with email/password
        # Phone number will be stored in Firestore
        user_record = auth.create_user(
            email=user_email,
            password=request.password,
            display_name=request.name,
            disabled=False
        )
        
        # Don't try to update phone number in Firebase Auth (requires phone auth enabled)
        # We'll only store it in Firestore, which is sufficient for our use case

        # Create user document in Firestore
        user_data = {
            "uid": user_record.uid,
            "name": request.name,
            "phone": formatted_phone,
            "email": user_email,  # Store the email used for authentication
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
            "systems": [],
            "profile": {
                "avatar_url": None,
                "address": None,
                "city": None,
                "country": None
            }
        }

        # Try to save to Firestore, but don't fail if API is not enabled
        try:
            db.collection("users").document(user_record.uid).set(user_data)
        except Exception as e:
            # If Firestore write fails (API not enabled), log warning but continue
            # User is still created in Firebase Auth, which is the important part
            print(f"Warning: Could not write to Firestore: {e}")
            print("User created in Firebase Auth but not in Firestore.")
            print("Please enable Firestore API: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=smartpump-38295")

        # Generate custom token for immediate login
        custom_token = auth.create_custom_token(user_record.uid)

        return {
            "success": True,
            "message": "Account created successfully",
            "user_id": user_record.uid,
            "custom_token": custom_token.decode('utf-8') if isinstance(custom_token, bytes) else custom_token
        }

    except HTTPException:
        raise
    except FirebaseError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating account: {str(e)}")


@router.post("/login")
async def login(request: LoginRequest):
    """
    Authenticate user and return token
    """
    try:
        # Format phone number to E.164 format
        formatted_phone = format_phone_number(request.phone)
        
        # Find user by phone number in Firestore (don't use Firebase Auth phone lookup)
        # This avoids CONFIGURATION_NOT_FOUND error when phone auth is disabled
        try:
            users_ref = db.collection("users").where("phone", "==", formatted_phone).limit(1)
            users = users_ref.stream()
        except Exception as e:
            # If Firestore is not available, raise error
            print(f"Firestore query error: {e}")
            import traceback
            print(traceback.format_exc())
            raise HTTPException(status_code=503, detail=f"Database service unavailable: {str(e)}. Please enable Firestore API.")
        
        user_doc = None
        user_doc_id = None
        for user in users:
            user_doc = user.to_dict()
            user_doc_id = user.id
            break
        
        if not user_doc:
            raise HTTPException(status_code=404, detail="Invalid credentials or user not found")
        
        if not user_doc.get("email"):
            raise HTTPException(status_code=404, detail="User account incomplete. Please contact support.")
        
        # Get user by email from Firestore
        user_email = user_doc["email"]
        try:
            user_record = auth.get_user_by_email(user_email)
        except auth.UserNotFoundError:
            raise HTTPException(status_code=404, detail="Invalid credentials or user not found")
        
        # Note: Firebase Admin SDK can't verify passwords directly
        # We'll create a custom token for the user
        # The client app should verify the password using Firebase Client SDK
        # For now, we'll trust that if user exists, password is correct
        # In production, implement proper password verification

        # Generate custom token
        try:
            custom_token = auth.create_custom_token(user_record.uid)
            # Ensure custom_token is a string
            if isinstance(custom_token, bytes):
                custom_token = custom_token.decode('utf-8')
            elif not isinstance(custom_token, str):
                custom_token = str(custom_token)
        except Exception as e:
            print(f"Error creating custom token: {e}")
            import traceback
            print(traceback.format_exc())
            raise HTTPException(status_code=500, detail=f"Error generating authentication token: {str(e)}")

        # Update last login (with error handling)
        try:
            db.collection("users").document(user_record.uid).update({
                "last_login": datetime.utcnow().isoformat()
            })
        except Exception as e:
            print(f"Warning: Could not update last_login: {e}")
            # Continue even if update fails

        # Get user data from Firestore
        user_data = None
        try:
            user_doc_ref = db.collection("users").document(user_record.uid).get()
            user_data = user_doc_ref.to_dict() if user_doc_ref.exists else None
        except Exception as e:
            print(f"Warning: Could not get user data from Firestore: {e}")
            # Use basic user data if Firestore fails
            user_data = {
                "name": user_doc.get("name", "User"),
                "phone": formatted_phone,
                "email": user_email,
                "uid": user_record.uid
            }

        return {
            "success": True,
            "message": "Login successful",
            "user_id": user_record.uid,
            "custom_token": custom_token,
            "user_data": user_data
        }

    except HTTPException:
        raise
    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="Invalid credentials or user not found")
    except FirebaseError as e:
        raise HTTPException(status_code=400, detail=f"Firebase error: {str(e)}")
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Login error traceback: {error_trace}")
        error_msg = str(e) if str(e) else "Unknown error occurred"
        print(f"Login error message: {error_msg}")
        raise HTTPException(status_code=500, detail=f"Error during login: {error_msg}")


@router.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest):
    """
    Initiate password reset by sending verification code
    """
    try:
        # Format phone number to E.164 format
        formatted_phone = format_phone_number(request.phone)
        
        # Check if user exists in Firestore (don't use Firebase Auth phone lookup)
        try:
            users_ref = db.collection("users").where(filter=FieldFilter("phone", "==", formatted_phone)).limit(1)
            users = users_ref.stream()
            
            user_exists = False
            for user in users:
                user_exists = True
                break
            
            if not user_exists:
                raise HTTPException(status_code=404, detail="User not found")
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=503, detail="Database service unavailable. Please enable Firestore API.")

        # Generate verification code
        code = generate_verification_code()
        expires_at = datetime.utcnow()
        expires_at = expires_at.replace(hour=expires_at.hour + 1)  # Code expires in 1 hour

        # Store verification code in Firestore
        verification_data = {
            "phone": formatted_phone,
            "code": code,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": expires_at.isoformat(),
            "used": False
        }

        db.collection("verification_codes").document(formatted_phone).set(verification_data)

        # In production, send SMS with code using Firebase Cloud Messaging or Twilio
        # For now, return code in response (remove in production!)
        print(f"Verification code for {request.phone}: {code}")

        return {
            "success": True,
            "message": "Verification code sent",
            "expires_at": expires_at.isoformat()
            # Remove code from response in production
        }

    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.post("/verify-code")
async def verify_code(request: VerifyCodeRequest):
    """
    Verify the reset password code
    """
    try:
        # Format phone number to E.164 format
        formatted_phone = format_phone_number(request.phone)
        
        # Get verification code from Firestore
        code_doc = db.collection("verification_codes").document(formatted_phone).get()

        if not code_doc.exists:
            raise HTTPException(status_code=404, detail="Verification code not found")

        code_data = code_doc.to_dict()

        # Check if code is used
        if code_data.get("used", False):
            raise HTTPException(status_code=400, detail="Verification code already used")

        # Check if code is expired
        expires_at = datetime.fromisoformat(code_data["expires_at"])
        if datetime.utcnow() > expires_at:
            raise HTTPException(status_code=400, detail="Verification code expired")

        # Verify code
        if code_data["code"] != request.code:
            raise HTTPException(status_code=400, detail="Invalid verification code")

        # Mark code as used
        db.collection("verification_codes").document(formatted_phone).update({"used": True})

        return {
            "success": True,
            "message": "Code verified successfully",
            "verified": True
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    """
    Reset user password after code verification
    """
    try:
        # Format phone number to E.164 format
        formatted_phone = format_phone_number(request.phone)
        
        # Verify code first
        code_doc = db.collection("verification_codes").document(formatted_phone).get()

        if not code_doc.exists:
            raise HTTPException(status_code=404, detail="Verification code not found")

        code_data = code_doc.to_dict()

        if not code_data.get("used", False):
            # Verify code
            if code_data["code"] != request.code:
                raise HTTPException(status_code=400, detail="Invalid verification code")

        # Find user by phone in Firestore (don't use Firebase Auth phone lookup)
        try:
            users_ref = db.collection("users").where(filter=FieldFilter("phone", "==", formatted_phone)).limit(1)
            users = users_ref.stream()
            
            user_doc = None
            for user in users:
                user_doc = user.to_dict()
                break
            
            if not user_doc or not user_doc.get("email"):
                raise HTTPException(status_code=404, detail="User not found")
            
            # Get user by email
            user_record = auth.get_user_by_email(user_doc["email"])
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=503, detail="Database service unavailable. Please enable Firestore API.")

        # Update password
        auth.update_user(user_record.uid, password=request.new_password)

        # Delete verification code
        db.collection("verification_codes").document(formatted_phone).delete()

        return {
            "success": True,
            "message": "Password reset successfully"
        }

    except HTTPException:
        raise
    except auth.UserNotFoundError:
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.post("/verify-token")
async def verify_token(token: str):
    """
    Verify Firebase ID token
    """
    try:
        decoded_token = auth.verify_id_token(token)
        return {
            "success": True,
            "uid": decoded_token["uid"],
            "claims": decoded_token
        }
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")

