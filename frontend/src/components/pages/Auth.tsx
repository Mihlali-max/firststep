import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Eye, EyeOff, ArrowRight, Loader2 } from 'lucide-react'
import React from 'react'
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


function PhoneLogin({ navigate }: { navigate: any }) {
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)
  const [err, setErr] = useState('')

  const sendOtp = async () => {
    if (!phone.trim()) return
    setLoading(true); setErr('')
    try {
      await fetch((import.meta.env.VITE_API_BASE||'')+'/api/auth/phone/send-otp', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({phone: phone.startsWith('+') ? phone : '+27' + phone.replace(/^0/, '')})})
      setSent(true)
    } catch { setErr('Failed to send OTP. Try again.') }
    setLoading(false)
  }

  const verifyOtp = async () => {
    if (!otp.trim()) return
    setLoading(true); setErr('')
    try {
      const _r = await fetch((import.meta.env.VITE_API_BASE||'')+'/api/auth/phone/verify-otp', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({phone: phone.startsWith('+') ? phone : '+27' + phone.replace(/^0/, ''), otp})})
      if (!_r.ok) throw new Error('Invalid OTP')
      const data = await _r.json()
      const s = { user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token }
      useAuthStore.setState(s)
      localStorage.setItem('firststep-auth', JSON.stringify({ state: s, version: 0 }))
      navigate('/')
    } catch { setErr('Invalid OTP. Try again.') }
    setLoading(false)
  }

  return (
    <div>
      {!sent ? (
        <div className="flex gap-2">
          <input value={phone} onChange={e=>setPhone(e.target.value)} placeholder="e.g. 0812345678"
            className="flex-1 border border-black/15 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]"/>
          <button onClick={sendOtp} disabled={loading}
            className="bg-[#1A1A0F] text-white px-4 py-3 rounded-xl text-sm font-medium hover:bg-black transition-colors whitespace-nowrap">
            {loading ? '...' : 'Send OTP'}
          </button>
        </div>
      ) : (
        <div>
          <p className="text-xs text-black/50 mb-2">OTP sent to {phone}. Enter it below:</p>
          <div className="flex gap-2">
            <input value={otp} onChange={e=>setOtp(e.target.value)} placeholder="Enter 6-digit OTP"
              className="flex-1 border border-black/15 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]" maxLength={6}/>
            <button onClick={verifyOtp} disabled={loading}
              className="bg-[#F5A623] text-[#1A1A0F] px-4 py-3 rounded-xl text-sm font-bold hover:bg-[#e09620] transition-colors">
              {loading ? '...' : 'Verify'}
            </button>
          </div>
          <button onClick={()=>setSent(false)} className="text-xs text-black/40 mt-2 hover:text-black/60">← Change number</button>
        </div>
      )}
      {err && <p className="text-red-500 text-xs mt-2">{err}</p>}
    </div>
  )
}

function GoogleBtn({ navigate }: { navigate: any }) {
  const [loading, setLoading] = React.useState(false)
  const handleGoogle = async () => {
    setLoading(true)
    try {
      const { google } = window as any
      if (!google) throw new Error('Google not loaded')
      if ((window as any).__googleInitDone) { google.accounts.id.prompt(); setLoading(false); return }
      ;(window as any).__googleInitDone = true
      google.accounts.id.initialize({
        client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
        callback: async (res: any) => {
          try {
            const axios = (await import('axios')).default
            const { data } = await axios.post(
              (import.meta.env.VITE_API_BASE || '') + '/api/auth/google',
              { token: res.credential }
            )
            const s = { user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token }
            useAuthStore.setState(s)
            localStorage.setItem('firststep-auth', JSON.stringify({ state: s, version: 0 }))
            navigate('/')
          } catch { alert('Google sign in failed') }
          setLoading(false)
        }
      })
      google.accounts.id.prompt()
    } catch { alert('Google sign in failed'); setLoading(false) }
  }
  return (
    <button type="button" onClick={handleGoogle} disabled={loading}
      className="w-full flex items-center justify-center gap-3 border border-black/15 bg-white hover:bg-gray-50 text-[#1A1A0F] font-medium py-3 rounded-xl transition-colors text-sm">
      <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>
      {loading ? 'Signing in...' : 'Continue with Google'}
    </button>
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
    try { await login(fd.get('email') as string, fd.get('password') as string); navigate(sessionStorage.getItem('redirectAfter') || '/') }
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
      <div className="my-5 flex items-center gap-3"><div className="flex-1 h-px bg-black/10"/><span className="text-xs text-black/30">or continue with</span><div className="flex-1 h-px bg-black/10"/></div>
      <GoogleBtn navigate={navigate} />
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
    try { await register({ full_name: fd.get('full_name'), email: fd.get('email'), password: fd.get('password'), province: fd.get('province') || undefined, city: fd.get('city') || undefined }); navigate(sessionStorage.getItem('redirectAfter') || '/') }
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
      <div className="my-5 flex items-center gap-3"><div className="flex-1 h-px bg-black/10"/><span className="text-xs text-black/30">or continue with</span><div className="flex-1 h-px bg-black/10"/></div>
      <GoogleBtn navigate={navigate} />
      <p className="text-center text-sm text-[#7A7260] mt-6">Already have an account? <Link to="/login" className="text-[#C47D0A] font-medium hover:underline">Log in</Link></p>
    </AuthShell>
  )
}
