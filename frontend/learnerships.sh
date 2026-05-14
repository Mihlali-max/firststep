#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📚 Building Learnerships page..."

cat > src/components/pages/Learnerships.tsx << 'EOF'
import { useState, useMemo } from 'react'
import { Search, MapPin, Briefcase, Calendar, ExternalLink, BookmarkPlus, ChevronDown, Filter, X } from 'lucide-react'
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
  logo?: string
  featured?: boolean
  new?: boolean
}

const LEARNERSHIPS: Learnership[] = [
  {
    id:1, title:'Retail Operations Learnership', company:'Shoprite Group', sector:'Retail & FMCG',
    province:'Western Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 500/month',
    duration:'12 months', closing:'30 Jun 2026',
    description:'Learn retail operations, customer service, and stock management at one of South Africa\'s largest retail chains. No prior experience needed — just matric and a willingness to learn.',
    requirements:['Matric / Grade 12','South African citizen','Between 18–35 years','No criminal record'],
    apply_url:'https://www.shopriteholdings.co.za/careers', featured:true, new:true,
  },
  {
    id:2, title:'YES Programme — Customer Service', company:'Standard Bank', sector:'Banking & Finance',
    province:'Gauteng', type:'YES Programme', stipend:'R4 500/month',
    duration:'12 months', closing:'15 Jul 2026',
    description:'The YES (Youth Employment Service) programme at Standard Bank gives you real work experience in banking and customer service. Build your CV with a top financial institution.',
    requirements:['Matric','18–35 years','South African citizen','No work experience needed'],
    apply_url:'https://www.standardbank.co.za/southafrica/business/campaigns/yes-programme', featured:true,
  },
  {
    id:3, title:'ICT Technical Support Learnership', company:'MICT SETA', sector:'IT & Digital',
    province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R3 000/month',
    duration:'12 months', closing:'31 May 2026',
    description:'Technical support and IT fundamentals learnership funded by the MICT SETA. Covers networking basics, hardware, software support, and digital literacy.',
    requirements:['Matric with Maths or Technical subject','Interest in technology','18–35 years','South African citizen'],
    apply_url:'https://www.mict.org.za/learnerships',
  },
  {
    id:4, title:'Banking Operations Learnership', company:'Capitec Bank', sector:'Banking & Finance',
    province:'Western Cape', type:'Learnership', nqf:'NQF Level 4', stipend:'R5 000/month',
    duration:'12 months', closing:'30 Jun 2026',
    description:'Join Capitec\'s award-winning banking team. Learn teller operations, client service, and basic financial advice. One of the most sought-after learnerships in SA.',
    requirements:['Matric with Maths','South African citizen','Clean credit record','18–30 years'],
    apply_url:'https://www.capitecbank.co.za/about-us/careers', featured:true,
  },
  {
    id:5, title:'Journalism & Media Learnership', company:'Media24', sector:'Media & Communications',
    province:'Gauteng', type:'Learnership', nqf:'NQF Level 5', stipend:'R6 000/month',
    duration:'12 months', closing:'01 Aug 2026',
    description:'Media24 offers a comprehensive journalism learnership covering digital writing, video production, social media, and broadcast basics.',
    requirements:['Matric','Passion for writing and media','18–30 years','South African citizen'],
    apply_url:'https://www.media24.com/careers',
  },
  {
    id:6, title:'Transport & Logistics Learnership', company:'TETA', sector:'Transport & Logistics',
    province:'KwaZulu-Natal', type:'Learnership', nqf:'NQF Level 3', stipend:'R2 800/month',
    duration:'12 months', closing:'15 Jun 2026',
    description:'Warehouse operations, logistics coordination, and supply chain basics. TETA-funded learnership for unemployed youth in the transport sector.',
    requirements:['Grade 10 or higher','Valid Code 8 licence (advantageous)','18–35 years','South African citizen'],
    apply_url:'https://www.teta.org.za/learnerships',
  },
  {
    id:7, title:'Agricultural Practices Learnership', company:'AgriSETA', sector:'Agriculture',
    province:'Limpopo', type:'Learnership', nqf:'NQF Level 2', stipend:'R2 500/month',
    duration:'12 months', closing:'30 Jun 2026',
    description:'Practical farming skills learnership covering crop production, irrigation, pest control, and agricultural safety. Accommodation provided at training farm.',
    requirements:['Grade 9 or higher','Interest in farming','18–35 years','South African citizen'],
    apply_url:'https://www.agriseta.co.za/learnerships',
  },
  {
    id:8, title:'Hospitality Services Learnership', company:'CATHSSETA', sector:'Hospitality & Tourism',
    province:'Western Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 200/month',
    duration:'12 months', closing:'31 Jul 2026',
    description:'Front-of-house service, food & beverage, and hospitality operations learnership. Placement at partner hotels and restaurants in the Western Cape.',
    requirements:['Matric','Neat appearance','18–30 years','South African citizen'],
    apply_url:'https://www.cathsseta.org.za/learnerships',
  },
  {
    id:9, title:'Construction Trades Learnership', company:'CETA', sector:'Construction',
    province:'Gauteng', type:'Apprenticeship', nqf:'NQF Level 3', stipend:'R3 800/month',
    duration:'18 months', closing:'15 Jun 2026',
    description:'Hands-on construction skills including bricklaying, plastering, and general building. CETA-accredited qualification with tools and PPE provided.',
    requirements:['Grade 10 or higher','Physical fitness','18–35 years','South African citizen'],
    apply_url:'https://www.ceta.org.za/learnerships',
  },
  {
    id:10, title:'Healthcare Support Learnership', company:'HWSETA', sector:'Healthcare',
    province:'Eastern Cape', type:'Learnership', nqf:'NQF Level 3', stipend:'R3 000/month',
    duration:'12 months', closing:'30 Jun 2026',
    description:'Basic healthcare support, patient care, and community health learnership. Placement at partner clinics and hospitals in the Eastern Cape.',
    requirements:['Matric with Biology (advantageous)','Caring personality','18–35 years','South African citizen'],
    apply_url:'https://www.hwseta.org.za/learnerships',
  },
  {
    id:11, title:'Finance & Accounting Learnership', company:'FASSET', sector:'Banking & Finance',
    province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R4 000/month',
    duration:'12 months', closing:'01 Aug 2026',
    description:'Bookkeeping, payroll, and accounting fundamentals learnership funded by FASSET. Online and in-person delivery. Great for anyone interested in finance.',
    requirements:['Matric with Maths or Accounting','18–35 years','South African citizen'],
    apply_url:'https://www.fasset.org.za/learnerships',
  },
  {
    id:12, title:'Motor Industry Learnership', company:'MERSETA', sector:'Manufacturing',
    province:'Gauteng', type:'Apprenticeship', nqf:'NQF Level 3', stipend:'R3 500/month',
    duration:'24 months', closing:'30 Jun 2026',
    description:'Motor vehicle servicing and repair apprenticeship. Covers diagnostics, engine repair, and electrical systems. Trade test on completion.',
    requirements:['Grade 10 with Maths/Science','Physical fitness','18–30 years','South African citizen'],
    apply_url:'https://www.merseta.org.za/learnerships',
  },
  {
    id:13, title:'Early Childhood Development Learnership', company:'ETDP SETA', sector:'Education',
    province:'All Provinces', type:'Learnership', nqf:'NQF Level 4', stipend:'R2 800/month',
    duration:'12 months', closing:'31 Jul 2026',
    description:'ECD learnership for aspiring teachers and childcare workers. Covers child development theory, lesson planning, and practical classroom experience.',
    requirements:['Matric','Passion for children and education','18–35 years','South African citizen'],
    apply_url:'https://www.etdpseta.org.za/learnerships',
  },
  {
    id:14, title:'Security Industry Learnership', company:'SASSETA', sector:'Security',
    province:'All Provinces', type:'Learnership', nqf:'NQF Level 3', stipend:'R2 500/month',
    duration:'12 months', closing:'15 Jun 2026',
    description:'PSIRA-registered security operations learnership. Covers access control, surveillance, and emergency response. SAPS clearance required.',
    requirements:['Grade 10 or higher','Clean criminal record','18–35 years','South African citizen','PSIRA registration (assisted)'],
    apply_url:'https://www.sasseta.org.za/learnerships',
  },
  {
    id:15, title:'Social Auxiliary Work Learnership', company:'SACSSP', sector:'Social Services',
    province:'Western Cape', type:'Learnership', nqf:'NQF Level 4', stipend:'R3 000/month',
    duration:'12 months', closing:'01 Aug 2026',
    description:'Community development and social auxiliary work learnership. Work alongside social workers in communities, NGOs, and government departments.',
    requirements:['Matric','Passion for community upliftment','18–35 years','South African citizen'],
    apply_url:'https://www.sacssp.co.za/learnerships',
  },
]

