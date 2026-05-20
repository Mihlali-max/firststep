import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
export default function ResetPassword() {
  const [params] = useSearchParams()
  const token = params.get('token') || ''
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [loading, setLoading] = useState(false)
  const [err, setErr] = useState('')
  const navigate = useNavigate()
  const submit = async () => {
    if (password !== confirm) { setErr('Passwords do not match'); return }
    if (password.length < 8) { setErr('Password must be at least 8 characters'); return }
    setLoading(true); setErr('')
    const r = await fetch((import.meta.env.VITE_API_BASE||'')+'/api/auth/reset-password',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({token,new_password:password})})
    if (r.ok) navigate('/login?reset=1')
    else { setErr('Reset link is invalid or expired.'); setLoading(false) }
  }
  return (
    <div className="min-h-screen bg-[#F7F3EB] flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-sm border border-black/8 p-8 w-full max-w-sm">
        <h1 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">Set new password</h1>
        <p className="text-black/50 text-sm mb-6">Choose a strong password for your account.</p>
        <input value={password} onChange={e=>setPassword(e.target.value)} type="password" placeholder="New password"
          className="w-full border border-black/15 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623] mb-3"/>
        <input value={confirm} onChange={e=>setConfirm(e.target.value)} type="password" placeholder="Confirm password"
          className="w-full border border-black/15 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623] mb-4"/>
        {err && <p className="text-red-500 text-xs mb-3">{err}</p>}
        <button onClick={submit} disabled={loading||!password||!confirm}
          className="w-full bg-[#F5A623] text-[#1A1A0F] font-bold py-3 rounded-xl hover:bg-[#e09620] transition-colors text-sm disabled:opacity-50">
          {loading ? 'Saving...' : 'Set new password'}
        </button>
      </div>
    </div>
  )
}
