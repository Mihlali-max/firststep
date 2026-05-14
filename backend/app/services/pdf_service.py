from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas
from io import BytesIO

W, H = A4

def hex_to_color(hex_str, alpha=1.0):
    try:
        h = hex_str.lstrip('#')
        r,g,b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
        return colors.Color(r,g,b,alpha=alpha)
    except:
        return colors.Color(0.08,0.39,0.75,alpha=alpha)

def wrapped_lines(c, text, font, size, max_w):
    c.setFont(font, size)
    words = str(text).split()
    lines, cur = [], ""
    for w in words:
        test = (cur+" "+w).strip()
        if c.stringWidth(test, font, size) <= max_w: cur = test
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines

def draw_wrapped(c, text, x, y, font, size, color, max_w, lh):
    c.setFont(font, size); c.setFillColor(color)
    for line in wrapped_lines(c, text, font, size, max_w):
        c.drawString(x, y, line); y -= lh
    return y

def generate_cv_pdf(cv_data: dict) -> bytes:
    buf = BytesIO()
    pi    = cv_data.get('personal_info') or {}
    edu   = cv_data.get('education') or []
    skills= cv_data.get('skills') or []
    exp   = cv_data.get('experience') or []
    refs  = cv_data.get('references') or []
    langs = [l.strip() for l in (pi.get('languages') or 'English').split(',') if l.strip()]

    acc   = hex_to_color(pi.get('color','#1565C0'))
    acc_l = hex_to_color(pi.get('color','#1565C0'), 0.13)
    dark  = colors.Color(0.08,0.08,0.04)
    grey  = colors.Color(0.45,0.45,0.45)
    lgrey = colors.Color(0.72,0.72,0.72)

    cv = canvas.Canvas(buf, pagesize=A4)
    cv.setTitle(f"{pi.get('name','CV')} - CV")

    # ── HEADER: full-width accent band
    hh = 26*mm
    cv.setFillColor(acc_l)
    cv.rect(0, H-hh, W, hh, fill=1, stroke=0)

    # Name left-aligned in header
    cv.setFillColor(dark)
    cv.setFont("Helvetica-Bold", 20)
    cv.drawString(24*mm, H-16*mm, (pi.get('name') or 'YOUR NAME').upper())

    # Title below name
    if pi.get('title'):
        cv.setFont("Helvetica", 10)
        cv.setFillColor(grey)
        cv.drawString(24*mm, H-23*mm, pi['title'])

    # Contact row right-aligned in header
    cv.setFont("Helvetica", 7.5)
    cv.setFillColor(grey)
    contact = []
    if pi.get('email'):    contact.append(f"✉ {pi['email']}")
    if pi.get('phone'):    contact.append(f"☏ {pi['phone']}")
    if pi.get('location'): contact.append(f"⊕ {pi['location']}")
    cstr = "   ·   ".join(contact)
    cv.drawRightString(W-10*mm, H-16*mm, cstr)

    # Accent bottom line
    cv.setStrokeColor(acc)
    cv.setLineWidth(2)
    cv.line(0, H-hh, W, H-hh)

    # ── COLUMNS
    LX = 10*mm; LW = 58*mm
    RX = 74*mm; RW = W-RX-10*mm
    LY = H-hh-7*mm
    RY = H-hh-7*mm

    def sec_l(title, y):
        cv.setFont("Helvetica-Bold",7.5); cv.setFillColor(dark)
        cv.drawString(LX, y, title.upper())
        y -= 2.5*mm
        cv.setStrokeColor(lgrey); cv.setLineWidth(0.5)
        cv.line(LX, y, LX+LW, y)
        return y-4*mm

    def sec_r(title, y):
        cv.setFont("Helvetica-Bold",12); cv.setFillColor(dark)
        cv.drawString(RX, y, title)
        y -= 2.5*mm
        cv.setStrokeColor(dark); cv.setLineWidth(1.5)
        cv.line(RX, y, RX+RW, y)
        return y-5*mm

    # ── LEFT: contact card
    cv.setFillColor(acc_l)
    cv.roundRect(LX-1.5*mm, LY-30*mm, LW+3*mm, 30*mm, 2.5*mm, fill=1, stroke=0)
    cy = LY-5*mm
    for icon, val in [
        ("☏", pi.get('phone','')),
        ("✉", pi.get('email','')),
        ("⊕", pi.get('location','')),
    ]:
        if not val: continue
        cv.setFont("Helvetica",7.5); cv.setFillColor(grey)
        cv.drawString(LX+2*mm, cy, icon)
        cv.setFillColor(dark)
        cv.drawString(LX+7*mm, cy, str(val)[:30])
        cy -= 5*mm
    LY -= 33*mm

    # ── LEFT: education
    if any(e.get('school') for e in edu):
        LY = sec_l("Education", LY)
        for e in edu:
            if not e.get('school'): continue
            if e.get('year'):
                cv.setFont("Helvetica",7); cv.setFillColor(lgrey)
                cv.drawString(LX, LY, e['year']); LY -= 3.5*mm
            cv.setFont("Helvetica-Bold",8.5); cv.setFillColor(dark)
            LY = draw_wrapped(cv, e.get('qualification',''), LX, LY, "Helvetica-Bold",8.5, dark, LW, 4*mm)
            cv.setFont("Helvetica",8); cv.setFillColor(grey)
            cv.drawString(LX, LY, str(e.get('school',''))[:28]); LY -= 6.5*mm

    # ── LEFT: skills
    if skills:
        LY -= 2*mm; LY = sec_l("Skills", LY)
        for s in skills:
            if LY < 22*mm: break
            cv.setFillColor(grey); cv.circle(LX+2*mm, LY+1.5*mm, 1.1*mm, fill=1, stroke=0)
            cv.setFont("Helvetica",8.5); cv.setFillColor(dark)
            cv.drawString(LX+5.5*mm, LY, str(s)[:26]); LY -= 5*mm

    # ── LEFT: languages
    if langs:
        LY -= 2*mm; LY = sec_l("Language", LY)
        for l in langs:
            if LY < 18*mm: break
            cv.setFont("Helvetica",9); cv.setFillColor(dark)
            cv.drawString(LX, LY, l); LY -= 5*mm

    # ── RIGHT: about me
    if pi.get('summary'):
        RY = sec_r("About Me", RY)
        RY = draw_wrapped(cv, pi['summary'], RX, RY, "Helvetica",8.5, grey, RW, 4.5*mm)
        RY -= 5*mm

    # ── RIGHT: experience
    if any(e.get('title') for e in exp):
        RY = sec_r("Work Experience", RY)
        for e in exp:
            if not e.get('title') or RY < 28*mm: break
            dates = " – ".join(filter(None,[e.get('start_date',''),e.get('end_date','')]))
            if e.get('is_volunteer'): dates += " (Volunteer)"
            if dates:
                cv.setFont("Helvetica-Bold",8.5); cv.setFillColor(acc)
                cv.drawString(RX, RY, dates); RY -= 4.5*mm
            tl = e.get('title','')
            if e.get('organisation'): tl += f" — {e['organisation']}"
            cv.setFont("Helvetica-Bold",10); cv.setFillColor(dark)
            RY = draw_wrapped(cv, tl, RX, RY, "Helvetica-Bold",10, dark, RW, 5*mm)
            RY -= 1*mm
            for bullet in (e.get('description') or '').split('\n'):
                bullet = bullet.strip().lstrip('-•').strip()
                if not bullet or RY < 28*mm: continue
                cv.setFillColor(grey); cv.circle(RX+2*mm, RY+1.5*mm, 1*mm, fill=1, stroke=0)
                RY = draw_wrapped(cv, bullet, RX+5.5*mm, RY, "Helvetica",8.5, grey, RW-5.5*mm, 4.5*mm)
            RY -= 5*mm

    # ── RIGHT: references (2 col grid)
    good_refs = [r for r in refs if r.get('name')]
    if good_refs:
        RY -= 2*mm; RY = sec_r("References", RY)
        cw = RW/2
        for i, r in enumerate(good_refs):
            rx = RX + (i%2)*cw
            if i%2==0 and i>0: RY -= 14*mm
            cv.setFont("Helvetica-Bold",9.5); cv.setFillColor(dark)
            cv.drawString(rx, RY, str(r['name'])[:20])
            cv.setFont("Helvetica",8); cv.setFillColor(grey)
            if r.get('relation'): cv.drawString(rx, RY-4*mm, str(r['relation'])[:22])
            if r.get('contact'):  cv.drawString(rx, RY-8*mm, f"Phone: {r['contact']}")

    cv.save()
    return buf.getvalue()
