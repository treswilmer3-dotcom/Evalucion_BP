from pydantic import BaseModel, Field


class DevOpsRequest(BaseModel):
    message: str
    to: str
    from_: str = Field(alias="from")
    timeToLifeSec: int


class DevOpsResponse(BaseModel):
    message: str
