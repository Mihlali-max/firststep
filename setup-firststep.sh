#!/bin/bash
set -e
cd ~/firststep

echo "📁 Creating directory structure..."
mkdir -p backend/app/{api,core,models,schemas,services,tests}
mkdir -p frontend/src/{components/{ui,layout,pages},hooks,lib,store}
mkdir -p frontend/public
mkdir -p infra/terraform
mkdir -p .github/workflows

echo "📝 Writing backend files..."

cat > backend/requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.6
sqlalchemy==2.0.35
alembic==1.13.3
psycopg2-binary==2.9.9
asyncpg==0.29.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.12
pydantic==2.9.2
pydantic-settings==2.5.2
httpx==0.27.2
groq==0.11.0
python-dotenv==1.0.1
pyotp==2.9.0
qrcode[pil]==7.4.0
itsdangerous==2.2.0
pillow==10.4.0
fpdf2==2.8.1
prometheus-fastapi-instrumentator==7.0.0
aiosqlite==0.20.0
EOF

cat > backend/.env.example << 'EOF'
# Database (Supabase Session Pooler)
DATABASE_URL=postgresql+asyncpg://postgres:[PASSWORD]@aws-1-eu-west-1.pooler.supabase.com:5432/postgres

# Auth
SECRET_KEY=change-me-to-a-long-random-string
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30

# AI
GROQ_API_KEY=your-groq-api-key
GROQ_MODEL=llama-3.1-70b-versatile
ELEVENLABS_API_KEY=your-elevenlabs-api-key
ELEVENLABS_VOICE_ID=your-voice-id

# App
APP_ENV=development
FRONTEND_URL=http://localhost:5173
CORS_ORIGINS=["http://localhost:5173","http://localhost:3000"]
EOF

touch backend/app/__init__.py
touch backend/app/api/__init__.py
touch backend/app/core/__init__.py
touch backend/app/models/__init__.py
touch backend/app/schemas/__init__.py
touch backend/app/services/__init__.py

cat > backend/app/core/config.py << 'EOF'
from pydantic_settings import BaseSettings
from typing import List
import json

class Settings(BaseSettings):
    APP_ENV: str = "development"
    FRONTEND_URL: str = "http://localhost:5173"
    CORS_ORIGINS: str = '["http://localhost:5173"]'
    DATABASE_URL: str = "sqlite+aiosqlite:///./firststep.db"
    SECRET_KEY: str = "dev-secret-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "llama-3.1-70b-versatile"
    ELEVENLABS_API_KEY: str = ""
    ELEVENLABS_VOICE_ID: str = ""

    @property
    def cors_origins_list(self) -> List[str]:
        try:
            return json.loads(self.CORS_ORIGINS)
        except Exception:
            return [self.FRONTEND_URL]

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
EOF

cat > backend/app/core/database.py << 'EOF'
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase
from app.core.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.APP_ENV == "development",
    connect_args={"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {},
)

AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
EOF

cat > backend/app/core/security.py << 'EOF'
from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
import pyotp, qrcode, io, base64
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict, expires_delta=None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_token(token: str) -> Optional[dict]:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None

def generate_totp_secret() -> str:
    return pyotp.random_base32()

def get_totp_uri(secret: str, email: str) -> str:
    return pyotp.totp.TOTP(secret).provisioning_uri(name=email, issuer_name="FirstStep")

def generate_qr_code(uri: str) -> str:
    img = qrcode.make(uri)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()

def verify_totp(secret: str, code: str) -> bool:
    return pyotp.TOTP(secret).verify(code, valid_window=1)
EOF

cat > backend/app/models/user.py << 'EOF'
from sqlalchemy import String, Boolean, DateTime, Integer, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from app.core.database import Base
import uuid

class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(20))
    province: Mapped[str | None] = mapped_column(String(100))
    city: Mapped[str | None] = mapped_column(String(100))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    totp_secret: Mapped[str | None] = mapped_column(String(64))
    totp_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    cv: Mapped["CV"] = relationship("CV", back_populates="user", uselist=False, cascade="all, delete-orphan")
    chat_sessions: Mapped[list["ChatSession"]] = relationship("ChatSession", back_populates="user", cascade="all, delete-orphan")

