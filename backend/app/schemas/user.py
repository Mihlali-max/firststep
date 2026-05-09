from pydantic import BaseModel, EmailStr
from typing import Optional

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone: Optional[str] = None
    province: Optional[str] = None
    city: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    totp_code: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    province: Optional[str]
    city: Optional[str]
    is_verified: bool
    totp_enabled: bool
    model_config = {"from_attributes": True}

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse

class RefreshRequest(BaseModel):
    refresh_token: str

class CVUpdate(BaseModel):
    personal_info: Optional[dict] = None
    education: Optional[list] = None
    skills: Optional[list] = None
    experience: Optional[list] = None
    references: Optional[list] = None

class CVResponse(BaseModel):
    id: str
    personal_info: Optional[dict]
    education: Optional[list]
    skills: Optional[list]
    experience: Optional[list]
    references: Optional[list]
    completion_pct: int
    model_config = {"from_attributes": True}

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    session_id: str
