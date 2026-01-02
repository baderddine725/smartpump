# Complete Project Setup Guide

## ✅ What's Fixed

1. **Profile Page**: Now fetches and displays real user data from backend
2. **Phone Number Formatting**: Automatically formats to E.164 format
3. **Backend API**: All endpoints work without Phone Authentication enabled
4. **User Data Storage**: Saves user data on login/signup

## 🔧 Required Firebase Setup

### 1. Enable Firestore Database
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `smartpump-38295`
3. Click **"Firestore Database"** in left menu
4. Click **"Create database"**
5. Choose **"Start in test mode"** (for development)
6. Select a location (choose closest to you)
7. Click **"Enable"**

**OR** enable via direct link:
```
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=smartpump-38295
```

### 2. Enable Email/Password Authentication
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Click on **"Email/Password"**
3. Enable it (toggle ON)
4. Click **"Save"**

### 3. Phone Authentication (Optional)
- You DON'T need to enable this anymore!
- The backend now uses email/password authentication
- Phone numbers are stored in Firestore only

## 🚀 How to Test

### Step 1: Start Backend
```bash
cd backend
python main.py
```

### Step 2: Run Flutter App
```bash
cd myapp
flutter run
```

### Step 3: Create Account
1. Go to "créer un compte"
2. Enter:
   - Name: `saleh`
   - Phone: `25252525`
   - Password: `yourpassword`
3. Click "Créer un compte"

### Step 4: Check Profile
1. After signup, you'll be logged in
2. Go to Profile page
3. You should see:
   - Name: `saleh`
   - Phone: `+125252525` (formatted)

## 📱 What Works Now

✅ **Signup**: Creates account with email/password, stores phone in Firestore
✅ **Login**: Authenticates and loads user data
✅ **Profile Page**: Shows real name and phone number from backend
✅ **Edit Profile**: Can update name (phone is read-only)
✅ **Logout**: Clears all stored data

## 🔍 Troubleshooting

### Profile shows "No name" or "No phone"
- Make sure Firestore is enabled
- Check backend logs for errors
- Verify user was created in Firestore (check Firebase Console)

### Still seeing old data
- Hot restart the Flutter app (press `R` in terminal)
- Or stop and run `flutter run` again

### Backend errors
- Make sure Firestore API is enabled
- Restart backend server
- Check Firebase service account JSON is in `backend/` folder

## 📝 Next Steps

1. **Enable Firestore** (if not done)
2. **Restart backend**
3. **Create account** with name "saleh" and phone "25252525"
4. **Check profile** - should show your real data!

Your project is now fully functional! 🎉

