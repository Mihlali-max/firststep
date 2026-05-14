#!/bin/bash
set -e
cd ~/firststep/backend
echo "🔌 Adding Adzuna live jobs endpoint..."

cat > app/api/jobs.py << 'EOF'
from fastapi import APIRouter, Query
from app.core.config import settings
import httpx

router = APIRouter(prefix="/jobs", tags=["jobs"])

BASE = "https://api.adzuna.com/v1/api/jobs/za/search"

@router.get("")
async def search_jobs(
    q: str = Query(default="learnership", description="Search query"),
    province: str = Query(default="", description="Province filter"),
    page: int = Query(default=1, ge=1),
    results_per_page: int = Query(default=20, le=50),
):
    """Search real SA jobs from Adzuna."""
    params = {
        "app_id":          settings.ADZUNA_APP_ID,
        "app_key":         settings.ADZUNA_APP_KEY,
        "results_per_page": results_per_page,
        "what":            q,
        "content-type":    "application/json",
        "sort_by":         "date",
    }

    # Map province to Adzuna location
    province_map = {
        "Western Cape":  "Cape Town",
        "Gauteng":       "Johannesburg",
        "KwaZulu-Natal": "Durban",
        "Eastern Cape":  "Gqeberha",
        "Limpopo":       "Polokwane",
        "Mpumalanga":    "Nelspruit",
        "North West":    "Rustenburg",
        "Free State":    "Bloemfontein",
        "Northern Cape": "Kimberley",
    }
    if province and province in province_map:
        params["where"] = province_map[province]

    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.get(f"{BASE}/{page}", params=params)
        resp.raise_for_status()
        data = resp.json()

    jobs = []
    for j in data.get("results", []):
        jobs.append({
            "id":          j.get("id", ""),
            "title":       j.get("title", ""),
            "company":     j.get("company", {}).get("display_name", ""),
            "location":    j.get("location", {}).get("display_name", ""),
            "description": j.get("description", ""),
            "salary_min":  j.get("salary_min"),
            "salary_max":  j.get("salary_max"),
            "created":     j.get("created", "")[:10] if j.get("created") else "",
            "apply_url":   j.get("redirect_url", ""),
            "category":    j.get("category", {}).get("label", ""),
            "contract":    j.get("contract_time", ""),
        })

    return {
        "total":   data.get("count", 0),
        "page":    page,
        "results": jobs,
    }

@router.get("/categories")
async def job_categories():
    """Get available job categories for SA."""
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(
            "https://api.adzuna.com/v1/api/jobs/za/categories",
            params={"app_id": settings.ADZUNA_APP_ID, "app_key": settings.ADZUNA_APP_KEY}
        )
        resp.raise_for_status()
        data = resp.json()
    return data.get("results", [])
EOF

# Register router in main.py
python3 - << 'PYEOF'
with open("app/main.py","r") as f: c = f.read()
if "jobs" not in c:
    c = c.replace(
        "from app.api import auth, cv, coach",
        "from app.api import auth, cv, coach\nfrom app.api.jobs import router as jobs_router"
    )
    c = c.replace(
        "app.include_router(applications_router",
        "app.include_router(jobs_router, prefix=\"/api\")\napp.include_router(applications_router"
    )
    with open("app/main.py","w") as f: f.write(c)
    print("✅ jobs router registered")
else:
    print("ℹ️  already registered")
PYEOF

echo "✅ Adzuna backend done! Restarting..."
fuser -k 8000/tcp 2>/dev/null || true
uvicorn app.main:app --reload --port 8000
