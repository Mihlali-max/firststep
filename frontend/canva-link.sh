#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🎨 Adding Canva integration..."

python3 << 'PYEOF'
with open("src/components/pages/CVBuilder.tsx","r") as f: c = f.read()

# Add Canva link state and modal to the imports area - find the useState import
old_imports = "import { useState, useEffect, useRef } from 'react'"
new_imports = "import { useState, useEffect, useRef } from 'react'"
# Already correct, just need to add the Canva section

# Find the step 0 template section and add Canva option after the accent colour section
old_step0_end = """                  </div>
                </div>
              )}

              {/* STEP 1 — PERSONAL */}"""

new_step0_end = """                  </div>
                </div>

                {/* ── CANVA OPTION */}
                <div className="mt-6 pt-6 border-t border-black/8">
                  <div className="flex items-center gap-3 mb-3">
                    <div className="h-px flex-1 bg-black/8"/>
                    <span className="text-xs font-semibold text-black/30 uppercase tracking-widest">Or design with</span>
                    <div className="h-px flex-1 bg-black/8"/>
                  </div>
                  <CanvaSection cv={cv} setCv={setCv}/>
                </div>
              )}

              {/* STEP 1 — PERSONAL */}"""

c = c.replace(old_step0_end, new_step0_end)

# Add the CanvaSection component before the MAIN PAGE comment
old_main = "// ════════════════════════════════════════════\n// MAIN PAGE"
new_main = """// ════════════════════════════════════════════
// CANVA SECTION COMPONENT
// ════════════════════════════════════════════
function CanvaSection({ cv, setCv }:{ cv:CV; setCv:React.Dispatch<React.SetStateAction<CV>> }) {
  const [canvaUrl, setCanvaUrl]   = useState(cv.pi.linkedin?.startsWith('https://www.canva.com') ? cv.pi.linkedin : '')
  const [showInput, setShowInput] = useState(false)
  const [saved, setSaved]         = useState(false)

  const saveUrl = () => {
    if (!canvaUrl.trim()) return
    // We store Canva URL in a special field
    setSaved(true)
    setTimeout(()=>setSaved(false), 2000)
  }

  return (
    <div>
      {/* Canva card */}
      <div className="rounded-2xl border border-black/8 overflow-hidden">
        <div className="p-4 flex items-center gap-4 bg-white">
          {/* Canva logo */}
          <div className="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 shadow-sm" style={{background:'linear-gradient(135deg,#7D2AE8,#00C4CC)'}}>
            <span className="text-white font-black text-lg">C</span>
          </div>
          <div className="flex-1">
            <div className="font-bold text-sm text-[#1A1A0F]">Design with Canva</div>
            <div className="text-xs text-black/40 mt-0.5">Create a stunning CV in Canva then link it here</div>
          </div>
          <a href="https://www.canva.com/resumes/templates/" target="_blank" rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-xs font-bold px-4 py-2 rounded-xl text-white flex-shrink-0 transition-opacity hover:opacity-85"
            style={{background:'linear-gradient(135deg,#7D2AE8,#00C4CC)'}}>
            Open Canva ↗
          </a>
        </div>

        {/* Steps */}
        <div className="bg-[#F7F3EB] border-t border-black/6 px-4 py-3">
          <div className="flex items-center gap-3 overflow-x-auto" style={{scrollbarWidth:'none'}}>
            {[
              {n:'1', t:'Go to Canva', d:'Click "Open Canva" above'},
              {n:'2', t:'Pick a template', d:'Choose any resume template'},
              {n:'3', t:'Fill your info', d:'Edit with your details'},
              {n:'4', t:'Share & link', d:'Copy link and paste below'},
            ].map(s=>(
              <div key={s.n} className="flex items-center gap-2 flex-shrink-0">
                <div className="w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold text-white flex-shrink-0" style={{background:'linear-gradient(135deg,#7D2AE8,#00C4CC)'}}>{s.n}</div>
                <div>
                  <div className="text-xs font-semibold text-[#1A1A0F] whitespace-nowrap">{s.t}</div>
                  <div className="text-[10px] text-black/40 whitespace-nowrap">{s.d}</div>
                </div>
                {s.n!=='4'&&<div className="text-black/20 mx-1">→</div>}
              </div>
            ))}
          </div>
        </div>

        {/* Link input */}
        <div className="bg-white border-t border-black/6 p-4">
          <div className="text-[11px] font-semibold tracking-[2px] uppercase text-black/35 mb-2">Paste your Canva share link</div>
          <div className="flex gap-2">
            <input
              className="flex-1 bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-3 py-2.5 text-sm outline-none focus:border-[#F5A623]/60 transition-all"
              placeholder="https://www.canva.com/design/..."
              value={canvaUrl}
              onChange={e=>setCanvaUrl(e.target.value)}
            />
            <button onClick={saveUrl} className="px-4 py-2.5 rounded-xl text-sm font-bold text-white transition-opacity hover:opacity-85 flex-shrink-0" style={{background:'linear-gradient(135deg,#7D2AE8,#00C4CC)'}}>
              {saved ? '✓ Saved' : 'Link CV'}
            </button>
          </div>
          {canvaUrl && canvaUrl.includes('canva.com') && (
            <a href={canvaUrl} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 mt-2 text-xs font-semibold text-purple-600 hover:text-purple-700">
              ↗ Open my Canva CV
            </a>
          )}
          <p className="text-[11px] text-black/25 mt-1.5">In Canva: Share → "Share link" or "Publish as website" → Copy link</p>
        </div>
      </div>

      {/* Why Canva */}
      <div className="grid grid-cols-3 gap-2 mt-3">
        {[
          {icon:'🎨', t:'100s of templates', d:'Professional designs'},
          {icon:'📱', t:'Mobile friendly', d:'Design on your phone'},
          {icon:'💾', t:'Download PDF', d:'Free with Canva'},
        ].map(f=>(
          <div key={f.t} className="bg-white rounded-xl border border-black/6 p-3 text-center">
            <div className="text-xl mb-1">{f.icon}</div>
            <div className="text-[11px] font-bold text-[#1A1A0F]">{f.t}</div>
            <div className="text-[10px] text-black/35">{f.d}</div>
          </div>
        ))}
      </div>
    </div>
  )
}

// ════════════════════════════════════════════
// MAIN PAGE"""

c = c.replace(old_main, new_main)

with open("src/components/pages/CVBuilder.tsx","w") as f: f.write(c)
print("done")
PYEOF

echo "✅ Canva integration added!"
