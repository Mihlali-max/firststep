import os
from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.api.auth import get_current_user
from app.models.user import User
from app.services.email_service import send_learnership_alert, send_welcome_email
from pydantic import BaseModel
import httpx, os

router = APIRouter(prefix="/notifications", tags=["notifications"])

class NotificationPrefs(BaseModel):
    email_alerts: bool = True
    preferred_sector: str = ""
    preferred_province: str = ""

@router.post("/preferences")
async def save_preferences(
    prefs: NotificationPrefs,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Store in user record (we'll use city field for sector, province for province)
    user.city = prefs.preferred_sector
    if prefs.preferred_province:
        user.province = prefs.preferred_province
    await db.commit()
    return {"message": "Preferences saved"}

@router.post("/test")
async def send_test_email(
    user: User = Depends(get_current_user),
):
    """Send a test notification email to the current user."""
    test_jobs = [
        {"title": "Retail Operations Learnership", "company": "Shoprite Group", "location": "Cape Town, Western Cape",
         "description": "Learn retail operations and customer service. No prior experience needed.", 
         "salary_min": 3500, "apply_url": "https://firststep-frontend-sqyb.onrender.com/learnerships"},
        {"title": "Banking YES Programme", "company": "Standard Bank", "location": "Johannesburg, Gauteng",
         "description": "12-month YES Programme in banking and customer service.", 
         "salary_min": 4500, "apply_url": "https://firststep-frontend-sqyb.onrender.com/learnerships"},
        {"title": "ICT Support Learnership NQF 4", "company": "MICT SETA", "location": "All Provinces",
         "description": "Technical support and IT fundamentals learnership.", 
         "salary_min": None, "apply_url": "https://firststep-frontend-sqyb.onrender.com/learnerships"},
    ]
    success = send_learnership_alert(
        to_email=user.email,
        name=user.full_name,
        jobs=test_jobs,
        province=user.province or ""
    )
    return {"success": success, "sent_to": user.email}

@router.post("/welcome")
async def send_welcome(user: User = Depends(get_current_user)):
    success = send_welcome_email(user.email, user.full_name)
    return {"success": success}

@router.post("/send-daily-alerts")
async def trigger_daily_alerts(
    secret: str = "",
    db: AsyncSession = Depends(get_db),
):
    """Trigger daily alerts — called by Render cron job."""
    # Simple secret check to prevent abuse
    if secret != os.getenv("CRON_SECRET", "firststep-cron-2026"):
        from fastapi import HTTPException
        raise HTTPException(status_code=403, detail="Forbidden")
    
    import asyncio
    from app.jobs.daily_alerts import run_daily_alerts
    # Run in background
    asyncio.create_task(run_daily_alerts())
    return {"message": "Daily alerts triggered"}

from pydantic import BaseModel as PM
class ContactForm(PM):
    name: str
    email: str
    subject: str = ""
    message: str

@router.post("/contact")
async def contact_form(form: ContactForm):
    import resend, os
    from dotenv import load_dotenv; load_dotenv()
    resend.api_key = os.getenv("RESEND_API_KEY","")
    try:
        from resend import Emails
        Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": "momozamihlali@gmail.com",
            "subject": f"[FirstStep] {form.subject or 'New message'} from {form.name}",
            "html": f"<p><b>From:</b> {form.name} ({form.email})</p><p><b>Message:</b></p><p>{form.message}</p>",
        })
        return {"success": True}
    except Exception as e:
        print(f"Contact error: {e}")
        return {"success": False}

from pydantic import BaseModel as PM
class ContactForm(PM):
    name: str
    email: str
    subject: str = ""
    message: str

@router.post("/contact")
async def contact_form(form: ContactForm):
    import resend, os
    from dotenv import load_dotenv; load_dotenv()
    resend.api_key = os.getenv("RESEND_API_KEY","")
    try:
        from resend import Emails
        Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": "momozamihlali@gmail.com",
            "subject": f"[FirstStep] {form.subject or 'New message'} from {form.name}",
            "html": f"<p><b>From:</b> {form.name} ({form.email})</p><p><b>Message:</b></p><p>{form.message}</p>",
        })
        return {"success": True}
    except Exception as e:
        print(f"Contact error: {e}")
        return {"success": False}

from pydantic import BaseModel as PM
class ContactForm(PM):
    name: str
    email: str
    subject: str = ""
    message: str

@router.post("/contact")
async def contact_form(form: ContactForm):
    import resend, os
    from dotenv import load_dotenv; load_dotenv()
    resend.api_key = os.getenv("RESEND_API_KEY","")
    try:
        from resend import Emails
        Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": "momozamihlali@gmail.com",
            "subject": f"[FirstStep] {form.subject or 'New message'} from {form.name}",
            "html": f"<p><b>From:</b> {form.name} ({form.email})</p><p><b>Message:</b></p><p>{form.message}</p>",
        })
        return {"success": True}
    except Exception as e:
        print(f"Contact error: {e}")
        return {"success": False}
