# Smart Solar Pump Backend API

A FastAPI-based backend for the Smart Solar Pump mobile application, integrated with Firebase for authentication and data storage.

## Features

- **Authentication**: User signup, login, password reset with verification codes
- **System Management**: CRUD operations for solar pump systems
- **User Profiles**: User profile management and updates
- **Alerts**: System alerts and notifications management
- **Monitoring**: Real-time metrics tracking and historical data

## Prerequisites

- Python 3.8 or higher
- Firebase project with Firestore enabled
- Firebase Admin SDK service account key

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Firebase Configuration

#### Option A: Using Service Account JSON File (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file as `firebase-service-account.json` in the `backend` directory
6. Add `firebase-service-account.json` to `.gitignore`

#### Option B: Using Environment Variables

1. Copy `.env.example` to `.env`
2. Extract the following from your Firebase service account JSON:
   - `project_id`
   - `private_key_id`
   - `private_key` (keep the `\n` characters)
   - `client_email`
   - `client_id`
3. Fill in the values in `.env`

### 3. Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your Firebase credentials
```

### 4. Run the Server

```bash
# Development mode
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## API Endpoints

### Authentication (`/api/auth`)

- `POST /api/auth/signup` - Create new user account
- `POST /api/auth/login` - Authenticate user
- `POST /api/auth/forgot-password` - Request password reset code
- `POST /api/auth/verify-code` - Verify reset code
- `POST /api/auth/reset-password` - Reset password with verified code
- `POST /api/auth/verify-token` - Verify Firebase ID token

### Systems (`/api/systems`)

- `GET /api/systems/?user_id={user_id}` - Get all user systems
- `GET /api/systems/{system_id}` - Get specific system
- `POST /api/systems/?user_id={user_id}` - Create new system
- `PUT /api/systems/{system_id}?user_id={user_id}` - Update system
- `DELETE /api/systems/{system_id}?user_id={user_id}` - Delete system

### Users (`/api/users`)

- `GET /api/users/{user_id}/profile` - Get user profile
- `PUT /api/users/{user_id}/profile` - Update user profile
- `DELETE /api/users/{user_id}` - Delete user account

### Alerts (`/api/alerts`)

- `GET /api/alerts/system/{system_id}` - Get system alerts
- `GET /api/alerts/user/{user_id}` - Get user alerts
- `POST /api/alerts/{alert_id}/resolve` - Resolve alert
- `DELETE /api/alerts/{alert_id}` - Delete alert
- `POST /api/alerts/create` - Create new alert

### Monitoring (`/api/monitoring`)

- `GET /api/monitoring/{system_id}/metrics` - Get current metrics
- `PUT /api/monitoring/{system_id}/metrics` - Update metrics
- `GET /api/monitoring/{system_id}/history` - Get metrics history
- `GET /api/monitoring/{system_id}/status` - Get system status

## Example Requests

### Sign Up

```bash
curl -X POST "http://localhost:8000/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "+1234567890",
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

### Login

```bash
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890",
    "password": "securepassword123"
  }'
```

### Create System

```bash
curl -X POST "http://localhost:8000/api/systems/?user_id=USER_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Solar Pump System 1",
    "description": "Main irrigation system",
    "location": "Farm A",
    "latitude": 40.7128,
    "longitude": -74.0060
  }'
```

### Update Metrics

```bash
curl -X PUT "http://localhost:8000/api/monitoring/SYSTEM_ID/metrics" \
  -H "Content-Type: application/json" \
  -d '{
    "current_power": "2500 W",
    "daily_energy": "45 kWh",
    "efficiency": "85%",
    "total_flow": "120 L/min"
  }'
```

## Firebase Firestore Structure

### Collections

- **users**: User profiles and account information
- **systems**: Solar pump system configurations
- **alerts**: System alerts and notifications
- **verification_codes**: Password reset verification codes
- **metrics_history**: Historical metrics data

### Example Document Structure

**users/{userId}**
```json
{
  "uid": "user123",
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "created_at": "2024-01-01T00:00:00",
  "systems": ["system1", "system2"],
  "profile": {
    "address": "123 Main St",
    "city": "New York",
    "country": "USA"
  }
}
```

**systems/{systemId}**
```json
{
  "name": "Solar Pump System 1",
  "description": "Main irrigation system",
  "owner_id": "user123",
  "status": "active",
  "metrics": {
    "current_power": "2500 W",
    "daily_energy": "45 kWh",
    "efficiency": "85%",
    "total_flow": "120 L/min"
  },
  "created_at": "2024-01-01T00:00:00"
}
```

## Security Notes

1. **Authentication**: In production, implement proper token extraction from Authorization headers
2. **CORS**: Update `allow_origins` in `main.py` to specific domains
3. **Rate Limiting**: Consider adding rate limiting for API endpoints
4. **Input Validation**: All inputs are validated using Pydantic models
5. **Error Handling**: Comprehensive error handling with appropriate HTTP status codes

## Development

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

### Code Formatting

```bash
pip install black isort
black .
isort .
```

## Deployment

### Using Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Variables for Production

- Set `FIREBASE_CREDENTIALS_PATH` or Firebase environment variables
- Configure proper CORS origins
- Use environment-specific configurations

## License

MIT License

