import { Link } from 'react-router-dom'
export default function About() {
  return (
    <div className="min-h-screen bg-[#FFFDF7]">
      <div className="bg-[#1A1A0F] py-16 px-6">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-[#F5A623] text-xs font-semibold tracking-[3px] uppercase mb-3">Our story</p>
          <h1 className="font-display text-4xl md:text-5xl font-bold text-[#FFFDF7] mb-4">Built for South African youth.<br/>By someone who gets it.</h1>
          <p className="text-[#FFFDF7]/50 text-base font-light max-w-xl mx-auto">FirstStep was built because the gap between "I want a job" and "I have a job" is too wide for too many young South Africans.</p>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-6 py-16">
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          {[['46%','Youth unemployment rate in SA'],['4.8M','Young people need their first job'],['Free','Forever, for all job seekers']].map(([n,l]) => (
            <div key={n} className="text-center p-6 bg-white rounded-2xl border border-black/6 shadow-sm">
              <div className="font-display text-4xl font-bold text-[#F5A623] mb-2">{n}</div>
              <p className="text-black/50 text-sm">{l}</p>
            </div>
          ))}
        </div>

        <div className="mb-16">
          <h2 className="font-display text-3xl font-bold text-[#1A1A0F] mb-4">Why FirstStep exists</h2>
          <p className="text-black/55 leading-relaxed mb-4">South Africa has one of the highest youth unemployment rates in the world. Most job platforms assume you already have experience, a CV, and know where to look. Most young people have none of those things.</p>
          <p className="text-black/55 leading-relaxed mb-4">FirstStep meets you where you are — whether you've never written a CV, don't know what a learnership is, or just need someone to tell you what to say in an interview.</p>
          <p className="text-black/55 leading-relaxed">Everything on this platform is free. No hidden fees, no premium tiers, no ads. Just tools that work.</p>
        </div>

        <div id="partners" className="mb-16">
          <h2 className="font-display text-3xl font-bold text-[#1A1A0F] mb-2">Partners & data sources</h2>
          <p className="text-black/45 text-sm mb-8">FirstStep aggregates real opportunities from trusted SA sources.</p>
          <div className="grid md:grid-cols-2 gap-4">
            {[
              ['Adzuna SA','Live job listings updated daily from 50+ SA job boards','https://www.adzuna.co.za'],
              ['Department of Employment & Labour','LAP programme data and government opportunities','https://www.labour.gov.za'],
              ['SAYouth.mobi','Presidential Youth Employment Intervention listings','https://www.sayouth.mobi'],
              ['YES Programme','Youth Employment Service opportunities','https://www.yes4youth.co.za'],
            ].map(([name, desc, url]) => (
              <a key={name} href={url} target="_blank" rel="noopener noreferrer"
                className="p-5 bg-white rounded-2xl border border-black/6 shadow-sm hover:border-[#F5A623]/40 transition-colors group">
                <p className="font-semibold text-[#1A1A0F] group-hover:text-[#C47D0A] transition-colors mb-1">{name}</p>
                <p className="text-black/45 text-sm">{desc}</p>
              </a>
            ))}
          </div>
        </div>

        <div className="bg-[#1A1A0F] rounded-3xl p-8 text-center">
          <h2 className="font-display text-2xl font-bold text-[#FFFDF7] mb-2">Want to partner with FirstStep?</h2>
          <p className="text-[#FFFDF7]/50 text-sm mb-6">We work with SETAs, NGOs, and companies who want to reach SA youth with real opportunities.</p>
          <Link to="/contact" className="inline-flex items-center gap-2 bg-[#F5A623] text-[#1A1A0F] font-semibold px-6 py-3 rounded-2xl hover:bg-[#e09620] transition-colors">Get in touch</Link>
        </div>
      </div>
    </div>
  )
}
