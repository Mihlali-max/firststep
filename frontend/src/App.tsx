import { useState } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/layout/Layout'
import Home from './components/pages/Home'
import { Login, Register } from './components/pages/Auth'
import LAP from './components/pages/LAP'
import Profile from './components/pages/Profile'
import Dashboard from './components/pages/Dashboard'
import Contact from './components/pages/Contact'
import Coach from './components/pages/Coach'
import Learnerships from './components/pages/Learnerships'
import CVBuilder from './components/pages/CVBuilder'
import CVUpload from './components/pages/CVUpload'
import { useAuthStore } from './store/authStore'

function OnboardingModal({ onClose }: { onClose: () => void }) {
  const [step, setStep] = useState(0)
  const steps = [
    { icon: '📄', title: 'Build your CV', body: 'Create a professional CV in minutes using our designer templates. Download as PDF for free.', action: 'Go to CV Builder', href: '/cv' },
    { icon: '💼', title: 'Find learnerships', body: '600+ real SA opportunities updated daily — filter by province and sector, apply without leaving the app.', action: 'Browse jobs', href: '/learnerships' },
    { icon: '🤖', title: 'Get coached by AI', body: 'Ask anything — interview prep, cover letters, what to say, what to wear. Available 24/7, completely free.', action: 'Open AI Coach', href: '/coach' },
  ]
  const s = steps[step]
  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={onClose}>
      <div className="bg-white rounded-3xl p-8 max-w-sm w-full shadow-2xl" onClick={e => e.stopPropagation()}>
        <div className="flex justify-between items-center mb-6">
          <div className="flex gap-1.5">
            {steps.map((_, i) => (
              <div key={i} className={`h-1.5 rounded-full transition-all ${i === step ? 'bg-[#F5A623] w-8' : 'bg-black/10 w-4'}`} />
            ))}
          </div>
          <button onClick={onClose} className="text-black/30 hover:text-black/60 text-sm">Skip</button>
        </div>
        <div className="text-5xl mb-4">{s.icon}</div>
        <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">{s.title}</h2>
        <p className="text-black/50 text-sm leading-relaxed mb-8">{s.body}</p>
        <div className="flex gap-3">
          {step < steps.length - 1
            ? <button onClick={() => setStep(step + 1)} className="flex-1 bg-[#F5A623] text-[#1A1A0F] font-semibold py-3 rounded-2xl hover:bg-[#e09620] transition-colors">Next</button>
            : <a href={s.href} onClick={onClose} className="flex-1 bg-[#F5A623] text-[#1A1A0F] font-semibold py-3 rounded-2xl hover:bg-[#e09620] transition-colors text-center">{s.action}</a>
          }
        </div>
      </div>
    </div>
  )
}

export default function App() {
  const { user } = useAuthStore()
  const [showOnboarding, setShowOnboarding] = useState(() => {
    return !!user && !localStorage.getItem('fs_onboarded')
  })
  const closeOnboarding = () => {
    localStorage.setItem('fs_onboarded', '1')
    setShowOnboarding(false)
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
          <Route path="/lap" element={<LAP />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/cv" element={<CVBuilder />} />
          <Route path="/cv/upload" element={<CVUpload />} />
          <Route path="/learnerships" element={<Learnerships />} />
          <Route path="/coach" element={<Coach />} />
          <Route path="/contact" element={<Contact />} />
        </Route>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
      {showOnboarding && <OnboardingModal onClose={closeOnboarding} />}
    </BrowserRouter>
  )
}
