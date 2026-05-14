import resend
import os
from datetime import datetime

resend.api_key = os.getenv("RESEND_API_KEY", "")
from resend import Emails

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
        Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": to_email,
            "subject": f"🎯 {len(jobs)} new learnership{'s' if len(jobs)>1 else ''} for you{' in ' + province if province else ''}!",
            "html": html,
        })
        return True
    except Exception as e:
        print(f"Email error: {e}")
        # Try with resend.dev domain as fallback
        try:
            Emails.send({
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
        Emails.send({
            "from": "FirstStep <onboarding@resend.dev>",
            "to": to_email,
            "subject": "Welcome to FirstStep 🇿🇦 — your first job starts here",
            "html": html,
        })
        return True
    except Exception as e:
        print(f"Welcome email error: {e}")
        return False
