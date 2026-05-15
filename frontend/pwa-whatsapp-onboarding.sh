#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📱 Adding PWA + WhatsApp share + Onboarding..."

# ══════════════════════════════
# 1. PWA
# ══════════════════════════════
npm install vite-plugin-pwa --save-dev 2>/dev/null

# Update vite.config.ts
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico'],
      manifest: {
        name: 'FirstStep — SA Youth Jobs',
        short_name: 'FirstStep',
        description: 'Build your CV, find learnerships, get coached by AI. Free for SA youth.',
        theme_color: '#1A1A0F',
        background_color: '#1A1A0F',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/firststep-backend-mf6j\.onrender\.com\/api\/.*/i,
            handler: 'NetworkFirst',
            options: { cacheName: 'api-cache', expiration: { maxEntries: 50, maxAgeSeconds: 300 } },
          },
        ],
      },
    }),
  ],
  server: {
    proxy: {
      '/api': { target: 'http://localhost:8000', changeOrigin: true }
    }
  }
})
EOF

# Create simple icon SVGs that will render as PNG
cat > public/icon-192.png << 'ICONEOF'
ICONEOF
# We'll use a simple approach — create icons via canvas in a script
cat > /tmp/make_icons.py << 'PYEOF'
try:
    from PIL import Image, ImageDraw, ImageFont
    import os
    for size in [192, 512]:
        img = Image.new('RGB', (size, size), color=(26, 26, 15))
        draw = ImageDraw.Draw(img)
        # Draw "FS" text
        font_size = size // 3
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
        except:
            font = ImageFont.load_default()
        text = "FS"
        bbox = draw.textbbox((0,0), text, font=font)
        tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
        x = (size - tw) // 2
        y = (size - th) // 2
        draw.text((x, y), text, fill=(245, 166, 35), font=font)
        img.save(f"public/icon-{size}.png")
        print(f"Created icon-{size}.png")
except ImportError:
    # Fallback: copy favicon
    import shutil
    for size in [192, 512]:
        if os.path.exists("public/favicon.ico"):
            shutil.copy("public/favicon.ico", f"public/icon-{size}.png")
        else:
            open(f"public/icon-{size}.png","wb").write(b"")
    print("Used fallback icons")
PYEOF
python3 /tmp/make_icons.py

# ══════════════════════════════
# 2. WhatsApp share on learnerships
# ══════════════════════════════
python3 << 'PYEOF'
with open("src/components/pages/Learnerships.tsx","r") as f: c = f.read()

# Find the Apply now button and add WhatsApp share next to it
old = '"Apply now"'
# Add WhatsApp share button after apply button in job cards
# Find the apply button area
if 'wa.me' not in c:
    c = c.replace(
        'className="btn-amber',
        'className="btn-amber',
        1
    )
    # Add share function
    c = c.replace(
        "export default function Learnerships",
        """const shareOnWhatsApp = (title: string, company: string, url: string) => {
  const text = encodeURIComponent(`🎯 Check out this learnership on FirstStep!\n\n*${title}*\n${company}\n\nApply here: ${url}\n\nFind more free SA learnerships at https://firststep-frontend-sqyb.onrender.com/learnerships`)
  window.open(\`https://wa.me/?text=\${text}\`, '_blank')
}

export default function Learnerships"""
    )
    # Add share button near apply button - find the apply button in job cards
    c = c.replace(
        '<a href={job.redirect_url || \'#\'} target="_blank" rel="noopener noreferrer" className="btn-amber text-sm flex items-center gap-1.5 flex-shrink-0">Apply now</a>',
        '''<div className="flex gap-2">
                <a href={job.redirect_url || \'#\'} target="_blank" rel="noopener noreferrer" className="btn-amber text-sm flex items-center gap-1.5">Apply now</a>
                <button onClick={()=>shareOnWhatsApp(job.title, job.company?.display_name||\'company\', job.redirect_url||\'#\')}
                  className="flex items-center gap-1.5 text-sm font-semibold px-3 py-2 rounded-xl border border-black/10 bg-white hover:bg-green-50 hover:border-green-300 hover:text-green-700 transition-all"
                  title="Share on WhatsApp">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="text-green-600"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                </button>
              </div>'''
    )
    with open("src/components/pages/Learnerships.tsx","w") as f: f.write(c)
    print("WhatsApp share added")
else:
    print("WhatsApp share already exists")
PYEOF

