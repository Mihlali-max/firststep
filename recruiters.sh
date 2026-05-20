#!/bin/bash
echo "🏢 Building Recruiters page..."

cat > frontend/src/components/pages/Recruiters.tsx << 'EOF'
import { Link } from 'react-router-dom'
import { useState } from 'react'
import api from '../../lib/api'

const PLANS = [
  {
    name: 'Free',
    price: 'R0',
    period: 'forever',
    desc: 'Perfect for small businesses and NGOs',
    features: [
      '1 active listing at a time',
      'Listed for 30 days',
      'Basic applicant details',
      'Apply via FirstStep',
    ],
    cta: 'Post for free',
    highlighted: false,
  },
  {
    name: 'Growth',
    price: 'R499',
    period: 'per month',
    desc: 'For companies hiring regularly',
    features: [
      'Up to 5 active listings',
      'Featured placement — top of search',
      'Full applicant CV access',
      'Branded employer profile',
      'Email alerts to matched candidates',
    ],
    cta: 'Get started',
    highlighted: true,
  },
  {
    name: 'Enterprise',
    price: 'Custom',
    period: 'contact us',
    desc: 'For SETAs, large corporates and NGOs',
    features: [
      'Unlimited listings',
      'CV database access',
      'Dedicated account manager',
      'Co-branded campaigns',
      'API integration',
      'Analytics dashboard',
    ],
    cta: 'Contact us',
    highlighted: false,
  },
]

const STATS = [
  { n: '600+', l: 'Active opportunities listed' },
  { n: '100%', l: 'Verified SA youth profiles' },
  { n: 'Free', l: 'For job seekers, always' },
  { n: '9', l: 'Provinces covered' },
]

