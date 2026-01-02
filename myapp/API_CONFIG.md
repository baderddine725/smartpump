# API Configuration Guide

## Setting the API Base URL

The API base URL is configured in `lib/services/api_service.dart`. You need to update it based on where you're running the app:

### For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

### For iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

### For Physical Device:
1. Find your computer's IP address:
   - Windows: Run `ipconfig` in CMD and look for IPv4 Address
   - Mac/Linux: Run `ifconfig` or `ip addr` and look for your local IP
   
2. Update the base URL:
```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:8000/api';
// Example: 'http://192.168.1.100:8000/api'
```

### Important Notes:
- Make sure your backend server is running on port 8000
- Ensure your computer and device are on the same network
- For physical devices, you may need to allow the port in your firewall
- The backend must have CORS enabled (already configured in `backend/main.py`)

## Testing the Connection

1. Start your backend server:
   ```bash
   cd backend
   python main.py
   ```

2. Test the health endpoint:
   - Open browser: `http://localhost:8000/api/health`
   - Should return: `{"status": "healthy", "firebase_connected": true}`

3. Run your Flutter app and try logging in

## Troubleshooting

### Connection Refused Error
- Check if backend is running
- Verify the IP address is correct
- Ensure port 8000 is not blocked by firewall

### CORS Errors
- Backend already has CORS configured for all origins
- If issues persist, check `backend/main.py` CORS settings

### Timeout Errors
- Check network connection
- Verify backend is accessible from your device
- Try pinging the IP address from your device

