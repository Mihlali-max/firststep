import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, ChevronRight, Star } from 'lucide-react'
import { useParticleCanvas, useParallax, useMagneticButtons, useCardTilt, useRipple, useScrollReveal, useCursorGlow } from '../../hooks/useAnimations'

const PHRASES = ['your first job.','your future.','your career.','your opportunity.','your story.']
const FEATURES = [
  { icon:'⭐', title:'AI Career Coach', desc:'Chat with an AI that understands the SA job market. Interview prep, job advice in English, isiXhosa, or Zulu.', to:'/coach' },
  { icon:'📄', title:'CV Builder', desc:'No blank pages. We ask simple questions and build your CV — even with zero work experience. Volunteering counts.', to:'/cv' },
  { icon:'🔍', title:'Learnership Finder', desc:'Browse SETA learnerships, YES Programme, and entry-level jobs — filtered for no-experience roles.', to:'/learnerships' },
  { icon:'🎤', title:'Interview Prep', desc:'Practice real SA interview questions with AI feedback. Build confidence before the real thing — free.', to:'/interview' },
  { icon:'✅', title:'LAP Programme Checker', desc:'Search active Labour Activation Programme opportunities from the Dept. of Employment & Labour — live.', to:'/lap' },
  { icon:'👥', title:'Community & Support', desc:'Connect with others. Share advice, celebrate wins, and get peer support from job seekers across SA.', to:'/' },
]
const TESTIMONIALS = [
  { quote:'"I never thought I could write a CV. FirstStep walked me through everything and I got called for an interview within two weeks."', name:'Nomvula M.', role:'Khayelitsha, Cape Town' },
  { quote:'"The AI coach helped me practice my interview answers. When I sat in the real interview I already knew what to say."', name:'Thabo S.', role:'Soweto, Johannesburg' },
  { quote:'"I found a LAP learnership paying R3 500/month, five minutes from my house. I didn\'t know learnerships existed before."', name:'Zanele D.', role:"Mitchell's Plain, Cape Town" },
]