export default function Recruiters() {
  const [form, setForm] = useState({ company: '', email: '', phone: '', size: '', message: '' })
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)

  const submit = async () => {
    if (!form.company || !form.email) return
    setLoading(true)
    try {
      await fetch((import.meta.env.VITE_API_BASE || '') + '/api/notifications/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: form.company,
          email: form.email,
          subject: `Recruiter enquiry — ${form.size}`,
          message: `Company: ${form.company}\nEmail: ${form.email}\nPhone: ${form.phone}\nSize: ${form.size}\n\n${form.message}`
        })
      })
      setSent(true)
    } catch { setSent(true) }
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-[#FFFDF7]">

      {/* Hero */}
      <div style={{ background: 'linear-gradient(135deg,#1A1A0F 0%,#2A3820 100%)' }} className="py-20 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 bg-[#F5A623]/12 border border-[#F5A623]/25 px-4 py-1.5 rounded-full mb-6">
            <span className="text-[#F5A623] text-xs font-semibold tracking-widest uppercase">For Employers & Recruiters</span>
          </div>
          <h1 className="font-display text-4xl md:text-5xl font-bold text-[#FFFDF7] leading-tight mb-6">
            Reach thousands of<br/>
            <span className="text-[#F5A623]">job-ready SA youth.</span>
          </h1>
          <p className="text-[#FFFDF7]/55 text-base md:text-lg font-light max-w-2xl mx-auto mb-10 leading-relaxed">
            FirstStep connects your learnerships, internships, and entry-level roles directly to verified South African youth who have built their CVs and are actively looking for work.
          </p>
          <div className="flex gap-4 justify-center flex-wrap">
            <a href="#post" className="bg-[#F5A623] text-[#1A1A0F] font-bold px-8 py-4 rounded-2xl hover:bg-[#e09620] transition-colors">
              Post a listing free →
            </a>
            <a href="#contact" className="border border-[#FFFDF7]/25 text-[#FFFDF7]/80 font-medium px-8 py-4 rounded-2xl hover:border-[#FFFDF7]/60 transition-colors">
              Talk to us
            </a>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="border-b border-[#1A1A0F]/8">
        <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4">
          {STATS.map((s, i) => (
            <div key={s.n} className={`py-8 px-6 text-center ${i < 3 ? 'border-r border-[#1A1A0F]/8' : ''}`}>
              <div className="font-display text-3xl font-bold text-[#F5A623] mb-1">{s.n}</div>
              <div className="text-xs text-black/45">{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Why FirstStep */}
      <div className="py-16 px-6">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-widest uppercase mb-3">Why FirstStep</p>
          <h2 className="font-display text-3xl font-bold text-[#1A1A0F] mb-12">Hire better, faster, for less.</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              { icon: '🎯', title: 'Pre-qualified candidates', desc: 'Every applicant has a complete CV, verified location, and declared skills. No time wasted on unqualified applications.' },
              { icon: '📱', title: 'Mobile-first reach', desc: 'Most SA youth only have a phone. FirstStep is built mobile-first — your listing reaches people LinkedIn and PNet miss.' },
              { icon: '💸', title: 'Fraction of the cost', desc: 'PNet charges thousands per listing. Your first listing on FirstStep is free. Growth plan starts at R499/month.' },
            ].map(f => (
              <div key={f.title} className="bg-white border border-black/6 rounded-2xl p-6 shadow-sm">
                <div className="text-3xl mb-4">{f.icon}</div>
                <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-2">{f.title}</h3>
                <p className="text-sm text-black/50 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Pricing */}
      <div id="post" className="py-16 px-6 bg-[#F7F3EB]">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-widest uppercase mb-3">Pricing</p>
          <h2 className="font-display text-3xl font-bold text-[#1A1A0F] mb-12">Simple, transparent pricing.</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {PLANS.map(p => (
              <div key={p.name} className={`rounded-2xl p-6 ${p.highlighted ? 'bg-[#1A1A0F] border-2 border-[#F5A623]' : 'bg-white border border-black/8'} shadow-sm`}>
                {p.highlighted && <div className="inline-block bg-[#F5A623] text-[#1A1A0F] text-xs font-bold px-3 py-1 rounded-full mb-4">Most popular</div>}
                <h3 className={`font-display text-xl font-bold mb-1 ${p.highlighted ? 'text-[#FFFDF7]' : 'text-[#1A1A0F]'}`}>{p.name}</h3>
                <div className={`text-3xl font-bold mb-1 ${p.highlighted ? 'text-[#F5A623]' : 'text-[#1A1A0F]'}`}>{p.price}</div>
                <div className={`text-xs mb-2 ${p.highlighted ? 'text-[#FFFDF7]/40' : 'text-black/40'}`}>{p.period}</div>
                <p className={`text-sm mb-6 ${p.highlighted ? 'text-[#FFFDF7]/55' : 'text-black/50'}`}>{p.desc}</p>
                <ul className="space-y-2.5 mb-8">
                  {p.features.map(f => (
                    <li key={f} className="flex items-start gap-2">
                      <span className="text-[#F5A623] mt-0.5 flex-shrink-0">✓</span>
                      <span className={`text-sm ${p.highlighted ? 'text-[#FFFDF7]/70' : 'text-black/60'}`}>{f}</span>
                    </li>
                  ))}
                </ul>
                <a href="#contact"
                  className={`block text-center py-3 rounded-xl font-semibold text-sm transition-colors ${p.highlighted ? 'bg-[#F5A623] text-[#1A1A0F] hover:bg-[#e09620]' : 'border border-black/15 text-[#1A1A0F] hover:bg-black/5'}`}>
                  {p.cta}
                </a>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Who we work with */}
      <div className="py-16 px-6">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-widest uppercase mb-3">Who posts on FirstStep</p>
          <h2 className="font-display text-3xl font-bold text-[#1A1A0F] mb-10">Built for every type of employer.</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[
              { title: 'SETAs', desc: 'Post NQF-accredited learnerships and reach youth across all 9 provinces.' },
              { title: 'Corporates', desc: 'Run YES Programme, graduate programmes, and entry-level campaigns at scale.' },
              { title: 'SMEs & Retailers', desc: 'Find motivated local youth for part-time, seasonal, and permanent roles.' },
              { title: 'NGOs & Government', desc: 'Reach unemployed youth for EPWP, social development, and community roles.' },
            ].map(w => (
              <div key={w.title} className="flex gap-4 p-5 bg-white border border-black/6 rounded-2xl">
                <div className="w-10 h-10 rounded-xl bg-[#F5A623]/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-[#F5A623] font-bold text-sm">✓</span>
                </div>
                <div>
                  <h3 className="font-semibold text-[#1A1A0F] mb-1">{w.title}</h3>
                  <p className="text-sm text-black/50">{w.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Contact form */}
      <div id="contact" className="py-16 px-6 bg-[#1A1A0F]">
        <div className="max-w-2xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-widest uppercase mb-3">Get started</p>
          <h2 className="font-display text-3xl font-bold text-[#FFFDF7] mb-3">Post your first listing.</h2>
          <p className="text-[#FFFDF7]/45 text-sm mb-10">Fill in your details and we'll set up your employer account within 24 hours.</p>

          {sent ? (
            <div className="bg-[#2A5C3F]/30 border border-[#F5A623]/20 rounded-2xl p-8 text-center">
              <div className="text-4xl mb-4">🎉</div>
              <h3 className="font-display text-xl font-bold text-[#FFFDF7] mb-2">We'll be in touch!</h3>
              <p className="text-[#FFFDF7]/50 text-sm">Expect a response within 24 hours at {form.email}</p>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-[#FFFDF7]/40 uppercase tracking-widest block mb-2">Company name *</label>
                  <input value={form.company} onChange={e=>setForm(f=>({...f,company:e.target.value}))}
                    placeholder="e.g. Shoprite Holdings"
                    className="w-full bg-white/6 border border-white/10 rounded-xl px-4 py-3 text-[#FFFDF7] text-sm placeholder:text-white/25 outline-none focus:border-[#F5A623]/50"/>
                </div>
                <div>
                  <label className="text-xs font-medium text-[#FFFDF7]/40 uppercase tracking-widest block mb-2">Work email *</label>
                  <input value={form.email} onChange={e=>setForm(f=>({...f,email:e.target.value}))}
                    placeholder="hr@company.co.za" type="email"
                    className="w-full bg-white/6 border border-white/10 rounded-xl px-4 py-3 text-[#FFFDF7] text-sm placeholder:text-white/25 outline-none focus:border-[#F5A623]/50"/>
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-[#FFFDF7]/40 uppercase tracking-widest block mb-2">Phone number</label>
                  <input value={form.phone} onChange={e=>setForm(f=>({...f,phone:e.target.value}))}
                    placeholder="+27 82 000 0000"
                    className="w-full bg-white/6 border border-white/10 rounded-xl px-4 py-3 text-[#FFFDF7] text-sm placeholder:text-white/25 outline-none focus:border-[#F5A623]/50"/>
                </div>
                <div>
                  <label className="text-xs font-medium text-[#FFFDF7]/40 uppercase tracking-widest block mb-2">Company size</label>
                  <select value={form.size} onChange={e=>setForm(f=>({...f,size:e.target.value}))}
                    className="w-full bg-white/6 border border-white/10 rounded-xl px-4 py-3 text-[#FFFDF7] text-sm outline-none focus:border-[#F5A623]/50">
                    <option value="" className="bg-[#1A1A0F]">Select...</option>
                    <option value="1-10" className="bg-[#1A1A0F]">1–10 employees</option>
                    <option value="11-50" className="bg-[#1A1A0F]">11–50 employees</option>
                    <option value="51-200" className="bg-[#1A1A0F]">51–200 employees</option>
                    <option value="200+" className="bg-[#1A1A0F]">200+ employees</option>
                    <option value="SETA/NGO" className="bg-[#1A1A0F]">SETA / NGO</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="text-xs font-medium text-[#FFFDF7]/40 uppercase tracking-widest block mb-2">What are you hiring for?</label>
                <textarea value={form.message} onChange={e=>setForm(f=>({...f,message:e.target.value}))}
                  placeholder="e.g. We're looking to post 3 retail learnerships in Cape Town and Johannesburg..."
                  rows={3}
                  className="w-full bg-white/6 border border-white/10 rounded-xl px-4 py-3 text-[#FFFDF7] text-sm placeholder:text-white/25 outline-none focus:border-[#F5A623]/50 resize-none"/>
              </div>
              <button onClick={submit} disabled={loading || !form.company || !form.email}
                className="w-full bg-[#F5A623] text-[#1A1A0F] font-bold py-4 rounded-2xl hover:bg-[#e09620] transition-colors disabled:opacity-50 text-sm">
                {loading ? 'Sending...' : 'Get started — it\'s free →'}
              </button>
              <p className="text-center text-xs text-[#FFFDF7]/25">No commitment. We'll set up your account and you post your first listing free.</p>
            </div>
          )}
        </div>
      </div>

    </div>
  )
}
EOF

echo "✅ Recruiters page done!"
