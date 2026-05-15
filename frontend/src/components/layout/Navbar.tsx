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
              <a href="/dashboard" className="text-sm font-medium text-black/50 hover:text-[#F5A623] transition-colors mr-2">Dashboard</a>
              <a href="/profile" className="text-sm font-medium text-[#7A7260] hover:text-[#F5A623] transition-colors mr-1">Hi, {user.full_name.split(' ')[0]}</a>
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

      <div className={clsx('fixed top-[68px] left-0 right-0 bg-[#FFFDF7] border-b border-[#1A1A0F]/10 z-40 flex flex-col gap-1 px-5 transition-all duration-300 overflow-hidden', open ? 'max-h-screen py-4 opacity-100' : 'max-h-0 py-0 opacity-0')}>
        {LINKS.map(l => (
          <Link key={l.to} to={l.to} onClick={() => setOpen(false)}
            className={clsx('text-base px-4 py-3 rounded-xl transition-colors', loc.pathname === l.to ? 'bg-[#F5A623]/10 text-[#C47D0A] font-medium' : 'text-[#1A1A0F] hover:bg-[#F7F3EB]')}>
            {l.label}
          </Link>
        ))}
        {user && (
          <>
            <Link to="/dashboard" onClick={() => setOpen(false)}
              className={clsx('text-base px-4 py-3 rounded-xl transition-colors', loc.pathname === '/dashboard' ? 'bg-[#F5A623]/10 text-[#C47D0A] font-medium' : 'text-[#1A1A0F] hover:bg-[#F7F3EB]')}>
              Dashboard
            </Link>
            <Link to="/profile" onClick={() => setOpen(false)}
              className={clsx('text-base px-4 py-3 rounded-xl transition-colors', loc.pathname === '/profile' ? 'bg-[#F5A623]/10 text-[#C47D0A] font-medium' : 'text-[#1A1A0F] hover:bg-[#F7F3EB]')}>
              My Profile
            </Link>
          </>
        )}
        <div className="flex gap-3 mt-3 pt-3 border-t border-[#1A1A0F]/10">
          {user
            ? <button onClick={() => { logout(); setOpen(false); }} className="flex-1 text-center border border-red-200 text-red-500 py-2.5 rounded-xl text-sm font-medium">Log out</button>
            : <>
                <Link to="/login" onClick={() => setOpen(false)} className="flex-1 text-center border border-[#1A1A0F]/15 text-[#1A1A0F] py-2.5 rounded-xl text-sm font-medium">Log in</Link>
                <Link to="/register" onClick={() => setOpen(false)} className="flex-1 btn-amber text-center text-sm !py-2.5 flex items-center justify-center">Get started</Link>
              </>
          }
        </div>
      </div>
    </>
  )
}