export default function Home() {
  const [pIdx, setPIdx] = useState(0)
  const [pVis, setPVis] = useState(true)
  const [pTxt, setPTxt] = useState(PHRASES[0])
  const heroRef  = useRef<HTMLElement>(null)
  const photoRef = useRef<HTMLImageElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)

  // All animations
  useParticleCanvas(canvasRef, heroRef)
  useParallax(heroRef, photoRef)
  useMagneticButtons()
  useCardTilt()
  useRipple()
  useScrollReveal()
  useCursorGlow()

  // Phrase crossfade
  useEffect(() => {
    const id = setInterval(() => {
      setPVis(false)
      setTimeout(() => {
        const n = (pIdx + 1) % PHRASES.length
        setPIdx(n); setPTxt(PHRASES[n]); setPVis(true)
      }, 650)
    }, 3200)
    return () => clearInterval(id)
  }, [pIdx])

  return (
    <>
      {/* ─── HERO ─── */}
      <section ref={heroRef}
        className="relative min-h-[calc(100vh-68px)] grid grid-cols-1 lg:grid-cols-2 items-center gap-12 px-8 md:px-12 py-20 overflow-hidden"
        style={{ background: 'linear-gradient(135deg,#1A1A0F 0%,#2A3820 50%,#1F2D16 100%)' }}>

        <canvas ref={canvasRef} className="absolute inset-0 w-full h-full pointer-events-none opacity-30 z-0" />
        <div className="absolute right-[-80px] top-[-80px] w-[560px] h-[560px] rounded-full pointer-events-none z-0"
          style={{ background: 'radial-gradient(circle,rgba(245,166,35,0.2) 0%,rgba(245,166,35,0.04) 50%,transparent 75%)', animation: 'orbpulse 6s ease-in-out infinite' }} />

        {/* Content */}
        <div className="relative z-10">
          <div className="inline-flex items-center gap-2 text-[#F5A623] text-[11px] font-medium tracking-[3px] uppercase bg-[#F5A623]/12 border border-[#F5A623]/25 px-3 py-1.5 rounded-full mb-5"
            style={{ animation: 'fadeup .8s cubic-bezier(.16,1,.3,1) .2s both' }}>
            <span className="w-1.5 h-1.5 rounded-full bg-[#F5A623]" />
            For SA Youth &amp; Graduates
          </div>

          <h1 className="font-display font-bold leading-[1.05] tracking-tight text-[#FFFDF7] mb-5"
            style={{ fontSize: 'clamp(2.8rem,5vw,4.6rem)' }}>
            <span style={{ display:'block', animation:'wordslide .8s cubic-bezier(.16,1,.3,1) .35s both' }}>Your first job</span>
            <span style={{ display:'block', animation:'wordslide .8s cubic-bezier(.16,1,.3,1) .5s both' }}>
              starts{' '}
              <em className="not-italic text-[#F5A623]" style={{
                fontSize: '0.75em', display: 'inline-block',
                opacity: pVis ? 1 : 0,
                transform: pVis ? 'translateY(0) skewY(0deg)' : 'translateY(-16px) skewY(2deg)',
                transition: 'opacity .65s cubic-bezier(.16,1,.3,1), transform .65s cubic-bezier(.16,1,.3,1)'
              }}>
                {pTxt}
              </em>
            </span>
          </h1>

          <p className="text-[#FFFDF7]/65 font-light text-base leading-relaxed max-w-md mb-9"
            style={{ animation: 'fadeup .8s cubic-bezier(.16,1,.3,1) .7s both' }}>
            Build your CV, find learnerships, graduate programmes, internships and bursaries — coached by AI, completely free. For matric holders and graduates across SA.
          </p>

          <div className="flex gap-3 flex-wrap mb-14" style={{ animation: 'fadeup .8s cubic-bezier(.16,1,.3,1) .9s both' }}>
            <Link to="/register" className="magnetic ripple btn-amber flex items-center gap-2">
              Get started free <ArrowRight size={16} />
            </Link>
            <Link to="/lap" className="magnetic ripple btn-outline !text-[#FFFDF7]/85 !border-[#FFFDF7]/25 hover:!border-[#FFFDF7]/60 hover:!bg-[#FFFDF7]/5">
              Check LAP programmes →
            </Link>
          </div>

          <div className="flex gap-7 border-t border-[#FFFDF7]/10 pt-7"
            style={{ animation: 'fadeup .8s cubic-bezier(.16,1,.3,1) 1.1s both' }}>
            {[['46%','Youth unemployment in SA'],['4.8M','Young people need first job'],['Free','Always, for job seekers']].map(([n,l]) => (
              <div key={l}>
                <div className="font-display text-3xl font-bold text-[#FFFDF7] tracking-tight">{n}</div>
                <div className="text-xs font-light text-[#FFFDF7]/50 mt-1">{l}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Image */}
        <div className="relative z-10 hidden lg:block" style={{ animation: 'fadeup 1s cubic-bezier(.16,1,.3,1) .4s both' }}>
          <img ref={photoRef}
            src="https://images.unsplash.com/photo-1531482615713-2afd69097998?w=700&q=80&fit=crop&crop=faces,top"
            alt="Young South African professional at interview"
            className="w-full h-[520px] object-cover object-top rounded-2xl shadow-[0_24px_64px_rgba(0,0,0,0.5)]" />
          <div className="absolute -bottom-5 -left-5 bg-[#1A1A0F]/85 border border-[#F5A623]/35 rounded-2xl px-5 py-4 backdrop-blur-xl min-w-[180px]"
            style={{ animation: 'cardentrance .7s cubic-bezier(.16,1,.3,1) 1.1s both, floatcard 5s ease-in-out 2s infinite' }}>
            <div className="text-[10px] font-medium tracking-[1.5px] uppercase text-[#FFFDF7]/50 mb-1">AI coach says</div>
            <div className="font-display text-base font-bold text-[#FFFDF7]">"You're ready to apply."</div>
            <div className="inline-block text-[11px] font-medium px-3 py-0.5 rounded-full mt-2 bg-[#2A5C3F]/40 text-green-300">Interview prep: 87%</div>
          </div>
          <div className="absolute -top-5 -right-5 bg-[#1A1A0F]/85 border border-[#F5A623]/35 rounded-2xl px-5 py-4 backdrop-blur-xl min-w-[160px]"
            style={{ animation: 'cardentrance .7s cubic-bezier(.16,1,.3,1) 1.3s both, floatcard 5s ease-in-out 3.5s infinite' }}>
            <div className="text-[10px] font-medium tracking-[1.5px] uppercase text-[#FFFDF7]/50 mb-1">New near you</div>
            <div className="font-display text-base font-bold text-[#FFFDF7]">14 learnerships</div>
            <div className="inline-block text-[11px] font-medium px-3 py-0.5 rounded-full mt-2 bg-[#F5A623]/25 text-[#F5A623]">Updated today</div>
          </div>
        </div>
      </section>

      {/* ─── MARQUEE ─── */}
      <div className="bg-[#1A1A0F] border-y border-[#FFFDF7]/8 py-4 overflow-hidden">
        <div className="flex" style={{ animation: 'marquee 28s linear infinite', width: 'max-content' }}>
          {[0,1].map(i => (
            <div key={i} className="flex items-center">
              {['Build your CV','Find learnerships','Check LAP programmes','AI career coach','Interview prep','YES Programme','SETA learnerships','No experience needed','UIF funded training'].map(item => (
                <span key={item+i} className="flex items-center">
                  <span className="text-[#F5A623]/70 text-xs font-medium tracking-[1.5px] uppercase px-7 hover:text-[#F5A623] transition-colors cursor-default">{item}</span>
                  <span className="text-[#F5A623]/30 text-[10px]">✦</span>
                </span>
              ))}
            </div>
          ))}
        </div>
      </div>

      {/* ─── FEATURES ─── */}
      <section className="bg-[#F7F3EB] py-20 px-8 md:px-12 border-b border-[#1A1A0F]/10">
        <div className="max-w-6xl mx-auto">
          <p className="section-eyebrow reveal mb-3">What we offer</p>
          <h2 className="section-title reveal mb-14">Everything you need to land<br/><em className="not-italic text-[#F5A623]">your first job.</em></h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {FEATURES.map((f, i) => (
              <Link key={f.title} to={f.to}
                className="card reveal tilt-card group"
                data-delay={String(i * 80)}>
                <div className="w-12 h-12 rounded-xl bg-[#F5A623]/10 flex items-center justify-center text-2xl mb-5 group-hover:scale-110 transition-transform duration-300">{f.icon}</div>
                <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-2">{f.title}</h3>
                <p className="text-sm font-light text-[#7A7260] leading-relaxed mb-4">{f.desc}</p>
                <span className="text-sm font-medium text-[#C47D0A] flex items-center gap-1 group-hover:gap-3 transition-all duration-300">
                  Learn more <ChevronRight size={14} />
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* ─── LAP HIGHLIGHT ─── */}
      <section className="bg-[#1A1A0F] py-20 px-8 md:px-12">
        <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
          <div className="reveal">
            <p className="text-[#F5A623] text-[11px] font-medium tracking-[3px] uppercase flex items-center gap-2 mb-3 before:content-[''] before:block before:w-5 before:h-0.5 before:bg-[#F5A623] before:rounded">Government Programmes</p>
            <h2 className="font-display text-4xl font-bold text-[#FFFDF7] tracking-tight leading-tight mb-4">Don't miss out on<br/><em className="not-italic text-[#F5A623]">LAP funding.</em></h2>
            <p className="text-[#FFFDF7]/60 font-light text-sm leading-relaxed mb-8 max-w-md">The Labour Activation Programme funds free skills training for UIF contributors. Thousands miss out simply because they don't know it exists.</p>
            <Link to="/lap" className="magnetic ripple inline-flex items-center gap-2 text-[#F5A623] border border-[#F5A623]/30 hover:bg-[#F5A623]/10 hover:border-[#F5A623] transition-all px-6 py-3 rounded-xl text-sm font-medium">
              Search LAP programmes →
            </Link>
          </div>
          <div className="flex flex-col gap-4 reveal">
            {[['9','Provinces covered — search by your location'],['Free','Training costs covered by UIF contributions'],['Live','AI searches official sources in real time']].map(([n,l], i) => (
              <div key={n}
                className="flex items-center gap-5 bg-[#FFFDF7]/5 border border-[#FFFDF7]/8 rounded-xl px-6 py-5 hover:border-[#F5A623]/25 transition-colors"
                style={{ animation: `fadeup .6s cubic-bezier(.16,1,.3,1) ${i*100}ms both` }}>
                <div className="font-display text-3xl font-bold text-[#F5A623] tracking-tight flex-shrink-0">{n}</div>
                <div className="text-sm font-light text-[#FFFDF7]/55 leading-snug">{l}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── TESTIMONIALS ─── */}
      <section className="py-20 px-8 md:px-12 border-b border-[#1A1A0F]/10">
        <div className="max-w-6xl mx-auto">
          <p className="section-eyebrow reveal mb-3">From our community</p>
          <h2 className="section-title reveal mb-14">Stories of first<br/><em className="not-italic text-[#F5A623]">steps taken.</em></h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {TESTIMONIALS.map((t, i) => (
              <div key={t.name} className="reveal tilt-card border-t-2 border-[#1A1A0F]/10 hover:border-[#F5A623]/40 transition-all duration-300 pt-6" data-delay={String(i * 100)}>
                <div className="flex gap-0.5 mb-4">{[0,1,2,3,4].map(j => <Star key={j} size={14} className="fill-[#F5A623] text-[#F5A623]" />)}</div>
                <p className="font-display text-base font-light italic text-[#1A1A0F] leading-relaxed mb-5">{t.quote}</p>
                <div className="text-sm font-medium text-[#1A1A0F]">{t.name}</div>
                <div className="text-xs font-light text-[#7A7260] mt-0.5">{t.role}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── CTA ─── */}
      <section className="bg-[#F5A623] py-20 px-8 md:px-12 flex flex-wrap items-center justify-between gap-8">
        <div className="reveal">
          <p className="text-[#1A1A0F]/60 text-xs font-medium tracking-[2px] uppercase mb-2">Ready to start?</p>
          <h2 className="font-display text-4xl font-bold text-[#1A1A0F] tracking-tight leading-tight">Your first job is<br/>closer than you think.</h2>
        </div>
        <Link to="/register" className="magnetic ripple btn-ink flex items-center gap-2 whitespace-nowrap reveal">
          Create your free profile <ArrowRight size={16} />
        </Link>
      </section>

      <style>{`
        @keyframes fadeup    { from { opacity:0; transform:translateY(20px) } to { opacity:1; transform:none } }
        @keyframes wordslide { from { opacity:0; transform:translateY(28px) skewY(2deg) } to { opacity:1; transform:none } }
        @keyframes orbpulse  { 0%,100% { transform:scale(1); opacity:.6 } 50% { transform:scale(1.08); opacity:1 } }
        @keyframes floatcard { 0%,100% { transform:translateY(0) } 50% { transform:translateY(-10px) } }
        @keyframes cardentrance { from { opacity:0; transform:translateY(20px) } to { opacity:1; transform:translateY(0) } }
        @keyframes marquee   { from { transform:translateX(0) } to { transform:translateX(-50%) } }
      `}</style>
    </>
  )
}
