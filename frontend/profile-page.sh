#!/bin/bash
set -e
cd ~/firststep/frontend
echo "👤 Building Profile/Settings page..."

cat > src/components/pages/Profile.tsx << 'EOF'
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { User, Bell, Lock, MapPin, Check, Loader2, LogOut, ChevronRight, X } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

const SECTORS = ['Any sector','Retail & FMCG','Banking & Finance','IT & Digital','Construction','Healthcare','Education','Hospitality','Administration','Transport & Logistics','Engineering','Legal','Social Services']
const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']

const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

export default function Profile() {
  const { user, logout } = useAuthStore()
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState<'profile'|'notifications'|'security'>('profile')

  // Profile form
  const [fullName, setFullName]   = useState(user?.full_name || '')
  const [phone, setPhone]         = useState('')
  const [province, setProvince]   = useState(user?.province || '')
  const [city, setCity]           = useState(user?.city || '')
  const [saving, setSaving]       = useState(false)
  const [saved, setSaved]         = useState(false)

  // Notification prefs
  const [sector, setSector]       = useState('Any sector')
  const [alertProvince, setAlertProv] = useState('All Provinces')
  const [emailAlerts, setEmailAlerts] = useState(true)
  const [savingPrefs, setSavingPrefs] = useState(false)
  const [savedPrefs, setSavedPrefs]   = useState(false)
  const [testSent, setTestSent]       = useState(false)
  const [testLoading, setTestLoading] = useState(false)

  // Password
  const [oldPass, setOldPass]     = useState('')
  const [newPass, setNewPass]     = useState('')
  const [savingPass, setSavingPass] = useState(false)
  const [passMsg, setPassMsg]     = useState('')

  useEffect(() => { if (!user) navigate('/login') }, [user])

  const saveProfile = async () => {
    setSaving(true)
    try {
      await api.patch('/auth/me', { full_name: fullName, phone, province, city })
      setSaved(true); setTimeout(()=>setSaved(false), 2000)
    } catch(e) { console.error(e) }
    finally { setSaving(false) }
  }

  const saveNotifPrefs = async () => {
    setSavingPrefs(true)
    try {
      await api.post('/notifications/preferences', {
        email_alerts: emailAlerts,
        preferred_sector: sector === 'Any sector' ? '' : sector,
        preferred_province: alertProvince === 'All Provinces' ? '' : alertProvince,
      })
      setSavedPrefs(true); setTimeout(()=>setSavedPrefs(false), 2000)
    } catch(e) { console.error(e) }
    finally { setSavingPrefs(false) }
  }

  const sendTestEmail = async () => {
    setTestLoading(true)
    try {
      await api.post('/notifications/test')
      setTestSent(true); setTimeout(()=>setTestSent(false), 3000)
    } catch(e) { console.error(e) }
    finally { setTestLoading(false) }
  }

  const handleLogout = () => { logout(); navigate('/') }

  const tabs = [
    { id:'profile',       label:'Profile',       icon:User },
    { id:'notifications', label:'Job Alerts',     icon:Bell },
    { id:'security',      label:'Security',       icon:Lock },
  ]

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Header */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-8">
        <div className="max-w-3xl mx-auto flex items-center justify-between">
          <div>
            <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-1">Account</p>
            <h1 className="font-display text-2xl font-bold text-white">
              Hi, {user?.full_name?.split(' ')[0]} 👋
            </h1>
            <p className="text-white/40 text-sm mt-0.5">{user?.email}</p>
          </div>
          <div className="w-14 h-14 rounded-2xl bg-[#F5A623] flex items-center justify-center text-2xl font-bold text-[#1A1A0F]">
            {user?.full_name?.[0]?.toUpperCase() || '?'}
          </div>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 md:px-6 py-6">
        {/* Tabs */}
        <div className="flex gap-2 mb-6 overflow-x-auto" style={{scrollbarWidth:'none'}}>
          {tabs.map(t => (
            <button key={t.id} onClick={()=>setActiveTab(t.id as any)}
              className={clsx('flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all border flex-shrink-0',
                activeTab===t.id ? 'bg-[#1A1A0F] text-white border-transparent' : 'bg-white border-black/10 text-black/55 hover:border-black/20')}>
              <t.icon size={14}/>{t.label}
            </button>
          ))}
        </div>

        {/* PROFILE TAB */}
        {activeTab==='profile' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
              <h2 className="font-display text-lg font-bold text-[#1A1A0F] mb-5">Personal details</h2>
              <div className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div><label className={lbl}>Full name</label><input className={inp} value={fullName} onChange={e=>setFullName(e.target.value)} placeholder="Your full name"/></div>
                  <div><label className={lbl}>Phone</label><input className={inp} value={phone} onChange={e=>setPhone(e.target.value)} placeholder="071 234 5678"/></div>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className={lbl}>Province</label>
                    <select className={inp+' appearance-none'} value={province} onChange={e=>setProvince(e.target.value)}>
                      <option value="">Select province…</option>
                      {PROVINCES.filter(p=>p!=='All Provinces').map(p=><option key={p}>{p}</option>)}
                    </select>
                  </div>
                  <div><label className={lbl}>City / Town</label><input className={inp} value={city} onChange={e=>setCity(e.target.value)} placeholder="Cape Town"/></div>
                </div>
                <div><label className={lbl}>Email</label><input className={inp+' opacity-50 cursor-not-allowed'} value={user?.email || ''} disabled/></div>
              </div>
              <button onClick={saveProfile} disabled={saving} className="btn-amber mt-5 flex items-center gap-2 !py-2.5">
                {saving ? <Loader2 size={14} className="animate-spin"/> : saved ? <Check size={14}/> : null}
                {saved ? 'Saved!' : 'Save changes'}
              </button>
            </div>

            {/* Quick links */}
            <div className="bg-white rounded-2xl border border-black/8 shadow-sm overflow-hidden">
              {[
                { label:'Build my CV', desc:'Update your professional CV', href:'/cv', color:'text-[#F5A623]' },
                { label:'Browse learnerships', desc:'600+ live SA opportunities', href:'/learnerships', color:'text-blue-500' },
                { label:'AI Coach', desc:'Get career advice', href:'/coach', color:'text-purple-500' },
              ].map((l,i) => (
                <a key={l.label} href={l.href} className={clsx('flex items-center justify-between px-5 py-4 hover:bg-[#F7F3EB] transition-colors',i>0&&'border-t border-black/6')}>
                  <div>
                    <div className={clsx('font-semibold text-sm', l.color)}>{l.label}</div>
                    <div className="text-xs text-black/40">{l.desc}</div>
                  </div>
                  <ChevronRight size={16} className="text-black/25"/>
                </a>
              ))}
            </div>

            {/* Logout */}
            <button onClick={handleLogout} className="w-full flex items-center justify-center gap-2 text-sm font-semibold text-red-500 hover:text-red-600 bg-white border border-red-200 hover:border-red-300 rounded-2xl py-3.5 transition-all">
              <LogOut size={15}/> Log out
            </button>
          </div>
        )}

        {/* NOTIFICATIONS TAB */}
        {activeTab==='notifications' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
              <div className="flex items-center gap-3 mb-5">
                <div className="w-10 h-10 rounded-xl bg-[#F5A623]/15 flex items-center justify-center flex-shrink-0">
                  <Bell size={18} className="text-[#F5A623]"/>
                </div>
                <div>
                  <div className="font-bold text-sm text-[#1A1A0F]">Job Alert Emails</div>
                  <div className="text-xs text-black/40">Get notified when new learnerships match your profile</div>
                </div>
                <div className="ml-auto">
                  <div onClick={()=>setEmailAlerts(!emailAlerts)} className={clsx('w-10 h-[22px] rounded-full transition-all relative cursor-pointer flex-shrink-0',emailAlerts?'bg-[#F5A623]':'bg-black/12')}>
                    <div className={clsx('absolute top-[3px] w-4 h-4 rounded-full bg-white shadow-sm transition-all',emailAlerts?'left-5':'left-[3px]')}/>
                  </div>
                </div>
              </div>

              <div className="space-y-3 mb-5">
                <div>
                  <label className={lbl}>Preferred sector</label>
                  <select className={inp+' appearance-none'} value={sector} onChange={e=>setSector(e.target.value)}>
                    {SECTORS.map(s=><option key={s}>{s}</option>)}
                  </select>
                </div>
                <div>
                  <label className={lbl}>Your province</label>
                  <select className={inp+' appearance-none'} value={alertProvince} onChange={e=>setAlertProv(e.target.value)}>
                    {PROVINCES.map(p=><option key={p}>{p}</option>)}
                  </select>
                </div>
              </div>

              <div className="flex gap-2">
                <button onClick={saveNotifPrefs} disabled={savingPrefs} className="btn-amber flex-1 flex items-center justify-center gap-2 !py-2.5 text-sm">
                  {savingPrefs?<Loader2 size={14} className="animate-spin"/>:savedPrefs?<Check size={14}/>:<Bell size={14}/>}
                  {savedPrefs?'Saved!':'Save preferences'}
                </button>
                <button onClick={sendTestEmail} disabled={testLoading} className="flex items-center gap-1.5 text-sm font-semibold px-4 py-2.5 rounded-xl border border-black/10 bg-white hover:bg-[#F7F3EB] transition-colors whitespace-nowrap">
                  {testLoading?<Loader2 size={13} className="animate-spin"/>:testSent?'✓ Sent!':'📧 Test email'}
                </button>
              </div>
              {testSent&&<p className="text-xs text-green-600 mt-2 text-center font-medium">Test email sent to {user?.email}! Check your inbox.</p>}
            </div>

            <div className="bg-[#F5A623]/10 border border-[#F5A623]/20 rounded-2xl p-4">
              <p className="text-sm text-[#1A1A0F] font-semibold mb-1">📬 How job alerts work</p>
              <p className="text-sm text-black/50 leading-relaxed">When new learnerships matching your sector and province appear on FirstStep, we'll email you automatically. We never spam — only relevant opportunities.</p>
            </div>
          </div>
        )}

        {/* SECURITY TAB */}
        {activeTab==='security' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
              <h2 className="font-display text-lg font-bold text-[#1A1A0F] mb-5">Change password</h2>
              <div className="space-y-3">
                <div><label className={lbl}>Current password</label><input className={inp} type="password" value={oldPass} onChange={e=>setOldPass(e.target.value)} placeholder="••••••••"/></div>
                <div><label className={lbl}>New password</label><input className={inp} type="password" value={newPass} onChange={e=>setNewPass(e.target.value)} placeholder="••••••••"/></div>
              </div>
              {passMsg && <p className={clsx('text-sm mt-3 font-medium', passMsg.includes('successfully') ? 'text-green-600' : 'text-red-500')}>{passMsg}</p>}
              <button onClick={async()=>{
                setSavingPass(true)
                try {
                  await api.post('/auth/change-password', { old_password: oldPass, new_password: newPass })
                  setPassMsg('Password changed successfully!'); setOldPass(''); setNewPass('')
                } catch { setPassMsg('Incorrect current password.') }
                finally { setSavingPass(false) }
              }} disabled={savingPass||!oldPass||!newPass} className="btn-amber mt-5 flex items-center gap-2 !py-2.5 disabled:opacity-50">
                {savingPass?<Loader2 size={14} className="animate-spin"/>:<Lock size={14}/>}
                Update password
              </button>
            </div>

            <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
              <h2 className="font-bold text-sm text-[#1A1A0F] mb-1">Account info</h2>
              <div className="space-y-2 text-sm text-black/50">
                <div className="flex justify-between"><span>Email</span><span className="font-medium text-[#1A1A0F]">{user?.email}</span></div>
                <div className="flex justify-between"><span>Account ID</span><span className="font-mono text-xs">{user?.id?.slice(0,8)}…</span></div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
EOF

# Add route to App.tsx
sed -i "s|import LAP from './components/pages/LAP'|import LAP from './components/pages/LAP'\nimport Profile from './components/pages/Profile'|" src/App.tsx
sed -i "s|<Route path=\"/lap\" element={<LAP />} />|<Route path=\"/lap\" element={<LAP />} />\n          <Route path=\"/profile\" element={<Profile />} />|" src/App.tsx

# Add profile link to navbar
python3 << 'PYEOF'
with open("src/components/layout/Navbar.tsx","r") as f: c = f.read()
# Add profile link next to "Hi, Name"
c = c.replace(
    "Hi, {user.full_name?.split(' ')[0]}",
    "Hi, {user.full_name?.split(' ')[0]}"
)
# Find the Hi name span and make it a link
c = c.replace(
    "<span className=\"text-sm font-medium text-[#1A1A0F]\">Hi, {user.full_name?.split(' ')[0]}</span>",
    "<a href=\"/profile\" className=\"text-sm font-medium text-[#1A1A0F] hover:text-[#F5A623] transition-colors\">Hi, {user.full_name?.split(' ')[0]}</a>"
)
with open("src/components/layout/Navbar.tsx","w") as f: f.write(c)
print("done")
PYEOF

echo "✅ Profile page done!"
npm run dev
