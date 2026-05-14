#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📝 Writing React components..."

# ── Layout.tsx
cat > src/components/layout/Layout.tsx << 'EOF'
import { useEffect } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import Navbar from './Navbar'
import Footer from './Footer'

export default function Layout() {
  const { pathname } = useLocation()
  useEffect(() => { window.scrollTo({ top: 0, behavior: 'smooth' }) }, [pathname])
  useEffect(() => {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); obs.unobserve(e.target) } })
    }, { threshold: 0.1 })
    setTimeout(() => document.querySelectorAll('.reveal:not(.in)').forEach(el => obs.observe(el)), 100)
    return () => obs.disconnect()
  }, [pathname])
  useEffect(() => {
    const bar = document.getElementById('scroll-bar')
    if (!bar) return
    const h = () => { const t = document.body.scrollHeight - window.innerHeight; bar.style.width = t > 0 ? (window.scrollY/t*100)+'%' : '0%' }
    window.addEventListener('scroll', h)
    return () => window.removeEventListener('scroll', h)
  }, [])
  return (
    <>
      <div id="scroll-bar" />
      <Navbar />
      <main><Outlet /></main>
      <Footer />
    </>
  )
}
EOF

# ── Navbar.tsx
cat > src/components/layout/Navbar.tsx << 'EOF'
import { useState, useEffect, useRef } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Menu, X, ArrowRight, User } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import clsx from 'clsx'

const LINKS = [
  { label: 'Home', to: '/' },
  { label: 'LAP Programmes', to: '/lap' },
  { label: 'CV Builder', to: '/cv' },
  { label: 'Learnerships', to: '/learnerships' },
  { label: 'Contact', to: '/contact' },
]

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [open, setOpen] = useState(false)
  const [pill, setPill] = useState<any>({})
  const listRef = useRef<HTMLUListElement>(null)
  const loc = useLocation()
  const nav = useNavigate()
  const { user, logout } = useAuthStore()

  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 10)
    window.addEventListener('scroll', h); return () => window.removeEventListener('scroll', h)
  }, [])

  const movePill = (el: HTMLElement) => {
    const l = listRef.current; if (!l) return
    const lr = l.getBoundingClientRect(), er = el.getBoundingClientRect()
    setPill({ left: er.left-lr.left, top: er.top-lr.top, width: er.width, height: er.height })
  }

  useEffect(() => {
    const a = listRef.current?.querySelector<HTMLElement>('.nav-active')
    if (a) movePill(a)
  }, [loc.pathname])

  return (
    <>
      <nav className={clsx('sticky top-0 z-50 flex items-center justify-between px-8 md:px-12 h-[68px] bg-[#FFFDF7]/85 backdrop-blur-lg border-b border-[#1A1A0F]/7 transition-shadow duration-300', scrolled && 'shadow-[0_8px_32px_rgba(26,26,15,0.08)]')}>
        <Link to="/" className="font-display text-2xl font-bold text-[#1A1A0F] tracking-tight">First<span className="text-[#F5A623]">Step</span></Link>

        <ul ref={listRef} className="hidden md:flex gap-1 list-none relative">
          <div className="absolute bg-[#F7F3EB] border border-[#1A1A0F]/10 rounded-lg transition-all duration-300 pointer-events-none z-0" style={pill} />
          {LINKS.map(l => {
            const active = loc.pathname === l.to
            return (
              <li key={l.to}>
                <Link to={l.to}
                  className={clsx('relative z-10 block px-4 py-1.5 rounded-lg text-sm transition-colors', active ? 'nav-active text-[#1A1A0F] font-medium' : 'text-[#7A7260] hover:text-[#1A1A0F]')}
                  onMouseEnter={e => movePill(e.currentTarget)}
                  onMouseLeave={() => { const a = listRef.current?.querySelector<HTMLElement>('.nav-active'); if (a) movePill(a) }}>
                  {l.label}
                  {active && <span className="absolute bottom-1 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full bg-[#F5A623]" />}
                </Link>
              </li>
            )
          })}
        </ul>

        <div className="hidden md:flex items-center gap-2">
          {user ? (
            <>
              <span className="text-sm text-[#7A7260] mr-1">Hi, {user.full_name.split(' ')[0]}</span>
              <button onClick={() => { logout(); nav('/') }} className="text-sm text-[#7A7260] hover:text-[#1A1A0F] px-3 py-2 rounded-lg hover:bg-[#F7F3EB] transition-colors">Log out</button>
            </>
          ) : (
            <>
              <Link to="/login" className="flex items-center gap-1.5 text-sm text-[#1A1A0F] px-3 py-2 rounded-lg hover:bg-[#F7F3EB] transition-colors"><User size={14} />Log in</Link>
              <div className="w-px h-5 bg-[#1A1A0F]/10" />
              <Link to="/register" className="btn-amber flex items-center gap-2 text-sm !py-2 !px-4">Get started <ArrowRight size={13} /></Link>
            </>
          )}
        </div>

        <button className="md:hidden p-2 rounded-lg hover:bg-[#F7F3EB]" onClick={() => setOpen(!open)}>
          {open ? <X size={20} /> : <Menu size={20} />}
        </button>
      </nav>

      <div className={clsx('fixed top-[68px] left-0 right-0 bg-[#FFFDF7]/98 backdrop-blur-xl border-b border-[#1A1A0F]/10 z-40 flex flex-col gap-1 px-5 transition-all duration-300 overflow-hidden', open ? 'max-h-screen py-4 opacity-100' : 'max-h-0 py-0 opacity-0')}>
        {LINKS.map(l => (
          <Link key={l.to} to={l.to} onClick={() => setOpen(false)}
            className={clsx('text-base px-4 py-3 rounded-xl transition-colors', loc.pathname === l.to ? 'bg-[#F5A623]/10 text-[#C47D0A] font-medium' : 'text-[#1A1A0F] hover:bg-[#F7F3EB]')}>
            {l.label}
          </Link>
        ))}
        <div className="flex gap-3 mt-3 pt-3 border-t border-[#1A1A0F]/10">
          <Link to="/login" onClick={() => setOpen(false)} className="flex-1 text-center border border-[#1A1A0F]/15 text-[#1A1A0F] py-2.5 rounded-xl text-sm font-medium">Log in</Link>
          <Link to="/register" onClick={() => setOpen(false)} className="flex-1 btn-amber text-center text-sm !py-2.5 flex items-center justify-center">Get started</Link>
        </div>
      </div>
    </>
  )
}
EOF

