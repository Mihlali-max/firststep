from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
from io import BytesIO
import base64, io

W, H = A4

def hex_to_color(hex_str, alpha=1.0):
    try:
        h = hex_str.lstrip('#')
        r,g,b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
        return colors.Color(r,g,b,alpha=alpha)
    except:
        return colors.Color(0.72,0.78,0.83,alpha=alpha)

def get_image(b64_str):
    try:
        if ',' in b64_str:
            b64_str = b64_str.split(',')[1]
        return ImageReader(io.BytesIO(base64.b64decode(b64_str)))
    except:
        return None

def wrapped_lines(c, text, font, size, max_w):
    c.setFont(font, size)
    words = str(text).split()
    lines, cur = [], ""
    for w in words:
        test = (cur + " " + w).strip()
        if c.stringWidth(test, font, size) <= max_w:
            cur = test
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines

def draw_wrapped(c, text, x, y, font, size, color, max_w, lh):
    c.setFont(font, size)
    c.setFillColor(color)
    for line in wrapped_lines(c, text, font, size, max_w):
        c.drawString(x, y, line)
        y -= lh
    return y

def generate_cv_pdf(cv_data: dict) -> bytes:
    buf = BytesIO()
    pi    = cv_data.get('personal_info') or {}
    edu   = cv_data.get('education') or []
    skills= cv_data.get('skills') or []
    exp   = cv_data.get('experience') or []
    refs  = cv_data.get('references') or []
    langs = [l.strip() for l in (pi.get('languages') or 'English').split(',') if l.strip()]

    # Colors
    acc   = hex_to_color(pi.get('color', '#B8C4CC'))
    acc_l = hex_to_color(pi.get('color', '#B8C4CC'), 0.18)
    dark  = colors.Color(0.10, 0.10, 0.10)
    grey  = colors.Color(0.40, 0.40, 0.40)
    lgrey = colors.Color(0.65, 0.65, 0.65)
    white = colors.white

    cv = canvas.Canvas(buf, pagesize=A4)
    cv.setTitle(f"{pi.get('name','CV')} - CV")

    # ── HEADER BAND ──────────────────────────────────────────────────────────
    header_h = 52*mm
    cv.setFillColor(acc_l)
    cv.rect(0, H - header_h, W, header_h, fill=1, stroke=0)

    # Photo circle — top left, overlapping header bottom
    photo_size = 38*mm
    photo_x = 10*mm
    photo_y = H - header_h - photo_size/2 + 14*mm  # overlaps header bottom

    if pi.get('photo'):
        img = get_image(pi['photo'])
        if img:
            # Draw white circle background
            cv.setFillColor(white)
            cv.circle(photo_x + photo_size/2, photo_y + photo_size/2, photo_size/2 + 1.5*mm, fill=1, stroke=0)
            # Draw image clipped to circle using a rectangular approximation
            cv.saveState()
            p = cv.beginPath()
            p.circle(photo_x + photo_size/2, photo_y + photo_size/2, photo_size/2)
            cv.clipPath(p, stroke=0)
            cv.drawImage(img, photo_x, photo_y, width=photo_size, height=photo_size, mask='auto')
            cv.restoreState()
            # Draw accent circle border
            cv.setStrokeColor(acc)
            cv.setLineWidth(2)
            cv.circle(photo_x + photo_size/2, photo_y + photo_size/2, photo_size/2 + 1*mm, fill=0, stroke=1)

    # Name & title — right of photo in the header
    name_x = photo_x + photo_size + 8*mm
    name = (pi.get('name') or 'YOUR NAME').upper()
    cv.setFont("Helvetica-Bold", 22)
    cv.setFillColor(dark)
    cv.drawString(name_x, H - 22*mm, name)

    if pi.get('title'):
        cv.setFont("Helvetica", 11)
        cv.setFillColor(grey)
        # Handle multi-word title with wrapping
        title_lines = wrapped_lines(cv, pi['title'], "Helvetica", 11, W - name_x - 10*mm)
        ty = H - 30*mm
        for tl in title_lines[:2]:
            cv.drawString(name_x, ty, tl)
            ty -= 6*mm

    # ── COLUMNS ──────────────────────────────────────────────────────────────
    LX = 10*mm
    LW = 62*mm
    RX = 78*mm
    RW = W - RX - 10*mm
    # Start below header + photo overlap
    content_top = H - header_h - photo_size/2 - 12*mm
    LY = H - header_h - 14*mm
    RY = H - header_h - 10*mm  # right column starts just below header

    # ── LEFT sidebar background card ─────────────────────────────────────────
    card_bottom = 15*mm
    card_top = H - header_h - 8*mm
    cv.setFillColor(acc_l)
    cv.roundRect(LX - 2*mm, card_bottom, LW + 4*mm, card_top - card_bottom, 4*mm, fill=1, stroke=0)

    # Contact info in left sidebar
    def contact_item(icon, text, y):
        if not text: return y
        cv.setFont("Helvetica", 8)
        cv.setFillColor(grey)
        cv.drawString(LX + 1*mm, y, icon)
        cv.setFillColor(dark)
        lines = wrapped_lines(cv, str(text), "Helvetica", 8, LW - 10*mm)
        for line in lines[:2]:
            cv.drawString(LX + 7*mm, y, line)
            y -= 4.5*mm
        return y - 1.5*mm

    LY = contact_item("✆", pi.get('phone',''), LY)
    LY = contact_item("@", pi.get('email',''), LY)
    LY = contact_item("⊕", pi.get('location',''), LY)
    LY -= 4*mm

    # Left section header
    def sec_l(title, y):
        cv.setFont("Helvetica-Bold", 9)
        cv.setFillColor(dark)
        cv.drawString(LX, y, title.upper())
        y -= 2*mm
        cv.setStrokeColor(dark)
        cv.setLineWidth(0.8)
        cv.line(LX, y, LX + LW, y)
        return y - 4*mm

    # Right section header
    def sec_r(title, y):
        cv.setFont("Helvetica-Bold", 11)
        cv.setFillColor(dark)
        cv.drawString(RX, y, title.upper())
        y -= 2.5*mm
        cv.setStrokeColor(dark)
        cv.setLineWidth(0.8)
        cv.line(RX, y, RX + RW, y)
        return y - 5*mm

    # ── LEFT: Education ───────────────────────────────────────────────────────
    edu_valid = [e for e in edu if e.get('school')]
    if edu_valid:
        LY = sec_l("Education", LY)
        for e in edu_valid:
            if LY < 25*mm: break
            cv.setFont("Helvetica", 8.5)
            cv.setFillColor(dark)
            LY = draw_wrapped(cv, e.get('qualification',''), LX, LY, "Helvetica", 8.5, dark, LW, 4.5*mm)
            cv.setFont("Helvetica-Bold", 8.5)
            cv.setFillColor(dark)
            cv.drawString(LX, LY, str(e.get('school',''))[:28])
            LY -= 4.5*mm
            if e.get('year'):
                cv.setFont("Helvetica", 7.5)
                cv.setFillColor(lgrey)
                cv.drawString(LX, LY, e['year'])
                LY -= 5*mm
            LY -= 2*mm

    # ── LEFT: Skills ──────────────────────────────────────────────────────────
    if skills:
        LY -= 2*mm
        LY = sec_l("Skills", LY)
        for s in skills:
            if LY < 25*mm: break
            cv.setFillColor(grey)
            cv.circle(LX + 2*mm, LY + 1.5*mm, 1*mm, fill=1, stroke=0)
            cv.setFont("Helvetica", 8.5)
            cv.setFillColor(dark)
            cv.drawString(LX + 5*mm, LY, str(s)[:26])
            LY -= 5*mm

    # ── LEFT: Languages ───────────────────────────────────────────────────────
    if langs:
        LY -= 2*mm
        LY = sec_l("Language", LY)
        for l in langs:
            if LY < 20*mm: break
            cv.setFont("Helvetica", 8.5)
            cv.setFillColor(dark)
            cv.drawString(LX, LY, l)
            LY -= 5.5*mm

    # ── RIGHT: About Me ───────────────────────────────────────────────────────
    if pi.get('summary'):
        RY = sec_r("About Me", RY)
        cv.setFont("Helvetica", 9)
        cv.setFillColor(dark)
        # Justified-style wrapping
        lines = wrapped_lines(cv, pi['summary'], "Helvetica", 9, RW)
        for line in lines:
            cv.drawString(RX, RY, line)
            RY -= 5*mm
        RY -= 4*mm

    # ── RIGHT: Work Experience ────────────────────────────────────────────────
    exp_valid = [e for e in exp if e.get('title')]
    if exp_valid:
        RY = sec_r("Work Experience", RY)
        for e in exp_valid:
            if RY < 25*mm: break
            # Company / dates line
            org = e.get('organisation','')
            dates = " – ".join(filter(None,[e.get('start_date',''),e.get('end_date','')]))
            if e.get('is_volunteer'): dates += " (Volunteer)"
            if org or dates:
                label = " | ".join(filter(None,[dates, org]))
                cv.setFont("Helvetica", 8)
                cv.setFillColor(acc)
                cv.drawString(RX, RY, label[:60])
                RY -= 5*mm
            # Job title
            cv.setFont("Helvetica-Bold", 10.5)
            cv.setFillColor(dark)
            RY = draw_wrapped(cv, e.get('title',''), RX, RY, "Helvetica-Bold", 10.5, dark, RW, 5.5*mm)
            RY -= 1*mm
            # Bullets
            for bullet in (e.get('description') or '').split('\n'):
                bullet = bullet.strip().lstrip('-•').strip()
                if not bullet or RY < 25*mm: continue
                cv.setFillColor(dark)
                cv.circle(RX + 2*mm, RY + 1.5*mm, 1*mm, fill=1, stroke=0)
                RY = draw_wrapped(cv, bullet, RX + 5.5*mm, RY, "Helvetica", 8.5, grey, RW - 5.5*mm, 4.5*mm)
            RY -= 5*mm

    # ── RIGHT: References ─────────────────────────────────────────────────────
    good_refs = [r for r in refs if r.get('name')]
    if good_refs:
        RY -= 2*mm
        RY = sec_r("References", RY)
        cw = RW / 2
        for i, r in enumerate(good_refs[:4]):
            rx = RX + (i % 2) * cw
            if i % 2 == 0 and i > 0:
                RY -= 14*mm
            cv.setFont("Helvetica-Bold", 9)
            cv.setFillColor(dark)
            cv.drawString(rx, RY, str(r.get('name',''))[:22])
            cv.setFont("Helvetica", 8)
            cv.setFillColor(grey)
            if r.get('relation'):
                cv.drawString(rx, RY - 4*mm, str(r['relation'])[:24])
            if r.get('contact'):
                cv.drawString(rx, RY - 8*mm, f"☏  {r['contact']}")
    elif RY > 40*mm:
        RY -= 2*mm
        RY = sec_r("References", RY)
        cv.setFont("Helvetica", 9)
        cv.setFillColor(grey)
        cv.drawString(RX, RY, "References available on request")

    cv.save()
    return buf.getvalue()
