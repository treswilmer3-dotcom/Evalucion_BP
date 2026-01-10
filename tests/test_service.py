import pytest

from app.models import DevOpsRequest, DevOpsResponse
from app.service import process_devops_request


class TestModels:

    def test_devops_request_valid_data(self):
        """Test DevOpsRequest model with valid data"""
        data = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }
        request = DevOpsRequest(**data)
        assert request.message == "This is a test"
        assert request.to == "Juan Perez"
        assert request.from_ == "Rita Asturia"
        assert request.timeToLifeSec == 45

    def test_devops_response_model(self):
        """Test DevOpsResponse model"""
        response = DevOpsResponse(message="Hello World")
        assert response.message == "Hello World"


class TestService:

    def test_process_devops_request(self):
        """Test process_devops_request service function"""
        data = {
            "message": "This is a test",
            "to": "Juan Perez",
            "from": "Rita Asturia",
            "timeToLifeSec": 45,
        }
        request = DevOpsRequest(**data)

        response = process_devops_request(request)
        assert isinstance(response, DevOpsResponse)
        assert response.message == "Hello Juan Perez your message will be send"

    def test_process_devops_request_different_names(self):
        """Test process_devops_request with different recipient"""
        data = {
            "message": "Test message",
            "to": "Maria Garcia",
            "from": "Carlos Lopez",
            "timeToLifeSec": 30,
        }
        request = DevOpsRequest(**data)

        response = process_devops_request(request)
        assert response.message == "Hello Maria Garcia your message will be send"