# ── Footer.tsx
cat > src/components/layout/Footer.tsx << 'EOF'
import { Link } from 'react-router-dom'
const COLS = [
  { title: 'Platform', links: [['CV Builder','/cv'],['AI Coach','/coach'],['Learnerships','/learnerships'],['LAP Programmes','/lap']] },
  { title: 'Company', links: [['About us','/contact'],['Contact','/contact'],['Partners','/contact']] },
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
EOF

# ── Auth.tsx
cat > src/components/pages/Auth.tsx << 'EOF'
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Eye, EyeOff, ArrowRight, Loader2 } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-xs font-medium tracking-wider uppercase text-[#7A7260] mb-1.5">{label}</label>
      {children}
    </div>
  )
}
const inputCls = "w-full bg-[#F7F3EB] border border-[#1A1A0F]/15 text-[#1A1A0F] placeholder:text-[#7A7260]/60 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/50 transition-colors"

function AuthShell({ title, sub, children }: { title: string; sub: string; children: React.ReactNode }) {
  return (
    <div className="min-h-[calc(100vh-68px)] grid grid-cols-1 lg:grid-cols-2">
      <div className="hidden lg:flex flex-col justify-between p-16" style={{ background: 'linear-gradient(135deg,#1A1A0F 0%,#2A3820 60%,#1A1A0F 100%)' }}>
        <Link to="/" className="font-display text-2xl font-bold text-[#FFFDF7] tracking-tight">First<span className="text-[#F5A623]">Step</span></Link>
        <div>
          <blockquote className="font-display text-3xl font-light italic text-[#FFFDF7]/80 leading-relaxed mb-6">"Every young person deserves the chance to take their first step."</blockquote>
          <p className="text-[#FFFDF7]/40 text-sm">FirstStep — Cape Town, South Africa</p>
        </div>
        <p className="text-[#FFFDF7]/30 text-xs">Free for all job seekers, always.</p>
      </div>
      <div className="flex items-center justify-center px-8 py-16 bg-[#FFFDF7]">
        <div className="w-full max-w-md">
          <h1 className="font-display text-3xl font-bold text-[#1A1A0F] tracking-tight mb-2">{title}</h1>
          <p className="text-[#7A7260] text-sm font-light mb-8">{sub}</p>
          {children}
        </div>
      </div>
    </div>
  )
}

