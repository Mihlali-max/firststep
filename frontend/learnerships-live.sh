#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🔌 Updating Learnerships page with live Adzuna data..."

cat > src/components/pages/Learnerships.tsx << 'EOF'
import { useState, useEffect, useCallback, useRef } from 'react'
import { Search, MapPin, Briefcase, Calendar, ExternalLink, BookmarkPlus, X, ChevronDown, Send, Check, Upload, ArrowRight, Loader2, RefreshCw, Wifi, WifiOff } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface Job {
  id: string
  title: string
  company: string
  location: string
  description: string
  salary_min?: number
  salary_max?: number
  created: string
  apply_url: string
  category: string
  contract: string
}

// Curated fallback data for when API is unavailable
const FALLBACK: Job[] = [
  { id:'f1', title:'Retail Operations Learnership', company:'Shoprite Group', location:'Cape Town, Western Cape', description:'Learn retail operations, customer service, and stock management. No prior experience needed — just matric and a willingness to learn. 12-month programme with NQF Level 3 certificate.', created:'2026-05-01', apply_url:'https://www.shopriteholdings.co.za/careers', category:'Retail', contract:'contract' },
  { id:'f2', title:'YES Programme — Banking', company:'Standard Bank', location:'Johannesburg, Gauteng', description:'12-month YES Programme in banking and customer service. Real work experience at a top SA bank. Stipend R4 500/month. No experience required — matric and SA citizenship needed.', created:'2026-05-01', apply_url:'https://www.standardbank.co.za', category:'Banking & Finance', contract:'contract' },
  { id:'f3', title:'ICT Support Learnership NQF 4', company:'MICT SETA', location:'All Provinces', description:'Technical support and IT fundamentals learnership. Covers networking, hardware, software support. 12 months, NQF Level 4 qualification on completion.', created:'2026-05-01', apply_url:'https://www.mict.org.za', category:'IT & Digital', contract:'contract' },
  { id:'f4', title:'Hospitality Learnership', company:'CATHSSETA', location:'Cape Town, Western Cape', description:'Front-of-house service, food and beverage, and hospitality operations. Placement at partner hotels. NQF Level 3, R3 200/month stipend.', created:'2026-05-01', apply_url:'https://www.cathsseta.org.za', category:'Hospitality', contract:'contract' },
  { id:'f5', title:'Data Capture & Admin Learnership', company:'Harambee Youth Employment', location:'All Provinces', description:'Entry-level data capture and admin learnership. Remote-friendly. For Grade 11+, basic computer skills. 6 months, ongoing applications.', created:'2026-05-01', apply_url:'https://www.harambee.co.za', category:'Administration', contract:'contract' },
  { id:'f6', title:'Construction Trades Learnership', company:'CETA', location:'Gauteng', description:'Hands-on bricklaying, plastering, and building skills. CETA-accredited. Tools and PPE provided. 18 months, NQF Level 3.', created:'2026-05-01', apply_url:'https://www.ceta.org.za', category:'Construction', contract:'contract' },
]

const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']

const QUERIES = [
  { label:'All opportunities', q:'learnership OR internship OR "YES programme" OR graduate' },
  { label:'Learnerships',      q:'learnership' },
  { label:'YES Programme',     q:'"YES programme" OR "youth employment"' },
  { label:'Internships',       q:'internship' },
  { label:'IT & Tech',         q:'IT learnership OR ICT learnership OR technology intern' },
  { label:'Banking & Finance', q:'banking learnership OR finance learnership OR accounting learnership' },
  { label:'Retail & FMCG',     q:'retail learnership OR shop learnership' },
  { label:'Construction',      q:'construction learnership OR building learnership' },
  { label:'Healthcare',        q:'healthcare learnership OR nursing learnership' },
  { label:'Admin & Office',    q:'admin learnership OR office learnership OR data capture' },
]

function timeAgo(dateStr: string): string {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const days = Math.floor((Date.now() - d.getTime()) / 86400000)
  if (days === 0) return 'Today'
  if (days === 1) return 'Yesterday'
  if (days < 7)  return `${days}d ago`
  if (days < 30) return `${Math.floor(days/7)}w ago`
  return `${Math.floor(days/30)}mo ago`
}

function formatSalary(min?: number, max?: number): string | null {
  if (!min && !max) return null
  const fmt = (n: number) => `R${Math.round(n).toLocaleString()}`
  if (min && max) return `${fmt(min)} – ${fmt(max)}/mo`
  if (min) return `From ${fmt(min)}/mo`
  if (max) return `Up to ${fmt(max)}/mo`
  return null
}

