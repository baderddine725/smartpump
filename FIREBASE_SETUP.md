# Firebase Setup Instructions

## Current Issue

The error "No auth provider found for the given identifier (CONFIGURATION_NOT_FOUND)" means Firebase Phone Authentication is not enabled.

## Solution Options

### Option 1: Enable Phone Authentication (Recommended for Production)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Click on **Phone** provider
5. Enable it
6. For testing, you can use Firebase's test phone numbers
7. For production, you'll need to configure reCAPTCHA

### Option 2: Use Email/Password Authentication (Current Implementation)

The backend has been updated to:
- Create users with email/password (required by Firebase)
- Store phone number in Firestore
- Generate email from phone if not provided: `+1234567890` → `1234567890@solarsystem.local`

**How it works:**
- User signs up with phone number
- Backend creates account with email (auto-generated from phone)
- Phone number is stored in Firestore
- User can login with phone number (backend looks up email from Firestore)

## Testing

After restarting the backend, try:
1. Sign up with phone: `+21623000000`
2. Backend will create account with email: `21623000000@solarsystem.local`
3. Login with the same phone number

## Next Steps

1. **Restart your backend server** (to load the new code)
2. **Try signing up again**
3. If you want phone authentication, enable it in Firebase Console