export function Login() {
  const [show, setShow] = useState(false)
  const [error, setError] = useState('')
  const { login, isLoading } = useAuthStore()
  const navigate = useNavigate()
  const submit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); setError('')
    const fd = new FormData(e.currentTarget)
    try { await login(fd.get('email') as string, fd.get('password') as string); navigate('/') }
    catch (err: any) { setError(err?.response?.data?.detail || 'Invalid email or password') }
  }
  return (
    <AuthShell title="Welcome back." sub="Log in to your FirstStep account.">
      <form onSubmit={submit} className="space-y-4">
        <Field label="Email"><input name="email" type="email" required placeholder="you@email.com" className={inputCls} /></Field>
        <Field label="Password">
          <div className="relative">
            <input name="password" type={show ? 'text' : 'password'} required placeholder="••••••••" className={inputCls + ' pr-11'} />
            <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-[#7A7260]">{show ? <EyeOff size={16}/> : <Eye size={16}/>}</button>
          </div>
        </Field>
        {error && <p className="text-red-500 text-sm bg-red-50 border border-red-200 rounded-xl px-4 py-3">{error}</p>}
        <button type="submit" disabled={isLoading} className="btn-amber w-full flex items-center justify-center gap-2 py-3 disabled:opacity-50">
          {isLoading ? <Loader2 size={16} className="animate-spin"/> : <><span>Log in</span><ArrowRight size={15}/></>}
        </button>
      </form>
      <p className="text-center text-sm text-[#7A7260] mt-6">No account? <Link to="/register" className="text-[#C47D0A] font-medium hover:underline">Get started free</Link></p>
    </AuthShell>
  )
}

export function Register() {
  const [show, setShow] = useState(false)
  const [error, setError] = useState('')
  const { register, isLoading } = useAuthStore()
  const navigate = useNavigate()
  const PROVINCES = ['Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']
  const submit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); setError('')
    const fd = new FormData(e.currentTarget)
    try { await register({ full_name: fd.get('full_name'), email: fd.get('email'), password: fd.get('password'), province: fd.get('province') || undefined, city: fd.get('city') || undefined }); navigate('/') }
    catch (err: any) { setError(err?.response?.data?.detail || 'Something went wrong') }
  }
  return (
    <AuthShell title="Create your profile." sub="Free forever. No credit card needed.">
      <form onSubmit={submit} className="space-y-4">
        <Field label="Full name"><input name="full_name" required placeholder="e.g. Lebo Sithole" className={inputCls} /></Field>
        <Field label="Email"><input name="email" type="email" required placeholder="you@email.com" className={inputCls} /></Field>
        <Field label="Password">
          <div className="relative">
            <input name="password" type={show ? 'text' : 'password'} required placeholder="At least 8 characters" className={inputCls + ' pr-11'} />
            <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-[#7A7260]">{show ? <EyeOff size={16}/> : <Eye size={16}/>}</button>
          </div>
        </Field>
        <div className="grid grid-cols-2 gap-3">
          <Field label="Province">
            <select name="province" className={inputCls + ' appearance-none'}>
              <option value="">Select…</option>
              {PROVINCES.map(p => <option key={p} value={p}>{p}</option>)}
            </select>
          </Field>
          <Field label="City"><input name="city" placeholder="Cape Town" className={inputCls} /></Field>
        </div>
        {error && <p className="text-red-500 text-sm bg-red-50 border border-red-200 rounded-xl px-4 py-3">{error}</p>}
        <button type="submit" disabled={isLoading} className="btn-amber w-full flex items-center justify-center gap-2 py-3 disabled:opacity-50">
          {isLoading ? <Loader2 size={16} className="animate-spin"/> : <><span>Create free profile</span><ArrowRight size={15}/></>}
        </button>
      </form>
      <p className="text-center text-sm text-[#7A7260] mt-6">Already have an account? <Link to="/login" className="text-[#C47D0A] font-medium hover:underline">Log in</Link></p>
    </AuthShell>
  )
}
EOF

# ── App.tsx
cat > src/App.tsx << 'EOF'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/layout/Layout'
import Home from './components/pages/Home'
import { Login, Register } from './components/pages/Auth'

const Soon = ({ title }: { title: string }) => (
  <div className="min-h-[60vh] flex items-center justify-center">
    <div className="text-center">
      <h1 className="font-display text-4xl font-bold text-[#1A1A0F] mb-3">{title}</h1>
      <p className="text-[#7A7260] text-sm">Coming soon — building this next.</p>
    </div>
  </div>
)

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
          <Route path="/lap" element={<Soon title="LAP Programmes" />} />
          <Route path="/cv" element={<Soon title="CV Builder" />} />
          <Route path="/learnerships" element={<Soon title="Learnerships" />} />
          <Route path="/coach" element={<Soon title="AI Coach" />} />
          <Route path="/contact" element={<Soon title="Contact" />} />
        </Route>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  )
}
EOF

echo "✅ Components done! Starting dev server..."
npm run dev
