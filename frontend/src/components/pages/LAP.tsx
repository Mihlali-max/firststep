import { useState } from 'react'
import { ExternalLink, ChevronDown, ChevronUp, CheckCircle, AlertCircle, BookOpen, Briefcase, Award, ArrowRight, Phone, Globe } from 'lucide-react'
import clsx from 'clsx'

interface Programme {
  id: number
  title: string
  sector: string
  provider: string
  stipend: string
  duration: string
  nqf: string
  provinces: string[]
  requirements: string[]
  documents: string[]
  description: string
  apply_url: string
  apply_phone?: string
  status: 'open' | 'coming_soon' | 'closed'
  tag?: string
}

const PROGRAMMES: Programme[] = [
  {
    id: 1,
    title: 'Wholesale & Retail Operations Learnership',
    sector: 'Retail & FMCG',
    provider: 'UIF LAP + Ubuntu Institute',
    stipend: 'R2 000/month',
    duration: '12 months',
    nqf: 'NQF Level 2',
    provinces: ['All 9 provinces'],
    status: 'open',
    tag: 'Popular',
    description: 'The UIF Labour Activation Programme (LAP) offers unemployed South African youth practical skills and accredited training in the Wholesale & Retail sector. You\'ll gain hands-on experience in a real retail environment while earning a monthly stipend and a nationally recognised qualification.',
    requirements: [
      'South African citizen aged 18–28',
      'Minimum Grade 11 (not Grade 12 required)',
      'Previous UIF contributor (or dependent of a contributor)',
      'Currently unemployed',
      'Not enrolled in another learnership or full-time study',
      'People with disabilities strongly encouraged to apply',
    ],
    documents: [
      'Certified copy of SA ID (not older than 2 months)',
      'Certified copy of highest qualification',
      'Proof of residence (not older than 3 months)',
      'SARS letter / tax number',
      'UIF proof of registration',
      'Medical certificate (if applying as person with disability)',
    ],
    apply_url: 'https://www.labour.gov.za/lap',
    apply_phone: '0800 843 843',
  },
  {
    id: 2,
    title: 'Electronics & Electrical Learnership',
    sector: 'Engineering & Technical',
    provider: 'UIF LAP + Ubuntu Institute',
    stipend: 'R2 000/month',
    duration: '12 months',
    nqf: 'NQF Level 3',
    provinces: ['Gauteng', 'Western Cape', 'KwaZulu-Natal', 'Eastern Cape'],
    status: 'open',
    description: 'Gain practical skills in electronics installation, maintenance, and repair through the UIF LAP Electronics Learnership. You\'ll work with a registered training provider and receive workplace exposure at a host employer in the electronics or electrical sector.',
    requirements: [
      'South African citizen aged 18–28',
      'Minimum Grade 10 with Maths or Science',
      'Previous UIF contributor',
      'Currently unemployed',
      'Physically fit for technical work',
    ],
    documents: [
      'Certified copy of SA ID (not older than 2 months)',
      'Certified copy of highest qualification',
      'Proof of residence',
      'SARS letter / tax number',
      'UIF proof of registration',
    ],
    apply_url: 'https://youthopportunitieshub.com/uif-lap-electronics-learnership-programme-2025-2026/',
  },
  {
    id: 3,
    title: 'Business Administration Learnership',
    sector: 'Administration & Office',
    provider: 'UIF LAP',
    stipend: 'R2 000/month',
    duration: '12 months',
    nqf: 'NQF Level 4',
    provinces: ['All 9 provinces'],
    status: 'open',
    tag: 'Entry level',
    description: 'Learn office administration, business communication, computer literacy, and professional workplace skills. This NQF Level 4 learnership is one of the most in-demand UIF LAP programmes, giving you a qualification that\'s recognised across all industries.',
    requirements: [
      'South African citizen aged 18–35',
      'Matric / Grade 12',
      'Previous UIF contributor',
      'Currently unemployed',
      'Basic computer literacy advantageous',
    ],
    documents: [
      'Certified copy of SA ID',
      'Certified copy of Matric certificate',
      'Proof of residence',
      'SARS letter',
      'UIF proof of registration',
    ],
    apply_url: 'https://www.labour.gov.za/lap',
    apply_phone: '0800 843 843',
  },
  {
    id: 4,
    title: 'YES Programme — SPAR YES4Youth',
    sector: 'Retail & FMCG',
    provider: 'SPAR & Youth Employment Service',
    stipend: 'Stipend provided',
    duration: '12 months',
    nqf: 'Work experience (not NQF)',
    provinces: ['All 9 provinces'],
    status: 'open',
    tag: 'New',
    description: 'SPAR has opened its YES4Youth registration platform for unemployed youth across all 9 provinces. The YES Programme (Youth Employment Service) gives you 12 months of real workplace experience at SPAR stores. While registering doesn\'t guarantee placement, it puts you in the pool for selection.',
    requirements: [
      'South African citizen aged 18–35',
      'Unemployed (affidavit may be required)',
      'No prior workplace experience needed',
      'Black youth (African, Coloured, Indian) per B-BBEE requirements',
    ],
    documents: [
      'SA ID copy',
      'CV (build yours free at FirstStep)',
      'Proof of residence',
      'Matric certificate (if available)',
    ],
    apply_url: 'https://www.clindz-careers.co.za/2026/05/11/spar-yes4youth-programme-2026-register-your-cv-for-opportunities-across-all-9-provinces/',
  },
  {
    id: 5,
    title: 'FNB FirstJob Learner Programme',
    sector: 'Banking & Finance',
    provider: 'First National Bank (FNB)',
    stipend: 'Competitive stipend',
    duration: '12 months',
    nqf: 'NQF Level 4',
    provinces: ['Gauteng (Johannesburg)'],
    status: 'open',
    tag: 'Closing soon',
    description: 'FNB\'s FirstJob Learner Programme gives unemployed youth hands-on experience in banking and financial services. You\'ll work across various business areas including customer service, administration, and operations while earning an accredited qualification. Applications close 22 May 2026.',
    requirements: [
      'Matric / Grade 12',
      'South African citizen',
      'Unemployed',
      'No prior banking experience needed',
      'Strong numerical skills',
    ],
    documents: [
      'SA ID copy',
      'Matric certificate',
      'CV',
      'Proof of residence',
    ],
    apply_url: 'https://applyscholars.com/fnb-learnerships-2026/',
  },
  {
    id: 6,
    title: 'EPWP Youth Employment Programme',
    sector: 'Government & Public Sector',
    provider: 'Dept. of Forestry, Fisheries & Environment',
    stipend: 'Government stipend',
    duration: '12 months',
    nqf: 'Work experience',
    provinces: ['All 9 provinces'],
    status: 'open',
    description: 'The Expanded Public Works Programme (EPWP) Youth Employment Programme by DFFE gives unemployed graduates workplace exposure and practical work experience in environmental and government projects. Preference given to candidates with 0–2 years of experience. Closing 26 May 2026.',
    requirements: [
      'Three-year Bachelor\'s Degree / National Diploma or equivalent',
      'South African citizen aged 18–35',
      'Unemployed or 0–2 years experience',
      'Basic knowledge of data management advantageous',
    ],
    documents: [
      'SA ID copy',
      'Degree/Diploma certificate',
      'CV',
      'Proof of residence',
      'Academic transcripts',
    ],
    apply_url: 'https://www.npowerdg.com/2026/05/apply-south-africa-epwp-youth.html',
  },
]

