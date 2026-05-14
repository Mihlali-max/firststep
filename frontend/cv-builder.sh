#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📝 Building CV Builder page..."

cat > src/components/pages/CVBuilder.tsx << 'EOF'
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, Trash2, Loader2 } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

// ── Types
interface PersonalInfo { name: string; email: string; phone: string; location: string; summary: string }
interface Education    { school: string; qualification: string; year: string }
interface Experience   { title: string; organisation: string; start_date: string; end_date: string; description: string; is_volunteer: boolean }
interface Reference    { name: string; relation: string; contact: string }

interface CVData {
  personal_info: PersonalInfo
  education: Education[]
  skills: string[]
  experience: Experience[]
  references: Reference[]
}

const EMPTY: CVData = {
  personal_info: { name:'', email:'', phone:'', location:'', summary:'' },
  education: [{ school:'', qualification:'', year:'' }],
  skills: [],
  experience: [],
  references: [],
}

const ALL_SKILLS = [
  'Communication','Microsoft Office','Customer service','Teamwork','Time management',
  'Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling',
  'Basic accounting','Attention to detail','Computer literacy','Adaptability',
  'Leadership','Report writing','Filing & admin','Telephone etiquette',
]

const STEPS = ['Personal info','Education','Skills','Experience','References']

const inputCls = "w-full bg-[#F7F3EB] border border-[#1A1A0F]/12 text-[#1A1A0F] placeholder:text-[#7A7260]/50 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 transition-colors"
const labelCls = "block text-[11px] font-medium tracking-wider uppercase text-[#7A7260] mb-1.5"

