import pytest
from fastapi import HTTPException

from app.security import API_KEY, generate_jwt, validate_api_key, validate_jwt


class TestSecurity:

    def test_validate_api_key_valid(self):
        """Test validate_api_key with valid key"""
        result = validate_api_key(API_KEY)
        assert result is True

    def test_validate_api_key_invalid(self):
        """Test validate_api_key with invalid key"""
        with pytest.raises(HTTPException) as exc_info:
            validate_api_key("invalid-key")
        assert exc_info.value.status_code == 401
        assert exc_info.value.detail == "Invalid API Key"

    def test_validate_jwt_valid(self):
        """Test validate_jwt with valid token"""
        token = generate_jwt()
        payload = validate_jwt(token)
        assert isinstance(payload, dict)
        assert "exp" in payload
        assert "msg" in payload
        assert payload["msg"] == "devops-test"

    def test_validate_jwt_invalid(self):
        """Test validate_jwt with invalid token"""
        with pytest.raises(HTTPException) as exc_info:
            validate_jwt("invalid-jwt-token")
        assert exc_info.value.status_code == 401
        assert exc_info.value.detail == "Invalid JWT"

    def test_generate_jwt(self):
        """Test JWT generation"""
        token = generate_jwt()
        assert isinstance(token, str)
        assert len(token) > 0
        # JWT tokens have 3 parts separated by dots
        assert token.count(".") == 2

        # Test that generated token is valid
        payload = validate_jwt(token)
        assert payload["msg"] == "devops-test"
