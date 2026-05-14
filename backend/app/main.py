from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import engine, Base
from app.api import auth, cv, coach
from app.api.jobs import router as jobs_router
from app.api import cv_extract
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
app.include_router(cv_extract.router, prefix="/api")
app.include_router(jobs_router, prefix="/api")

@app.get("/health")
async def health():
    return {"status": "ok", "app": "firststep"}
