import { useState } from 'react'
import { Bell, Check, Loader2 } from 'lucide-react'
import api from '../lib/api'
import clsx from 'clsx'

const SECTORS = ['Any sector','Retail & FMCG','Banking & Finance','IT & Digital','Construction','Healthcare','Education','Hospitality','Administration','Transport & Logistics']
const PROVINCES = ['All Provinces','Western Cape','Gauteng','KwaZulu-Natal','Eastern Cape','Limpopo','Mpumalanga','North West','Free State','Northern Cape']

export default function NotificationPrefs() {
  const [sector, setSector]   = useState('Any sector')
  const [province, setProv]   = useState('All Provinces')
  const [saving, setSaving]   = useState(false)
  const [saved, setSaved]     = useState(false)
  const [testing, setTesting] = useState(false)
  const [tested, setTested]   = useState(false)

  const save = async () => {
    setSaving(true)
    try {
      await api.post('/notifications/preferences', {
        email_alerts: true,
        preferred_sector: sector === 'Any sector' ? '' : sector,
        preferred_province: province === 'All Provinces' ? '' : province,
      })
      setSaved(true); setTimeout(()=>setSaved(false), 2000)
    } catch(e){ console.error(e) }
    finally { setSaving(false) }
  }

  const sendTest = async () => {
    setTesting(true)
    try {
      await api.post('/notifications/test')
      setTested(true); setTimeout(()=>setTested(false), 3000)
    } catch(e){ console.error(e) }
    finally { setTesting(false) }
  }

  const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 transition-all appearance-none"

  return (
    <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
      <div className="flex items-center gap-3 mb-5">
        <div className="w-10 h-10 rounded-xl bg-[#F5A623]/15 flex items-center justify-center">
          <Bell size={18} className="text-[#F5A623]"/>
        </div>
        <div>
          <div className="font-bold text-sm text-[#1A1A0F]">Job Alert Notifications</div>
          <div className="text-xs text-black/40">Get emailed when new learnerships match your profile</div>
        </div>
      </div>

      <div className="space-y-3 mb-5">
        <div>
          <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Preferred sector</label>
          <select className={inp} value={sector} onChange={e=>setSector(e.target.value)}>
            {SECTORS.map(s=><option key={s}>{s}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5">Your province</label>
          <select className={inp} value={province} onChange={e=>setProv(e.target.value)}>
            {PROVINCES.map(p=><option key={p}>{p}</option>)}
          </select>
        </div>
      </div>

      <div className="flex gap-2">
        <button onClick={save} disabled={saving} className="btn-amber flex-1 flex items-center justify-center gap-2 !py-2.5 text-sm font-bold">
          {saving ? <Loader2 size={14} className="animate-spin"/> : saved ? <Check size={14}/> : <Bell size={14}/>}
          {saved ? 'Saved!' : 'Save preferences'}
        </button>
        <button onClick={sendTest} disabled={testing} className="flex items-center gap-1.5 text-sm font-semibold px-4 py-2.5 rounded-xl border border-black/10 hover:bg-[#F7F3EB] transition-colors">
          {testing ? <Loader2 size={13} className="animate-spin"/> : tested ? '✓ Sent!' : '📧 Test'}
        </button>
      </div>
      {tested && <p className="text-xs text-green-600 mt-2 text-center">Test email sent! Check your inbox.</p>}
    </div>
  )
}