class CV(Base):
    __tablename__ = "cvs"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), unique=True)
    personal_info: Mapped[dict | None] = mapped_column(JSON)
    education: Mapped[list | None] = mapped_column(JSON)
    skills: Mapped[list | None] = mapped_column(JSON)
    experience: Mapped[list | None] = mapped_column(JSON)
    references: Mapped[list | None] = mapped_column(JSON)
    completion_pct: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[DateTime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    user: Mapped["User"] = relationship("User", back_populates="cv")

class ChatSession(Base):
    __tablename__ = "chat_sessions"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"))
    messages: Mapped[list] = mapped_column(JSON, default=list)
    created_at: Mapped[DateTime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    user: Mapped["User"] = relationship("User", back_populates="chat_sessions")
EOF

cat > backend/app/schemas/user.py << 'EOF'
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
EOF

cat > backend/app/api/auth.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token, verify_totp
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
    return TokenResponse(access_token=create_access_token({"sub": user.id}), refresh_token=create_refresh_token({"sub": user.id}), user=UserResponse.model_validate(user))

@router.get("/me", response_model=UserResponse)
async def get_me(user: User = Depends(get_current_user)):
    return UserResponse.model_validate(user)
EOF

cat > backend/app/services/coach_service.py << 'EOF'
from groq import AsyncGroq
from app.core.config import settings
from typing import AsyncGenerator

client = AsyncGroq(api_key=settings.GROQ_API_KEY) if settings.GROQ_API_KEY else None

async def get_coach_reply(messages: list, system: str, user_context: dict = None) -> str:
    if not client:
        return "AI coach is not configured yet. Add your GROQ_API_KEY to .env to enable it."
    system_full = system
    if user_context:
        ctx = [f"{k}: {v}" for k, v in user_context.items() if v]
        if ctx:
            system_full += "\n\nUser context:\n" + "\n".join(ctx)
    response = await client.chat.completions.create(
        model=settings.GROQ_MODEL,
        messages=[{"role": "system", "content": system_full}, *messages],
        max_tokens=600, temperature=0.7,
    )
    return response.choices[0].message.content
EOF

cat > backend/app/services/cv_service.py << 'EOF'
from app.models.user import CV, User

def calculate_completion(cv: CV) -> int:
    score = 0
    if cv.personal_info: score += 25
    if cv.education: score += 20
    if cv.skills: score += 20
    if cv.experience: score += 20
    if cv.references: score += 15
    return score
EOF

cat > backend/app/api/cv.py << 'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.api.auth import get_current_user
from app.models.user import User, CV
from app.schemas.user import CVUpdate, CVResponse
from app.services.cv_service import calculate_completion

router = APIRouter(prefix="/cv", tags=["cv"])

@router.get("", response_model=CVResponse)
async def get_cv(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CV).where(CV.user_id == user.id))
    cv = result.scalar_one_or_none()
    if not cv:
        cv = CV(user_id=user.id)
        db.add(cv)
        await db.commit()
        await db.refresh(cv)
    return CVResponse.model_validate(cv)

@router.patch("", response_model=CVResponse)
async def update_cv(body: CVUpdate, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CV).where(CV.user_id == user.id))
    cv = result.scalar_one_or_none()
    if not cv:
        cv = CV(user_id=user.id)
        db.add(cv)
    for field in ["personal_info", "education", "skills", "experience", "references"]:
        val = getattr(body, field)
        if val is not None:
            setattr(cv, field, val)
    cv.completion_pct = calculate_completion(cv)
    await db.commit()
    await db.refresh(cv)
    return CVResponse.model_validate(cv)
EOF

cat > backend/app/api/coach.py << 'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.api.auth import get_current_user
from app.models.user import User, ChatSession
from app.schemas.user import ChatRequest, ChatResponse
from app.services.coach_service import get_coach_reply

router = APIRouter(prefix="/coach", tags=["coach"])

SYSTEM = """You are FirstStep's AI career coach helping South African youth find their first job.
You know SA learnerships, SETAs, YES Programme, LAP, UIF, and entry-level jobs well.
Be warm, practical, and encouraging. Keep responses concise."""

