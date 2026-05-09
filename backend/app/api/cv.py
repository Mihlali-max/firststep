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
