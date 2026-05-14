#!/bin/bash
set -e
cd ~/firststep/backend
echo "📄 Building CV PDF download..."

pip install reportlab --break-system-packages 2>/dev/null || true
echo "reportlab" >> requirements.txt

cat > app/services/pdf_service.py << 'EOF'
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_JUSTIFY
from reportlab.pdfgen import canvas
from io import BytesIO
import json

W, H = A4  # 210mm x 297mm

def hex_to_rgb(hex_color: str):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16)/255 for i in (0, 2, 4))

def generate_cv_pdf(cv_data: dict) -> bytes:
    buffer = BytesIO()
    pi = cv_data.get('personal_info', {}) or {}
    edu = cv_data.get('education', []) or []
    skills = cv_data.get('skills', []) or []
    exp = cv_data.get('experience', []) or []
    refs = cv_data.get('references', []) or []
    langs = [l.strip() for l in (pi.get('languages') or '').split(',') if l.strip()]
    accent = pi.get('color', '#1565C0')
    
    try:
        ar, ag, ab = hex_to_rgb(accent)
        accent_color = colors.Color(ar, ag, ab)
    except:
        accent_color = colors.Color(0.08, 0.39, 0.75)

    c = canvas.Canvas(buffer, pagesize=A4)
    
    # ── HEADER BACKGROUND
    light_r, light_g, light_b = accent_color.red, accent_color.green, accent_color.blue
    c.setFillColor(colors.Color(light_r, light_g, light_b, alpha=0.15))
    c.rect(0, H - 55*mm, W, 55*mm, fill=1, stroke=0)
    
    # ── NAME
    c.setFillColor(colors.Color(0.1, 0.1, 0.06))
    c.setFont("Helvetica-Bold", 22)
    name = (pi.get('name') or 'YOUR NAME').upper()
    c.drawString(28*mm, H - 22*mm, name)
    
    # ── TITLE
    if pi.get('title'):
        c.setFont("Helvetica", 11)
        c.setFillColor(colors.Color(0.33, 0.33, 0.33))
        c.drawString(28*mm, H - 30*mm, pi['title'])
    
    # ── CONTACT ROW
    c.setFont("Helvetica", 8)
    c.setFillColor(colors.Color(0.45, 0.45, 0.45))
    contact_parts = []
    if pi.get('email'):    contact_parts.append(f"✉ {pi['email']}")
    if pi.get('phone'):    contact_parts.append(f"☏ {pi['phone']}")
    if pi.get('location'): contact_parts.append(f"⊕ {pi['location']}")
    contact_str = "   |   ".join(contact_parts)
    c.drawString(28*mm, H - 39*mm, contact_str)
    
    # ── ACCENT LINE
    c.setStrokeColor(accent_color)
    c.setLineWidth(3)
    c.line(0, H - 55*mm, W, H - 55*mm)

    # ── TWO COLUMN LAYOUT
    left_x = 10*mm
    left_w = 60*mm
    right_x = 75*mm
    right_w = W - right_x - 10*mm
    y = H - 62*mm

    def section_title_left(title, ypos):
        c.setFont("Helvetica-Bold", 8)
        c.setFillColor(colors.Color(0.1, 0.1, 0.06))
        c.drawString(left_x, ypos, title.upper())
        ypos -= 2*mm
        c.setStrokeColor(colors.Color(0.8, 0.8, 0.8))
        c.setLineWidth(0.5)
        c.line(left_x, ypos, left_x + left_w, ypos)
        return ypos - 4*mm

    def section_title_right(title, ypos):
        c.setFont("Helvetica-Bold", 11)
        c.setFillColor(colors.Color(0.1, 0.1, 0.06))
        c.drawString(right_x, ypos, title)
        ypos -= 2*mm
        c.setStrokeColor(colors.Color(0.1, 0.1, 0.06))
        c.setLineWidth(1.5)
        c.line(right_x, ypos, right_x + right_w, ypos)
        return ypos - 5*mm

    def wrap_text(text, font, size, max_width, canvas_obj):
        canvas_obj.setFont(font, size)
        words = str(text).split()
        lines = []
        current = ""
        for word in words:
            test = f"{current} {word}".strip()
            if canvas_obj.stringWidth(test, font, size) <= max_width:
                current = test
            else:
                if current: lines.append(current)
                current = word
        if current: lines.append(current)
        return lines

    left_y = y
    right_y = y

    # ── LEFT: CONTACT CARD
    c.setFillColor(colors.Color(accent_color.red, accent_color.green, accent_color.blue, alpha=0.1))
    c.roundRect(left_x - 2*mm, left_y - 28*mm, left_w + 4*mm, 28*mm, 3*mm, fill=1, stroke=0)
    
    c.setFont("Helvetica", 8)
    c.setFillColor(colors.Color(0.2, 0.2, 0.2))
    cy = left_y - 6*mm
    if pi.get('email'):
        c.drawString(left_x + 2*mm, cy, f"✉  {pi['email'][:32]}")
        cy -= 5*mm
    if pi.get('phone'):
        c.drawString(left_x + 2*mm, cy, f"☏  {pi['phone']}")
        cy -= 5*mm
    if pi.get('location'):
        c.drawString(left_x + 2*mm, cy, f"⊕  {pi['location'][:30]}")
        cy -= 5*mm
    if pi.get('linkedin'):
        c.drawString(left_x + 2*mm, cy, f"in  {pi['linkedin'][:28]}")
    
    left_y -= 32*mm

    # ── LEFT: EDUCATION
    if edu:
        left_y = section_title_left("Education", left_y)
        for e in edu:
            if not e.get('school'): continue
            if e.get('year'):
                c.setFont("Helvetica", 7)
                c.setFillColor(colors.Color(0.5, 0.5, 0.5))
                c.drawString(left_x, left_y, e['year'])
                left_y -= 4*mm
            c.setFont("Helvetica-Bold", 8.5)
            c.setFillColor(colors.Color(0.1, 0.1, 0.06))
            for line in wrap_text(e.get('qualification',''), "Helvetica-Bold", 8.5, left_w, c):
                c.drawString(left_x, left_y, line)
                left_y -= 4*mm
            c.setFont("Helvetica", 8)
            c.setFillColor(colors.Color(0.4, 0.4, 0.4))
            c.drawString(left_x, left_y, e.get('school','')[:30])
            left_y -= 6*mm

    # ── LEFT: SKILLS
    if skills:
        left_y -= 2*mm
        left_y = section_title_left("Skills", left_y)
        c.setFont("Helvetica", 8.5)
        c.setFillColor(colors.Color(0.2, 0.2, 0.2))
        for s in skills:
            c.setFillColor(colors.Color(0.5, 0.5, 0.5))
            c.circle(left_x + 2*mm, left_y + 1.5*mm, 1.2*mm, fill=1, stroke=0)
            c.setFillColor(colors.Color(0.2, 0.2, 0.2))
            c.drawString(left_x + 5*mm, left_y, s[:28])
            left_y -= 5*mm
            if left_y < 20*mm: break

    # ── LEFT: LANGUAGES
    if langs:
        left_y -= 2*mm
        left_y = section_title_left("Languages", left_y)
        for l in langs:
            c.setFont("Helvetica", 9)
            c.setFillColor(colors.Color(0.2, 0.2, 0.2))
            c.drawString(left_x, left_y, l)
            left_y -= 5*mm

    # ── RIGHT: ABOUT ME
    if pi.get('summary'):
        right_y = section_title_right("About Me", right_y)
        c.setFont("Helvetica", 8.5)
        c.setFillColor(colors.Color(0.27, 0.27, 0.27))
        for line in wrap_text(pi['summary'], "Helvetica", 8.5, right_w, c):
            c.drawString(right_x, right_y, line)
            right_y -= 4.5*mm
        right_y -= 4*mm

    # ── RIGHT: WORK EXPERIENCE
    if exp:
        right_y = section_title_right("Work Experience", right_y)
        for e in exp:
            if not e.get('title'): continue
            # Date
            dates = " – ".join(filter(None, [e.get('start_date',''), e.get('end_date','')]))
            if dates:
                c.setFont("Helvetica-Bold", 8.5)
                c.setFillColor(accent_color)
                c.drawString(right_x, right_y, dates)
                right_y -= 4.5*mm
            # Title — Org
            title_org = e.get('title','')
            if e.get('organisation'): title_org += f" — {e['organisation']}"
            if e.get('is_volunteer'): title_org += " (Volunteer)"
            c.setFont("Helvetica-Bold", 10)
            c.setFillColor(colors.Color(0.1, 0.1, 0.06))
            for line in wrap_text(title_org, "Helvetica-Bold", 10, right_w, c):
                c.drawString(right_x, right_y, line)
                right_y -= 5*mm
            # Bullets
            desc = e.get('description','')
            if desc:
                for bullet in desc.split('\n'):
                    bullet = bullet.strip().lstrip('-•').strip()
                    if not bullet: continue
                    c.setFillColor(colors.Color(0.4, 0.4, 0.4))
                    c.circle(right_x + 2*mm, right_y + 1.5*mm, 1*mm, fill=1, stroke=0)
                    c.setFont("Helvetica", 8.5)
                    c.setFillColor(colors.Color(0.27, 0.27, 0.27))
                    lines = wrap_text(bullet, "Helvetica", 8.5, right_w - 6*mm, c)
                    for i, line in enumerate(lines):
                        c.drawString(right_x + 5*mm, right_y, line)
                        right_y -= 4.5*mm
                    if right_y < 30*mm: break
            right_y -= 4*mm
            if right_y < 30*mm: break

    # ── RIGHT: REFERENCES
    if refs:
        right_y -= 2*mm
        right_y = section_title_right("References", right_y)
        # Two columns
        col_w = right_w / 2
        ref_x = [right_x, right_x + col_w]
        ref_y = right_y
        for i, r in enumerate(refs):
            if not r.get('name'): continue
            rx = ref_x[i % 2]
            if i % 2 == 0 and i > 0: ref_y -= 14*mm
            c.setFont("Helvetica-Bold", 9.5)
            c.setFillColor(colors.Color(0.1, 0.1, 0.06))
            c.drawString(rx, ref_y, r['name'][:22])
            c.setFont("Helvetica", 8)
            c.setFillColor(colors.Color(0.5, 0.5, 0.5))
            if r.get('relation'):
                c.drawString(rx, ref_y - 4*mm, r['relation'][:25])
            if r.get('contact'):
                c.drawString(rx, ref_y - 8*mm, f"Phone: {r['contact']}")

    c.save()
    return buffer.getvalue()
EOF

# Add download endpoint to cv.py
cat >> app/api/cv.py << 'EOF'

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
EOF

echo "✅ CV PDF download done!"
fuser -k 8000/tcp 2>/dev/null || true
uvicorn app.main:app --reload --port 8000