@router.post("/chat", response_model=ChatResponse)
async def chat(body: ChatRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    session = None
    if body.session_id:
        result = await db.execute(select(ChatSession).where(ChatSession.id == body.session_id, ChatSession.user_id == user.id))
        session = result.scalar_one_or_none()
    if not session:
        session = ChatSession(user_id=user.id, messages=[])
        db.add(session)
        await db.flush()
    history = list(session.messages or [])
    history.append({"role": "user", "content": body.message})
    reply = await get_coach_reply(history, SYSTEM, {"name": user.full_name, "province": user.province})
    history.append({"role": "assistant", "content": reply})
    session.messages = history[-20:]
    await db.commit()
    return ChatResponse(reply=reply, session_id=str(session.id))
EOF

cat > backend/app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import engine, Base
from app.api import auth, cv, coach
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

app = FastAPI(title="FirstStep API", version="1.0.0", lifespan=lifespan)

app.add_middleware(CORSMiddleware, allow_origins=settings.cors_origins_list, allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

app.include_router(auth.router, prefix="/api")
app.include_router(cv.router, prefix="/api")
app.include_router(coach.router, prefix="/api")

@app.get("/health")
async def health():
    return {"status": "ok", "app": "firststep"}
EOF

cat > backend/Dockerfile << 'EOF'
FROM python:3.12-slim
RUN addgroup --system app && adduser --system --group app
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt
COPY . .
RUN chown -R app:app /app
USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

echo "📝 Writing frontend files..."

cat > frontend/package.json << 'EOF'
{
  "name": "firststep-frontend",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.2",
    "zustand": "^5.0.0",
    "axios": "^1.7.7",
    "framer-motion": "^11.5.4",
    "lucide-react": "^0.447.0",
    "clsx": "^2.1.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.8",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.1",
    "typescript": "^5.5.3",
    "vite": "^5.4.6",
    "vite-plugin-pwa": "^0.20.5",
    "tailwindcss": "^3.4.12",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47"
  }
}
EOF

cat > frontend/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'FirstStep',
        short_name: 'FirstStep',
        description: 'Your first job starts here',
        theme_color: '#F5A623',
        background_color: '#FFFDF7',
        display: 'standalone',
        start_url: '/',
        icons: [
          { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ]
      }
    })
  ],
  server: {
    port: 5173,
    proxy: { '/api': { target: 'http://localhost:8000', changeOrigin: true } }
  }
})
EOF

cat > frontend/src/lib/api.ts << 'EOF'
import axios from 'axios'

const api = axios.create({ baseURL: '/api', timeout: 15000 })

api.interceptors.request.use((config) => {
  const raw = localStorage.getItem('firststep-auth')
  if (raw) {
    try {
      const { state } = JSON.parse(raw)
      if (state?.accessToken) config.headers.Authorization = `Bearer ${state.accessToken}`
    } catch {}
  }
  return config
})

export default api
EOF

cat > frontend/src/store/authStore.ts << 'EOF'
import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import api from '../lib/api'

interface User { id: string; email: string; full_name: string; province?: string; city?: string; totp_enabled: boolean }
interface AuthState {
  user: User | null; accessToken: string | null; refreshToken: string | null; isLoading: boolean
  login: (email: string, password: string, totp?: string) => Promise<void>
  register: (data: any) => Promise<void>
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null, accessToken: null, refreshToken: null, isLoading: false,
      login: async (email, password, totp) => {
        set({ isLoading: true })
        try {
          const { data } = await api.post('/auth/login', { email, password, totp_code: totp })
          set({ user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token })
        } finally { set({ isLoading: false }) }
      },
      register: async (registerData) => {
        set({ isLoading: true })
        try {
          const { data } = await api.post('/auth/register', registerData)
          set({ user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token })
        } finally { set({ isLoading: false }) }
      },
      logout: () => set({ user: null, accessToken: null, refreshToken: null }),
    }),
    { name: 'firststep-auth', partialize: (s) => ({ user: s.user, accessToken: s.accessToken, refreshToken: s.refreshToken }) }
  )
)
EOF

cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FirstStep — Your first job starts here</title>
    <meta name="theme-color" content="#F5A623" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > frontend/src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
EOF

cat > frontend/src/App.tsx << 'EOF'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from './store/authStore'

function Home() {
  const { user, logout } = useAuthStore()
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '600px', margin: '0 auto' }}>
      <h1 style={{ color: '#F5A623' }}>🚀 FirstStep</h1>
      <p>Your first job starts here.</p>
      {user ? (
        <div>
          <p>Welcome, <strong>{user.full_name}</strong>!</p>
          <button onClick={logout} style={{ background: '#1A1A0F', color: '#fff', padding: '8px 16px', border: 'none', borderRadius: '6px', cursor: 'pointer' }}>
            Log out
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', gap: '12px' }}>
          <a href="/login" style={{ background: '#F5A623', color: '#1A1A0F', padding: '10px 20px', borderRadius: '8px', textDecoration: 'none', fontWeight: 500 }}>Log in</a>
          <a href="/register" style={{ background: '#1A1A0F', color: '#fff', padding: '10px 20px', borderRadius: '8px', textDecoration: 'none', fontWeight: 500 }}>Get started</a>
        </div>
      )}
    </div>
  )
}

