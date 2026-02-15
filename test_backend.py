#!/usr/bin/env python3

import requests
import json
import random
import string
from pprint import pprint

def test_backend():
    base_url = "http://localhost:8000"

    print("Testing FastAPI backend with PostgreSQL and JWT...")
    print(f"Base URL: {base_url}")
    print("=" * 60)

    # Test 1: Root endpoint
    print("\n1. Testing root endpoint:")
    try:
        response = requests.get(base_url)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error: {e}")

    # Test 2: Login endpoint with correct credentials
    print("\n2. Testing login with correct credentials (admin/secret):")
    try:
        response = requests.post(
            f"{base_url}/token",
            auth=("admin", "secret")
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2)}")
            print(f"Token type: JWT (starts with ey...)")
            token = data.get("access_token")
            username = data.get("user", {}).get("username")
        else:
            print(f"Response: {response.text}")
            token = None
            username = None
    except Exception as e:
        print(f"Error: {e}")
        token = None
        username = None

    # Test 3: Welcome endpoint with valid token
    if token and username:
        print("\n3. Testing welcome endpoint with valid token:")
        try:
            response = requests.get(
                f"{base_url}/welcome",
                params={"token": token, "username": username}
            )
            print(f"Status: {response.status_code}")
            print(f"Response: {json.dumps(response.json(), indent=2)}")
        except Exception as e:
            print(f"Error: {e}")

    # Test 4: Login endpoint with incorrect credentials
    print("\n4. Testing login with incorrect credentials:")
    try:
        response = requests.post(
            f"{base_url}/token",
            auth=("admin", "wrongpassword")
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

    # Test 5: Welcome endpoint with invalid token
    print("\n5. Testing welcome endpoint with invalid token:")
    try:
        response = requests.get(
            f"{base_url}/welcome",
            params={"token": "invalid_token_12345", "username": "admin"}
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

    # Test 6: User registration
    # Generate random username to avoid conflicts
    random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
    test_username = f"testuser_{random_suffix}"

    print(f"\n6. Testing user registration (username: {test_username}):")
    try:
        response = requests.post(
            f"{base_url}/register",
            json={
                "username": test_username,
                "password": "testpass123",
                "full_name": "Test User"
            }
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 201:
            print(f"Response: {json.dumps(response.json(), indent=2)}")

            # Test 7: Login with newly registered user
            print(f"\n7. Testing login with newly registered user ({test_username}):")
            response = requests.post(
                f"{base_url}/token",
                auth=(test_username, "testpass123")
            )
            print(f"Status: {response.status_code}")
            if response.status_code == 200:
                data = response.json()
                print(f"Response: {json.dumps(data, indent=2)}")
                new_token = data.get("access_token")
                new_username = data.get("user", {}).get("username")

                # Test 8: Welcome endpoint with new user's token
                print(f"\n8. Testing welcome endpoint with new user's token:")
                response = requests.get(
                    f"{base_url}/welcome",
                    params={"token": new_token, "username": new_username}
                )
                print(f"Status: {response.status_code}")
                print(f"Response: {json.dumps(response.json(), indent=2)}")
            else:
                print(f"Response: {response.text}")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

    # Test 9: Duplicate username registration (should fail)
    print("\n9. Testing duplicate username registration (should fail):")
    try:
        response = requests.post(
            f"{base_url}/register",
            json={
                "username": "admin",  # Already exists
                "password": "newpassword",
                "full_name": "Another Admin"
            }
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

    print("\n" + "=" * 60)
    print("All tests completed!")

if __name__ == "__main__":
    test_backend()