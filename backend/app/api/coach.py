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

@router.get("/sessions")
async def get_sessions(user=Depends(get_current_user)):
    return []
