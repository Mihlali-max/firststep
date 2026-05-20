import { useState } from 'react'
import { Link } from 'react-router-dom'
export default function ForgotPassword() {
  const [email, setEmail] = useState('')
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)
  const submit = async () => {
    setLoading(true)
    await fetch((import.meta.env.VITE_API_BASE||'')+'/api/auth/forgot-password',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email})})
    setSent(true); setLoading(false)
  }
  return (
    <div className="min-h-screen bg-[#F7F3EB] flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-sm border border-black/8 p-8 w-full max-w-sm">
        <h1 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">Forgot password?</h1>
        {sent ? (
          <div>
            <p className="text-black/60 text-sm mb-6">If that email is registered, we've sent a reset link. Check your inbox.</p>
            <Link to="/login" className="text-[#C47D0A] font-medium text-sm hover:underline">← Back to login</Link>
          </div>
        ) : (
          <div>
            <p className="text-black/50 text-sm mb-6">Enter your email and we'll send you a reset link.</p>
            <input value={email} onChange={e=>setEmail(e.target.value)} type="email" placeholder="your@email.com"
              className="w-full border border-black/15 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623] mb-4"/>
            <button onClick={submit} disabled={loading||!email}
              className="w-full bg-[#F5A623] text-[#1A1A0F] font-bold py-3 rounded-xl hover:bg-[#e09620] transition-colors text-sm disabled:opacity-50">
              {loading ? 'Sending...' : 'Send reset link'}
            </button>
            <div className="mt-4 text-center"><Link to="/login" className="text-black/40 text-sm hover:text-black/60">← Back to login</Link></div>
          </div>
        )}
      </div>
    </div>
  )
}
