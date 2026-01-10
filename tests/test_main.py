import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.security import generate_jwt

client = TestClient(app)


class TestDevOpsEndpoint:

    def test_root_endpoint(self):
        """Test root endpoint returns status ok"""
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}

    def test_health_endpoint(self):
        """Test health endpoint returns status ok"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}

    def test_devops_post_valid_request(self):
        """Test POST /DevOps with valid data and headers"""
        jwt_token = generate_jwt()
        headers = {
            "X-Parse-REST-API-Key": "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c",
            "X-JWT-KWY": jwt_token,
            "Content-Type": "application/json",
        }
        payload = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }

        response = client.post("/DevOps", headers=headers, json=payload)
        assert response.status_code == 200
        assert response.json() == {
            "message": "Hello Juan Perez your message will be send"
        }

    def test_devops_post_invalid_api_key(self):
        """Test POST /DevOps with invalid API key"""
        jwt_token = generate_jwt()
        headers = {
            "X-Parse-REST-API-Key": "invalid-api-key",
            "X-JWT-KWY": jwt_token,
            "Content-Type": "application/json",
        }
        payload = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }

        response = client.post("/DevOps", headers=headers, json=payload)
        assert response.status_code == 401

    def test_devops_post_invalid_jwt(self):
        """Test POST /DevOps with invalid JWT"""
        headers = {
            "X-Parse-REST-API-Key": "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c",
            "X-JWT-KWY": "invalid-jwt-token",
            "Content-Type": "application/json",
        }
        payload = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }

        response = client.post("/DevOps", headers=headers, json=payload)
        assert response.status_code == 401

    def test_devops_post_missing_headers(self):
        """Test POST /DevOps without required headers"""
        payload = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }

        response = client.post("/DevOps", json=payload)
        assert response.status_code == 401  # Returns 401 when headers are missing

    def test_devops_get_method(self):
        """Test GET /DevOps returns ERROR"""
        response = client.get("/DevOps")
        assert response.status_code == 200
        assert response.text == '"ERROR"'

    def test_devops_put_method(self):
        """Test PUT /DevOps returns ERROR"""
        response = client.put("/DevOps")
        assert response.status_code == 200
        assert response.text == '"ERROR"'

    def test_devops_delete_method(self):
        """Test DELETE /DevOps returns ERROR"""
        response = client.delete("/DevOps")
        assert response.status_code == 200
        assert response.text == '"ERROR"'

    def test_devops_patch_method(self):
        """Test PATCH /DevOps returns ERROR"""
        response = client.patch("/DevOps")
        assert response.status_code == 200
        assert response.text == '"ERROR"'

    def test_devops_post_invalid_payload(self):
        """Test POST /DevOps with invalid payload structure"""
        jwt_token = generate_jwt()
        headers = {
            "X-Parse-REST-API-Key": "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c",
            "X-JWT-KWY": jwt_token,
            "Content-Type": "application/json",
        }
        invalid_payload = {
            "message": "This is a test",
            # Missing required fields
        }

        response = client.post("/DevOps", headers=headers, json=invalid_payload)
        assert response.status_code == 422  # Validation error


class TestSecurity:

    def test_generate_jwt(self):
        """Test JWT generation"""
        token = generate_jwt()
        assert isinstance(token, str)
        assert len(token) > 0
        # JWT tokens have 3 parts separated by dots
        assert token.count(".") == 2
