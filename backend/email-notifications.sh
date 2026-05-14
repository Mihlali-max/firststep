#!/bin/bash
set -e
cd ~/firststep/backend
echo "📧 Building email notification system..."

# Install resend
pip install resend --break-system-packages 2>/dev/null || true
echo "resend" >> requirements.txt

# Create email service
cat > app/services/email_service.py << 'EOF'
import resend
import os
from datetime import datetime

resend.api_key = os.getenv("RESEND_API_KEY", "")

def send_learnership_alert(to_email: str, name: str, jobs: list, province: str = ""):
    if not resend.api_key:
        print("No RESEND_API_KEY set")
        return False
    
    jobs_html = ""
    for j in jobs[:5]:
        salary = ""
        if j.get("salary_min"):
            salary = f"<span style='color:#2E7D32;font-weight:700'>R{int(j['salary_min']):,}/mo</span>"
        jobs_html += f"""
        <div style="border:1px solid #E5E7EB;border-radius:12px;padding:16px;margin-bottom:12px;background:#fff">
          <div style="font-weight:800;font-size:15px;color:#1A1A0F;margin-bottom:4px">{j.get('title','')}</div>
          <div style="font-size:13px;color:#6B7280;margin-bottom:6px">{j.get('company','')} · {j.get('location','')}</div>
          {f'<div style="margin-bottom:8px">{salary}</div>' if salary else ''}
          <div style="font-size:12px;color:#9CA3AF;margin-bottom:10px;line-height:1.5">{j.get('description','')[:120]}...</div>
          <a href="{j.get('apply_url','https://firststep-frontend-sqyb.onrender.com/learnerships')}" 
             style="display:inline-block;background:#F5A623;color:#1A1A0F;font-weight:700;font-size:13px;padding:8px 16px;border-radius:8px;text-decoration:none">
            Apply now →
          </a>
        </div>"""

    html = f"""
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
    <body style="margin:0;padding:0;background:#F7F3EB;font-family:'Helvetica Neue',Arial,sans-serif">
      <div style="max-width:600px;margin:0 auto;padding:20px">
        
        <!-- Header -->
        <div style="background:#1A1A0F;border-radius:16px;padding:28px 24px;margin-bottom:20px;text-align:center">
          <div style="font-size:24px;font-weight:900;color:#FFFDF7;letter-spacing:-0.5px">
            First<span style="color:#F5A623">Step</span>
          </div>
          <div style="color:rgba(255,255,255,0.5);font-size:12px;margin-top:4px">Your first job starts here</div>
        </div>

        <!-- Main card -->
        <div style="background:#fff;border-radius:16px;padding:28px 24px;margin-bottom:16px;border:1px solid #E5E7EB">
          <div style="font-size:22px;font-weight:800;color:#1A1A0F;margin-bottom:6px">
            Hey {name.split()[0]}! 👋
          </div>
          <div style="font-size:14px;color:#6B7280;margin-bottom:20px;line-height:1.6">
            We found <strong style="color:#1A1A0F">{len(jobs)} new {'learnership' if len(jobs)==1 else 'learnerships'}</strong>
            {f' in <strong>{province}</strong>' if province else ''} that match your profile. 
            Don't miss out — these fill up fast!
          </div>
          
          {jobs_html}
          
          <div style="text-align:center;margin-top:20px">
            <a href="https://firststep-frontend-sqyb.onrender.com/learnerships"
               style="display:inline-block;background:#1A1A0F;color:#F5A623;font-weight:700;font-size:14px;padding:12px 28px;border-radius:12px;text-decoration:none">
              View all {len(jobs)}+ opportunities →
            </a>
          </div>
        </div>

        <!-- Tips -->
        <div style="background:#fff;border-radius:16px;padding:20px 24px;margin-bottom:16px;border:1px solid #E5E7EB">
          <div style="font-weight:700;font-size:14px;color:#1A1A0F;margin-bottom:12px">💡 Quick tips to stand out</div>
          <div style="font-size:13px;color:#6B7280;line-height:1.8">
            ✅ Apply within 48 hours — early applicants get noticed<br>
            ✅ Make sure your CV is complete on FirstStep<br>
            ✅ Use our AI Coach to prep your cover letter<br>
            ✅ Add references to your CV before applying
          </div>
        </div>

        <!-- Footer -->
        <div style="text-align:center;padding:16px;color:#9CA3AF;font-size:12px">
          <div style="margin-bottom:8px">
            <a href="https://firststep-frontend-sqyb.onrender.com/cv" style="color:#F5A623;text-decoration:none;margin:0 8px">Build CV</a>
            <a href="https://firststep-frontend-sqyb.onrender.com/coach" style="color:#F5A623;text-decoration:none;margin:0 8px">AI Coach</a>
            <a href="https://firststep-frontend-sqyb.onrender.com/learnerships" style="color:#F5A623;text-decoration:none;margin:0 8px">Learnerships</a>
          </div>
          <div>© 2026 FirstStep — Cape Town, South Africa</div>
          <div style="margin-top:4px">Free, always. Built with purpose. 🇿🇦</div>
        </div>
      </div>
    </body>
    </html>"""

    try:
        resend.Emails.send({
            "from": "FirstStep <notifications@firststep.co.za>",
            "to": to_email,
            "subject": f"🎯 {len(jobs)} new learnership{'s' if len(jobs)>1 else ''} for you{' in ' + province if province else ''}!",
            "html": html,
        })
        return True
    except Exception as e:
        print(f"Email error: {e}")
        # Try with resend.dev domain as fallback
        try:
            resend.Emails.send({
                "from": "FirstStep <onboarding@resend.dev>",
                "to": to_email,
                "subject": f"🎯 {len(jobs)} new learnership{'s' if len(jobs)>1 else ''} for you!",
                "html": html,
            })
            return True
        except Exception as e2:
            print(f"Email fallback error: {e2}")
            return False