function Login() {
  const { login, isLoading } = useAuthStore()
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const form = new FormData(e.currentTarget)
    await login(form.get('email') as string, form.get('password') as string)
    window.location.href = '/'
  }
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '400px', margin: '4rem auto' }}>
      <h2>Log in to FirstStep</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '1.5rem' }}>
        <input name="email" type="email" placeholder="Email" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="password" type="password" placeholder="Password" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <button type="submit" disabled={isLoading} style={{ background: '#F5A623', color: '#1A1A0F', padding: '12px', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}>
          {isLoading ? 'Logging in...' : 'Log in'}
        </button>
      </form>
      <p style={{ marginTop: '1rem', fontSize: '0.875rem' }}>No account? <a href="/register">Get started free</a></p>
    </div>
  )
}

function Register() {
  const { register, isLoading } = useAuthStore()
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const form = new FormData(e.currentTarget)
    await register({ email: form.get('email'), password: form.get('password'), full_name: form.get('full_name') })
    window.location.href = '/'
  }
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '400px', margin: '4rem auto' }}>
      <h2>Create your free profile</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '1.5rem' }}>
        <input name="full_name" placeholder="Full name" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="email" type="email" placeholder="Email" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="password" type="password" placeholder="Password (min 8 chars)" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <button type="submit" disabled={isLoading} style={{ background: '#F5A623', color: '#1A1A0F', padding: '12px', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}>
          {isLoading ? 'Creating account...' : 'Get started free'}
        </button>
      </form>
      <p style={{ marginTop: '1rem', fontSize: '0.875rem' }}>Already have an account? <a href="/login">Log in</a></p>
    </div>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  )
}
EOF

cat > frontend/src/index.css << 'EOF'
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'DM Sans', sans-serif; background: #FFFDF7; color: #1A1A0F; }
a { color: #C47D0A; }
EOF

cat > frontend/.env.example << 'EOF'
VITE_API_URL=http://localhost:8000/api
VITE_APP_NAME=FirstStep
EOF

echo "📝 Writing infra files..."

cat > infra/terraform/variables.tf << 'EOF'
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}
variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "server_type" {
  default = "cx22"
}
variable "location" {
  default = "nbg1"
}
EOF

cat > infra/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.47" }
  }
}
provider "hcloud" { token = var.hcloud_token }

resource "hcloud_ssh_key" "firststep" {
  name       = "firststep-deploy"
  public_key = file(var.ssh_public_key_path)
}
resource "hcloud_server" "firststep" {
  name        = "firststep-prod"
  server_type = var.server_type
  image       = "debian-12"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.firststep.id]
  labels      = { project = "firststep" }
}
output "server_ip" { value = hcloud_server.firststep.ipv4_address }
EOF

cat > docker-compose.yml << 'EOF'
services:
  backend:
    build: ./backend
    container_name: firststep-api
    restart: unless-stopped
    env_file: ./backend/.env
    ports:
      - "8000:8000"
  frontend:
    build: ./frontend
    container_name: firststep-web
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend
EOF

cat > Makefile << 'EOF'
.PHONY: dev backend frontend setup

backend:
	cd backend && uvicorn app.main:app --reload --port 8000

frontend:
	cd frontend && npm run dev

dev:
	docker compose up --build

setup:
	cp backend/.env.example backend/.env
	cp frontend/.env.example frontend/.env
	cd frontend && npm install
	cd backend && pip install -r requirements.txt
	@echo "✅ Done. Edit backend/.env with your secrets then run: make backend"
EOF

cat > README.md << 'EOF'
# FirstStep 🚀
> Your first job starts here. Free, always.

SA youth employment platform — CV builder, AI coach, learnership finder, LAP checker.

## Quick start
```bash
make setup
# edit backend/.env
make backend   # terminal 1
make frontend  # terminal 2
```
EOF

cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
.venv/
venv/
.env
node_modules/
frontend/dist/
infra/terraform/.terraform/
infra/terraform/*.tfstate
infra/terraform/*.tfvars
.DS_Store
*.log
firststep.db
EOF

echo ""
echo "✅ All files created!"
echo ""
echo "Now committing and pushing to GitHub..."
git add .
git commit -m "feat: initial FirstStep scaffold — FastAPI + React PWA + Terraform + CI/CD"
git push -u origin main
echo ""
echo "🎉 Done! Your repo is live at: https://github.com/Mihlali-max/firststep"
