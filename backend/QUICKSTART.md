# Quick Start Guide

## 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

## 2. Set Up Firebase

### Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click the gear icon ⚙️ → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. Save the JSON file as `firebase-service-account.json` in the `backend` folder

### Enable Firebase Services

In Firebase Console:
- **Authentication**: Enable Phone Number sign-in method
- **Firestore Database**: Create database in production/test mode

## 3. Run the Server

```bash
python main.py
```

Or with uvicorn:
```bash
uvicorn main:app --reload
```

The API will be available at: `http://localhost:8000`

## 4. Test the API

### Option A: Using the test script

```bash
# Install requests if not already installed
pip install requests

# Run the test script
python test_api.py
```

### Option B: Using curl

```bash
# Health check
curl http://localhost:8000/api/health

# Sign up
curl -X POST http://localhost:8000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"+1234567890","email":"test@example.com","password":"test123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+1234567890","password":"test123"}'
```

### Option C: Using Swagger UI

Open your browser and go to: `http://localhost:8000/docs`

You can test all endpoints directly from the Swagger interface!

## 5. Connect Your Flutter App

Update your Flutter app's API base URL to:
```dart
const String apiBaseUrl = 'http://localhost:8000/api';
// For Android emulator, use: http://10.0.2.2:8000/api
// For iOS simulator, use: http://localhost:8000/api
// For physical device, use your computer's IP: http://YOUR_IP:8000/api
```

## Common Issues

### Firebase Not Initialized Error

- Make sure `firebase-service-account.json` exists in the backend folder
- Check that the JSON file is valid
- Verify Firestore is enabled in Firebase Console

### Port Already in Use

- Change the port in `main.py` or use: `uvicorn main:app --port 8001`

### CORS Errors

- Update `allow_origins` in `main.py` to include your Flutter app's origin
- For development, `["*"]` is fine, but use specific origins in production

## Next Steps

1. Integrate the API with your Flutter app
2. Set up proper authentication token handling
3. Configure production environment variables
4. Deploy to a cloud service (Heroku, AWS, Google Cloud, etc.)

