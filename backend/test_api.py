"""
Simple script to test the API endpoints
Run this after starting the server to verify everything works
"""
import requests
import json

BASE_URL = "http://localhost:8000"


def test_health_check():
    """Test health check endpoint"""
    print("Testing health check...")
    response = requests.get(f"{BASE_URL}/api/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")


def test_signup():
    """Test user signup"""
    print("Testing signup...")
    data = {
        "name": "Test User",
        "phone": "+1234567890",
        "email": "test@example.com",
        "password": "testpassword123"
    }
    response = requests.post(f"{BASE_URL}/api/auth/signup", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.json() if response.status_code == 200 else None


def test_login():
    """Test user login"""
    print("Testing login...")
    data = {
        "phone": "+1234567890",
        "password": "testpassword123"
    }
    response = requests.post(f"{BASE_URL}/api/auth/login", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.json() if response.status_code == 200 else None


def test_create_system(user_id):
    """Test creating a system"""
    print("Testing create system...")
    data = {
        "name": "Test Solar Pump System",
        "description": "Test system for API",
        "location": "Test Farm",
        "latitude": 40.7128,
        "longitude": -74.0060
    }
    response = requests.post(f"{BASE_URL}/api/systems/?user_id={user_id}", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.json() if response.status_code == 200 else None


def test_get_systems(user_id):
    """Test getting user systems"""
    print("Testing get systems...")
    response = requests.get(f"{BASE_URL}/api/systems/?user_id={user_id}")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")


def test_update_metrics(system_id):
    """Test updating system metrics"""
    print("Testing update metrics...")
    data = {
        "current_power": "2500 W",
        "daily_energy": "45 kWh",
        "efficiency": "85%",
        "total_flow": "120 L/min"
    }
    response = requests.put(f"{BASE_URL}/api/monitoring/{system_id}/metrics", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")


if __name__ == "__main__":
    print("=" * 50)
    print("API Testing Script")
    print("=" * 50)
    print()

    try:
        # Test health check
        test_health_check()

        # Test signup (may fail if user already exists)
        signup_result = test_signup()

        # Test login
        login_result = test_login()
        if login_result:
            user_id = login_result.get("user_id")

            # Test creating a system
            system_result = test_create_system(user_id)
            if system_result:
                system_id = system_result.get("id")

                # Test getting systems
                test_get_systems(user_id)

                # Test updating metrics
                test_update_metrics(system_id)

        print("=" * 50)
        print("Testing complete!")
        print("=" * 50)

    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to the API server.")
        print("Make sure the server is running on http://localhost:8000")
    except Exception as e:
        print(f"Error: {e}")

