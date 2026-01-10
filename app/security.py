from datetime import datetime, timedelta

from fastapi import Header, HTTPException
from jose import jwt

API_KEY = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
JWT_SECRET = "LOCAL_DEV_SECRET"
JWT_ALGO = "HS256"


def validate_api_key(api_key: str = Header(None, alias="X-Parse-REST-API-Key")):
    if api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    return True


def validate_jwt(token: str = Header(None, alias="X-JWT-KWY")):
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGO])
        return payload
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid JWT")


def generate_jwt():
    exp = datetime.utcnow() + timedelta(minutes=5)
    payload = {"exp": exp, "msg": "devops-test"}
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)
    return token
