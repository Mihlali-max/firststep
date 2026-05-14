#!/bin/bash
set -e
cd ~/firststep/backend
echo "🎨 Rebuilding CV PDF to match Classic template..."

cat > app/services/pdf_service.py << 'PYEOF'
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas
from io import BytesIO

W, H = A4

def hex_to_color(hex_str: str, alpha=1.0):
    h = hex_str.lstrip('#')
    if len(h) != 6:
        return colors.Color(0.08, 0.39, 0.75, alpha=alpha)
    r,g,b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
    return colors.Color(r, g, b, alpha=alpha)

def draw_text_wrapped(c, text, x, y, max_width, font, size, color, line_height):
    c.setFont(font, size)
    c.setFillColor(color)
    words = str(text).split()
    line = ""
    for word in words:
        test = (line + " " + word).strip()
        if c.stringWidth(test, font, size) <= max_width:
            line = test
        else:
            if line:
                c.drawString(x, y, line)
                y -= line_height
            line = word
    if line:
        c.drawString(x, y, line)
        y -= line_height
    return y

def generate_cv_pdf(cv_data: dict) -> bytes:
    buffer = BytesIO()
    pi      = cv_data.get('personal_info') or {}
    edu     = cv_data.get('education') or []
    skills  = cv_data.get('skills') or []
    exp     = cv_data.get('experience') or []
    refs    = cv_data.get('references') or []
    langs   = [l.strip() for l in (pi.get('languages') or 'English').split(',') if l.strip()]
    
    accent_hex = pi.get('color', '#1565C0')
    accent     = hex_to_color(accent_hex)
    accent_bg  = hex_to_color(accent_hex, alpha=0.12)
    accent_mid = hex_to_color(accent_hex, alpha=0.35)
    
    dark   = colors.Color(0.08, 0.08, 0.04)
    grey   = colors.Color(0.45, 0.45, 0.45)
    lgrey  = colors.Color(0.65, 0.65, 0.65)
    white  = colors.white
    offwht = colors.Color(0.98, 0.97, 0.96)

    cv = canvas.Canvas(buffer, pagesize=A4)
    cv.setTitle(f"{pi.get('name','CV')} - CV")

    # ══════════════════════════════════════════
    # HEADER BANNER — light accent background
    # ══════════════════════════════════════════
    header_h = 52*mm
    cv.setFillColor(accent_bg)
    cv.rect(0, H - header_h, W, header_h, fill=1, stroke=0)

    # Photo circle placeholder (left side)
    circle_x = 28*mm
    circle_y = H - header_h + 8*mm
    circle_r = 18*mm
    cv.setFillColor(accent_mid)
    cv.circle(circle_x, circle_y, circle_r, fill=1, stroke=0)
    cv.setFillColor(white)
    initial = (pi.get('name') or '?')[0].upper()
    cv.setFont("Helvetica-Bold", 22)
    cv.drawCentredString(circle_x, circle_y - 4*mm, initial)

    # Name + title (right of circle)
    name_x = 52*mm
    cv.setFillColor(dark)
    cv.setFont("Helvetica-Bold", 22)
    name_text = (pi.get('name') or 'YOUR NAME').upper()
    cv.drawString(name_x, H - 18*mm, name_text)

    if pi.get('title'):
        cv.setFont("Helvetica", 11)
        cv.setFillColor(grey)
        cv.drawString(name_x, H - 25*mm, pi['title'])

    # Accent line below header
    cv.setStrokeColor(accent)
    cv.setLineWidth(2.5)
    cv.line(0, H - header_h - 0.5*mm, W, H - header_h - 0.5*mm)

    # ══════════════════════════════════════════
    # TWO COLUMN BODY
    # ══════════════════════════════════════════
    left_x  = 10*mm
    left_w  = 58*mm
    right_x = 74*mm
    right_w = W - right_x - 10*mm
    top_y   = H - header_h - 8*mm

    left_y  = top_y
    right_y = top_y

    # ── helpers
    def section_header_left(title, y):
        cv.setFont("Helvetica-Bold", 8)
        cv.setFillColor(dark)
        cv.drawString(left_x, y, title.upper())
        y -= 2.5*mm
        cv.setStrokeColor(lgrey)
        cv.setLineWidth(0.5)
        cv.line(left_x, y, left_x + left_w, y)
        return y - 4*mm

    def section_header_right(title, y):
        cv.setFont("Helvetica-Bold", 13)
        cv.setFillColor(dark)
        cv.drawString(right_x, y, title)
        y -= 2.5*mm
        cv.setStrokeColor(dark)
        cv.setLineWidth(1.5)
        cv.line(right_x, y, right_x + right_w, y)
        return y - 5*mm

    # ── LEFT: Contact card
    cv.setFillColor(accent_bg)
    cv.roundRect(left_x - 1.5*mm, left_y - 32*mm, left_w + 3*mm, 32*mm, 3*mm, fill=1, stroke=0)
    cy = left_y - 5.5*mm
    items = []
    if pi.get('phone'):    items.append(("☏", pi['phone']))
    if pi.get('email'):    items.append(("✉", pi['email'][:30]))
    if pi.get('location'): items.append(("⊕", pi['location'][:28]))
    if pi.get('linkedin'): items.append(("in", pi['linkedin'][:25]))
    for icon, val in items:
        cv.setFont("Helvetica", 7)
        cv.setFillColor(grey)
        cv.drawString(left_x + 2*mm, cy, icon)
        cv.setFillColor(dark)
        cv.drawString(left_x + 7*mm, cy, val)
        cy -= 5*mm
    left_y -= 35*mm

    # ── LEFT: Education
    if any(e.get('school') for e in edu):
        left_y = section_header_left("Education", left_y)
        for e in edu:
            if not e.get('school'): continue
            if e.get('year'):
                cv.setFont("Helvetica", 7.5)
                cv.setFillColor(lgrey)
                cv.drawString(left_x, left_y, e['year'])
                left_y -= 4*mm
            cv.setFont("Helvetica-Bold", 8.5)
            cv.setFillColor(dark)
            left_y = draw_text_wrapped(cv, e.get('qualification',''), left_x, left_y, left_w, "Helvetica-Bold", 8.5, dark, 4*mm)
            cv.setFont("Helvetica", 8)
            cv.setFillColor(grey)
            cv.drawString(left_x, left_y, (e.get('school') or '')[:28])
            left_y -= 7*mm

    # ── LEFT: Skills
    if skills:
        left_y -= 1*mm
        left_y = section_header_left("Skills", left_y)
        for s in skills:
            if left_y < 25*mm: break
            cv.setFillColor(grey)
            cv.circle(left_x + 2*mm, left_y + 1.5*mm, 1.2*mm, fill=1, stroke=0)
            cv.setFont("Helvetica", 8.5)
            cv.setFillColor(dark)
            cv.drawString(left_x + 5.5*mm, left_y, s[:26])
            left_y -= 5*mm

    # ── LEFT: Languages
    if langs:
        left_y -= 1*mm
        left_y = section_header_left("Language", left_y)
        for l in langs:
            if left_y < 20*mm: break
            cv.setFont("Helvetica", 9)
            cv.setFillColor(dark)
            cv.drawString(left_x, left_y, l)
            left_y -= 5*mm

    # ── LEFT: References
    if refs and any(r.get('name') for r in refs):
        left_y -= 1*mm
        left_y = section_header_left("References", left_y)
        for r in refs:
            if not r.get('name'): continue
            if left_y < 20*mm: break
            cv.setFont("Helvetica-Bold", 8.5)
            cv.setFillColor(dark)
            cv.drawString(left_x, left_y, (r['name'])[:22])
            left_y -= 4*mm
            cv.setFont("Helvetica", 7.5)
            cv.setFillColor(grey)
            if r.get('relation'):
                cv.drawString(left_x, left_y, r['relation'][:24])
                left_y -= 3.5*mm
            if r.get('contact'):
                cv.drawString(left_x, left_y, f"Phone: {r['contact']}")
                left_y -= 5*mm

    # ══ RIGHT COLUMN ══

    # ── RIGHT: About Me
    if pi.get('summary'):
        right_y = section_header_right("About Me", right_y)
        cv.setFont("Helvetica", 8.5)
        cv.setFillColor(colors.Color(0.27, 0.27, 0.27))
        right_y = draw_text_wrapped(cv, pi['summary'], right_x, right_y, right_w, "Helvetica", 8.5, colors.Color(0.27,0.27,0.27), 4.5*mm)
        right_y -= 5*mm

    # ── RIGHT: Work Experience
    if any(e.get('title') for e in exp):
        right_y = section_header_right("Work Experience", right_y)
        for e in exp:
            if not e.get('title'): continue
            if right_y < 30*mm: break
            # Date range
            dates = " – ".join(filter(None, [e.get('start_date',''), e.get('end_date','')]))
            if e.get('is_volunteer'): dates += " (Volunteer)"
            if dates:
                cv.setFont("Helvetica-Bold", 8.5)
                cv.setFillColor(accent)
                cv.drawString(right_x, right_y, dates)
                right_y -= 4.5*mm
            # Title — Org
            title_line = e.get('title','')
            if e.get('organisation'): title_line += f" — {e['organisation']}"
            cv.setFont("Helvetica-Bold", 10.5)
            cv.setFillColor(dark)
            right_y = draw_text_wrapped(cv, title_line, right_x, right_y, right_w, "Helvetica-Bold", 10.5, dark, 5*mm)
            right_y -= 1*mm
            # Bullet points
            desc = e.get('description') or ''
            for bullet in desc.split('\n'):
                bullet = bullet.strip().lstrip('-•').strip()
                if not bullet or right_y < 30*mm: continue
                # Bullet dot
                cv.setFillColor(grey)
                cv.circle(right_x + 2*mm, right_y + 1.5*mm, 1*mm, fill=1, stroke=0)
                right_y = draw_text_wrapped(cv, bullet, right_x + 5.5*mm, right_y, right_w - 5.5*mm, "Helvetica", 8.5, colors.Color(0.27,0.27,0.27), 4.5*mm)
            right_y -= 5*mm

    cv.save()
    return buffer.getvalue()
PYEOF

echo "✅ PDF v2 done! Restarting backend..."
fuser -k 8000/tcp 2>/dev/null || true
uvicorn app.main:app --reload --port 8000