# ══════════════════════════════
# 3. Onboarding flow
# ══════════════════════════════
cat > src/components/Onboarding.tsx << 'EOF'
import { useState, useEffect } from 'react'
import { X, ArrowRight, FileText, Briefcase, Bot, Check } from 'lucide-react'
import { useAuthStore } from '../store/authStore'
import { useNavigate } from 'react-router-dom'

const STEPS = [
  {
    icon: '👋',
    title: "Welcome to FirstStep!",
    desc: "You're one step closer to your first job. Let's get you set up in 3 quick steps.",
    cta: "Let's go",
    action: null,
  },
  {
    icon: '📄',
    title: "Build your CV",
    desc: "A professional CV is your ticket to any job. Our CV Builder takes less than 5 minutes — 5 templates, PDF download, completely free.",
    cta: "Build my CV",
    action: '/cv',
    skip: true,
  },
  {
    icon: '💼',
    title: "Find learnerships",
    desc: "Browse 600+ real SA learnerships and YES programmes updated daily. Filter by province and sector, apply directly.",
    cta: "Browse jobs",
    action: '/learnerships',
    skip: true,
  },
  {
    icon: '🤖',
    title: "Meet your AI Coach",
    desc: "Ask anything about job hunting, CVs, interviews, or the YES programme. Available 24/7, completely free.",
    cta: "Chat with Coach",
    action: '/coach',
    skip: true,
  },
]

export default function Onboarding() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [step, setStep] = useState(0)
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    if (!user) return
    const key = `onboarded-${user.id}`
    if (!localStorage.getItem(key)) {
      setTimeout(() => setVisible(true), 800)
    }
  }, [user])

  const dismiss = () => {
    if (user) localStorage.setItem(`onboarded-${user.id}`, '1')
    setVisible(false)
  }

  const next = (action: string | null) => {
    if (step === STEPS.length - 1) {
      dismiss()
      if (action) navigate(action)
      return
    }
    if (action && step > 0) {
      dismiss()
      navigate(action)
      return
    }
    setStep(s => s + 1)
  }

  if (!visible || !user) return null

  const s = STEPS[step]

  return (
    <div className="fixed inset-0 z-[100] flex items-end sm:items-center justify-center p-4" onClick={dismiss}>
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
      <div className="relative bg-white rounded-3xl shadow-2xl w-full max-w-sm overflow-hidden" onClick={e=>e.stopPropagation()}>
        {/* Progress dots */}
        <div className="flex gap-1.5 justify-center pt-5 pb-1">
          {STEPS.map((_,i) => (
            <div key={i} className={`h-1.5 rounded-full transition-all ${i===step?'w-6 bg-[#F5A623]':'w-1.5 bg-black/15'}`}/>
          ))}
        </div>

        <button onClick={dismiss} className="absolute top-4 right-4 w-8 h-8 rounded-full bg-black/8 flex items-center justify-center hover:bg-black/15 transition-colors">
          <X size={14} className="text-black/50"/>
        </button>

        <div className="px-6 py-5 text-center">
          <div className="text-5xl mb-4">{s.icon}</div>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">{s.title}</h2>
          <p className="text-sm text-black/50 leading-relaxed mb-6">{s.desc}</p>

          <button onClick={()=>next(s.action || null)}
            className="btn-amber w-full flex items-center justify-center gap-2 !py-3 text-sm font-bold mb-3">
            {s.action ? s.cta : <>{s.cta} <ArrowRight size={14}/></>}
          </button>

          {(s as any).skip && (
            <button onClick={()=>setStep(st=>Math.min(st+1, STEPS.length-1))}
              className="text-sm text-black/35 hover:text-black/55 transition-colors">
              Skip for now
            </button>
          )}
        </div>

        {/* Bottom tip */}
        {step === 0 && (
          <div className="bg-[#F7F3EB] border-t border-black/6 px-6 py-3 text-center">
            <p className="text-xs text-black/40">🇿🇦 Free forever · No ads · Built for SA youth</p>
          </div>
        )}
      </div>
    </div>
  )
}
EOF

# Add Onboarding to App.tsx
python3 << 'PYEOF'
with open("src/App.tsx","r") as f: c = f.read()
if "Onboarding" not in c:
    c = c.replace(
        "import Dashboard from './components/pages/Dashboard'",
        "import Dashboard from './components/pages/Dashboard'\nimport Onboarding from './components/Onboarding'"
    )
    c = c.replace(
        "<Router>",
        "<Router>\n      <Onboarding/>"
    )
    with open("src/App.tsx","w") as f: f.write(c)
    print("Onboarding added to App.tsx")
else:
    print("Already added")
PYEOF

echo "✅ PWA + WhatsApp share + Onboarding all done!"
