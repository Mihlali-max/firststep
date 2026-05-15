#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📊 Building Application Tracker Dashboard..."

cat > src/components/pages/Dashboard.tsx << 'EOF'
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Briefcase, FileText, Bot, BookOpen, TrendingUp, Clock, CheckCircle, XCircle, Send, ExternalLink, Trash2, Plus } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface Application {
  id: string
  learnership_title: string
  company: string
  date: string
  apply_email?: string
}

interface CVStats {
  completion_pct: number
  name: string
}

const STATUS_OPTIONS = ['Applied','Interview','Waiting','Rejected','Offered']
const STATUS_COLORS: Record<string,string> = {
  'Applied':   'bg-blue-50 text-blue-700 border-blue-200',
  'Interview': 'bg-purple-50 text-purple-700 border-purple-200',
  'Waiting':   'bg-yellow-50 text-yellow-700 border-yellow-200',
  'Rejected':  'bg-red-50 text-red-500 border-red-200',
  'Offered':   'bg-green-50 text-green-700 border-green-200',
}
const STATUS_ICONS: Record<string,any> = {
  'Applied':   Send,
  'Interview': Clock,
  'Waiting':   Clock,
  'Rejected':  XCircle,
  'Offered':   CheckCircle,
}

export default function Dashboard() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [apps, setApps]         = useState<Application[]>([])
  const [statuses, setStatuses] = useState<Record<string,string>>({})
  const [cv, setCv]             = useState<CVStats|null>(null)
  const [loading, setLoading]   = useState(true)

  useEffect(() => { if (!user) navigate('/login') }, [user])

  useEffect(() => {
    Promise.all([
      api.get('/applications').catch(()=>({ data: [] })),
      api.get('/cv').catch(()=>({ data: null })),
    ]).then(([appsRes, cvRes]) => {
      setApps(appsRes.data || [])
      if (cvRes.data) {
        setCv({
          completion_pct: cvRes.data.completion_pct || 0,
          name: cvRes.data.personal_info?.name || '',
        })
      }
      // Load saved statuses from localStorage
      const saved = JSON.parse(localStorage.getItem('app-statuses') || '{}')
      setStatuses(saved)
    }).finally(() => setLoading(false))
  }, [user])

  const setStatus = (id: string, status: string) => {
    const updated = { ...statuses, [id]: status }
    setStatuses(updated)
    localStorage.setItem('app-statuses', JSON.stringify(updated))
  }

  const firstName = user?.full_name?.split(' ')[0] || 'there'
  const appliedCount   = apps.length
  const interviewCount = Object.values(statuses).filter(s=>s==='Interview').length
  const offeredCount   = Object.values(statuses).filter(s=>s==='Offered').length
  const cvPct          = cv?.completion_pct || 0

  const tips = [
    { icon:'📄', text:'Complete your CV to 100% to stand out', action:'/cv', cta:'Build CV', done: cvPct >= 100 },
    { icon:'🤖', text:'Prep for interviews with the AI Coach', action:'/coach', cta:'Open Coach', done: false },
    { icon:'💼', text:'Apply to at least 5 learnerships this week', action:'/learnerships', cta:'Browse jobs', done: appliedCount >= 5 },
  ]

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Header */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-8">
        <div className="max-w-5xl mx-auto">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-1">My Dashboard</p>
          <h1 className="font-display text-2xl md:text-3xl font-bold text-white mb-1">
            Welcome back, {firstName} 👋
          </h1>
          <p className="text-white/40 text-sm">Track your job applications and career progress.</p>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 md:px-6 py-6 space-y-6">

        {/* Stats row */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { label:'Applications', value: appliedCount, icon: Send, color:'text-blue-500', bg:'bg-blue-50' },
            { label:'Interviews',   value: interviewCount, icon: Clock, color:'text-purple-500', bg:'bg-purple-50' },
            { label:'Offers',       value: offeredCount, icon: CheckCircle, color:'text-green-500', bg:'bg-green-50' },
            { label:'CV complete',  value: `${cvPct}%`, icon: FileText, color:'text-[#F5A623]', bg:'bg-[#F5A623]/10' },
          ].map(s => (
            <div key={s.label} className="bg-white rounded-2xl border border-black/8 p-4 shadow-sm">
              <div className={clsx('w-9 h-9 rounded-xl flex items-center justify-center mb-3', s.bg)}>
                <s.icon size={18} className={s.color}/>
              </div>
              <div className="font-display text-2xl font-bold text-[#1A1A0F]">{s.value}</div>
              <div className="text-xs text-black/40 mt-0.5">{s.label}</div>
            </div>
          ))}
        </div>

        {/* CV progress */}
        <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <div className="font-bold text-sm text-[#1A1A0F]">CV completion</div>
            <span className="text-sm font-bold text-[#F5A623]">{cvPct}%</span>
          </div>
          <div className="h-2.5 bg-[#F7F3EB] rounded-full overflow-hidden mb-3">
            <div className="h-full rounded-full bg-[#F5A623] transition-all duration-700" style={{width:`${cvPct}%`}}/>
          </div>
          <div className="flex items-center justify-between">
            <p className="text-xs text-black/40">
              {cvPct < 60 ? 'Add more info to unlock PDF download' :
               cvPct < 100 ? 'Looking good! Fill in the rest to stand out' :
               '✅ Your CV is complete and ready to download!'}
            </p>
            <a href="/cv" className="text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623]">Edit CV →</a>
          </div>
        </div>

        {/* Quick actions */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {[
            { icon:FileText, label:'Build CV',         desc:'5 pro templates', href:'/cv',           color:'#F5A623' },
            { icon:Briefcase,label:'Find learnerships',desc:'600+ live jobs',  href:'/learnerships',  color:'#1565C0' },
            { icon:Bot,      label:'AI Coach',         desc:'Career advice',   href:'/coach',          color:'#7D2AE8' },
          ].map(a => (
            <a key={a.label} href={a.href}
              className="bg-white rounded-2xl border border-black/8 p-4 flex items-center gap-3 hover:border-black/20 hover:shadow-sm transition-all group">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{background:`${a.color}15`}}>
                <a.icon size={18} style={{color:a.color}}/>
              </div>
              <div>
                <div className="font-semibold text-sm text-[#1A1A0F] group-hover:text-[#F5A623] transition-colors">{a.label}</div>
                <div className="text-xs text-black/40">{a.desc}</div>
              </div>
            </a>
          ))}
        </div>

        {/* Tips */}
        <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
          <h3 className="font-bold text-sm text-[#1A1A0F] mb-4">📋 Your next steps</h3>
          <div className="space-y-3">
            {tips.map(t => (
              <div key={t.text} className={clsx('flex items-center gap-3 p-3 rounded-xl border transition-all',
                t.done ? 'bg-green-50 border-green-200 opacity-60' : 'bg-[#F7F3EB] border-black/6')}>
                <span className="text-xl flex-shrink-0">{t.done ? '✅' : t.icon}</span>
                <div className="flex-1 text-sm text-[#1A1A0F]">{t.text}</div>
                {!t.done && (
                  <a href={t.action} className="text-xs font-bold text-[#C47D0A] hover:text-[#F5A623] whitespace-nowrap">{t.cta} →</a>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Applications tracker */}
        <div className="bg-white rounded-2xl border border-black/8 shadow-sm overflow-hidden">
          <div className="px-5 py-4 border-b border-black/6 flex items-center justify-between">
            <h3 className="font-bold text-sm text-[#1A1A0F]">My applications ({appliedCount})</h3>
            <a href="/learnerships" className="flex items-center gap-1.5 text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623]">
              <Plus size={12}/> Apply to more
            </a>
          </div>

          {loading ? (
            <div className="p-8 text-center text-black/30 text-sm">Loading…</div>
          ) : apps.length === 0 ? (
            <div className="p-10 text-center">
              <div className="text-4xl mb-3">📭</div>
              <h4 className="font-bold text-sm text-[#1A1A0F] mb-1">No applications yet</h4>
              <p className="text-xs text-black/40 mb-4">Start applying to learnerships and they'll appear here.</p>
              <a href="/learnerships" className="btn-amber text-sm inline-flex items-center gap-1.5">
                <Briefcase size={13}/> Browse learnerships
              </a>
            </div>
          ) : (
            <div className="divide-y divide-black/5">
              {apps.map(app => {
                const status = statuses[app.id] || 'Applied'
                const StatusIcon = STATUS_ICONS[status] || Send
                return (
                  <div key={app.id} className="px-5 py-4 flex items-center gap-4 hover:bg-[#FAFAFA] transition-colors">
                    <div className="w-9 h-9 rounded-xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center flex-shrink-0 font-bold text-sm text-black/30">
                      {app.company?.[0] || '?'}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-semibold text-sm text-[#1A1A0F] truncate">{app.learnership_title}</div>
                      <div className="text-xs text-black/40">{app.company} · {app.date}</div>
                    </div>
                    <select
                      value={status}
                      onChange={e=>setStatus(app.id, e.target.value)}
                      className={clsx('text-xs font-semibold px-2.5 py-1.5 rounded-full border outline-none cursor-pointer appearance-none', STATUS_COLORS[status])}
                    >
                      {STATUS_OPTIONS.map(s=><option key={s} value={s}>{s}</option>)}
                    </select>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
EOF

# Add route to App.tsx
sed -i "s|import Profile from './components/pages/Profile'|import Profile from './components/pages/Profile'\nimport Dashboard from './components/pages/Dashboard'|" src/App.tsx
sed -i "s|<Route path=\"/profile\" element={<Profile />} />|<Route path=\"/profile\" element={<Profile />} />\n          <Route path=\"/dashboard\" element={<Dashboard />} />|" src/App.tsx

# Add Dashboard link to navbar
python3 << 'PYEOF'
with open("src/components/layout/Navbar.tsx","r") as f: c = f.read()
c = c.replace(
    '<a href="/profile"',
    '<a href="/dashboard" className="text-sm font-medium text-black/50 hover:text-[#F5A623] transition-colors mr-2">Dashboard</a>\n              <a href="/profile"'
)
with open("src/components/layout/Navbar.tsx","w") as f: f.write(c)
print("done")
PYEOF

echo "✅ Dashboard done!"
npm run dev
