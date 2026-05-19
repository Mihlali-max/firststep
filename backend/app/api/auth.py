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
class GoogleAuthRequest(PM2):
    token: str

@router.post("/google")
async def google_auth(body: GoogleAuthRequest, db: AsyncSession = Depends(get_db)):
    import httpx
    async with httpx.AsyncClient() as client:
        r = await client.get(f"https://oauth2.googleapis.com/tokeninfo?id_token={body.token}")
        if r.status_code != 200:
            raise HTTPException(status_code=400, detail="Invalid Google token")
        info = r.json()
        email = info.get("email")
        name = info.get("name", email)
        if not email:
            raise HTTPException(status_code=400, detail="No email from Google")
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if not user:
            import uuid
            user = User(
                id=str(uuid.uuid4()), email=email, full_name=name,
                hashed_password="", is_active=True, is_verified=True,
                totp_enabled=False
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
        return TokenResponse(
            access_token=create_access_token({"sub": user.id}),
            refresh_token=create_refresh_token({"sub": user.id}),
            user=UserResponse.model_validate(user)
        )