def send_welcome_email(to_email: str, name: str):
    if not resend.api_key:
        return False
    html = f"""
    <!DOCTYPE html>
    <html>
    <body style="margin:0;padding:0;background:#F7F3EB;font-family:'Helvetica Neue',Arial,sans-serif">
      <div style="max-width:600px;margin:0 auto;padding:20px">
        <div style="background:#1A1A0F;border-radius:16px;padding:28px 24px;margin-bottom:20px;text-align:center">
          <div style="font-size:24px;font-weight:900;color:#FFFDF7">First<span style="color:#F5A623">Step</span></div>
        </div>
        <div style="background:#fff;border-radius:16px;padding:28px 24px;border:1px solid #E5E7EB">
          <div style="font-size:22px;font-weight:800;color:#1A1A0F;margin-bottom:12px">Welcome, {name.split()[0]}! 🎉</div>
          <div style="font-size:14px;color:#6B7280;line-height:1.8;margin-bottom:20px">
            You've just joined thousands of SA youth using FirstStep to land their first job.<br><br>
            Here's what you can do right now:
          </div>
          <div style="font-size:14px;color:#1A1A0F;line-height:2">
            📄 <a href="https://firststep-frontend-sqyb.onrender.com/cv" style="color:#F5A623;font-weight:700">Build your CV</a> — takes 5 minutes<br>
            💼 <a href="https://firststep-frontend-sqyb.onrender.com/learnerships" style="color:#F5A623;font-weight:700">Browse learnerships</a> — 600+ live opportunities<br>
            🤖 <a href="https://firststep-frontend-sqyb.onrender.com/coach" style="color:#F5A623;font-weight:700">Chat to AI Coach</a> — free career advice<br>
            🏛️ <a href="https://firststep-frontend-sqyb.onrender.com/lap" style="color:#F5A623;font-weight:700">Check LAP programmes</a> — government funded
          </div>
          <div style="margin-top:24px;text-align:center">
            <a href="https://firststep-frontend-sqyb.onrender.com" style="display:inline-block;background:#F5A623;color:#1A1A0F;font-weight:700;padding:12px 28px;border-radius:12px;text-decoration:none">
              Get started →
            </a>
          </div>
        </div>
        <div style="text-align:center;padding:16px;color:#9CA3AF;font-size:12px;margin-top:8px">
          © 2026 FirstStep — Free, always. 🇿🇦
        </div>
      </div>
    </body>
    </html>"""
    try:
        resend.Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": to_email,
            "subject": "Welcome to FirstStep 🇿🇦 — your first job starts here",
            "html": html,
        })
        return True
    except Exception as e:
        print(f"Welcome email error: {e}")
        return False
EOF

# Create notification scheduler
cat > app/api/notifications.py << 'EOF'
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
EOF

# Register router in main.py
python3 - << 'PYEOF'
with open("app/main.py","r") as f: c = f.read()
if "notifications" not in c:
    c = c.replace(
        "from app.api.jobs import router as jobs_router",
        "from app.api.jobs import router as jobs_router\nfrom app.api.notifications import router as notifications_router"
    )
    c = c.replace(
        "app.include_router(jobs_router, prefix=\"/api\")",
        "app.include_router(jobs_router, prefix=\"/api\")\napp.include_router(notifications_router, prefix=\"/api\")"
    )
    with open("app/main.py","w") as f: f.write(c)
    print("✅ notifications router registered")
