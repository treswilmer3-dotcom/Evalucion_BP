from .models import DevOpsRequest, DevOpsResponse


def process_devops_request(data: DevOpsRequest) -> DevOpsResponse:
    msg = f"Hello {data.to} your message will be send"
    return DevOpsResponse(message=msg)
