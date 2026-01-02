# Enable Firestore API - Required!

## The Error

```
403 Cloud Firestore API has not been used in project smartpump-38295 before or it is disabled.
```

## Solution: Enable Firestore API

### Step 1: Go to Google Cloud Console
Click this link (or copy-paste):
```
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=smartpump-38295
```

### Step 2: Enable the API
1. You'll see the "Cloud Firestore API" page
2. Click the **"ENABLE"** button (big blue button)
3. Wait for it to enable (usually takes 10-30 seconds)

### Step 3: Verify It's Enabled
- You should see "API enabled" message
- Status should show as "Enabled"

### Step 4: Wait a Few Minutes
- Google says to wait a few minutes for changes to propagate
- Usually works within 1-2 minutes

### Step 5: Restart Your Backend
```bash
# Stop backend (Ctrl+C)
cd backend
python main.py
```

### Step 6: Test Again
Try the signup endpoint again in Swagger UI or your Flutter app.

## Alternative: Enable via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `smartpump-38295`
3. Go to **Firestore Database** in the left menu
4. Click **"Create database"** if you haven't already
5. Choose **"Start in test mode"** (for development)
6. Select a location
7. Click **"Enable"**

This will automatically enable the Firestore API.

## After Enabling

Once Firestore is enabled:
- ✅ Backend can write user data to Firestore
- ✅ Backend can query users by phone number
- ✅ No more 403 errors
- ✅ Signup will work completely

## Quick Test

After enabling and restarting backend, test with:
```json
{
  "name": "Test User",
  "phone": "21234234",
  "password": "test123456"
}
```

You should get a 200 OK response with user_id and token!

