from fastapi import Depends, FastAPI, HTTPException, Request

from .models import DevOpsRequest
from .security import validate_api_key, validate_jwt
from .service import process_devops_request

app = FastAPI()


@app.get("/")
def root():
    return {"status": "ok"}


@app.get("/DevOps")
@app.put("/DevOps")
@app.delete("/DevOps")
@app.patch("/DevOps")
def invalid_methods():
    return "ERROR"


@app.post("/DevOps")
def devops_endpoint(
    payload: DevOpsRequest,
    api_key_ok: bool = Depends(validate_api_key),
    jwt_data: dict = Depends(validate_jwt),
):
    response = process_devops_request(payload)
    return response


@app.get("/health")
def health():
    return {"status": "ok"}
