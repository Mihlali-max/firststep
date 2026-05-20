from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.core.security import hash_password
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token, verify_totp
from app.services.email_service import send_welcome_email
from app.models.user import User, CV
from app.schemas.user import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=401, detail="Invalid token")
    user = await db.get(User, payload.get("sub"))
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found")
    return user

@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(User).where(User.email == body.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Email already registered")
    user = User(email=body.email, hashed_password=hash_password(body.password), full_name=body.full_name, phone=body.phone, province=body.province, city=body.city)
    db.add(user)
    await db.flush()
    db.add(CV(user_id=user.id))
    await db.commit()
    await db.refresh(user)
    try:
        send_welcome_email(user.email, user.full_name)
    except: pass
    return TokenResponse(access_token=create_access_token({"sub": user.id}), refresh_token=create_refresh_token({"sub": user.id}), user=UserResponse.model_validate(user))

@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.totp_enabled:
        if not body.totp_code or not verify_totp(user.totp_secret, body.totp_code):
            raise HTTPException(status_code=401, detail="Invalid or missing 2FA code")
    try:
        send_welcome_email(user.email, user.full_name)
    except: pass
    return TokenResponse(access_token=create_access_token({"sub": user.id}), refresh_token=create_refresh_token({"sub": user.id}), user=UserResponse.model_validate(user))

@router.get("/me", response_model=UserResponse)
async def get_me(user: User = Depends(get_current_user)):
    return UserResponse.model_validate(user)

from pydantic import BaseModel as PM

class RefreshBody(PM):
    refresh_token: str

@router.post("/auth/refresh")
async def refresh_token(body: RefreshBody, db: AsyncSession = Depends(get_db)):
    from app.core.security import decode_token
    payload = decode_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return {
        "access_token": create_access_token({"sub": user.id}),
        "refresh_token": create_refresh_token({"sub": user.id}),
    }

from pydantic import BaseModel as PM2

class PhoneSendRequest(PM2):
    phone: str

class PhoneVerifyRequest(PM2):
    phone: str
    otp: str

@router.post("/phone/send-otp")
async def send_otp(body: PhoneSendRequest):
    otp = str(random.randint(100000, 999999))
    _otp_store[body.phone] = {"otp": otp, "expires": time.time() + 300}
    try:
        import africastalking
        africastalking.initialize(settings.AT_USERNAME, settings.AT_API_KEY)
        sms = africastalking.SMS
        sms.send(f"Your FirstStep OTP is: {otp}. Valid for 5 minutes.", [body.phone])
    except Exception as e:
        print(f"SMS error: {e}")
    return {"success": True, "message": "OTP sent"}

@router.post("/phone/verify-otp")
async def verify_otp(body: PhoneVerifyRequest, db: AsyncSession = Depends(get_db)):
    stored = _otp_store.get(body.phone)
    if not stored or stored["otp"] != body.otp or time.time() > stored["expires"]:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    del _otp_store[body.phone]
    result = await db.execute(select(User).where(User.email == body.phone))
    user = result.scalar_one_or_none()
    if not user:
        import uuid
        user = User(
            id=str(uuid.uuid4()), email=body.phone, full_name="FirstStep User",
            hashed_password="", is_active=True, is_verified=True, totp_enabled=False
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
    return TokenResponse(
        access_token=create_access_token({"sub": user.id}),
        refresh_token=create_refresh_token({"sub": user.id}),
        user=UserResponse.model_validate(user)
    )

import random, time
_otp_store: dict = {}

class PhoneSendRequest(PM2):
    phone: str

class PhoneVerifyRequest(PM2):
    phone: str
    otp: str

@router.post("/phone/send-otp")
async def send_otp(body: PhoneSendRequest):
    otp = str(random.randint(100000, 999999))
    _otp_store[body.phone] = {"otp": otp, "expires": time.time() + 300}
    try:
        import africastalking
        africastalking.initialize(settings.AT_USERNAME, settings.AT_API_KEY)
        sms = africastalking.SMS
        sms.send(f"Your FirstStep OTP is: {otp}. Valid for 5 minutes.", [body.phone])
    except Exception as e:
        print(f"SMS error: {e}")
    return {"success": True, "message": "OTP sent"}

@router.post("/phone/verify-otp")
async def verify_otp(body: PhoneVerifyRequest, db: AsyncSession = Depends(get_db)):
    stored = _otp_store.get(body.phone)
    if not stored or stored["otp"] != body.otp or time.time() > stored["expires"]:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    del _otp_store[body.phone]
    result = await db.execute(select(User).where(User.email == body.phone))
    user = result.scalar_one_or_none()
    if not user:
        import uuid
        user = User(
            id=str(uuid.uuid4()), email=body.phone, full_name="FirstStep User",
            hashed_password="", is_active=True, is_verified=True, totp_enabled=False
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
    return TokenResponse(
        access_token=create_access_token({"sub": user.id}),
        refresh_token=create_refresh_token({"sub": user.id}),
        user=UserResponse.model_validate(user)
    )


@router.get("/phone/debug-otp/{phone}")
async def debug_otp(phone: str):
    stored = _otp_store.get(phone)
    return {"otp": stored.get("otp") if stored else "not found", "keys": list(_otp_store.keys())}

from pydantic import BaseModel as PM2

class GoogleAuthRequest(PM2):
    token: str = ""
    email: str = ""
    name: str = ""

@router.post("/google")
async def google_auth(body: GoogleAuthRequest, db: AsyncSession = Depends(get_db)):
    import httpx as _httpx
    if body.token:
        async with _httpx.AsyncClient() as client:
            r = await client.get(f"https://oauth2.googleapis.com/tokeninfo?id_token={body.token}")
            if r.status_code == 200:
                info = r.json()
                body.email = info.get("email", body.email)
                body.name = info.get("name", body.name or body.email)
    email = body.email
    name = body.name or email
    if not email:
        raise HTTPException(status_code=400, detail="No email from Google")
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if not user:
            import uuid
            user = User(
                id=str(uuid.uuid4()), email=email, full_name=name,
                hashed_password="", is_active=True, is_verified=True, totp_enabled=False
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
        return TokenResponse(
            access_token=create_access_token({"sub": user.id}),
            refresh_token=create_refresh_token({"sub": user.id}),
            user=UserResponse.model_validate(user)
        )

import secrets
_reset_tokens: dict = {}

class ForgotPasswordRequest(PM2):
    email: str

class ResetPasswordRequest(PM2):
    token: str
    new_password: str

@router.post("/forgot-password")
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user:
        return {"success": True}  # Don't reveal if email exists
    token = secrets.token_urlsafe(32)
    _reset_tokens[token] = {"user_id": user.id, "expires": time.time() + 3600}
    reset_url = f"https://firststep-frontend-sqyb.onrender.com/reset-password?token={token}"
    try:
        from app.services.email_service import send_email
        await send_email(
            to=user.email,
            subject="Reset your FirstStep password",
            html=f"""<div style="font-family:sans-serif;max-width:480px;margin:0 auto">
<h2 style="color:#1A1A0F">Reset your password</h2>
<p>Click the button below to reset your FirstStep password. This link expires in 1 hour.</p>
<a href="{reset_url}" style="display:inline-block;background:#F5A623;color:#1A1A0F;font-weight:bold;padding:12px 24px;border-radius:8px;text-decoration:none">Reset password</a>
<p style="color:#999;font-size:12px;margin-top:24px">If you didn't request this, ignore this email.</p>
</div>"""
        )
    except Exception as e:
        print(f"Reset email error: {e}")
    return {"success": True}

@router.post("/reset-password")
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    stored = _reset_tokens.get(body.token)
    if not stored or time.time() > stored["expires"]:
        raise HTTPException(status_code=400, detail="Invalid or expired reset link")
    del _reset_tokens[body.token]
    result = await db.execute(select(User).where(User.id == stored["user_id"]))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=400, detail="User not found")
    from app.core.security import hash_password
    user.hashed_password = hash_password(body.new_password)
    await db.commit()
    return {"success": True}
