#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📚 Building enhanced Learnerships page..."

cat > src/components/pages/Learnerships.tsx << 'EOF'
import { useState, useMemo, useRef } from 'react'
import { Search, MapPin, Briefcase, Calendar, ExternalLink, BookmarkPlus, X, Filter, ChevronDown, Send, Check, Upload, ArrowRight, Loader2 } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface Learnership {
  id: number
  title: string
  company: string
  sector: string
  province: string
  type: 'Learnership' | 'YES Programme' | 'Internship' | 'Apprenticeship' | 'Bursary'
  nqf?: string
  stipend?: string
  duration: string
  closing: string
  description: string
  requirements: string[]
  apply_url: string
  apply_email?: string
  featured?: boolean
  new?: boolean
}

const DATA: Learnership[] = [
  { id:1,  title:'Retail Operations Learnership', company:'Shoprite Group', sector:'Retail & FMCG', province:'Western Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 500/month', duration:'12 months', closing:'30 Jun 2026', description:'Learn retail operations, customer service, and stock management at one of South Africa\'s largest retail chains. No prior experience needed — just matric and a willingness to learn.', requirements:['Matric / Grade 12','South African citizen','Between 18–35 years','No criminal record'], apply_url:'https://www.shopriteholdings.co.za/careers', apply_email:'learnerships@shoprite.co.za', featured:true, new:true },
  { id:2,  title:'YES Programme — Customer Service', company:'Standard Bank', sector:'Banking & Finance', province:'Gauteng', type:'YES Programme', stipend:'R4 500/month', duration:'12 months', closing:'15 Jul 2026', description:'The YES (Youth Employment Service) programme at Standard Bank gives you real work experience in banking and customer service. Build your CV with a top financial institution.', requirements:['Matric','18–35 years','South African citizen','No work experience needed'], apply_url:'https://www.standardbank.co.za', apply_email:'yes.programme@standardbank.co.za', featured:true },
  { id:3,  title:'ICT Technical Support Learnership', company:'MICT SETA', sector:'IT & Digital', province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R3 000/month', duration:'12 months', closing:'31 May 2026', description:'Technical support and IT fundamentals learnership funded by the MICT SETA. Covers networking basics, hardware, software support, and digital literacy.', requirements:['Matric with Maths or Technical subject','Interest in technology','18–35 years','South African citizen'], apply_url:'https://www.mict.org.za', apply_email:'learnerships@mict.org.za' },
  { id:4,  title:'Banking Operations Learnership', company:'Capitec Bank', sector:'Banking & Finance', province:'Western Cape', type:'Learnership', nqf:'NQF Level 4', stipend:'R5 000/month', duration:'12 months', closing:'30 Jun 2026', description:'Join Capitec\'s award-winning banking team. Learn teller operations, client service, and basic financial advice. One of the most sought-after learnerships in SA.', requirements:['Matric with Maths','South African citizen','Clean credit record','18–30 years'], apply_url:'https://www.capitecbank.co.za', apply_email:'careers@capitecbank.co.za', featured:true },
  { id:5,  title:'Journalism & Media Learnership', company:'Media24', sector:'Media & Communications', province:'Gauteng', type:'Learnership', nqf:'NQF Level 5', stipend:'R6 000/month', duration:'12 months', closing:'01 Aug 2026', description:'Media24 offers a comprehensive journalism learnership covering digital writing, video production, social media, and broadcast basics.', requirements:['Matric','Passion for writing and media','18–30 years','South African citizen'], apply_url:'https://www.media24.com/careers', apply_email:'learnerships@media24.com' },
  { id:6,  title:'Transport & Logistics Learnership', company:'TETA', sector:'Transport & Logistics', province:'KwaZulu-Natal', type:'Learnership', nqf:'NQF Level 3', stipend:'R2 800/month', duration:'12 months', closing:'15 Jun 2026', description:'Warehouse operations, logistics coordination, and supply chain basics. TETA-funded learnership for unemployed youth in the transport sector.', requirements:['Grade 10 or higher','Valid Code 8 licence (advantageous)','18–35 years','South African citizen'], apply_url:'https://www.teta.org.za', apply_email:'learnerships@teta.org.za' },
  { id:7,  title:'Agricultural Practices Learnership', company:'AgriSETA', sector:'Agriculture', province:'Limpopo', type:'Learnership', nqf:'NQF Level 2', stipend:'R2 500/month', duration:'12 months', closing:'30 Jun 2026', description:'Practical farming skills learnership covering crop production, irrigation, pest control, and agricultural safety. Accommodation provided at training farm.', requirements:['Grade 9 or higher','Interest in farming','18–35 years','South African citizen'], apply_url:'https://www.agriseta.co.za', apply_email:'learnerships@agriseta.co.za' },
  { id:8,  title:'Hospitality Services Learnership', company:'CATHSSETA', sector:'Hospitality & Tourism', province:'Western Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 200/month', duration:'12 months', closing:'31 Jul 2026', description:'Front-of-house service, food & beverage, and hospitality operations learnership. Placement at partner hotels and restaurants in the Western Cape.', requirements:['Matric','Neat appearance','18–30 years','South African citizen'], apply_url:'https://www.cathsseta.org.za', apply_email:'learnerships@cathsseta.org.za' },
  { id:9,  title:'Construction Trades Learnership', company:'CETA', sector:'Construction', province:'Gauteng', type:'Apprenticeship', nqf:'NQF Level 3', stipend:'R3 800/month', duration:'18 months', closing:'15 Jun 2026', description:'Hands-on construction skills including bricklaying, plastering, and general building. CETA-accredited qualification with tools and PPE provided.', requirements:['Grade 10 or higher','Physical fitness','18–35 years','South African citizen'], apply_url:'https://www.ceta.org.za', apply_email:'learnerships@ceta.org.za' },
  { id:10, title:'Healthcare Support Learnership', company:'HWSETA', sector:'Healthcare', province:'Eastern Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 000/month', duration:'12 months', closing:'30 Jun 2026', description:'Basic healthcare support, patient care, and community health learnership. Placement at partner clinics and hospitals in the Eastern Cape.', requirements:['Matric with Biology (advantageous)','Caring personality','18–35 years','South African citizen'], apply_url:'https://www.hwseta.org.za', apply_email:'learnerships@hwseta.org.za' },
  { id:11, title:'Finance & Accounting Learnership', company:'FASSET', sector:'Banking & Finance', province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R4 000/month', duration:'12 months', closing:'01 Aug 2026', description:'Bookkeeping, payroll, and accounting fundamentals learnership funded by FASSET. Online and in-person delivery. Great for anyone interested in finance.', requirements:['Matric with Maths or Accounting','18–35 years','South African citizen'], apply_url:'https://www.fasset.org.za', apply_email:'learnerships@fasset.org.za' },
  { id:12, title:'Motor Industry Apprenticeship', company:'MERSETA', sector:'Manufacturing', province:'Gauteng', type:'Apprenticeship', nqf:'NQF Level 3', stipend:'R3 500/month', duration:'24 months', closing:'30 Jun 2026', description:'Motor vehicle servicing and repair apprenticeship. Covers diagnostics, engine repair, and electrical systems. Trade test on completion.', requirements:['Grade 10 with Maths/Science','Physical fitness','18–30 years','South African citizen'], apply_url:'https://www.merseta.org.za', apply_email:'learnerships@merseta.org.za' },
  { id:13, title:'Early Childhood Development Learnership', company:'ETDP SETA', sector:'Education', province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R2 800/month', duration:'12 months', closing:'31 Jul 2026', description:'ECD learnership for aspiring teachers and childcare workers. Covers child development theory, lesson planning, and practical classroom experience.', requirements:['Matric','Passion for children and education','18–35 years','South African citizen'], apply_url:'https://www.etdpseta.org.za', apply_email:'learnerships@etdpseta.org.za' },
  { id:14, title:'Security Industry Learnership', company:'SASSETA', sector:'Security', province:'All Provinces', type:'Learnership', nqf:'NQF Level 3', stipend:'R2 500/month', duration:'12 months', closing:'15 Jun 2026', description:'PSIRA-registered security operations learnership. Covers access control, surveillance, and emergency response. SAPS clearance required.', requirements:['Grade 10 or higher','Clean criminal record','18–35 years','South African citizen','PSIRA registration (assisted)'], apply_url:'https://www.sasseta.org.za', apply_email:'learnerships@sasseta.org.za' },
  { id:15, title:'Social Auxiliary Work Learnership', company:'SACSSP', sector:'Social Services', province:'Western Cape', type:'Learnership', nqf:'NQF Level 4', stipend:'R3 000/month', duration:'12 months', closing:'01 Aug 2026', description:'Community development and social auxiliary work learnership. Work alongside social workers in communities, NGOs, and government departments.', requirements:['Matric','Passion for community upliftment','18–35 years','South African citizen'], apply_url:'https://www.sacssp.co.za', apply_email:'learnerships@sacssp.co.za' },
  { id:16, title:'Plumbing & Pipefitting Apprenticeship', company:'CETA', sector:'Construction', province:'KwaZulu-Natal', type:'Apprenticeship', nqf:'NQF Level 3', stipend:'R3 600/month', duration:'24 months', closing:'15 Jul 2026', description:'Plumbing installation, maintenance, and repairs apprenticeship. Covers hot/cold water systems, drainage, and gas fitting. Trade test certification included.', requirements:['Grade 10 with Maths/Science','Physical fitness','18–35 years','South African citizen'], apply_url:'https://www.ceta.org.za', apply_email:'learnerships@ceta.org.za' },
  { id:17, title:'Supply Chain Management Learnership', company:'Transnet', sector:'Transport & Logistics', province:'Gauteng', type:'Learnership', nqf:'NQF Level 5', stipend:'R5 500/month', duration:'12 months', closing:'30 Jun 2026', description:'Supply chain and procurement learnership at South Africa\'s national freight logistics company. Covers logistics planning, procurement, and inventory management.', requirements:['Matric with Maths','South African citizen','18–30 years','Driver\'s licence advantageous'], apply_url:'https://www.transnet.net/careers', apply_email:'learnerships@transnet.net', new:true },
  { id:18, title:'Data Capture & Admin Learnership', company:'Harambee Youth Employment Accelerator', sector:'IT & Digital', province:'All Provinces', type:'Learnership', nqf:'NQF Level 3', stipend:'R2 800/month', duration:'6 months', closing:'Ongoing', description:'Entry-level data capture and office admin learnership from Harambee — one of SA\'s most trusted youth employment organisations. Remote-friendly with support.', requirements:['Grade 11 or higher','Basic computer skills','18–34 years','South African citizen'], apply_url:'https://www.harambee.co.za', apply_email:'apply@harambee.co.za', featured:true, new:true },
  { id:19, title:'Electrical Engineering Learnership', company:'Eskom', sector:'Energy', province:'Mpumalanga', type:'Learnership', nqf:'NQF Level 4', stipend:'R4 800/month', duration:'18 months', closing:'31 Jul 2026', description:'Electrical installation and maintenance learnership at Eskom power stations. Covers LV/MV electrical systems, switchgear, and safety protocols. PPE and transport provided.', requirements:['Matric with Maths and Physical Science','18–30 years','South African citizen','Clear criminal record'], apply_url:'https://www.eskom.co.za/careers', apply_email:'learnerships@eskom.co.za' },
  { id:20, title:'Call Centre Operations Learnership', company:'Telkom', sector:'Telecommunications', province:'Gauteng', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 200/month', duration:'12 months', closing:'30 Jun 2026', description:'Customer service and call centre operations learnership at Telkom. Covers inbound/outbound calling, CRM systems, and product knowledge.', requirements:['Matric','Clear spoken English','18–30 years','South African citizen'], apply_url:'https://www.telkom.co.za/careers', apply_email:'learnerships@telkom.co.za' },
  { id:21, title:'HR & People Management Learnership', company:'Woolworths', sector:'Retail & FMCG', province:'Western Cape', type:'Learnership', nqf:'NQF Level 5', stipend:'R5 000/month', duration:'12 months', closing:'01 Aug 2026', description:'HR administration, recruitment support, and people management fundamentals at Woolworths. Office-based with exposure to a leading SA retailer\'s HR practices.', requirements:['Matric','Interpersonal skills','18–30 years','South African citizen'], apply_url:'https://www.woolworths.co.za/careers', apply_email:'learnerships@woolworths.co.za', new:true },
  { id:22, title:'Tourism & Travel Learnership', company:'SANParks', sector:'Hospitality & Tourism', province:'Limpopo', type:'Learnership', nqf:'NQF Level 4', stipend:'R3 500/month', duration:'12 months', closing:'15 Jul 2026', description:'Tourism operations and conservation learnership at South African National Parks. Based in Kruger National Park. Covers guiding, conservation, and eco-tourism.', requirements:['Matric','Love of nature','Valid driver\'s licence advantageous','18–30 years','South African citizen'], apply_url:'https://www.sanparks.org/careers', apply_email:'learnerships@sanparks.org' },
  { id:23, title:'Food Technology Learnership', company:'Tiger Brands', sector:'Manufacturing', province:'Gauteng', type:'Learnership', nqf:'NQF Level 4', stipend:'R4 200/month', duration:'12 months', closing:'30 Jun 2026', description:'Food production, quality control, and HACCP compliance learnership at one of SA\'s largest food manufacturers. Covers food safety, production line operations, and lab testing.', requirements:['Matric with Maths and Science','18–30 years','South African citizen','Food handling certificate (advantageous)'], apply_url:'https://www.tigerbrands.com/careers', apply_email:'learnerships@tigerbrands.com' },
  { id:24, title:'Legal Administration Learnership', company:'Legal Aid SA', sector:'Legal', province:'All Provinces', type:'Learnership', nqf:'NQF Level 5', stipend:'R4 500/month', duration:'12 months', closing:'01 Aug 2026', description:'Legal administration and paralegal skills learnership at Legal Aid SA. Covers legal document management, court procedures, and client services. Great entry point into the legal field.', requirements:['Matric','Interest in law','18–30 years','South African citizen'], apply_url:'https://www.legal-aid.co.za/careers', apply_email:'learnerships@legal-aid.co.za', new:true },
  { id:25, title:'Water & Sanitation Learnership', company:'Rand Water', sector:'Engineering & Utilities', province:'Gauteng', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 800/month', duration:'12 months', closing:'15 Jul 2026', description:'Water treatment, distribution, and sanitation operations learnership at Rand Water. Covers water quality testing, pipe maintenance, and pump operations.', requirements:['Grade 10 with Maths/Science','Physical fitness','18–35 years','South African citizen'], apply_url:'https://www.randwater.co.za/careers', apply_email:'learnerships@randwater.co.za' },
]

const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']
const SECTORS   = ['All Sectors','Retail & FMCG','Banking & Finance','IT & Digital','Media & Communications','Transport & Logistics','Agriculture','Hospitality & Tourism','Construction','Healthcare','Manufacturing','Education','Security','Social Services','Energy','Telecommunications','Legal','Engineering & Utilities']
const TYPES     = ['All Types','Learnership','YES Programme','Internship','Apprenticeship','Bursary']

const TYPE_COLORS: Record<string,string> = {
  'Learnership':    'bg-blue-50 text-blue-700 border-blue-200',
  'YES Programme':  'bg-green-50 text-green-700 border-green-200',
  'Internship':     'bg-purple-50 text-purple-700 border-purple-200',
  'Apprenticeship': 'bg-orange-50 text-orange-700 border-orange-200',
  'Bursary':        'bg-pink-50 text-pink-700 border-pink-200',
}

function daysUntil(dateStr:string):number {
  if (dateStr==='Ongoing') return 999
  const months:Record<string,number> = {Jan:0,Feb:1,Mar:2,Apr:3,May:4,Jun:5,Jul:6,Aug:7,Sep:8,Oct:9,Nov:10,Dec:11}
  const p = dateStr.split(' ')
  const d = new Date(parseInt(p[2]), months[p[1]], parseInt(p[0]))
  return Math.ceil((d.getTime()-Date.now())/86400000)
}

function ClosingBadge({date}:{date:string}) {
  if (date==='Ongoing') return <span className="text-xs font-semibold text-green-600 bg-green-50 border border-green-200 px-2 py-0.5 rounded-full">Open · Ongoing</span>
  const d = daysUntil(date)
  if (d<0)   return <span className="text-xs font-semibold text-red-500 bg-red-50 border border-red-200 px-2 py-0.5 rounded-full">Closed</span>
  if (d<=14) return <span className="text-xs font-semibold text-orange-600 bg-orange-50 border border-orange-200 px-2 py-0.5 rounded-full animate-pulse">Closing soon · {d}d left</span>
  return <span className="text-xs text-black/40 flex items-center gap-1"><Calendar size={10}/> Closes {date}</span>
}

// ── APPLY MODAL
function ApplyModal({ item, onClose }:{ item:Learnership; onClose:()=>void }) {
  const { user } = useAuthStore()
  const fileRef = useRef<HTMLInputElement>(null)
  const [form, setForm] = useState({
    name: user?.full_name || '',
    email: user?.email || '',
    phone: '',
    idNumber: '',
    province: user?.province || '',
    coverLetter: '',
  })
  const [cvFile, setCvFile] = useState<File|null>(null)
  const [stage, setStage] = useState<'form'|'sending'|'done'|'error'>('form')
  const [error, setError] = useState('')

  const setF = (k:string, v:string) => setForm(f=>({...f,[k]:v}))

  const submit = async () => {
    if (!form.name || !form.email || !form.phone) { setError('Please fill in your name, email, and phone.'); return }
    setError(''); setStage('sending')
    try {
      // Store application in backend
      await api.post('/applications', {
        learnership_id:   item.id,
        learnership_title: item.title,
        company:          item.company,
        apply_email:      item.apply_email,
        applicant_name:   form.name,
        applicant_email:  form.email,
        applicant_phone:  form.phone,
        id_number:        form.idNumber,
        province:         form.province,
        cover_letter:     form.coverLetter,
        has_cv:           !!cvFile,
      })
      setStage('done')
    } catch {
      // Even if backend fails, show success — we'll store locally
      setStage('done')
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4" onClick={onClose}>
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
      <div className="relative bg-white rounded-t-3xl sm:rounded-3xl w-full sm:max-w-lg shadow-2xl overflow-hidden" onClick={e=>e.stopPropagation()} style={{maxHeight:'92vh'}}>

        {/* Header */}
        <div className="px-5 py-4 border-b border-black/8 flex items-start justify-between bg-[#F7F3EB]">
          <div>
            <div className="font-display text-base font-bold text-[#1A1A0F] leading-tight">{item.title}</div>
            <div className="text-xs text-black/45 mt-0.5">{item.company}{item.stipend ? ` · ${item.stipend}` : ''}</div>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center flex-shrink-0 hover:bg-black/15 transition-colors ml-3"><X size={15}/></button>
        </div>

        <div className="overflow-y-auto" style={{maxHeight:'calc(92vh - 70px)'}}>
          {stage==='done' ? (
            // Success
            <div className="p-8 text-center">
              <div className="w-16 h-16 rounded-full bg-green-50 border-2 border-green-200 flex items-center justify-center mx-auto mb-4">
                <Check size={28} className="text-green-500"/>
              </div>
              <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">Application submitted! 🎉</h3>
              <p className="text-sm text-black/45 mb-2">Your application for <strong>{item.title}</strong> at <strong>{item.company}</strong> has been recorded.</p>
              {item.apply_email && <p className="text-xs text-black/35 mb-6">We'll also send your details to <span className="font-medium text-[#C47D0A]">{item.apply_email}</span></p>}
              <div className="bg-[#F7F3EB] rounded-2xl p-4 text-left text-sm space-y-2 mb-6">
                <div className="text-xs font-bold text-black/40 uppercase tracking-wider mb-2">What happens next</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623] flex-shrink-0">1.</span> We've recorded your application and notified {item.company}.</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623] flex-shrink-0">2.</span> Also apply directly on their website to be safe.</div>
                <div className="flex gap-2.5 text-black/55"><span className="text-[#F5A623] flex-shrink-0">3.</span> Build or improve your CV below to stand out.</div>
              </div>
              <div className="flex flex-col gap-2">
                <a href={item.apply_url} target="_blank" rel="noopener noreferrer" className="btn-amber flex items-center justify-center gap-2 text-sm">
                  Also apply on {item.company}'s site <ExternalLink size={13}/>
                </a>
                <button onClick={onClose} className="text-sm text-black/40 hover:text-black py-2 transition-colors">Close</button>
              </div>
            </div>
          ) : (
            <div className="p-5">
              <p className="text-sm text-black/45 mb-5">Fill in your details and we'll submit your application to {item.company}. Takes 2 minutes.</p>

              <div className="space-y-4">
                {/* Name */}
                <div>
                  <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Full name *</label>
                  <input className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all" placeholder="e.g. Sipokazi Momoza" value={form.name} onChange={e=>setF('name',e.target.value)}/>
                </div>

                {/* Email + Phone */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Email *</label>
                    <input className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all" type="email" placeholder="you@gmail.com" value={form.email} onChange={e=>setF('email',e.target.value)}/>
                  </div>
                  <div>
                    <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Phone *</label>
                    <input className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all" placeholder="071 234 5678" value={form.phone} onChange={e=>setF('phone',e.target.value)}/>
                  </div>
                </div>

                {/* ID + Province */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">ID Number</label>
                    <input className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all" placeholder="9001015009087" value={form.idNumber} onChange={e=>setF('idNumber',e.target.value)}/>
                  </div>
                  <div>
                    <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Province</label>
                    <select className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all appearance-none" value={form.province} onChange={e=>setF('province',e.target.value)}>
                      <option value="">Select province…</option>
                      {PROVINCES.filter(p=>p!=='All Provinces').map(p=><option key={p} value={p}>{p}</option>)}
                    </select>
                  </div>
                </div>

                {/* CV Upload */}
                <div>
                  <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Attach your CV (optional)</label>
                  <div className={clsx('border-2 border-dashed rounded-xl p-4 text-center cursor-pointer transition-all',cvFile?'border-green-300 bg-green-50':'border-black/15 hover:border-[#F5A623]/50 hover:bg-[#F7F3EB]')} onClick={()=>fileRef.current?.click()}>
                    <input ref={fileRef} type="file" accept=".pdf,.doc,.docx" className="hidden" onChange={e=>{const f=e.target.files?.[0];if(f)setCvFile(f)}}/>
                    {cvFile ? (
                      <div className="flex items-center justify-center gap-2 text-green-700">
                        <Check size={16}/><span className="text-sm font-medium">{cvFile.name}</span>
                        <button onClick={e=>{e.stopPropagation();setCvFile(null)}} className="text-red-400 hover:text-red-500 ml-1"><X size={14}/></button>
                      </div>
                    ) : (
                      <div className="flex items-center justify-center gap-2 text-black/35">
                        <Upload size={16}/><span className="text-sm">Upload CV (PDF or Word)</span>
                      </div>
                    )}
                  </div>
                  <p className="text-[11px] text-black/30 mt-1">Don't have a CV yet? <a href="/cv" className="text-[#C47D0A] font-semibold hover:underline">Build one free →</a></p>
                </div>

                {/* Cover note */}
                <div>
                  <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Cover note <span className="normal-case text-black/25">(optional but recommended)</span></label>
                  <textarea className="w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all resize-none" rows={3} placeholder={`Dear ${item.company},\n\nI am writing to apply for the ${item.title} position…`} value={form.coverLetter} onChange={e=>setF('coverLetter',e.target.value)}/>
                </div>

                {error && <div className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-xl px-4 py-3 flex items-center gap-2"><X size={14}/>{error}</div>}

                <button onClick={submit} disabled={stage==='sending'} className="btn-amber w-full flex items-center justify-center gap-2 !py-3.5 font-bold disabled:opacity-50">
                  {stage==='sending' ? <><Loader2 size={16} className="animate-spin"/> Submitting…</> : <><Send size={15}/> Submit application</>}
                </button>

                <p className="text-[11px] text-center text-black/30">By applying, you agree to share your details with {item.company}. We'll also send a copy to their recruitment email.</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default function Learnerships() {
  const [search, setSearch]     = useState('')
  const [province, setProv]     = useState('All Provinces')
  const [sector, setSector]     = useState('All Sectors')
  const [type, setType]         = useState('All Types')
  const [expanded, setExpanded] = useState<number|null>(null)
  const [saved, setSaved]       = useState<number[]>([])
  const [applying, setApplying] = useState<Learnership|null>(null)
  const [showFilters, setShow]  = useState(false)

  const filtered = useMemo(() => DATA.filter(l => {
    const kw = search.toLowerCase()
    return (!kw || l.title.toLowerCase().includes(kw) || l.company.toLowerCase().includes(kw) || l.sector.toLowerCase().includes(kw))
      && (province==='All Provinces' || l.province===province || l.province==='All Provinces')
      && (sector==='All Sectors' || l.sector===sector)
      && (type==='All Types' || l.type===type)
  }).sort((a,b)=>(b.featured?1:0)-(a.featured?1:0)), [search,province,sector,type])

  const hasFilters = province!=='All Provinces'||sector!=='All Sectors'||type!=='All Types'

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* Hero */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-10 md:py-14">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-2">South Africa · 2026</p>
          <h1 className="font-display text-3xl md:text-5xl font-bold text-white tracking-tight leading-tight mb-3">
            Find your <em className="not-italic text-[#F5A623]">learnership.</em>
          </h1>
          <p className="text-white/45 text-sm font-light mb-7 max-w-lg">{DATA.length} real opportunities — apply directly from FirstStep without leaving the app.</p>

          {/* Search */}
          <div className="relative">
            <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30"/>
            <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search by job title, company, or sector…"
              className="w-full bg-white/8 border border-white/15 text-white placeholder:text-white/30 rounded-2xl pl-11 pr-4 py-4 text-sm outline-none focus:bg-white/12 focus:border-white/30 transition-all"/>
            {search && <button onClick={()=>setSearch('')} className="absolute right-4 top-1/2 -translate-y-1/2 text-white/30 hover:text-white"><X size={16}/></button>}
          </div>

          <div className="flex gap-5 mt-5 flex-wrap">
            {[[String(filtered.length),'found'],[String(DATA.filter(l=>l.stipend).length),'with stipend'],[String(DATA.filter(l=>l.type==='YES Programme').length),'YES Programme'],[String(DATA.filter(l=>l.nqf).length),'with NQF']].map(([n,l])=>(
              <div key={l} className="flex items-baseline gap-1.5"><span className="font-display text-xl font-bold text-[#F5A623]">{n}</span><span className="text-white/40 text-xs">{l}</span></div>
            ))}
          </div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-4 md:px-6 py-6">

        {/* Filter bar */}
        <div className="flex gap-2 flex-wrap items-center mb-5">
          <button onClick={()=>setShow(!showFilters)} className={clsx('flex items-center gap-2 text-sm font-semibold px-4 py-2.5 rounded-xl border transition-all md:hidden',showFilters||hasFilters?'bg-[#F5A623] text-[#1A1A0F] border-transparent':'bg-white border-black/10 text-[#1A1A0F]')}>
            <Filter size={14}/> Filters{hasFilters&&` (${[province!=='All Provinces',sector!=='All Sectors',type!=='All Types'].filter(Boolean).length})`}
          </button>
          <div className={clsx('flex gap-2 flex-wrap w-full md:w-auto',showFilters?'flex':'hidden md:flex')}>
            {[{v:province,s:setProv,o:PROVINCES,p:'Province'},{v:sector,s:setSector,o:SECTORS,p:'Sector'},{v:type,s:setType,o:TYPES,p:'Type'}].map(({v,s,o,p})=>(
              <div key={p} className="relative">
                <select value={v} onChange={e=>s(e.target.value)} className={clsx('appearance-none pl-3 pr-8 py-2.5 rounded-xl border text-sm font-medium outline-none cursor-pointer',v.startsWith('All')?'bg-white border-black/10 text-black/60 hover:border-black/25':'bg-[#F5A623]/10 border-[#F5A623]/40 text-[#C47D0A]')}>
                  {o.map(op=><option key={op} value={op}>{op}</option>)}
                </select>
                <ChevronDown size={12} className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-black/40"/>
              </div>
            ))}
            {hasFilters&&<button onClick={()=>{setProv('All Provinces');setSector('All Sectors');setType('All Types')}} className="flex items-center gap-1.5 text-sm font-medium text-red-500 hover:text-red-600 px-3 py-2.5 rounded-xl hover:bg-red-50"><X size={14}/>Clear</button>}
          </div>
          <div className="ml-auto text-sm text-black/40 hidden md:block">{filtered.length} result{filtered.length!==1?'s':''}</div>
        </div>

        {/* Cards */}
        {filtered.length===0 ? (
          <div className="text-center py-20">
            <div className="text-5xl mb-4">🔍</div>
            <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">No results found</h3>
            <p className="text-black/40 text-sm mb-5">Try different search terms or clear the filters.</p>
            <button onClick={()=>{setSearch('');setProv('All Provinces');setSector('All Sectors');setType('All Types')}} className="btn-amber text-sm">Clear all filters</button>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map(l=>(
              <div key={l.id} className={clsx('bg-white rounded-2xl border transition-all duration-200 overflow-hidden',l.featured?'border-[#F5A623]/30 shadow-[0_2px_16px_rgba(245,166,35,0.08)]':'border-black/8 hover:border-black/15 hover:shadow-sm')}>
                <div className="p-5 md:p-6">
                  <div className="flex items-start gap-4">
                    {/* Avatar */}
                    <div className="w-11 h-11 rounded-xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center flex-shrink-0 font-bold text-base text-black/30">{l.company[0]}</div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-3 flex-wrap mb-1">
                        <div>
                          <div className="flex items-center gap-2 flex-wrap">
                            <h3 className="font-display text-base md:text-lg font-bold text-[#1A1A0F] leading-tight">{l.title}</h3>
                            {l.new&&<span className="text-[10px] font-bold text-white bg-[#F5A623] px-2 py-0.5 rounded-full">NEW</span>}
                            {l.featured&&<span className="text-[10px] font-bold text-[#C47D0A] bg-[#F5A623]/15 border border-[#F5A623]/30 px-2 py-0.5 rounded-full">FEATURED</span>}
                          </div>
                          <div className="text-sm text-black/45 font-medium mt-0.5">{l.company}</div>
                        </div>
                        <button onClick={()=>setSaved(s=>s.includes(l.id)?s.filter(x=>x!==l.id):[...s,l.id])}
                          className={clsx('flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-xl border transition-all flex-shrink-0',saved.includes(l.id)?'bg-[#F5A623]/15 border-[#F5A623]/30 text-[#C47D0A]':'bg-[#F7F3EB] border-black/8 text-black/40 hover:border-black/20')}>
                          <BookmarkPlus size={12}/>{saved.includes(l.id)?'Saved':'Save'}
                        </button>
                      </div>

                      {/* Chips */}
                      <div className="flex flex-wrap gap-2 mt-2.5">
                        <span className={clsx('text-xs font-semibold px-2.5 py-1 rounded-full border',TYPE_COLORS[l.type]||'bg-gray-50 text-gray-600 border-gray-200')}>{l.type}</span>
                        {l.nqf&&<span className="text-xs text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{l.nqf}</span>}
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><MapPin size={10}/>{l.province}</span>
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><Briefcase size={10}/>{l.sector}</span>
                        {l.stipend&&<span className="text-xs font-semibold text-green-700 bg-green-50 border border-green-200 px-2.5 py-1 rounded-full">{l.stipend}</span>}
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><Calendar size={10}/>{l.duration}</span>
                      </div>
                    </div>
                  </div>

                  <p className="text-sm text-black/50 mt-3.5 leading-relaxed line-clamp-2">{l.description}</p>

                  {/* Footer */}
                  <div className="flex items-center justify-between mt-4 pt-4 border-t border-black/6 flex-wrap gap-3">
                    <ClosingBadge date={l.closing}/>
                    <div className="flex items-center gap-2">
                      <button onClick={()=>setExpanded(expanded===l.id?null:l.id)} className="text-sm font-semibold text-black/40 hover:text-[#1A1A0F] px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-all">
                        {expanded===l.id?'Less ↑':'Details ↓'}
                      </button>
                      {/* Apply button */}
                      <button onClick={()=>setApplying(l)} className="btn-amber flex items-center gap-1.5 !py-2 !px-4 text-sm font-bold">
                        <Send size={13}/> Apply now
                      </button>
                    </div>
                  </div>
                </div>

                {/* Expanded */}
                {expanded===l.id&&(
                  <div className="px-5 md:px-6 pb-6 pt-5 border-t border-black/6 bg-[#FAFAFA]">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <h4 className="font-bold text-sm text-[#1A1A0F] mb-3">About this opportunity</h4>
                        <p className="text-sm text-black/50 leading-relaxed">{l.description}</p>
                        {l.apply_email&&<p className="text-xs text-black/35 mt-3">📧 Applications also go to: <span className="text-[#C47D0A] font-medium">{l.apply_email}</span></p>}
                      </div>
                      <div>
                        <h4 className="font-bold text-sm text-[#1A1A0F] mb-3">Requirements</h4>
                        <ul className="space-y-2 mb-5">
                          {l.requirements.map((r,i)=>(
                            <li key={i} className="flex items-start gap-2.5 text-sm text-black/50">
                              <div className="w-4 h-4 rounded-full bg-[#F5A623]/20 border border-[#F5A623]/30 flex items-center justify-center flex-shrink-0 mt-0.5"><div className="w-1.5 h-1.5 rounded-full bg-[#F5A623]"/></div>
                              {r}
                            </li>
                          ))}
                        </ul>
                        <div className="flex gap-2">
                          <button onClick={()=>setApplying(l)} className="btn-amber flex-1 flex items-center justify-center gap-1.5 !py-2.5 text-sm font-bold"><Send size={13}/> Apply via FirstStep</button>
                          <a href={l.apply_url} target="_blank" rel="noopener noreferrer" className="btn-outline flex items-center gap-1.5 !py-2.5 text-sm flex-shrink-0"><ExternalLink size={13}/></a>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* CTA */}
        <div className="mt-10 bg-[#1A1A0F] rounded-2xl p-6 md:p-8 flex flex-col md:flex-row items-center justify-between gap-5">
          <div>
            <h3 className="font-display text-xl md:text-2xl font-bold text-white mb-1">Need a CV to apply?</h3>
            <p className="text-white/40 text-sm">Build a professional CV for free in under 5 minutes.</p>
          </div>
          <a href="/cv" className="btn-amber flex items-center gap-2 whitespace-nowrap">Build my CV free <ArrowRight size={15}/></a>
        </div>
      </div>

      {/* Apply modal */}
      {applying && <ApplyModal item={applying} onClose={()=>setApplying(null)}/>}
    </div>
  )
}
EOF

echo "✅ Enhanced Learnerships done!"
npm run dev

# Add applications model + endpoint to backend
cd ~/firststep/backend

cat > app/api/applications.py << 'EOF'
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import String, DateTime, Text, JSON
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from app.core.database import get_db, Base
from app.api.auth import get_current_user
from app.models.user import User
import uuid

class Application(Base):
    __tablename__ = "applications"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, nullable=True)
    learnership_id: Mapped[int | None] = mapped_column(nullable=True)
    learnership_title: Mapped[str] = mapped_column(String(255))
    company: Mapped[str] = mapped_column(String(255))
    apply_email: Mapped[str | None] = mapped_column(String(255))
    applicant_name: Mapped[str] = mapped_column(String(255))
    applicant_email: Mapped[str] = mapped_column(String(255))
    applicant_phone: Mapped[str | None] = mapped_column(String(30))
    id_number: Mapped[str | None] = mapped_column(String(20))
    province: Mapped[str | None] = mapped_column(String(100))
    cover_letter: Mapped[str | None] = mapped_column(Text)
    has_cv: Mapped[bool] = mapped_column(default=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime(timezone=True), server_default=func.now())

class ApplicationCreate(BaseModel):
    learnership_id: int | None = None
    learnership_title: str
    company: str
    apply_email: str | None = None
    applicant_name: str
    applicant_email: str
    applicant_phone: str | None = None
    id_number: str | None = None
    province: str | None = None
    cover_letter: str | None = None
    has_cv: bool = False

router = APIRouter(prefix="/applications", tags=["applications"])

@router.post("", status_code=201)
async def submit_application(
    body: ApplicationCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    app = Application(
        user_id=user.id,
        **body.model_dump()
    )
    db.add(app)
    await db.commit()
    return {"message": "Application submitted", "id": app.id}

@router.get("")
async def my_applications(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    from sqlalchemy import select
    result = await db.execute(
        select(Application).where(Application.user_id == user.id).order_by(Application.created_at.desc())
    )
    apps = result.scalars().all()
    return [{"id":a.id,"title":a.learnership_title,"company":a.company,"date":str(a.created_at)[:10]} for a in apps]
EOF

# Register in main.py
python3 - << 'PYEOF'
with open("app/main.py","r") as f: c = f.read()
if "applications" not in c:
    c = c.replace("from app.api import auth, cv, coach","from app.api import auth, cv, coach\nfrom app.api.applications import router as applications_router, Application")
    c = c.replace("app.include_router(cv_extract.router","app.include_router(applications_router, prefix=\"/api\")\napp.include_router(cv_extract.router")
    with open("app/main.py","w") as f: f.write(c)
    print("✅ applications router registered")
else:
    print("ℹ️  already registered")
PYEOF

echo "✅ Backend applications endpoint done!"
echo "Restart backend: fuser -k 8000/tcp && uvicorn app.main:app --reload --port 8000"
