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
