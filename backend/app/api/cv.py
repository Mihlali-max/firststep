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

from fastapi.responses import StreamingResponse
from app.services.pdf_service import generate_cv_pdf
import io, json

@router.get("/download")
async def download_cv(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CV).where(CV.user_id == user.id))
    cv = result.scalar_one_or_none()
    if not cv:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="No CV found. Please build your CV first.")
    
    cv_data = {
        "personal_info": cv.personal_info or {},
        "education":     cv.education or [],
        "skills":        cv.skills or [],
        "experience":    cv.experience or [],
        "references":    cv.references or [],
    }
    
    pdf_bytes = generate_cv_pdf(cv_data)
    name = (cv.personal_info or {}).get('name', 'My CV').replace(' ', '_')
    
    return StreamingResponse(
        io.BytesIO(pdf_bytes),
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename={name}_CV.pdf"}
    )
