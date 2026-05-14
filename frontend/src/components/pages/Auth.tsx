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