else:
    print("ℹ️  already registered")
PYEOF

# Also send welcome email on register
python3 - << 'PYEOF'
with open("app/api/auth.py","r") as f: c = f.read()
if "send_welcome_email" not in c:
    c = c.replace(
        "from app.core.security import hash_password",
        "from app.core.security import hash_password\nfrom app.services.email_service import send_welcome_email"
    )
    # Add welcome email after register
    c = c.replace(
        "return TokenResponse(access_token=create_access_token({\"sub\": user.id}), refresh_token=create_refresh_token({\"sub\": user.id}), user=UserResponse.model_validate(user))\n\n",
        "try:\n        send_welcome_email(user.email, user.full_name)\n    except: pass\n    return TokenResponse(access_token=create_access_token({\"sub\": user.id}), refresh_token=create_refresh_token({\"sub\": user.id}), user=UserResponse.model_validate(user))\n\n"
    )
    with open("app/api/auth.py","w") as f: f.write(c)
    print("✅ welcome email on register")
PYEOF

echo "✅ Email notifications done!"

# Add notification preferences to frontend
cd ~/firststep/frontend

cat > src/components/NotificationPrefs.tsx << 'EOF'
import { useState } from 'react'
import { Bell, Check, Loader2 } from 'lucide-react'
import api from '../lib/api'
import clsx from 'clsx'

const SECTORS = ['Any sector','Retail & FMCG','Banking & Finance','IT & Digital','Construction','Healthcare','Education','Hospitality','Administration','Transport & Logistics']
const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']

export default function NotificationPrefs() {
  const [sector, setSector]   = useState('Any sector')
  const [province, setProv]   = useState('All Provinces')
  const [saving, setSaving]   = useState(false)
  const [saved, setSaved]     = useState(false)
  const [testing, setTesting] = useState(false)
  const [tested, setTested]   = useState(false)

  const save = async () => {
    setSaving(true)
    try {
      await api.post('/notifications/preferences', {
        email_alerts: true,
        preferred_sector: sector === 'Any sector' ? '' : sector,
        preferred_province: province === 'All Provinces' ? '' : province,
      })
      setSaved(true); setTimeout(()=>setSaved(false), 2000)
    } catch(e){ console.error(e) }
    finally { setSaving(false) }
  }

  const sendTest = async () => {
    setTesting(true)
    try {
      await api.post('/notifications/test')
      setTested(true); setTimeout(()=>setTested(false), 3000)
    } catch(e){ console.error(e) }
    finally { setTesting(false) }
  }

  const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 transition-all appearance-none"

  return (
    <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
      <div className="flex items-center gap-3 mb-5">
        <div className="w-10 h-10 rounded-xl bg-[#F5A623]/15 flex items-center justify-center">
          <Bell size={18} className="text-[#F5A623]"/>
        </div>
        <div>
          <div className="font-bold text-sm text-[#1A1A0F]">Job Alert Notifications</div>
          <div className="text-xs text-black/40">Get emailed when new learnerships match your profile</div>
        </div>
      </div>

      <div className="space-y-3 mb-5">
        <div>
          <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Preferred sector</label>
          <select className={inp} value={sector} onChange={e=>setSector(e.target.value)}>
            {SECTORS.map(s=><option key={s}>{s}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Your province</label>
          <select className={inp} value={province} onChange={e=>setProv(e.target.value)}>
            {PROVINCES.map(p=><option key={p}>{p}</option>)}
          </select>
        </div>
      </div>

      <div className="flex gap-2">
        <button onClick={save} disabled={saving} className="btn-amber flex-1 flex items-center justify-center gap-2 !py-2.5 text-sm font-bold">
          {saving ? <Loader2 size={14} className="animate-spin"/> : saved ? <Check size={14}/> : <Bell size={14}/>}
          {saved ? 'Saved!' : 'Save preferences'}
        </button>
        <button onClick={sendTest} disabled={testing} className="flex items-center gap-1.5 text-sm font-semibold px-4 py-2.5 rounded-xl border border-black/10 hover:bg-[#F7F3EB] transition-colors">
          {testing ? <Loader2 size={13} className="animate-spin"/> : tested ? '✓ Sent!' : '📧 Test'}
        </button>
      </div>
      {tested && <p className="text-xs text-green-600 mt-2 text-center">Test email sent! Check your inbox.</p>}
    </div>
  )
}
EOF

echo "✅ Frontend notification component done!"
