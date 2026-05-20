import { Link } from 'react-router-dom'
const COLS = [
  { title: 'Platform', links: [['CV Builder','/cv'],['AI Coach','/coach'],['Opportunities','/learnerships'],['LAP Programmes','/lap']] },
  { title: 'Company', links: [['About us','/about'],['For Recruiters','/recruiters'],['Contact','/contact'],['Partners','/about#partners']] },
  { title: 'Legal', links: [['Privacy Policy','/privacy'],['Terms of Use','/terms']] },
]
export default function Footer() {
  return (
    <footer className="bg-[#1A1A0F] text-[#FFFDF7]/50 pt-12 pb-6 border-t border-[#FFFDF7]/7">
      <div className="max-w-6xl mx-auto px-8 md:px-12">
        <div className="flex flex-wrap justify-between gap-10 mb-12">
          <div>
            <Link to="/" className="font-display text-2xl font-bold text-[#FFFDF7] tracking-tight">First<span className="text-[#F5A623]">Step</span></Link>
            <p className="text-sm font-light text-[#FFFDF7]/40 mt-2">Your first job starts here. Free, always.</p>
          </div>
          <div className="flex flex-wrap gap-12">
            {COLS.map(col => (
              <div key={col.title}>
                <p className="text-[10px] font-medium tracking-[3px] uppercase text-[#F5A623] mb-3">{col.title}</p>
                <ul className="space-y-2">
                  {col.links.map(([label, to]) => (
                    <li key={label}><Link to={to} className="text-sm font-light text-[#FFFDF7]/45 hover:text-[#FFFDF7] transition-colors">{label}</Link></li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
        <div className="border-t border-[#FFFDF7]/7 pt-5 flex flex-wrap justify-between gap-3">
          <p className="text-xs text-[#FFFDF7]/30">&copy; 2026 FirstStep — Cape Town, South Africa.</p>
          <p className="text-xs text-[#FFFDF7]/30">Built with purpose.</p>
        </div>
      </div>
    </footer>
  )
}