const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']
const SECTORS   = ['All Sectors','Retail & FMCG','Banking & Finance','IT & Digital','Media & Communications','Transport & Logistics','Agriculture','Hospitality & Tourism','Construction','Healthcare','Manufacturing','Education','Security','Social Services']
const TYPES     = ['All Types','Learnership','YES Programme','Internship','Apprenticeship','Bursary']

const TYPE_COLORS: Record<string,string> = {
  'Learnership':    'bg-blue-50 text-blue-700 border-blue-200',
  'YES Programme':  'bg-green-50 text-green-700 border-green-200',
  'Internship':     'bg-purple-50 text-purple-700 border-purple-200',
  'Apprenticeship': 'bg-orange-50 text-orange-700 border-orange-200',
  'Bursary':        'bg-pink-50 text-pink-700 border-pink-200',
}

function daysUntil(dateStr: string): number {
  const parts = dateStr.split(' ')
  const months: Record<string,number> = { Jan:0,Feb:1,Mar:2,Apr:3,May:4,Jun:5,Jul:6,Aug:7,Sep:8,Oct:9,Nov:10,Dec:11 }
  const d = new Date(parseInt(parts[2]), months[parts[1]], parseInt(parts[0]))
  return Math.ceil((d.getTime() - Date.now()) / 86400000)
}