const SECTORS = ['All Sectors', 'Retail & FMCG', 'Engineering & Technical', 'Administration & Office', 'Banking & Finance', 'Government & Public Sector']

const STATUS_STYLES = {
  open:         'bg-green-50 text-green-700 border-green-200',
  coming_soon:  'bg-yellow-50 text-yellow-700 border-yellow-200',
  closed:       'bg-red-50 text-red-500 border-red-200',
}
const STATUS_LABELS = { open:'Open', coming_soon:'Coming soon', closed:'Closed' }

function ProgrammeCard({ p }:{ p:Programme }) {
  const [open, setOpen] = useState(false)
  return (
    <div className={clsx('bg-white rounded-2xl border overflow-hidden transition-all',
      p.status==='open' ? 'border-black/8 hover:border-black/15 hover:shadow-sm' : 'border-black/6 opacity-75')}>
      <div className="p-5 md:p-6">
        <div className="flex items-start gap-4">
          <div className="w-11 h-11 rounded-xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center flex-shrink-0 font-bold text-base text-black/30">{p.provider[0]}</div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-3 flex-wrap mb-1">
              <div>
                <div className="flex items-center gap-2 flex-wrap">
                  <h3 className="font-display text-base md:text-lg font-bold text-[#1A1A0F] leading-tight">{p.title}</h3>
                  {p.tag && <span className="text-[10px] font-bold text-white bg-[#F5A623] px-2 py-0.5 rounded-full">{p.tag.toUpperCase()}</span>}
                </div>
                <div className="text-sm text-black/45 font-medium mt-0.5">{p.provider}</div>
              </div>
              <span className={clsx('text-xs font-semibold px-2.5 py-1 rounded-full border flex-shrink-0', STATUS_STYLES[p.status])}>
                {STATUS_LABELS[p.status]}
              </span>
            </div>
            <div className="flex flex-wrap gap-2 mt-2.5">
              <span className="text-xs font-semibold text-green-700 bg-green-50 border border-green-200 px-2.5 py-1 rounded-full">{p.stipend}</span>
              <span className="text-xs text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{p.nqf}</span>
              <span className="text-xs text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{p.duration}</span>
              <span className="text-xs text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{p.sector}</span>
            </div>
          </div>
        </div>

        <p className="text-sm text-black/50 mt-4 leading-relaxed">{p.description}</p>

        <div className="flex items-center justify-between mt-4 pt-4 border-t border-black/6 flex-wrap gap-3">
          <div className="text-xs text-black/35">
            📍 {p.provinces.join(' · ')}
          </div>
          <div className="flex items-center gap-2">
            <button onClick={()=>setOpen(!open)} className="text-sm font-semibold text-black/40 hover:text-[#1A1A0F] px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-all flex items-center gap-1">
              {open ? <><ChevronUp size={13}/>Less</> : <><ChevronDown size={13}/>Requirements</>}
            </button>
            {p.status==='open' && (
              <a href={p.apply_url} target="_blank" rel="noopener noreferrer"
                className="btn-amber flex items-center gap-1.5 !py-2 !px-4 text-sm font-bold">
                Apply now <ExternalLink size={13}/>
              </a>
            )}
          </div>
        </div>
      </div>

      {/* Expanded */}
      {open && (
        <div className="px-5 md:px-6 pb-6 pt-4 border-t border-black/6 bg-[#FAFAFA]">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h4 className="font-bold text-sm text-[#1A1A0F] mb-3 flex items-center gap-2"><CheckCircle size={14} className="text-green-500"/>Requirements</h4>
              <ul className="space-y-2">
                {p.requirements.map((r,i) => (
                  <li key={i} className="flex items-start gap-2.5 text-sm text-black/55">
                    <div className="w-4 h-4 rounded-full bg-[#F5A623]/20 border border-[#F5A623]/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <div className="w-1.5 h-1.5 rounded-full bg-[#F5A623]"/>
                    </div>
                    {r}
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <h4 className="font-bold text-sm text-[#1A1A0F] mb-3 flex items-center gap-2"><BookOpen size={14} className="text-blue-500"/>Documents needed</h4>
              <ul className="space-y-2 mb-5">
                {p.documents.map((d,i) => (
                  <li key={i} className="flex items-start gap-2.5 text-sm text-black/55">
                    <div className="w-4 h-4 rounded-full bg-blue-50 border border-blue-200 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <div className="w-1.5 h-1.5 rounded-full bg-blue-400"/>
                    </div>
                    {d}
                  </li>
                ))}
              </ul>
              {p.status==='open' && (
                <div className="space-y-2">
                  <a href={p.apply_url} target="_blank" rel="noopener noreferrer"
                    className="btn-amber flex items-center justify-center gap-2 !py-2.5 text-sm font-bold w-full">
                    <Globe size={13}/> Apply online
                  </a>
                  {p.apply_phone && (
                    <a href={`tel:${p.apply_phone}`}
                      className="btn-outline flex items-center justify-center gap-2 !py-2.5 text-sm w-full">
                      <Phone size={13}/> Call {p.apply_phone}
                    </a>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default function LAP() {
  const [sector, setSector] = useState('All Sectors')
  const filtered = PROGRAMMES.filter(p => sector==='All Sectors' || p.sector===sector)

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* Hero */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-10 md:py-14">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-2">Government Programmes · 2026</p>
          <h1 className="font-display text-3xl md:text-5xl font-bold text-white tracking-tight leading-tight mb-3">
            LAP <em className="not-italic text-[#F5A623]">Programmes.</em>
          </h1>
          <p className="text-white/45 text-sm font-light mb-6 max-w-xl">
            The UIF Labour Activation Programme (LAP) — real government-funded learnerships and YES programmes for unemployed SA youth. Paid monthly stipends, accredited qualifications, real work experience.
          </p>

          {/* What is LAP */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {[
              { icon:'🏛️', title:'Government funded', desc:'Run by the Dept. of Employment & Labour through UIF' },
              { icon:'💰', title:'R2 000/month stipend', desc:'Paid monthly for the full duration of the programme' },
              { icon:'🎓', title:'NQF qualification', desc:'Accredited certificate recognised across South Africa' },
            ].map(c => (
              <div key={c.title} className="bg-white/5 border border-white/10 rounded-2xl p-4">
                <div className="text-2xl mb-2">{c.icon}</div>
                <div className="font-semibold text-white text-sm mb-1">{c.title}</div>
                <div className="text-white/40 text-xs leading-relaxed">{c.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Warning banner */}
      <div className="bg-amber-50 border-b border-amber-200 px-4 md:px-12 py-3">
        <div className="max-w-4xl mx-auto flex items-start gap-3">
          <AlertCircle size={16} className="text-amber-600 flex-shrink-0 mt-0.5"/>
          <p className="text-sm text-amber-800">
            <strong>Watch out for scams.</strong> Real LAP programmes never charge a fee. Always apply through official government or company websites. If someone asks for money to secure your placement — walk away.
          </p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 md:px-6 py-7">

        {/* How to qualify */}
        <div className="bg-white rounded-2xl border border-black/8 p-5 md:p-7 mb-7 shadow-sm">
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-4">Who can apply for LAP?</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {[
              { ok:true,  text:'South African citizen aged 18–35' },
              { ok:true,  text:'Previously contributed to UIF (or dependent of a contributor)' },
              { ok:true,  text:'Currently unemployed' },
              { ok:true,  text:'Minimum Grade 10/11 (varies by programme)' },
              { ok:true,  text:'People with disabilities are strongly encouraged' },
              { ok:false, text:'Currently studying full-time' },
              { ok:false, text:'Already enrolled in another learnership' },
              { ok:false, text:'Currently employed' },
            ].map((item,i) => (
              <div key={i} className="flex items-center gap-3 text-sm">
                <div className={clsx('w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0',item.ok?'bg-green-100':'bg-red-50')}>
                  <span className={item.ok?'text-green-600':'text-red-400'}>{item.ok?'✓':'✕'}</span>
                </div>
                <span className={item.ok?'text-[#1A1A0F]':'text-black/40 line-through'}>{item.text}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Sector filter */}
        <div className="flex gap-2 overflow-x-auto pb-2 mb-5" style={{scrollbarWidth:'none'}}>
          {SECTORS.map(s => (
            <button key={s} onClick={()=>setSector(s)}
              className={clsx('text-sm font-semibold px-4 py-2 rounded-full whitespace-nowrap border transition-all flex-shrink-0',
                sector===s ? 'bg-[#F5A623] text-[#1A1A0F] border-transparent' : 'bg-white border-black/10 text-black/55 hover:border-black/25')}>
              {s}
            </button>
          ))}
        </div>

        {/* Programmes */}
        <div className="space-y-4 mb-8">
          {filtered.map(p => <ProgrammeCard key={p.id} p={p}/>)}
        </div>

        {/* How to apply steps */}
        <div className="bg-[#1A1A0F] rounded-2xl p-6 md:p-8 mb-6">
          <h2 className="font-display text-xl font-bold text-white mb-6">How to apply for a LAP programme</h2>
          <div className="space-y-4">
            {[
              { n:'1', title:'Get your documents ready', desc:'Certified copies of your ID and qualifications (not older than 2 months). Get them certified at your nearest police station or commissioner of oaths — it\'s free.' },
              { n:'2', title:'Get your UIF number', desc:'You need proof that you (or a family member) contributed to UIF. Check at your nearest Department of Labour office or call 0800 843 843.' },
              { n:'3', title:'Build your CV', desc:'A professional CV makes a big difference even for government programmes. Build yours for free using our CV Builder — takes less than 5 minutes.' },
              { n:'4', title:'Apply online or in person', desc:'Each programme has its own application link above. Some accept walk-ins at Dept. of Labour offices. Apply early — spots fill up fast.' },
            ].map(step => (
              <div key={step.n} className="flex gap-4">
                <div className="w-8 h-8 rounded-full bg-[#F5A623] flex items-center justify-center flex-shrink-0 font-bold text-sm text-[#1A1A0F]">{step.n}</div>
                <div>
                  <div className="font-semibold text-white text-sm mb-0.5">{step.title}</div>
                  <div className="text-white/45 text-sm leading-relaxed">{step.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* CTA */}
        <div className="bg-white rounded-2xl border border-black/8 p-6 flex flex-col sm:flex-row items-center justify-between gap-5 shadow-sm">
          <div>
            <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-1">Need a CV to apply?</h3>
            <p className="text-black/40 text-sm">Build a professional CV for free in under 5 minutes.</p>
          </div>
          <a href="/cv" className="btn-amber flex items-center gap-2 whitespace-nowrap">
            Build my CV free <ArrowRight size={15}/>
          </a>
        </div>

        {/* Useful links */}
        <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-3">
          {[
            { title:'Dept. of Employment & Labour', desc:'Official LAP programme info and applications', url:'https://www.labour.gov.za/lap', icon:'🏛️' },
            { title:'SAYouth.mobi', desc:'Free platform to find YES Programme placements', url:'https://www.sayouth.mobi', icon:'📱' },
            { title:'YES4Youth', desc:'Official YES Programme website for youth', url:'https://www.yes4youth.co.za', icon:'💼' },
            { title:'Labour helpline', desc:'Call 0800 843 843 for free LAP assistance', url:'tel:0800843843', icon:'📞' },
          ].map(l => (
            <a key={l.title} href={l.url} target="_blank" rel="noopener noreferrer"
              className="flex items-center gap-4 bg-white rounded-2xl border border-black/8 p-4 hover:border-[#F5A623]/40 hover:shadow-sm transition-all group">
              <span className="text-2xl">{l.icon}</span>
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-sm text-[#1A1A0F] group-hover:text-[#C47D0A] transition-colors">{l.title}</div>
                <div className="text-xs text-black/40 mt-0.5">{l.desc}</div>
              </div>
              <ExternalLink size={14} className="text-black/25 flex-shrink-0"/>
            </a>
          ))}
        </div>
      </div>
    </div>
  )
}
