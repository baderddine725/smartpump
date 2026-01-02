# How to Restart Backend Server

## Steps to Fix the Phone Number Error:

### 1. Stop the Current Backend Server
- Go to the terminal where your backend is running
- Press `Ctrl + C` to stop the server

### 2. Restart the Backend Server
```bash
cd backend
python main.py
```

Or if you're using uvicorn directly:
```bash
cd backend
uvicorn main:app --reload
```

### 3. Verify the Server Started
You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 4. Test the API
Open your browser and go to: `http://localhost:8000/docs`

### 5. Restart Your Flutter App
- Stop the Flutter app (if running)
- Run it again: `flutter run`

## Why This is Needed

The backend server needs to be restarted because:
- We modified the `auth_routes.py` file
- Python loads modules when the server starts
- Changes won't take effect until the server restarts

## Quick Check

After restarting, the phone number formatting should work:
- Input: `24564222` → Formatted: `+124564222`
- Input: `55555555` → Formatted: `+155555555`

The error should be gone! 🎉