function ClosingBadge({ date }: { date: string }) {
  const days = daysUntil(date)
  if (days < 0)   return <span className="text-xs font-semibold text-red-500 bg-red-50 border border-red-200 px-2 py-0.5 rounded-full">Closed</span>
  if (days <= 14) return <span className="text-xs font-semibold text-orange-600 bg-orange-50 border border-orange-200 px-2 py-0.5 rounded-full">Closing soon · {days}d</span>
  return <span className="text-xs font-medium text-black/40">Closes {date}</span>
}

export default function Learnerships() {
  const [search, setSearch]     = useState('')
  const [province, setProvince] = useState('All Provinces')
  const [sector, setSector]     = useState('All Sectors')
  const [type, setType]         = useState('All Types')
  const [expanded, setExpanded] = useState<number | null>(null)
  const [saved, setSaved]       = useState<number[]>([])
  const [showFilters, setShowFilters] = useState(false)

  const filtered = useMemo(() => {
    return LEARNERSHIPS.filter(l => {
      const kw = search.toLowerCase()
      const matchSearch = !kw || l.title.toLowerCase().includes(kw) || l.company.toLowerCase().includes(kw) || l.sector.toLowerCase().includes(kw) || l.description.toLowerCase().includes(kw)
      const matchProv   = province === 'All Provinces' || l.province === province || l.province === 'All Provinces'
      const matchSec    = sector   === 'All Sectors'   || l.sector === sector
      const matchType   = type     === 'All Types'     || l.type   === type
      return matchSearch && matchProv && matchSec && matchType
    }).sort((a,b) => (b.featured?1:0) - (a.featured?1:0))
  }, [search, province, sector, type])

  const hasFilters = province !== 'All Provinces' || sector !== 'All Sectors' || type !== 'All Types'
  const clearFilters = () => { setProvince('All Provinces'); setSector('All Sectors'); setType('All Types') }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Hero */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-10 md:py-14">
        <div className="max-w-4xl mx-auto">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-2">South Africa · 2026</p>
          <h1 className="font-display text-3xl md:text-5xl font-bold text-white tracking-tight leading-tight mb-3">
            Find your <em className="not-italic text-[#F5A623]">learnership.</em>
          </h1>
          <p className="text-white/45 text-sm font-light mb-8 max-w-lg">
            {LEARNERSHIPS.length} real opportunities — learnerships, YES Programme, apprenticeships, and bursaries across South Africa. All no-experience-needed.
          </p>

          {/* Search */}
          <div className="relative">
            <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30"/>
            <input
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search by job, company, or sector…"
              className="w-full bg-white/8 border border-white/15 text-white placeholder:text-white/30 rounded-2xl pl-11 pr-4 py-4 text-sm outline-none focus:bg-white/12 focus:border-white/30 transition-all"
            />
            {search && <button onClick={() => setSearch('')} className="absolute right-4 top-1/2 -translate-y-1/2 text-white/30 hover:text-white"><X size={16}/></button>}
          </div>

          {/* Stats */}
          <div className="flex gap-5 mt-5 flex-wrap">
            {[
              [String(filtered.length), 'opportunities found'],
              [String(LEARNERSHIPS.filter(l=>l.type==='YES Programme').length), 'YES Programme'],
              [String(LEARNERSHIPS.filter(l=>l.stipend).length), 'with stipend'],
              [String(LEARNERSHIPS.filter(l=>l.nqf).length), 'with NQF qualification'],
            ].map(([n,l]) => (
              <div key={l} className="flex items-baseline gap-1.5">
                <span className="font-display text-xl font-bold text-[#F5A623]">{n}</span>
                <span className="text-white/40 text-xs">{l}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-4 md:px-6 py-6">
        {/* Filter bar */}
        <div className="flex gap-2 flex-wrap items-center mb-6">
          {/* Mobile filter toggle */}
          <button onClick={() => setShowFilters(!showFilters)} className={clsx('flex items-center gap-2 text-sm font-semibold px-4 py-2.5 rounded-xl border transition-all md:hidden',showFilters||hasFilters?'bg-[#F5A623] text-[#1A1A0F] border-transparent':'bg-white text-[#1A1A0F] border-black/10')}>
            <Filter size={14}/> Filters {hasFilters && `(${[province!=='All Provinces',sector!=='All Sectors',type!=='All Types'].filter(Boolean).length})`}
          </button>

          {/* Desktop filters */}
          <div className={clsx('flex gap-2 flex-wrap w-full md:w-auto', showFilters ? 'flex' : 'hidden md:flex')}>
            {[
              { value:province, setter:setProvince, options:PROVINCES, placeholder:'Province' },
              { value:sector,   setter:setSector,   options:SECTORS,   placeholder:'Sector' },
              { value:type,     setter:setType,     options:TYPES,     placeholder:'Type' },
            ].map(({ value, setter, options, placeholder }) => (
              <div key={placeholder} className="relative">
                <select
                  value={value}
                  onChange={e => setter(e.target.value)}
                  className={clsx('appearance-none pl-3 pr-8 py-2.5 rounded-xl border text-sm font-medium outline-none transition-all cursor-pointer',
                    value.startsWith('All') ? 'bg-white border-black/10 text-black/60 hover:border-black/25' : 'bg-[#F5A623]/10 border-[#F5A623]/40 text-[#C47D0A]'
                  )}>
                  {options.map(o => <option key={o} value={o}>{o}</option>)}
                </select>
                <ChevronDown size={13} className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-black/40"/>
              </div>
            ))}
            {hasFilters && (
              <button onClick={clearFilters} className="flex items-center gap-1.5 text-sm font-medium text-red-500 hover:text-red-600 px-3 py-2.5 rounded-xl hover:bg-red-50 transition-colors">
                <X size={14}/> Clear
              </button>
            )}
          </div>

          <div className="ml-auto text-sm text-black/40 hidden md:block">
            {filtered.length} result{filtered.length !== 1 ? 's' : ''}
          </div>
        </div>

        {/* Results */}
        {filtered.length === 0 ? (
          <div className="text-center py-20">
            <div className="text-5xl mb-4">🔍</div>
            <h3 className="font-display text-xl font-bold text-[#1A1A0F] mb-2">No results found</h3>
            <p className="text-black/40 text-sm mb-5">Try different search terms or clear the filters.</p>
            <button onClick={() => { setSearch(''); clearFilters() }} className="btn-amber text-sm">Clear all filters</button>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map(l => (
              <div key={l.id} className={clsx('bg-white rounded-2xl border transition-all duration-200 overflow-hidden',
                l.featured ? 'border-[#F5A623]/30 shadow-[0_2px_16px_rgba(245,166,35,0.08)]' : 'border-black/8 hover:border-black/15 hover:shadow-sm'
              )}>
                {/* Card header */}
                <div className="p-5 md:p-6">
                  <div className="flex items-start gap-4">
                    {/* Logo placeholder */}
                    <div className="w-12 h-12 rounded-xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center flex-shrink-0 text-xl font-bold text-[#1A1A0F]/40 text-sm">
                      {l.company[0]}
                    </div>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-3 flex-wrap">
                        <div>
                          <div className="flex items-center gap-2 flex-wrap mb-1">
                            <h3 className="font-display text-base md:text-lg font-bold text-[#1A1A0F] leading-tight">{l.title}</h3>
                            {l.new && <span className="text-[10px] font-bold text-white bg-[#F5A623] px-2 py-0.5 rounded-full">NEW</span>}
                            {l.featured && <span className="text-[10px] font-bold text-[#C47D0A] bg-[#F5A623]/15 border border-[#F5A623]/30 px-2 py-0.5 rounded-full">FEATURED</span>}
                          </div>
                          <div className="text-sm font-semibold text-black/50">{l.company}</div>
                        </div>
                        <button
                          onClick={() => setSaved(s => s.includes(l.id) ? s.filter(x=>x!==l.id) : [...s,l.id])}
                          className={clsx('flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-xl border transition-all flex-shrink-0',
                            saved.includes(l.id) ? 'bg-[#F5A623]/15 border-[#F5A623]/30 text-[#C47D0A]' : 'bg-[#F7F3EB] border-black/8 text-black/40 hover:border-black/20'
                          )}>
                          <BookmarkPlus size={12}/>{saved.includes(l.id) ? 'Saved' : 'Save'}
                        </button>
                      </div>

                      {/* Meta pills */}
                      <div className="flex flex-wrap gap-2 mt-3">
                        <span className={clsx('text-xs font-semibold px-2.5 py-1 rounded-full border', TYPE_COLORS[l.type]||'bg-gray-50 text-gray-600 border-gray-200')}>{l.type}</span>
                        {l.nqf && <span className="text-xs font-medium text-black/50 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8">{l.nqf}</span>}
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><MapPin size={10}/>{l.province}</span>
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><Briefcase size={10}/>{l.sector}</span>
                        {l.stipend && <span className="text-xs font-semibold text-green-700 bg-green-50 border border-green-200 px-2.5 py-1 rounded-full">{l.stipend}</span>}
                        <span className="flex items-center gap-1 text-xs text-black/40 bg-[#F7F3EB] px-2.5 py-1 rounded-full border border-black/8"><Calendar size={10}/>{l.duration}</span>
                      </div>
                    </div>
                  </div>

                  {/* Description preview */}
                  <p className="text-sm text-black/55 mt-4 leading-relaxed line-clamp-2">{l.description}</p>

                  {/* Footer */}
                  <div className="flex items-center justify-between mt-4 pt-4 border-t border-black/6">
                    <ClosingBadge date={l.closing}/>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => setExpanded(expanded === l.id ? null : l.id)}
                        className="text-sm font-semibold text-black/50 hover:text-[#1A1A0F] px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-all">
                        {expanded === l.id ? 'Less info ↑' : 'More info ↓'}
                      </button>
                      <a href={l.apply_url} target="_blank" rel="noopener noreferrer"
                        className="btn-amber flex items-center gap-1.5 !py-2 !px-4 text-sm">
                        Apply now <ExternalLink size={13}/>
                      </a>
                    </div>
                  </div>
                </div>

                {/* Expanded details */}
                {expanded === l.id && (
                  <div className="px-5 md:px-6 pb-6 border-t border-black/6 pt-5 bg-[#FAFAFA]">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <h4 className="font-bold text-sm text-[#1A1A0F] mb-3">About this opportunity</h4>
                        <p className="text-sm text-black/55 leading-relaxed">{l.description}</p>
                      </div>
                      <div>
                        <h4 className="font-bold text-sm text-[#1A1A0F] mb-3">Requirements</h4>
                        <ul className="space-y-2">
                          {l.requirements.map((r,i) => (
                            <li key={i} className="flex items-start gap-2.5 text-sm text-black/55">
                              <div className="w-4 h-4 rounded-full bg-[#F5A623]/20 border border-[#F5A623]/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                                <div className="w-1.5 h-1.5 rounded-full bg-[#F5A623]"/>
                              </div>
                              {r}
                            </li>
                          ))}
                        </ul>
                        <a href={l.apply_url} target="_blank" rel="noopener noreferrer"
                          className="btn-amber flex items-center justify-center gap-2 mt-5 !py-2.5 text-sm">
                          Apply on {l.company}'s website <ExternalLink size={13}/>
                        </a>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Bottom CTA */}
        <div className="mt-10 bg-[#1A1A0F] rounded-2xl p-6 md:p-8 text-center">
          <h3 className="font-display text-xl md:text-2xl font-bold text-white mb-2">Ready to apply?</h3>
          <p className="text-white/45 text-sm mb-5">Build your free professional CV first — it takes less than 5 minutes.</p>
          <a href="/cv" className="btn-amber inline-flex items-center gap-2">Build my CV free →</a>
        </div>
      </div>
    </div>
  )
}
EOF

# Update App.tsx to use real Learnerships page
sed -i "s|import { Login, Register } from './components/pages/Auth'|import { Login, Register } from './components/pages/Auth'\nimport Learnerships from './components/pages/Learnerships'|" src/App.tsx
sed -i "s|<Route path=\"/learnerships\" element={<Soon title=\"Learnerships\" />} />|<Route path=\"/learnerships\" element={<Learnerships />} />|" src/App.tsx

echo "✅ Learnerships page done!"
npm run dev
