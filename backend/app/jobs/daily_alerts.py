"""
Daily job alert sender.
Run via: python -m app.jobs.daily_alerts
Or schedule as Render Cron Job: python -m app.jobs.daily_alerts
"""
import asyncio
import httpx
import os
import sys

# Add parent to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select
from app.core.config import settings
from app.models.user import User
from app.services.email_service import send_learnership_alert

ADZUNA_BASE = "https://api.adzuna.com/v1/api/jobs/za/search"

async def fetch_jobs(query: str, province: str = "", count: int = 5):
    params = {
        "app_id": settings.ADZUNA_APP_ID,
        "app_key": settings.ADZUNA_APP_KEY,
        "results_per_page": count,
        "what": query,
        "sort_by": "date",
    }
    province_map = {
        "Western Cape": "Cape Town",
        "Gauteng": "Johannesburg",
        "KwaZulu-Natal": "Durban",
        "Eastern Cape": "Gqeberha",
        "Limpopo": "Polokwane",
        "Mpumalanga": "Nelspruit",
        "North West": "Rustenburg",
        "Free State": "Bloemfontein",
        "Northern Cape": "Kimberley",
    }
    if province and province in province_map:
        params["where"] = province_map[province]

    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.get(f"{ADZUNA_BASE}/1", params=params)
        if resp.status_code != 200:
            return []
        data = resp.json()
        jobs = []
        for j in data.get("results", []):
            jobs.append({
                "title":       j.get("title", ""),
                "company":     j.get("company", {}).get("display_name", ""),
                "location":    j.get("location", {}).get("display_name", ""),
                "description": j.get("description", "")[:150],
                "salary_min":  j.get("salary_min"),
                "apply_url":   j.get("redirect_url", "https://firststep-frontend-sqyb.onrender.com/learnerships"),
            })
        return jobs

async def run_daily_alerts():
    print("🔔 Running daily job alerts...")

    engine = create_async_engine(settings.DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as db:
        # Get all users with email alerts enabled
        # We use city field for sector preference (set in notification prefs)
        result = await db.execute(
            select(User).where(User.is_active == True)
        )
        users = result.scalars().all()
        print(f"Found {len(users)} active users")

        sent = 0
        for user in users:
            if not user.email:
                continue

            # Get their preferences
            sector   = user.city or ""      # we store sector in city field
            province = user.province or ""

            # Build query based on preferences
            if sector and sector not in ["Any sector", ""]:
                query = f"learnership {sector}"
            else:
                query = "learnership"

            try:
                jobs = await fetch_jobs(query, province, count=5)
                if jobs:
                    success = send_learnership_alert(
                        to_email=user.email,
                        name=user.full_name or "there",
                        jobs=jobs,
                        province=province,
                    )
                    if success:
                        sent += 1
                        print(f"✅ Sent to {user.email}")
                    else:
                        print(f"❌ Failed for {user.email}")
            except Exception as e:
                print(f"❌ Error for {user.email}: {e}")

            # Small delay to avoid rate limiting
            await asyncio.sleep(0.5)

    print(f"✅ Done! Sent {sent}/{len(users)} alerts")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(run_daily_alerts())
