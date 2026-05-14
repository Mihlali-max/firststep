from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.auth import get_current_user
from app.models.user import User
import httpx, base64, json, os

router = APIRouter(prefix="/cv", tags=["cv"])

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")

EXTRACT_PROMPT = """You are a CV parser. Extract all information from this CV and return ONLY a valid JSON object with NO markdown, NO explanation, NO code fences.

Return exactly this structure:
{
  "personal_info": {
    "name": "",
    "title": "",
    "email": "",
    "phone": "",
    "location": "",
    "summary": "",
    "linkedin": "",
    "languages": ""
  },
  "education": [
    {"school": "", "qualification": "", "year": ""}
  ],
  "skills": ["skill1", "skill2"],
  "experience": [
    {
      "title": "",
      "organisation": "",
      "start_date": "",
      "end_date": "",
      "description": "",
      "is_volunteer": false
    }
  ],
  "references": [
    {"name": "", "relation": "", "contact": ""}
  ]
}

Rules:
- For "description" in experience: write each responsibility as a separate line (use \\n between them). These will become bullet points.
- For "languages": comma-separated string e.g. "English, IsiXhosa, Zulu"
- Extract ALL jobs, qualifications, skills, and references found
- If a field is not found, use empty string ""
- Return ONLY the JSON object, nothing else"""


class ExtractRequest(BaseModel):
    file_data: str   # base64 encoded
    file_type: str   # mime type
    file_name: str


@router.post("/extract")
async def extract_cv(
    body: ExtractRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if not ANTHROPIC_API_KEY:
        raise HTTPException(status_code=500, detail="AI extraction not configured. Add ANTHROPIC_API_KEY to .env")

    # Determine media type for Claude
    if body.file_type == "application/pdf":
        media_type = "application/pdf"
        source_type = "base64"
    elif body.file_type in ["image/jpeg", "image/jpg"]:
        media_type = "image/jpeg"
        source_type = "base64"
    elif body.file_type == "image/png":
        media_type = "image/png"
        source_type = "base64"
    elif body.file_type == "image/webp":
        media_type = "image/webp"
        source_type = "base64"
    else:
        raise HTTPException(status_code=400, detail="Unsupported file type. Use PDF, JPG, PNG, or WebP.")

    # Build message for Claude
    if media_type == "application/pdf":
        content = [
            {
                "type": "document",
                "source": {
                    "type": "base64",
                    "media_type": "application/pdf",
                    "data": body.file_data
                }
            },
            {"type": "text", "text": EXTRACT_PROMPT}
        ]
    else:
        content = [
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": media_type,
                    "data": body.file_data
                }
            },
            {"type": "text", "text": EXTRACT_PROMPT}
        ]

    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": ANTHROPIC_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json"
            },
            json={
                "model": "claude-opus-4-5",
                "max_tokens": 2000,
                "messages": [{"role": "user", "content": content}]
            }
        )

    if response.status_code != 200:
        raise HTTPException(status_code=500, detail=f"AI extraction failed: {response.text}")

    data = response.json()
    raw = data["content"][0]["text"].strip()

    # Clean any accidental markdown
    raw = raw.replace("```json", "").replace("```", "").strip()

    # Find JSON boundaries
    start = raw.find("{")
    end = raw.rfind("}") + 1
    if start == -1:
        raise HTTPException(status_code=500, detail="Could not parse CV. Please try a clearer image or PDF.")

    try:
        extracted = json.loads(raw[start:end])
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Could not parse extracted data: {str(e)}")

    return extracted