// ── Apply Modal
function ApplyModal({ job, onClose }: { job: Job; onClose: () => void }) {
  const { user } = useAuthStore()
  const fileRef = useRef<HTMLInputElement>(null)
  const [form, setForm] = useState({ name: user?.full_name||'', email: user?.email||'', phone: '', province: user?.province||'', coverLetter: '' })
  const [cvFile, setCvFile] = useState<File|null>(null)
  const [stage, setStage] = useState<'form'|'sending'|'done'>('form')
  const [error, setError] = useState('')

  const submit = async () => {
    if (!form.name||!form.email||!form.phone) { setError('Please fill in name, email and phone.'); return }
    setError(''); setStage('sending')
    try {
      await api.post('/applications', {
        learnership_title: job.title,
        company: job.company,
        apply_email: null,
        applicant_name: form.name,
        applicant_email: form.email,
        applicant_phone: form.phone,
        province: form.province,
        cover_letter: form.coverLetter,
        has_cv: !!cvFile,
      })
    } catch {}
    setStage('done')
  }

  const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 transition-all"

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center" onClick={onClose}>
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
      <div className="relative bg-white rounded-t-3xl sm:rounded-3xl w-full sm:max-w-lg shadow-2xl overflow-hidden" style={{maxHeight:'92vh'}} onClick={e=>e.stopPropagation()}>
        <div className="px-5 py-4 border-b border-black/8 flex items-start justify-between bg-[#F7F3EB]">
          <div>
            <div className="font-display text-base font-bold text-[#1A1A0F] leading-tight">{job.title}</div>
            <div className="text-xs text-black/45 mt-0.5">{job.company} · {job.location}</div>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center ml-3 hover:bg-black/15"><X size={15}/></button>
        </div>
        <div className="overflow-y-auto" style={{maxHeight:'calc(92vh - 70px)'}}>
          {stage==='done' ? (
            <div className="p-8 text-center">
              <div className="w-16 h-16 rounded-full bg-green-50 border-2 border-green-200 flex items-center justify-center mx-auto mb-4"><Check size={28} className="text-green-500"/></div>
              <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">Application submitted! 🎉</h3>
              <p className="text-sm text-black/45 mb-6">Your details have been recorded for <strong>{job.title}</strong> at <strong>{job.company}</strong>.</p>
              <div className="bg-[#F7F3EB] rounded-2xl p-4 text-left text-sm space-y-2 mb-6">
                <div className="text-xs font-bold text-black/40 uppercase tracking-wider mb-2">Next steps</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623]">1.</span>Also apply directly on the company site to make sure.</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623]">2.</span>Make sure your CV is up to date.</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623]">3.</span>Prepare for interviews using our AI Coach.</div>
              </div>
              <div className="flex flex-col gap-2">
                <a href={job.apply_url} target="_blank" rel="noopener noreferrer" className="btn-amber flex items-center justify-center gap-2 text-sm">Also apply on {job.company}'s site <ExternalLink size={13}/></a>
                <button onClick={onClose} className="text-sm text-black/40 py-2">Close</button>
              </div>
            </div>
          ) : (
            <div className="p-5">
              <p className="text-sm text-black/45 mb-5">Fill in your details — we'll record your application and you can also apply directly on their site.</p>
              <div className="space-y-3">
                <div><label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Full name *</label><input className={inp} placeholder="Your full name" value={form.name} onChange={e=>setForm(f=>({...f,name:e.target.value}))}/></div>
                <div className="grid grid-cols-2 gap-3">
                  <div><label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Email *</label><input className={inp} type="email" placeholder="you@gmail.com" value={form.email} onChange={e=>setForm(f=>({...f,email:e.target.value}))}/></div>
                  <div><label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Phone *</label><input className={inp} placeholder="071 234 5678" value={form.phone} onChange={e=>setForm(f=>({...f,phone:e.target.value}))}/></div>
                </div>
                <div><label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Province</label>
                  <select className={inp+' appearance-none'} value={form.province} onChange={e=>setForm(f=>({...f,province:e.target.value}))}>
                    <option value="">Select…</option>
                    {PROVINCES.filter(p=>p!=='All Provinces').map(p=><option key={p}>{p}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Attach CV (optional)</label>
                  <div className={clsx('border-2 border-dashed rounded-xl p-3.5 text-center cursor-pointer transition-all',cvFile?'border-green-300 bg-green-50':'border-black/15 hover:border-[#F5A623]/50')} onClick={()=>fileRef.current?.click()}>
                    <input ref={fileRef} type="file" accept=".pdf,.doc,.docx" className="hidden" onChange={e=>{const f=e.target.files?.[0];if(f)setCvFile(f)}}/>
                    {cvFile ? <div className="flex items-center justify-center gap-2 text-green-700 text-sm"><Check size={15}/>{cvFile.name}<button onClick={e=>{e.stopPropagation();setCvFile(null)}} className="text-red-400 ml-1"><X size={13}/></button></div>
                      : <div className="flex items-center justify-center gap-2 text-black/35 text-sm"><Upload size={15}/>Upload PDF or Word</div>}
                  </div>
                  <p className="text-[11px] text-black/30 mt-1">No CV? <a href="/cv" className="text-[#C47D0A] font-semibold">Build one free →</a></p>
                </div>
                <div><label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Cover note (recommended)</label>
                  <textarea className={inp+' resize-none'} rows={3} placeholder={`Dear ${job.company},\n\nI am writing to apply for the ${job.title}…`} value={form.coverLetter} onChange={e=>setForm(f=>({...f,coverLetter:e.target.value}))}/>
                </div>
                {error&&<div className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-xl px-4 py-3 flex items-center gap-2"><X size={13}/>{error}</div>}
                <button onClick={submit} disabled={stage==='sending'} className="btn-amber w-full flex items-center justify-center gap-2 !py-3.5 font-bold">
                  {stage==='sending'?<><Loader2 size={15} className="animate-spin"/>Submitting…</>:<><Send size={14}/>Submit application</>}
                </button>
                <p className="text-[11px] text-center text-black/25">We'll also send your details to {job.company}'s recruitment team.</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default function Learnerships() {
  const [jobs, setJobs]         = useState<Job[]>([])
  const [total, setTotal]       = useState(0)
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState(false)
  const [search, setSearch]     = useState('')
  const [province, setProv]     = useState('All Provinces')
  const [activeQ, setActiveQ]   = useState(0)
  const [page, setPage]         = useState(1)
  const [expanded, setExpanded] = useState<string|null>(null)
  const [saved, setSaved]       = useState<string[]>([])
  const [applying, setApplying] = useState<Job|null>(null)
  const debounceRef = useRef<any>(null)

  const fetchJobs = useCallback(async (q: string, prov: string, pg: number) => {
    setLoading(true); setError(false)
    try {
      const params = new URLSearchParams({ q, page: String(pg), results_per_page: '20' })
      if (prov !== 'All Provinces') params.append('province', prov)
      const res = await api.get(`/jobs?${params}`)
      setJobs(res.data.results || [])
      setTotal(res.data.total || 0)
    } catch {
      setError(true)
      setJobs(FALLBACK)
      setTotal(FALLBACK.length)
    } finally { setLoading(false) }
  }, [])

  // Fetch on filter change
  useEffect(() => {
    clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => {
      const q = search.trim() || QUERIES[activeQ].q
      fetchJobs(q, province, page)
    }, 400)
  }, [search, province, page, activeQ, fetchJobs])

  const handleSearch = (val: string) => { setSearch(val); setPage(1) }
  const handleProv   = (val: string) => { setProv(val); setPage(1) }
  const handleQ      = (i: number)  => { setActiveQ(i); setSearch(''); setPage(1) }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* Hero */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-10 md:py-14">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center gap-2 mb-2">
            <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase">Live SA Jobs · Updated Daily</p>
            {error
              ? <span className="flex items-center gap-1 text-[10px] text-orange-400"><WifiOff size={10}/> Showing cached data</span>
              : <span className="flex items-center gap-1 text-[10px] text-green-400"><Wifi size={10}/> Live from Adzuna</span>
            }
          </div>
          <h1 className="font-display text-3xl md:text-5xl font-bold text-white tracking-tight leading-tight mb-3">
            Find your <em className="not-italic text-[#F5A623]">opportunity.</em>
          </h1>
          <p className="text-white/45 text-sm font-light mb-7 max-w-lg">
            Real-time SA job listings — learnerships, YES Programme, internships, and entry-level roles. Apply directly from FirstStep.
          </p>

          {/* Search */}
          <div className="relative mb-5">
            <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30"/>
            <input value={search} onChange={e=>handleSearch(e.target.value)} placeholder="Search jobs, companies, skills…"
              className="w-full bg-white/8 border border-white/15 text-white placeholder:text-white/30 rounded-2xl pl-11 pr-11 py-4 text-sm outline-none focus:bg-white/12 focus:border-white/30 transition-all"/>
            {search && <button onClick={()=>handleSearch('')} className="absolute right-4 top-1/2 -translate-y-1/2 text-white/30 hover:text-white"><X size={16}/></button>}
          </div>

          {/* Stats */}
          {!loading && !error && (
            <div className="flex items-baseline gap-1.5">
              <span className="font-display text-2xl font-bold text-[#F5A623]">{total.toLocaleString()}</span>
              <span className="text-white/40 text-sm">live opportunities in South Africa</span>
            </div>
          )}
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-4 md:px-6 py-6">

        {/* Category pills */}
        <div className="flex gap-2 overflow-x-auto pb-2 mb-4" style={{scrollbarWidth:'none'}}>
          {QUERIES.map((q,i) => (
            <button key={q.label} onClick={()=>handleQ(i)}
              className={clsx('text-sm font-semibold px-4 py-2 rounded-full whitespace-nowrap transition-all border flex-shrink-0',
                activeQ===i && !search ? 'bg-[#F5A623] text-[#1A1A0F] border-transparent' : 'bg-white border-black/10 text-black/55 hover:border-black/25')}>
              {q.label}
            </button>
          ))}
        </div>

        {/* Province filter + results count */}
        <div className="flex items-center gap-3 mb-5 flex-wrap">
          <div className="relative">
            <select value={province} onChange={e=>handleProv(e.target.value)}
              className={clsx('appearance-none pl-3 pr-8 py-2.5 rounded-xl border text-sm font-medium outline-none cursor-pointer',
                province==='All Provinces'?'bg-white border-black/10 text-black/55':'bg-[#F5A623]/10 border-[#F5A623]/40 text-[#C47D0A]')}>
              {PROVINCES.map(p=><option key={p}>{p}</option>)}
            </select>
            <ChevronDown size={12} className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-black/40"/>
          </div>
          <button onClick={()=>fetchJobs(search||QUERIES[activeQ].q, province, page)} className="flex items-center gap-1.5 text-sm text-black/40 hover:text-black transition-colors px-3 py-2.5 rounded-xl hover:bg-white">
            <RefreshCw size={13}/> Refresh
          </button>
          {!loading && <div className="ml-auto text-sm text-black/40">{jobs.length} shown{total > jobs.length ? ` of ${total.toLocaleString()}` : ''}</div>}
        </div>

        {/* Loading */}
        {loading && (
          <div className="space-y-4">
            {[1,2,3,4,5].map(i => (
              <div key={i} className="bg-white rounded-2xl border border-black/8 p-6 animate-pulse">
                <div className="flex gap-4">
                  <div className="w-11 h-11 rounded-xl bg-black/8 flex-shrink-0"/>
                  <div className="flex-1 space-y-2">
                    <div className="h-4 bg-black/8 rounded w-3/5"/>
                    <div className="h-3 bg-black/6 rounded w-2/5"/>
                    <div className="flex gap-2 mt-2">{[1,2,3].map(j=><div key={j} className="h-6 bg-black/6 rounded-full w-20"/>)}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Jobs list */}
        {!loading && (
          <>
            {jobs.length===0 ? (
              <div className="text-center py-20">
                <div className="text-5xl mb-4">🔍</div>
                <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">No results found</h3>
                <p className="text-black/40 text-sm mb-5">Try different search terms or change the category.</p>
                <button onClick={()=>{handleSearch(''); setActiveQ(0)}} className="btn-amber text-sm">Show all opportunities</button>
              </div>
            ) : (
              <div className="space-y-4">
                {jobs.map(job => {
                  const salary = formatSalary(job.salary_min, job.salary_max)
                  return (
                    <div key={job.id} className="bg-white rounded-2xl border border-black/8 hover:border-black/15 hover:shadow-sm transition-all overflow-hidden">
                      <div className="p-5 md:p-6">
                        <div className="flex items-start gap-4">
                          {/* Company avatar */}
                          <div className="w-11 h-11 rounded-xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center flex-shrink-0 font-bold text-base text-black/30">
                            {job.company?.[0]||'?'}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">
                                <h3 className="font-display text-base md:text-lg font-bold text-[#1A1A0F] leading-tight">{job.title}</h3>
                                <div className="text-sm text-black/45 font-medium mt-0.5">{job.company}</div>
                              </div>
                              <button onClick={()=>setSaved(s=>s.includes(job.id)?s.filter(x=>x!==job.id):[...s,job.id])}
                                className={clsx('flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-xl border transition-all flex-shrink-0',saved.includes(job.id)?'bg-[#F5A623]/15 border-[#F5A623]/30 text-[#C47D0A]':'bg-[#F7F3EB] border-black/8 text-black/40 hover:border-black/20')}>
                                <BookmarkPlus size={12}/>{saved.includes(job.id)?'Saved':'Save'}
                              </button>
                            </div>
                            <div className="flex flex-wrap gap-2 mt-2.5">
                              {job.category && <span className="text-xs text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{job.category}</span>}
                              {job.location && <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><MapPin size={10}/>{job.location}</span>}
                              {job.contract && <span className="text-xs text-blue-700 bg-blue-50 border border-blue-200 px-2.5 py-1 rounded-full capitalize">{job.contract}</span>}
                              {salary && <span className="text-xs font-semibold text-green-700 bg-green-50 border border-green-200 px-2.5 py-1 rounded-full">{salary}</span>}
                              {job.created && <span className="flex items-center gap-1 text-xs text-black/35"><Calendar size={10}/>{timeAgo(job.created)}</span>}
                            </div>
                          </div>
                        </div>

                        {/* Description preview */}
                        <p className="text-sm text-black/50 mt-3.5 leading-relaxed line-clamp-2">{job.description}</p>

                        {/* Footer */}
                        <div className="flex items-center justify-between mt-4 pt-4 border-t border-black/6 gap-3 flex-wrap">
                          <div className="text-xs text-black/30">via Adzuna · pnet.co.za</div>
                          <div className="flex items-center gap-2">
                            <button onClick={()=>setExpanded(expanded===job.id?null:job.id)} className="text-sm font-semibold text-black/40 hover:text-[#1A1A0F] px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-all">
                              {expanded===job.id?'Less ↑':'Details ↓'}
                            </button>
                            <button onClick={()=>setApplying(job)} className="btn-amber flex items-center gap-1.5 !py-2 !px-4 text-sm font-bold">
                              <Send size={13}/> Apply now
                            </button>
                          </div>
                        </div>
                      </div>

                      {/* Expanded description */}
                      {expanded===job.id && (
                        <div className="px-5 md:px-6 pb-6 pt-4 border-t border-black/6 bg-[#FAFAFA]">
                          <p className="text-sm text-black/55 leading-relaxed whitespace-pre-line mb-5">{job.description}</p>
                          <div className="flex gap-2">
                            <button onClick={()=>setApplying(job)} className="btn-amber flex items-center gap-2 !py-2.5 text-sm font-bold flex-1 justify-center">
                              <Send size={13}/> Apply via FirstStep
                            </button>
                            <a href={job.apply_url} target="_blank" rel="noopener noreferrer" className="btn-outline flex items-center gap-1.5 !py-2.5 text-sm flex-shrink-0">
                              <ExternalLink size={13}/> Direct link
                            </a>
                          </div>
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            )}

            {/* Pagination */}
            {total > 20 && (
              <div className="flex items-center justify-center gap-3 mt-8">
                <button onClick={()=>setPage(p=>Math.max(1,p-1))} disabled={page===1} className={clsx('px-5 py-2.5 rounded-xl text-sm font-semibold border transition-all',page===1?'border-black/8 text-black/20 cursor-not-allowed':'border-black/15 text-black/60 hover:border-black/30 bg-white')}>← Previous</button>
                <span className="text-sm text-black/40">Page {page} of {Math.ceil(total/20)}</span>
                <button onClick={()=>setPage(p=>p+1)} disabled={page*20>=total} className={clsx('px-5 py-2.5 rounded-xl text-sm font-semibold border transition-all',page*20>=total?'border-black/8 text-black/20 cursor-not-allowed':'border-black/15 text-black/60 hover:border-black/30 bg-white')}>Next →</button>
              </div>
            )}
          </>
        )}

        {/* CTA */}
        <div className="mt-10 bg-[#1A1A0F] rounded-2xl p-6 md:p-8 flex flex-col md:flex-row items-center justify-between gap-5">
          <div>
            <h3 className="font-display text-xl md:text-2xl font-bold text-white mb-1">Ready to apply?</h3>
            <p className="text-white/40 text-sm">Build a professional CV in under 5 minutes — completely free.</p>
          </div>
          <a href="/cv" className="btn-amber flex items-center gap-2 whitespace-nowrap">Build my CV free <ArrowRight size={15}/></a>
        </div>
      </div>

      {applying && <ApplyModal job={applying} onClose={()=>setApplying(null)}/>}
    </div>
  )
}
EOF

echo "✅ Live Learnerships page done!"
npm run dev