export default function CVBuilder() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [step, setStep]     = useState(0)
  const [cv, setCv]         = useState<CVData>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved]   = useState(false)
  const [customSkill, setCustomSkill] = useState('')

  // Redirect if not logged in
  useEffect(() => { if (!user) navigate('/register') }, [user])

  // Load existing CV
  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      setCv({
        personal_info: d.personal_info || EMPTY.personal_info,
        education:     d.education?.length ? d.education : EMPTY.education,
        skills:        d.skills || [],
        experience:    d.experience || [],
        references:    d.references || [],
      })
    }).catch(() => {})
  }, [])

  const completion = () => {
    let s = 0
    if (cv.personal_info?.name) s += 25
    if (cv.education?.length && cv.education[0].school) s += 20
    if (cv.skills?.length) s += 20
    if (cv.experience?.length) s += 20
    if (cv.references?.length) s += 15
    return s
  }

  const save = async () => {
    setSaving(true)
    try {
      await api.patch('/cv', {
        personal_info: cv.personal_info,
        education:     cv.education.filter(e => e.school),
        skills:        cv.skills,
        experience:    cv.experience.filter(e => e.title),
        references:    cv.references.filter(r => r.name),
      })
      setSaved(true)
      setTimeout(() => setSaved(false), 2000)
    } catch(e) { console.error(e) }
    finally { setSaving(false) }
  }

  const next = async () => { await save(); if (step < 4) setStep(step + 1) }
  const back = () => { if (step > 0) setStep(step - 1) }

  const toggleSkill = (s: string) => {
    setCv(c => ({ ...c, skills: c.skills.includes(s) ? c.skills.filter(x => x !== s) : [...c.skills, s] }))
  }
  const addCustomSkill = () => {
    if (!customSkill.trim()) return
    setCv(c => ({ ...c, skills: [...c.skills, customSkill.trim()] }))
    setCustomSkill('')
  }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* Header */}
      <div className="bg-[#1A1A0F] px-8 md:px-12 py-10">
        <p className="text-[#F5A623] text-[11px] font-medium tracking-[3px] uppercase mb-2">Free · No experience needed</p>
        <h1 className="font-display text-3xl md:text-4xl font-bold text-[#FFFDF7] tracking-tight mb-2">
          Build your <em className="not-italic text-[#F5A623]">CV in minutes.</em>
        </h1>
        <p className="text-[#FFFDF7]/55 font-light text-sm">Answer a few simple questions — we'll write your professional CV for you.</p>

        {/* Progress bar */}
        <div className="mt-6 flex items-center gap-2 flex-wrap">
          {STEPS.map((s, i) => (
            <button key={s} onClick={() => setStep(i)}
              className={clsx('flex items-center gap-2 text-xs font-medium px-3 py-1.5 rounded-full transition-all', 
                i === step ? 'bg-[#F5A623] text-[#1A1A0F]' :
                i < step   ? 'bg-[#2A5C3F] text-[#FFFDF7]' :
                             'bg-[#FFFDF7]/10 text-[#FFFDF7]/50')}>
              {i < step ? <Check size={12} /> : <span>{i+1}</span>}
              {s}
            </button>
          ))}
          <div className="ml-auto text-xs text-[#FFFDF7]/40">{completion()}% complete</div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-8 md:px-12 py-10 grid grid-cols-1 lg:grid-cols-[1fr_360px] gap-8">

        {/* ── FORM PANEL ── */}
        <div className="bg-[#FFFDF7] rounded-2xl border border-[#1A1A0F]/10 p-8">

          {/* Step 0 — Personal info */}
          {step === 0 && (
            <div>
              <div className="inline-block text-[11px] font-medium tracking-[1.5px] uppercase text-[#C47D0A] bg-[#F5A623]/10 border border-[#F5A623]/25 px-3 py-1 rounded-full mb-4">Step 1 of 5</div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">Who are you?</h2>
              <p className="text-[#7A7260] text-sm font-light mb-7">Tell us your basic details so we can personalise your CV.</p>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className={labelCls}>Full name *</label>
                    <input className={inputCls} placeholder="e.g. Lebo Sithole" value={cv.personal_info.name}
                      onChange={e => setCv(c => ({ ...c, personal_info: { ...c.personal_info, name: e.target.value } }))} />
                  </div>
                  <div>
                    <label className={labelCls}>Email *</label>
                    <input className={inputCls} type="email" placeholder="lebo@gmail.com" value={cv.personal_info.email}
                      onChange={e => setCv(c => ({ ...c, personal_info: { ...c.personal_info, email: e.target.value } }))} />
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className={labelCls}>Phone number</label>
                    <input className={inputCls} placeholder="071 234 5678" value={cv.personal_info.phone}
                      onChange={e => setCv(c => ({ ...c, personal_info: { ...c.personal_info, phone: e.target.value } }))} />
                  </div>
                  <div>
                    <label className={labelCls}>Location</label>
                    <input className={inputCls} placeholder="Cape Town, Western Cape" value={cv.personal_info.location}
                      onChange={e => setCv(c => ({ ...c, personal_info: { ...c.personal_info, location: e.target.value } }))} />
                  </div>
                </div>
                <div>
                  <label className={labelCls}>Professional summary <span className="normal-case text-[#7A7260]/60">(optional — we can help write this)</span></label>
                  <textarea className={inputCls + ' resize-none'} rows={3} placeholder="A brief description of who you are and what you're looking for…" value={cv.personal_info.summary}
                    onChange={e => setCv(c => ({ ...c, personal_info: { ...c.personal_info, summary: e.target.value } }))} />
                </div>
              </div>
            </div>
          )}

          {/* Step 1 — Education */}
          {step === 1 && (
            <div>
              <div className="inline-block text-[11px] font-medium tracking-[1.5px] uppercase text-[#C47D0A] bg-[#F5A623]/10 border border-[#F5A623]/25 px-3 py-1 rounded-full mb-4">Step 2 of 5</div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">Your education</h2>
              <p className="text-[#7A7260] text-sm font-light mb-7">Tell us about your schooling — matric, courses, anything counts.</p>
              <div className="space-y-5">
                {cv.education.map((edu, i) => (
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    {i > 0 && (
                      <button onClick={() => setCv(c => ({ ...c, education: c.education.filter((_,j) => j!==i) }))}
                        className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500 transition-colors"><Trash2 size={14}/></button>
                    )}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className={labelCls}>School / institution *</label>
                        <input className={inputCls} placeholder="e.g. Khayelitsha High School" value={edu.school}
                          onChange={e => { const ed = [...cv.education]; ed[i].school = e.target.value; setCv(c => ({ ...c, education: ed })) }} />
                      </div>
                      <div>
                        <label className={labelCls}>Qualification *</label>
                        <input className={inputCls} placeholder="e.g. Matric Certificate, NQF Level 4" value={edu.qualification}
                          onChange={e => { const ed = [...cv.education]; ed[i].qualification = e.target.value; setCv(c => ({ ...c, education: ed })) }} />
                      </div>
                    </div>
                    <div className="mt-4 w-40">
                      <label className={labelCls}>Year completed</label>
                      <input className={inputCls} placeholder="2024" value={edu.year}
                        onChange={e => { const ed = [...cv.education]; ed[i].year = e.target.value; setCv(c => ({ ...c, education: ed })) }} />
                    </div>
                  </div>
                ))}
                <button onClick={() => setCv(c => ({ ...c, education: [...c.education, { school:'', qualification:'', year:'' }] }))}
                  className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                  <Plus size={15}/> Add another qualification
                </button>
              </div>
            </div>
          )}

          {/* Step 2 — Skills */}
          {step === 2 && (
            <div>
              <div className="inline-block text-[11px] font-medium tracking-[1.5px] uppercase text-[#C47D0A] bg-[#F5A623]/10 border border-[#F5A623]/25 px-3 py-1 rounded-full mb-4">Step 3 of 5</div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">What are you good at?</h2>
              <p className="text-[#7A7260] text-sm font-light mb-7">Select skills that apply to you — don't worry if you don't have many.</p>
              <div className="flex flex-wrap gap-2 mb-6">
                {ALL_SKILLS.map(s => (
                  <button key={s} onClick={() => toggleSkill(s)}
                    className={clsx('text-sm px-4 py-2 rounded-full border transition-all duration-200',
                      cv.skills.includes(s) ? 'bg-[#F5A623]/15 border-[#F5A623]/40 text-[#C47D0A] font-medium' : 'bg-[#F7F3EB] border-[#1A1A0F]/10 text-[#7A7260] hover:border-[#F5A623]/30 hover:text-[#1A1A0F]')}>
                    {cv.skills.includes(s) && <Check size={12} className="inline mr-1.5 -mt-0.5" />}{s}
                  </button>
                ))}
              </div>
              <div>
                <label className={labelCls}>Add your own skill</label>
                <div className="flex gap-2">
                  <input className={inputCls} placeholder="e.g. Welding, isiXhosa, Typing 60wpm…" value={customSkill}
                    onChange={e => setCustomSkill(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && addCustomSkill()} />
                  <button onClick={addCustomSkill} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-medium hover:opacity-85 transition-opacity whitespace-nowrap">
                    Add
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Step 3 — Experience */}
          {step === 3 && (
            <div>
              <div className="inline-block text-[11px] font-medium tracking-[1.5px] uppercase text-[#C47D0A] bg-[#F5A623]/10 border border-[#F5A623]/25 px-3 py-1 rounded-full mb-4">Step 4 of 5</div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">Your experience</h2>
              <p className="text-[#7A7260] text-sm font-light mb-4">Any work, volunteering, or projects — even informal ones count.</p>
              <div className="bg-[#F5A623]/8 border border-[#F5A623]/20 rounded-xl px-5 py-4 mb-6">
                <p className="text-sm font-medium text-[#1A1A0F] mb-1">💡 No work experience? That's okay.</p>
                <p className="text-sm font-light text-[#7A7260]">Helping at a family business, school tuck shop, community work, church projects — all of these count. We'll help you describe them properly.</p>
              </div>
              <div className="space-y-5">
                {cv.experience.map((exp, i) => (
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    <button onClick={() => setCv(c => ({ ...c, experience: c.experience.filter((_,j) => j!==i) }))}
                      className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500 transition-colors"><Trash2 size={14}/></button>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                      <div>
                        <label className={labelCls}>Job title / role *</label>
                        <input className={inputCls} placeholder="e.g. Shop assistant, Volunteer" value={exp.title}
                          onChange={e => { const ex = [...cv.experience]; ex[i].title = e.target.value; setCv(c => ({ ...c, experience: ex })) }} />
                      </div>
                      <div>
                        <label className={labelCls}>Organisation / place</label>
                        <input className={inputCls} placeholder="e.g. Shoprite, Community garden" value={exp.organisation}
                          onChange={e => { const ex = [...cv.experience]; ex[i].organisation = e.target.value; setCv(c => ({ ...c, experience: ex })) }} />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4 mb-4">
                      <div>
                        <label className={labelCls}>Start date</label>
                        <input className={inputCls} placeholder="Jan 2023" value={exp.start_date}
                          onChange={e => { const ex = [...cv.experience]; ex[i].start_date = e.target.value; setCv(c => ({ ...c, experience: ex })) }} />
                      </div>
                      <div>
                        <label className={labelCls}>End date</label>
                        <input className={inputCls} placeholder="Dec 2023 or Present" value={exp.end_date}
                          onChange={e => { const ex = [...cv.experience]; ex[i].end_date = e.target.value; setCv(c => ({ ...c, experience: ex })) }} />
                      </div>
                    </div>
                    <div>
                      <label className={labelCls}>What did you do?</label>
                      <textarea className={inputCls + ' resize-none'} rows={2} placeholder="Briefly describe what you did and what you learned…" value={exp.description}
                        onChange={e => { const ex = [...cv.experience]; ex[i].description = e.target.value; setCv(c => ({ ...c, experience: ex })) }} />
                    </div>
                    <label className="flex items-center gap-2 mt-3 cursor-pointer">
                      <input type="checkbox" checked={exp.is_volunteer} className="accent-[#F5A623]"
                        onChange={e => { const ex = [...cv.experience]; ex[i].is_volunteer = e.target.checked; setCv(c => ({ ...c, experience: ex })) }} />
                      <span className="text-sm text-[#7A7260]">This was volunteer / informal work</span>
                    </label>
                  </div>
                ))}
                <button onClick={() => setCv(c => ({ ...c, experience: [...c.experience, { title:'', organisation:'', start_date:'', end_date:'', description:'', is_volunteer:false }] }))}
                  className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                  <Plus size={15}/> Add experience
                </button>
              </div>
            </div>
          )}

          {/* Step 4 — References */}
          {step === 4 && (
            <div>
              <div className="inline-block text-[11px] font-medium tracking-[1.5px] uppercase text-[#C47D0A] bg-[#F5A623]/10 border border-[#F5A623]/25 px-3 py-1 rounded-full mb-4">Step 5 of 5</div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">References</h2>
              <p className="text-[#7A7260] text-sm font-light mb-4">Someone who can vouch for you — a teacher, community leader, neighbour, or pastor works fine.</p>
              <div className="space-y-5">
                {cv.references.map((ref, i) => (
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    {i > 0 && (
                      <button onClick={() => setCv(c => ({ ...c, references: c.references.filter((_,j) => j!==i) }))}
                        className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500 transition-colors"><Trash2 size={14}/></button>
                    )}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                      <div>
                        <label className={labelCls}>Full name *</label>
                        <input className={inputCls} placeholder="e.g. Mrs Dlamini" value={ref.name}
                          onChange={e => { const r = [...cv.references]; r[i].name = e.target.value; setCv(c => ({ ...c, references: r })) }} />
                      </div>
                      <div>
                        <label className={labelCls}>Relationship</label>
                        <input className={inputCls} placeholder="e.g. Former teacher, Community leader" value={ref.relation}
                          onChange={e => { const r = [...cv.references]; r[i].relation = e.target.value; setCv(c => ({ ...c, references: r })) }} />
                      </div>
                    </div>
                    <div>
                      <label className={labelCls}>Contact number or email</label>
                      <input className={inputCls} placeholder="072 000 0000 or email@example.com" value={ref.contact}
                        onChange={e => { const r = [...cv.references]; r[i].contact = e.target.value; setCv(c => ({ ...c, references: r })) }} />
                    </div>
                  </div>
                ))}
                <button onClick={() => setCv(c => ({ ...c, references: [...c.references, { name:'', relation:'', contact:'' }] }))}
                  className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                  <Plus size={15}/> Add reference
                </button>
              </div>

              {/* Download CTA */}
              {completion() >= 60 && (
                <div className="mt-8 p-6 bg-[#F5A623]/10 border border-[#F5A623]/25 rounded-2xl">
                  <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-2">Your CV is ready!</h3>
                  <p className="text-sm font-light text-[#7A7260] mb-4">Download your professional CV as a PDF and start applying.</p>
                  <a href="/api/cv/download" target="_blank"
                    className="btn-amber inline-flex items-center gap-2">
                    <Download size={15}/> Download CV (PDF)
                  </a>
                </div>
              )}
            </div>
          )}

          {/* Navigation */}
          <div className="flex items-center justify-between mt-10 pt-6 border-t border-[#1A1A0F]/8">
            <button onClick={back} disabled={step === 0}
              className={clsx('flex items-center gap-2 text-sm font-medium transition-colors', step === 0 ? 'text-[#1A1A0F]/20 cursor-not-allowed' : 'text-[#7A7260] hover:text-[#1A1A0F]')}>
              <ChevronLeft size={16}/> Back
            </button>
            <div className="flex items-center gap-3">
              <button onClick={save} disabled={saving}
                className="text-sm font-medium text-[#7A7260] hover:text-[#1A1A0F] transition-colors flex items-center gap-1.5">
                {saving ? <Loader2 size={14} className="animate-spin"/> : saved ? <Check size={14} className="text-green-500"/> : null}
                {saved ? 'Saved!' : 'Save'}
              </button>
              {step < 4 ? (
                <button onClick={next} className="btn-amber flex items-center gap-2 !py-2.5 !px-5 text-sm">
                  Save & continue <ChevronRight size={15}/>
                </button>
              ) : (
                <button onClick={save} className="btn-amber flex items-center gap-2 !py-2.5 !px-5 text-sm">
                  {saving ? <Loader2 size={14} className="animate-spin"/> : <Check size={14}/>} Finish
                </button>
              )}
            </div>
          </div>
        </div>

        {/* ── LIVE PREVIEW ── */}
        <div className="sticky top-24 h-fit">
          <div className="bg-[#FFFDF7] rounded-2xl border border-[#1A1A0F]/10 overflow-hidden shadow-[0_4px_24px_rgba(26,26,15,0.08)]">
            <div className="px-4 py-3 bg-[#F7F3EB] border-b border-[#1A1A0F]/8 flex items-center justify-between">
              <span className="text-[11px] font-medium tracking-wider uppercase text-[#7A7260]">Live preview</span>
              <span className="text-[11px] text-[#7A7260]">{completion()}% complete</span>
            </div>
            <div className="p-5 text-[11px] leading-relaxed max-h-[70vh] overflow-y-auto">
              {/* Header */}
              <div className="border-b-2 border-[#F5A623] pb-3 mb-3">
                <div className="font-display text-lg font-bold text-[#1A1A0F]">{cv.personal_info.name || 'Your Name'}</div>
                <div className="text-[#7A7260] mt-0.5">{[cv.personal_info.email, cv.personal_info.phone, cv.personal_info.location].filter(Boolean).join(' · ') || 'your@email.com · 07x xxx xxxx · City'}</div>
              </div>
              {cv.personal_info.summary && (
                <div className="mb-3">
                  <div className="text-[9px] font-semibold tracking-[2px] uppercase text-[#C47D0A] mb-1">Summary</div>
                  <p className="text-[#1A1A0F]">{cv.personal_info.summary}</p>
                </div>
              )}
              {cv.education.some(e => e.school) && (
                <div className="mb-3">
                  <div className="text-[9px] font-semibold tracking-[2px] uppercase text-[#C47D0A] mb-1">Education</div>
                  {cv.education.filter(e => e.school).map((e,i) => (
                    <div key={i} className="mb-1">
                      <span className="font-semibold text-[#1A1A0F]">{e.qualification}</span>
                      {e.year && <span className="text-[#7A7260]"> — {e.year}</span>}
                      <div className="text-[#7A7260]">{e.school}</div>
                    </div>
                  ))}
                </div>
              )}
              {cv.skills.length > 0 && (
                <div className="mb-3">
                  <div className="text-[9px] font-semibold tracking-[2px] uppercase text-[#C47D0A] mb-1">Skills</div>
                  <div className="flex flex-wrap gap-1">
                    {cv.skills.map(s => (
                      <span key={s} className="bg-[#F5A623]/10 text-[#C47D0A] border border-[#F5A623]/25 px-2 py-0.5 rounded text-[9px] font-medium">{s}</span>
                    ))}
                  </div>
                </div>
              )}
              {cv.experience.some(e => e.title) && (
                <div className="mb-3">
                  <div className="text-[9px] font-semibold tracking-[2px] uppercase text-[#C47D0A] mb-1">Experience</div>
                  {cv.experience.filter(e => e.title).map((e,i) => (
                    <div key={i} className="mb-2">
                      <div className="flex justify-between">
                        <span className="font-semibold text-[#1A1A0F]">{e.title}{e.is_volunteer ? ' (Volunteer)' : ''}</span>
                        <span className="text-[#7A7260]">{[e.start_date, e.end_date].filter(Boolean).join(' – ')}</span>
                      </div>
                      {e.organisation && <div className="text-[#7A7260]">{e.organisation}</div>}
                      {e.description && <div className="text-[#1A1A0F] mt-0.5">{e.description}</div>}
                    </div>
                  ))}
                </div>
              )}
              {cv.references.some(r => r.name) && (
                <div>
                  <div className="text-[9px] font-semibold tracking-[2px] uppercase text-[#C47D0A] mb-1">References</div>
                  {cv.references.filter(r => r.name).map((r,i) => (
                    <div key={i} className="mb-1">
                      <span className="font-semibold text-[#1A1A0F]">{r.name}</span>
                      {r.relation && <span className="text-[#7A7260]"> — {r.relation}</span>}
                      {r.contact && <div className="text-[#7A7260]">{r.contact}</div>}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
          {/* Tips */}
          <div className="mt-4 space-y-3">
            {[
              { icon:'💡', tip:'No work experience? Volunteering, school projects, and helping at home all count.' },
              { icon:'📄', tip:'Keep it to one page. We format it cleanly for you.' },
              { icon:'🎯', tip:'The more sections you fill, the stronger your CV.' },
            ].map(t => (
              <div key={t.tip} className="flex gap-3 bg-[#FFFDF7] border border-[#1A1A0F]/8 rounded-xl p-4">
                <span className="text-base flex-shrink-0">{t.icon}</span>
                <p className="text-xs font-light text-[#7A7260] leading-relaxed">{t.tip}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

echo "✅ CV Builder written! Updating App.tsx routes..."

# Update App.tsx to use real CV page
sed -i "s|import { Login, Register } from './components/pages/Auth'|import { Login, Register } from './components/pages/Auth'\nimport CVBuilder from './components/pages/CVBuilder'|" src/App.tsx
sed -i "s|<Route path=\"/cv\" element={<Soon title=\"CV Builder\" />} />|<Route path=\"/cv\" element={<CVBuilder />} />|" src/App.tsx

echo "✅ Done! Restarting..."
npm run dev
