#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📬 Building Contact page..."

cat > src/components/pages/Contact.tsx << 'EOF'
import { useState } from 'react'
import { Mail, MapPin, MessageCircle, Send, Check, Loader2, ExternalLink } from 'lucide-react'
import clsx from 'clsx'

const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

export default function Contact() {
  const [form, setForm]     = useState({ name:'', email:'', subject:'', message:'' })
  const [sending, setSending] = useState(false)
  const [sent, setSent]       = useState(false)
  const [error, setError]     = useState('')

  const handleSubmit = async () => {
    if (!form.name || !form.email || !form.message) {
      setError('Please fill in all required fields.'); return
    }
    setSending(true); setError('')
    try {
      const res = await fetch(`${import.meta.env.VITE_API_BASE || ''}/api/notifications/contact`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      if (res.ok) { setSent(true) }
      else { setError('Something went wrong. Try emailing us directly.') }
    } catch {
      setError('Something went wrong. Try emailing us directly.')
    } finally { setSending(false) }
  }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-12">
        <div className="max-w-4xl mx-auto text-center">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-2">Get in touch</p>
          <h1 className="font-display text-3xl md:text-5xl font-bold text-white tracking-tight mb-3">
            We'd love to <em className="not-italic text-[#F5A623]">hear from you.</em>
          </h1>
          <p className="text-white/45 text-sm max-w-md mx-auto">
            Got a question, suggestion, or want to partner with FirstStep? Reach out — we read every message.
          </p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 md:px-6 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="space-y-4">
            {[
              { icon:Mail, title:'Email us', value:'momozamihlali@gmail.com', href:'mailto:momozamihlali@gmail.com', desc:'We reply within 24 hours' },
              { icon:MessageCircle, title:'WhatsApp', value:'+27 63 087 7365', href:'https://wa.me/27630877365', desc:'Chat with us directly' },
              { icon:MapPin, title:'Based in', value:'Cape Town, South Africa', href:null, desc:'Built for SA youth 🇿🇦' },
            ].map(c => (
              <div key={c.title} className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
                <div className="w-10 h-10 rounded-xl bg-[#F5A623]/15 flex items-center justify-center mb-3">
                  <c.icon size={18} className="text-[#F5A623]"/>
                </div>
                <div className="font-bold text-sm text-[#1A1A0F] mb-0.5">{c.title}</div>
                {c.href
                  ? <a href={c.href} target="_blank" rel="noopener noreferrer" className="text-sm text-[#C47D0A] hover:text-[#F5A623] font-medium flex items-center gap-1.5">{c.value}<ExternalLink size={11}/></a>
                  : <div className="text-sm text-black/60 font-medium">{c.value}</div>
                }
                <div className="text-xs text-black/35 mt-1">{c.desc}</div>
              </div>
            ))}
            <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
              <h3 className="font-bold text-sm text-[#1A1A0F] mb-4">Common questions</h3>
              <div className="space-y-3">
                {[
                  { q:'Is FirstStep really free?', a:'Yes — 100% free, always. No hidden fees.' },
                  { q:'Can companies post learnerships?', a:'Email us to get listed on FirstStep.' },
                  { q:'I found a bug', a:'Let us know via the form — we fix things fast.' },
                ].map(f => (
                  <div key={f.q} className="border-b border-black/6 pb-3 last:border-0 last:pb-0">
                    <div className="font-semibold text-xs text-[#1A1A0F] mb-1">{f.q}</div>
                    <div className="text-xs text-black/45 leading-relaxed">{f.a}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="md:col-span-2">
            {sent ? (
              <div className="bg-white rounded-2xl border border-black/8 p-10 shadow-sm text-center h-full flex flex-col items-center justify-center">
                <div className="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mb-4">
                  <Check size={28} className="text-green-600"/>
                </div>
                <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">Message sent! 🎉</h3>
                <p className="text-black/45 text-sm mb-6 max-w-xs">We'll get back to you within 24 hours.</p>
                <button onClick={()=>{setSent(false); setForm({name:'',email:'',subject:'',message:''})}}
                  className="btn-amber text-sm">Send another message</button>
              </div>
            ) : (
              <div className="bg-white rounded-2xl border border-black/8 p-6 md:p-7 shadow-sm">
                <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-5">Send us a message</h2>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div><label className={lbl}>Your name *</label><input className={inp} placeholder="Thabo Nkosi" value={form.name} onChange={e=>setForm({...form,name:e.target.value})}/></div>
                    <div><label className={lbl}>Email address *</label><input className={inp} type="email" placeholder="thabo@gmail.com" value={form.email} onChange={e=>setForm({...form,email:e.target.value})}/></div>
                  </div>
                  <div>
                    <label className={lbl}>Subject</label>
                    <select className={inp+' appearance-none'} value={form.subject} onChange={e=>setForm({...form,subject:e.target.value})}>
                      <option value="">Select a topic…</option>
                      <option>General enquiry</option>
                      <option>Report a bug</option>
                      <option>Partnership / listing</option>
                      <option>CV or job advice</option>
                      <option>Feature suggestion</option>
                      <option>Other</option>
                    </select>
                  </div>
                  <div><label className={lbl}>Message *</label><textarea className={inp+' resize-none'} rows={5} placeholder="Tell us how we can help…" value={form.message} onChange={e=>setForm({...form,message:e.target.value})}/></div>
                  {error && <p className="text-sm text-red-500 font-medium">{error}</p>}
                  <button onClick={handleSubmit} disabled={sending} className="btn-amber w-full flex items-center justify-center gap-2 !py-3 text-sm font-bold">
                    {sending ? <Loader2 size={15} className="animate-spin"/> : <Send size={15}/>}
                    {sending ? 'Sending…' : 'Send message'}
                  </button>
                  <p className="text-xs text-black/30 text-center">Or email us at <a href="mailto:momozamihlali@gmail.com" className="text-[#C47D0A]">momozamihlali@gmail.com</a></p>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="mt-8 bg-[#1A1A0F] rounded-2xl p-6 md:p-8 flex flex-col sm:flex-row items-center justify-between gap-5">
          <div>
            <h3 className="font-display text-lg font-bold text-white mb-1">Want to partner with us?</h3>
            <p className="text-white/40 text-sm">Companies and SETAs — list your learnerships on FirstStep and reach thousands of SA youth.</p>
          </div>
          <a href="mailto:momozamihlali@gmail.com?subject=Partnership enquiry" className="btn-amber whitespace-nowrap flex items-center gap-2">
            <Mail size={14}/> Get in touch
          </a>
        </div>
      </div>
    </div>
  )
}
EOF

# Update App.tsx
sed -i "s|import Dashboard from './components/pages/Dashboard'|import Dashboard from './components/pages/Dashboard'\nimport Contact from './components/pages/Contact'|" src/App.tsx
sed -i "s|<Route path=\"/contact\".*/>|<Route path=\"/contact\" element={<Contact />} />|" src/App.tsx

echo "✅ Contact page done!"
