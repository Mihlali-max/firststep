#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🎨 Building final CV builder..."

cat > src/components/pages/CVBuilder.tsx << 'EOF'
import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, Trash2, Loader2, Eye, Settings, X } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

// ── Types
interface PI  { name:string; title:string; email:string; phone:string; location:string; summary:string; linkedin:string }
interface Edu { school:string; qualification:string; year:string }
interface Exp { title:string; org:string; start:string; end:string; desc:string; volunteer:boolean }
interface Ref { name:string; relation:string; contact:string }
interface CV  { pi:PI; edu:Edu[]; skills:string[]; exp:Exp[]; refs:Ref[] }
interface Opts { template:string; color:string; showPhone:boolean; showLoc:boolean; showLinkedin:boolean; showRefs:boolean }

const EMPTY:CV = {
  pi:{ name:'', title:'', email:'', phone:'', location:'', summary:'', linkedin:'' },
  edu:[{school:'',qualification:'',year:''}],
  skills:[], exp:[], refs:[],
}
const DEF_OPTS:Opts = { template:'executive', color:'#1A1A0F', showPhone:true, showLoc:true, showLinkedin:false, showRefs:true }

const SKILLS = ['Communication','Microsoft Office','Customer service','Teamwork','Time management','Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling','Basic accounting','Attention to detail','Computer literacy','Adaptability','Leadership','Filing & admin','Telephone etiquette','Forklift licence','First Aid','Report writing']
const COLORS = ['#1A1A0F','#1565C0','#2A5C3F','#7B1FA2','#C62828','#E65100','#00838F','#558B2F','#4A148C','#880E4F']
const STEPS  = ['Template','Personal','Education','Skills','Experience','References']

const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/30 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/70 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

// ══════════════════════════════
// CV TEMPLATES
// ══════════════════════════════

function TemplateExecutive({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ display:'flex', width:'100%', minHeight:'100%', fontFamily:'sans-serif', fontSize:'9px', lineHeight:'1.6', background:'white' }}>
      <div style={{ width:'36%', background:c, color:'white', padding:'24px 16px', flexShrink:0, display:'flex', flexDirection:'column', gap:12 }}>
        <div style={{ textAlign:'center', paddingBottom:12, borderBottom:'1px solid rgba(255,255,255,0.2)' }}>
          <div style={{ width:56, height:56, borderRadius:'50%', background:'rgba(255,255,255,0.2)', margin:'0 auto 8px', display:'flex', alignItems:'center', justifyContent:'center', fontSize:20, fontWeight:700, border:'2px solid rgba(255,255,255,0.4)' }}>{p.name?p.name[0].toUpperCase():'Y'}</div>
          <div style={{ fontSize:12, fontWeight:700, letterSpacing:'-0.3px' }}>{p.name||'Your Name'}</div>
          {p.title&&<div style={{ fontSize:7.5, opacity:0.7, marginTop:2, letterSpacing:'1px', textTransform:'uppercase' }}>{p.title}</div>}
        </div>
        <div>
          <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:6 }}>Contact</div>
          {p.email&&<div style={{ marginBottom:3, opacity:0.9, wordBreak:'break-all', fontSize:8 }}>✉ {p.email}</div>}
          {opts.showPhone&&p.phone&&<div style={{ marginBottom:3, opacity:0.9 }}>📞 {p.phone}</div>}
          {opts.showLoc&&p.location&&<div style={{ marginBottom:3, opacity:0.9 }}>📍 {p.location}</div>}
          {opts.showLinkedin&&p.linkedin&&<div style={{ marginBottom:3, opacity:0.9, wordBreak:'break-all' }}>in {p.linkedin}</div>}
        </div>
        {cv.skills.length>0&&(
          <div>
            <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:6 }}>Skills</div>
            {cv.skills.map(s=><div key={s} style={{ marginBottom:5 }}>
              <div style={{ marginBottom:2, fontSize:8 }}>{s}</div>
              <div style={{ height:2.5, background:'rgba(255,255,255,0.2)', borderRadius:2 }}><div style={{ height:2.5, background:'rgba(255,255,255,0.75)', borderRadius:2, width:'80%' }}/></div>
            </div>)}
          </div>
        )}
        {opts.showRefs&&cv.refs.some(r=>r.name)&&(
          <div>
            <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:6 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:7 }}>
              <div style={{ fontWeight:600, fontSize:8.5 }}>{r.name}</div>
              <div style={{ opacity:0.65, fontSize:7.5 }}>{r.relation}</div>
              {r.contact&&<div style={{ opacity:0.5, fontSize:7 }}>{r.contact}</div>}
            </div>)}
          </div>
        )}
      </div>
      <div style={{ flex:1, padding:'24px 18px' }}>
        {p.summary&&<div style={{ marginBottom:14, paddingBottom:10, borderBottom:`2px solid ${c}20` }}>
          <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:5 }}>Profile</div>
          <p style={{ color:'#374151', lineHeight:1.75 }}>{p.summary}</p>
        </div>}
        {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:14 }}>
          <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7, display:'flex', alignItems:'center', gap:6 }}>
            <span>Experience</span><div style={{ flex:1, height:1, background:`${c}25` }}/>
          </div>
          {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:9, paddingLeft:8, borderLeft:`2px solid ${c}30` }}>
            <div style={{ display:'flex', justifyContent:'space-between', marginBottom:1 }}>
              <span style={{ fontWeight:700, color:'#111', fontSize:9.5 }}>{e.title}{e.volunteer?' (Vol.)':''}</span>
              <span style={{ color:'#9CA3AF', fontSize:7.5 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
            </div>
            {e.org&&<div style={{ color:c, fontSize:7.5, marginBottom:2 }}>{e.org}</div>}
            {e.desc&&<div style={{ color:'#6B7280', fontSize:8 }}>{e.desc}</div>}
          </div>)}
        </div>}
        {cv.edu.some(e=>e.school)&&<div>
          <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7, display:'flex', alignItems:'center', gap:6 }}>
            <span>Education</span><div style={{ flex:1, height:1, background:`${c}25` }}/>
          </div>
          {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8, paddingLeft:8, borderLeft:`2px solid ${c}30` }}>
            <div style={{ display:'flex', justifyContent:'space-between' }}>
              <span style={{ fontWeight:700, color:'#111', fontSize:9.5 }}>{e.qualification}</span>
              <span style={{ color:'#9CA3AF', fontSize:7.5 }}>{e.year}</span>
            </div>
            <div style={{ color:'#6B7280' }}>{e.school}</div>
          </div>)}
        </div>}
      </div>
    </div>
  )
}

function TemplateCreative({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'100%', fontFamily:'sans-serif', fontSize:'9px', lineHeight:'1.6', background:'#FAFAFA' }}>
      <div style={{ background:c, padding:'20px 24px', position:'relative', overflow:'hidden' }}>
        <div style={{ position:'absolute', right:-30, top:-30, width:120, height:120, borderRadius:'50%', background:'rgba(255,255,255,0.08)' }}/>
        <div style={{ position:'absolute', right:30, bottom:-25, width:80, height:80, borderRadius:'50%', background:'rgba(255,255,255,0.05)' }}/>
        <div style={{ position:'relative' }}>
          <div style={{ fontSize:20, fontWeight:900, color:'white', letterSpacing:'-0.5px', marginBottom:2 }}>{p.name||'Your Name'}</div>
          {p.title&&<div style={{ fontSize:8, color:'rgba(255,255,255,0.7)', letterSpacing:'2px', textTransform:'uppercase', marginBottom:8 }}>{p.title}</div>}
          <div style={{ display:'flex', flexWrap:'wrap', gap:10, color:'rgba(255,255,255,0.8)', fontSize:7.5 }}>
            {p.email&&<span>✉ {p.email}</span>}
            {opts.showPhone&&p.phone&&<span>📞 {p.phone}</span>}
            {opts.showLoc&&p.location&&<span>📍 {p.location}</span>}
          </div>
        </div>
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 170px' }}>
        <div style={{ padding:'16px 20px', borderRight:'1px solid #E5E7EB' }}>
          {p.summary&&<div style={{ marginBottom:12 }}>
            <div style={{ fontSize:7, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:5 }}>About</div>
            <p style={{ color:'#4B5563', lineHeight:1.75 }}>{p.summary}</p>
          </div>}
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:12 }}>
            <div style={{ fontSize:7, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7 }}>Experience</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:10, paddingBottom:8, borderBottom:'1px solid #F3F4F6' }}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
                <div><div style={{ fontWeight:700, fontSize:9.5, color:'#111' }}>{e.title}{e.volunteer?' (Vol.)':''}</div>{e.org&&<div style={{ color:c, fontSize:7.5, fontWeight:600 }}>{e.org}</div>}</div>
                <div style={{ background:`${c}15`, color:c, fontSize:7, padding:'1.5px 6px', borderRadius:20, fontWeight:600, whiteSpace:'nowrap' }}>{[e.start,e.end].filter(Boolean).join('–')}</div>
              </div>
              {e.desc&&<p style={{ color:'#6B7280', marginTop:3, lineHeight:1.6 }}>{e.desc}</p>}
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:7, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7 }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:7, display:'flex', justifyContent:'space-between' }}>
              <div><div style={{ fontWeight:700, fontSize:9.5, color:'#111' }}>{e.qualification}</div><div style={{ color:'#6B7280' }}>{e.school}</div></div>
              {e.year&&<div style={{ background:`${c}15`, color:c, fontSize:7, padding:'1.5px 6px', borderRadius:20, fontWeight:600 }}>{e.year}</div>}
            </div>)}
          </div>}
        </div>
        <div style={{ padding:'16px 12px', background:'#F9FAFB' }}>
          {cv.skills.length>0&&<div style={{ marginBottom:12 }}>
            <div style={{ fontSize:7, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7 }}>Skills</div>
            <div style={{ display:'flex', flexWrap:'wrap', gap:3 }}>
              {cv.skills.map(s=><div key={s} style={{ background:`${c}15`, color:c, border:`1px solid ${c}30`, fontSize:7, padding:'2px 7px', borderRadius:20, fontWeight:600 }}>{s}</div>)}
            </div>
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:7, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:7 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:7, paddingBottom:5, borderBottom:'1px solid #E5E7EB' }}>
              <div style={{ fontWeight:700, fontSize:8.5, color:'#111' }}>{r.name}</div>
              <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF', fontSize:7 }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

function TemplateMinimal({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'100%', fontFamily:'Georgia, serif', fontSize:'9px', lineHeight:'1.7', padding:'36px 40px', background:'white' }}>
      <div style={{ marginBottom:20, paddingBottom:14, borderBottom:'1px solid #E5E7EB' }}>
        <div style={{ fontSize:24, fontWeight:300, letterSpacing:'0.08em', color:'#111', marginBottom:3, fontFamily:'sans-serif', textTransform:'uppercase' }}>{p.name||'Your Name'}</div>
        {p.title&&<div style={{ fontSize:8, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', marginBottom:7, fontFamily:'sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex', flexWrap:'wrap', gap:14, color:'#6B7280', fontSize:7.5, fontFamily:'sans-serif' }}>
          {p.email&&<span>{p.email}</span>}
          {opts.showPhone&&p.phone&&<span>{p.phone}</span>}
          {opts.showLoc&&p.location&&<span>{p.location}</span>}
          {opts.showLinkedin&&p.linkedin&&<span>{p.linkedin}</span>}
        </div>
        {p.summary&&<p style={{ marginTop:8, color:'#4B5563', lineHeight:1.8, fontStyle:'italic' }}>{p.summary}</p>}
      </div>
      {[
        cv.exp.some(e=>e.title)&&{ title:'Experience', rows: cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ display:'grid', gridTemplateColumns:'90px 1fr', gap:12, marginBottom:10 }}>
          <div style={{ color:'#9CA3AF', fontSize:7.5, paddingTop:1, fontFamily:'sans-serif' }}>{[e.start,e.end].filter(Boolean).join('–')||'—'}</div>
          <div><div style={{ fontWeight:700, color:'#111', fontSize:9.5, fontFamily:'sans-serif' }}>{e.title}{e.volunteer?' (Vol.)':''}</div>{e.org&&<div style={{ color:c, fontSize:7.5, fontFamily:'sans-serif' }}>{e.org}</div>}{e.desc&&<p style={{ color:'#6B7280', marginTop:2 }}>{e.desc}</p>}</div>
        </div>) },
        cv.edu.some(e=>e.school)&&{ title:'Education', rows: cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ display:'grid', gridTemplateColumns:'90px 1fr', gap:12, marginBottom:7 }}>
          <div style={{ color:'#9CA3AF', fontSize:7.5, paddingTop:1, fontFamily:'sans-serif' }}>{e.year||'—'}</div>
          <div><div style={{ fontWeight:700, color:'#111', fontSize:9.5, fontFamily:'sans-serif' }}>{e.qualification}</div><div style={{ color:'#6B7280', fontFamily:'sans-serif' }}>{e.school}</div></div>
        </div>) },
        cv.skills.length>0&&{ title:'Skills', rows: <div style={{ display:'flex', flexWrap:'wrap', gap:5 }}>{cv.skills.map(s=><span key={s} style={{ color:'#4B5563', fontSize:7.5, fontFamily:'sans-serif' }}>· {s}</span>)}</div> },
        opts.showRefs&&cv.refs.some(r=>r.name)&&{ title:'References', rows: <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>{cv.refs.filter(r=>r.name).map((r,i)=><div key={i}><div style={{ fontWeight:700, color:'#111', fontFamily:'sans-serif' }}>{r.name}</div><div style={{ color:'#9CA3AF', fontSize:7.5, fontFamily:'sans-serif', fontStyle:'italic' }}>{r.relation}</div>{r.contact&&<div style={{ color:'#9CA3AF', fontSize:7, fontFamily:'sans-serif' }}>{r.contact}</div>}</div>)}</div> },
      ].filter(Boolean).map((sec:any,i)=>sec&&<div key={i} style={{ marginBottom:16 }}>
        <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:8 }}>
          <div style={{ fontSize:7, fontWeight:600, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', fontFamily:'sans-serif' }}>{sec.title}</div>
          <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
        </div>
        {sec.rows}
      </div>)}
    </div>
  )
}

function TemplateElegant({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'100%', fontFamily:'Georgia, serif', fontSize:'9px', lineHeight:'1.65', background:'white' }}>
      <div style={{ padding:'28px 32px 20px', textAlign:'center', borderBottom:`3px solid ${c}`, position:'relative' }}>
        <div style={{ position:'absolute', top:10, left:16, width:16, height:16, borderTop:`2px solid ${c}`, borderLeft:`2px solid ${c}` }}/>
        <div style={{ position:'absolute', top:10, right:16, width:16, height:16, borderTop:`2px solid ${c}`, borderRight:`2px solid ${c}` }}/>
        <div style={{ fontSize:22, fontWeight:400, letterSpacing:'0.12em', color:'#111', marginBottom:3, fontFamily:'sans-serif', textTransform:'uppercase' }}>{p.name||'Your Name'}</div>
        {p.title&&<div style={{ fontSize:7.5, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', marginBottom:7, fontFamily:'sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex', justifyContent:'center', flexWrap:'wrap', gap:14, color:'#6B7280', fontSize:7.5, fontFamily:'sans-serif' }}>
          {p.email&&<span>{p.email}</span>}
          {opts.showPhone&&p.phone&&<span>{p.phone}</span>}
          {opts.showLoc&&p.location&&<span>{p.location}</span>}
        </div>
        {p.summary&&<p style={{ marginTop:8, color:'#4B5563', fontStyle:'italic', lineHeight:1.8, maxWidth:'80%', margin:'8px auto 0' }}>{p.summary}</p>}
      </div>
      <div style={{ padding:'18px 32px', display:'grid', gridTemplateColumns:'1fr 160px', gap:20 }}>
        <div>
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:7, letterSpacing:'3px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'sans-serif', display:'flex', alignItems:'center', gap:7 }}>
              <div style={{ flex:1, height:1, background:`${c}30` }}/><span>Experience</span><div style={{ flex:1, height:1, background:`${c}30` }}/>
            </div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:9 }}>
              <div style={{ display:'flex', justifyContent:'space-between' }}>
                <span style={{ fontWeight:700, color:'#111', fontFamily:'sans-serif', fontSize:9.5 }}>{e.title}{e.volunteer?' (Vol.)':''}</span>
                <span style={{ color:'#9CA3AF', fontSize:7.5, fontFamily:'sans-serif' }}>{[e.start,e.end].filter(Boolean).join('–')}</span>
              </div>
              {e.org&&<div style={{ color:c, fontSize:7.5, fontFamily:'sans-serif', fontStyle:'italic' }}>{e.org}</div>}
              {e.desc&&<p style={{ color:'#6B7280', marginTop:2 }}>{e.desc}</p>}
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:7, letterSpacing:'3px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'sans-serif', display:'flex', alignItems:'center', gap:7 }}>
              <div style={{ flex:1, height:1, background:`${c}30` }}/><span>Education</span><div style={{ flex:1, height:1, background:`${c}30` }}/>
            </div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:7 }}>
              <div style={{ display:'flex', justifyContent:'space-between' }}>
                <span style={{ fontWeight:700, color:'#111', fontFamily:'sans-serif', fontSize:9.5 }}>{e.qualification}</span>
                <span style={{ color:'#9CA3AF', fontSize:7.5, fontFamily:'sans-serif' }}>{e.year}</span>
              </div>
              <div style={{ color:'#6B7280', fontFamily:'sans-serif' }}>{e.school}</div>
            </div>)}
          </div>}
        </div>
        <div>
          {cv.skills.length>0&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:7, letterSpacing:'3px', textTransform:'uppercase', color:c, marginBottom:7, fontFamily:'sans-serif' }}>Skills</div>
            {cv.skills.map(s=><div key={s} style={{ marginBottom:4, display:'flex', alignItems:'center', gap:5 }}>
              <div style={{ width:3.5, height:3.5, background:c, flexShrink:0, transform:'rotate(45deg)' }}/>
              <span style={{ color:'#374151', fontFamily:'sans-serif' }}>{s}</span>
            </div>)}
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:7, letterSpacing:'3px', textTransform:'uppercase', color:c, marginBottom:7, fontFamily:'sans-serif' }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:7 }}>
              <div style={{ fontWeight:700, color:'#111', fontFamily:'sans-serif', fontSize:8.5 }}>{r.name}</div>
              <div style={{ color:'#9CA3AF', fontSize:7.5, fontFamily:'sans-serif', fontStyle:'italic' }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF', fontSize:7, fontFamily:'sans-serif' }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
      <div style={{ height:3, background:`linear-gradient(90deg, transparent, ${c}, transparent)` }}/>
    </div>
  )
}

const TEMPLATES = [
  { id:'executive', name:'Executive',   desc:'Sidebar · Skill bars' },
  { id:'creative',  name:'Creative',    desc:'Bold header · Badges' },
  { id:'minimal',   name:'Minimal',     desc:'Clean · Typography' },
  { id:'elegant',   name:'Elegant',     desc:'Serif · Decorative' },
]

function Preview({ cv, opts }:{ cv:CV; opts:Opts }) {
  if (opts.template==='executive') return <TemplateExecutive cv={cv} opts={opts}/>
  if (opts.template==='creative')  return <TemplateCreative  cv={cv} opts={opts}/>
  if (opts.template==='minimal')   return <TemplateMinimal   cv={cv} opts={opts}/>
  if (opts.template==='elegant')   return <TemplateElegant   cv={cv} opts={opts}/>
  return <TemplateExecutive cv={cv} opts={opts}/>
}

// ── Main component
export default function CVBuilder() {
  const { user } = useAuthStore()
  const navigate  = useNavigate()
  const [step, setStep]     = useState(0)
  const [cv, setCv]         = useState<CV>(EMPTY)
  const [opts, setOpts]     = useState<Opts>(DEF_OPTS)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved]   = useState(false)
  const [custom, setCustom] = useState('')
  const [showPreview, setShowPreview] = useState(false) // mobile preview sheet

  useEffect(() => { if (!user) navigate('/register') }, [user])

  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      setCv({
        pi:    d.personal_info || EMPTY.pi,
        edu:   d.education?.length ? d.education : EMPTY.edu,
        skills: d.skills || [],
        exp:   (d.experience || []).map((e:any) => ({ title:e.title||'', org:e.organisation||'', start:e.start_date||'', end:e.end_date||'', desc:e.description||'', volunteer:e.is_volunteer||false })),
        refs:  d.references || [],
      })
    }).catch(()=>{})
  }, [])

  const setOpt = (k:keyof Opts, v:any) => setOpts(o=>({...o,[k]:v}))
  const pct = () => {
    let s=0
    if(cv.pi?.name) s+=25
    if(cv.edu?.some(e=>e.school)) s+=20
    if(cv.skills?.length) s+=20
    if(cv.exp?.some(e=>e.title)) s+=20
    if(cv.refs?.some(r=>r.name)) s+=15
    return s
  }

  const save = async () => {
    setSaving(true)
    try {
      await api.patch('/cv', {
        personal_info: cv.pi,
        education:     cv.edu.filter(e=>e.school),
        skills:        cv.skills,
        experience:    cv.exp.filter(e=>e.title).map(e=>({ title:e.title, organisation:e.org, start_date:e.start, end_date:e.end, description:e.desc, is_volunteer:e.volunteer })),
        references:    cv.refs.filter(r=>r.name),
      })
      setSaved(true); setTimeout(()=>setSaved(false),2000)
    } catch(e){ console.error(e) }
    finally{ setSaving(false) }
  }

  const previewCv:CV = { ...cv, pi:{ ...cv.pi, phone:opts.showPhone?cv.pi.phone:'', location:opts.showLoc?cv.pi.location:'', linkedin:opts.showLinkedin?cv.pi.linkedin:'' }, refs:opts.showRefs?cv.refs:[] }

  // ── Field helpers
  const F = ({ label, children }:{ label:string; children:React.ReactNode }) => (
    <div><label className={lbl}>{label}</label>{children}</div>
  )

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* ── TOP HEADER ── */}
      <div className="bg-[#1A1A0F] px-4 md:px-10 py-6 md:py-8">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-between gap-4 mb-4">
            <div>
              <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-0.5">CV Builder</p>
              <h1 className="font-display text-xl md:text-3xl font-bold text-white tracking-tight">Design your <em className="not-italic text-[#F5A623]">perfect CV.</em></h1>
            </div>
            {/* Mobile preview button */}
            <button onClick={()=>setShowPreview(true)} className="xl:hidden flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white text-sm font-medium px-4 py-2 rounded-xl transition-colors border border-white/15">
              <Eye size={15}/> Preview
            </button>
          </div>

          {/* Progress */}
          <div className="flex items-center gap-3 mb-4">
            <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
              <div className="h-full rounded-full transition-all duration-700 bg-[#F5A623]" style={{ width:pct()+'%' }}/>
            </div>
            <span className="text-white/40 text-xs whitespace-nowrap">{pct()}% complete</span>
          </div>

          {/* Step pills — scrollable on mobile */}
          <div className="flex gap-1.5 overflow-x-auto pb-1 scrollbar-hide">
            {STEPS.map((s,i)=>(
              <button key={s} onClick={()=>setStep(i)}
                className={clsx('flex items-center gap-1.5 text-[11px] font-semibold px-3 py-1.5 rounded-full whitespace-nowrap transition-all flex-shrink-0',
                  i===step?'bg-[#F5A623] text-[#1A1A0F]':i<step?'bg-[#2A5C3F] text-white':'bg-white/8 text-white/40 hover:bg-white/15')}>
                {i<step?<Check size={10}/>:<span className="w-3.5 h-3.5 rounded-full border border-current flex items-center justify-center text-[9px]">{i+1}</span>}
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* ── BODY ── */}
      <div className="max-w-7xl mx-auto px-4 md:px-6 py-5 md:py-7 flex gap-5">

        {/* ── FORM PANEL ── */}
        <div className="flex-1 min-w-0">
          <div className="bg-white rounded-2xl border border-black/8 shadow-sm overflow-hidden">
            <div className="p-5 md:p-8">

              {/* ── STEP 0 — TEMPLATE ── */}
              {step===0&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Choose your template</h2>
                  <p className="text-black/40 text-sm font-light mb-6">Pick a design that matches the job you're going for.</p>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-7">
                    {TEMPLATES.map(t=>(
                      <button key={t.id} onClick={()=>setOpt('template',t.id)}
                        className={clsx('border-2 rounded-2xl p-3 text-left transition-all relative',opts.template===t.id?'border-[#F5A623] bg-[#F5A623]/5 shadow-[0_0_0_3px_rgba(245,166,35,0.12)]':'border-black/8 hover:border-[#F5A623]/40')}>
                        {/* Tiny template visual */}
                        <div className="w-full aspect-[3/4] rounded-xl mb-2.5 overflow-hidden bg-gray-50 border border-black/5">
                          {t.id==='executive'&&<div className="flex h-full"><div className="w-[36%] h-full" style={{background:opts.color}}/><div className="flex-1 p-1.5 space-y-1">{[70,50,80,60,75].map((w,i)=><div key={i} style={{height:2,background:'#eee',width:w+'%',borderRadius:1}}/>)}</div></div>}
                          {t.id==='creative'&&<div className="h-full"><div style={{height:'30%',background:opts.color}}/><div className="grid grid-cols-[1fr_30%] p-1.5 gap-1.5 h-[70%]"><div className="space-y-1">{[80,60,70,90].map((w,i)=><div key={i} style={{height:2,background:'#eee',width:w+'%',borderRadius:1}}/>)}</div><div style={{background:'#f5f5f5'}}></div></div></div>}
                          {t.id==='minimal'&&<div className="p-2 space-y-1.5"><div style={{height:3,background:'#333',width:'55%',borderRadius:1}}/><div style={{height:1.5,background:'#ccc',width:'40%',borderRadius:1}}/><div style={{height:1,background:opts.color,width:'100%',margin:'4px 0'}}/>{[90,70,80,60,85].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',width:w+'%',borderRadius:1}}/>)}</div>}
                          {t.id==='elegant'&&<div className="p-2"><div style={{height:1.5,background:opts.color,width:'100%',marginBottom:4}}/><div style={{textAlign:'center'}}><div style={{height:2.5,background:'#333',width:'50%',margin:'0 auto 2px',borderRadius:1}}/><div style={{height:1.5,background:'#ccc',width:'60%',margin:'0 auto',borderRadius:1}}/></div><div style={{height:1.5,background:opts.color,width:'100%',margin:'4px 0'}}/>{[80,60,70,50].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',width:w+'%',borderRadius:1,marginBottom:2}}/>)}</div>}
                        </div>
                        <div className="font-semibold text-xs text-[#1A1A0F]">{t.name}</div>
                        <div className="text-[10px] text-black/40 mt-0.5">{t.desc}</div>
                        {opts.template===t.id&&<div className="absolute top-2 right-2 w-5 h-5 rounded-full bg-[#F5A623] flex items-center justify-center"><Check size={11} className="text-[#1A1A0F]"/></div>}
                      </button>
                    ))}
                  </div>
                  <h3 className="font-display font-bold text-[#1A1A0F] mb-3 text-sm">Accent colour</h3>
                  <div className="flex gap-2.5 flex-wrap">
                    {COLORS.map(c=>(
                      <button key={c} onClick={()=>setOpt('color',c)}
                        className={clsx('w-8 h-8 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F] shadow-md':'border-transparent hover:scale-105')}
                        style={{background:c}}/>
                    ))}
                  </div>
                </div>
              )}

              {/* ── STEP 1 — PERSONAL ── */}
              {step===1&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Personal info</h2>
                  <p className="text-black/40 text-sm font-light mb-6">Only include what you're comfortable sharing.</p>
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <F label="Full name *"><input className={inp} placeholder="e.g. Lebo Sithole" value={cv.pi.name} onChange={e=>setCv(c=>({...c,pi:{...c.pi,name:e.target.value}}))}/></F>
                      <F label="Job title you want"><input className={inp} placeholder="e.g. Retail Assistant" value={cv.pi.title} onChange={e=>setCv(c=>({...c,pi:{...c.pi,title:e.target.value}}))}/></F>
                    </div>
                    <F label="Email *"><input className={inp} type="email" placeholder="lebo@gmail.com" value={cv.pi.email} onChange={e=>setCv(c=>({...c,pi:{...c.pi,email:e.target.value}}))}/></F>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <div className="flex items-center justify-between mb-1.5">
                          <label className={lbl.replace('mb-1.5','')}>Phone</label>
                          <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showPhone} onChange={e=>setOpt('showPhone',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/40">Show on CV</span></label>
                        </div>
                        <input className={inp} placeholder="071 234 5678" value={cv.pi.phone} onChange={e=>setCv(c=>({...c,pi:{...c.pi,phone:e.target.value}}))}/>
                      </div>
                      <div>
                        <div className="flex items-center justify-between mb-1.5">
                          <label className={lbl.replace('mb-1.5','')}>Location</label>
                          <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLoc} onChange={e=>setOpt('showLoc',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/40">Show on CV</span></label>
                        </div>
                        <input className={inp} placeholder="Cape Town, WC" value={cv.pi.location} onChange={e=>setCv(c=>({...c,pi:{...c.pi,location:e.target.value}}))}/>
                      </div>
                    </div>
                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <label className={lbl.replace('mb-1.5','')}>LinkedIn</label>
                        <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLinkedin} onChange={e=>setOpt('showLinkedin',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/40">Show on CV</span></label>
                      </div>
                      <input className={inp} placeholder="linkedin.com/in/yourname" value={cv.pi.linkedin} onChange={e=>setCv(c=>({...c,pi:{...c.pi,linkedin:e.target.value}}))}/>
                    </div>
                    <F label="Summary"><textarea className={inp+' resize-none'} rows={3} placeholder="A brief intro about yourself and what you're looking for…" value={cv.pi.summary} onChange={e=>setCv(c=>({...c,pi:{...c.pi,summary:e.target.value}}))}/></F>
                  </div>
                </div>
              )}

              {/* ── STEP 2 — EDUCATION ── */}
              {step===2&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Education</h2>
                  <p className="text-black/40 text-sm font-light mb-6">Matric, courses, learnerships — all count.</p>
                  <div className="space-y-4">
                    {cv.edu.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 md:p-5 relative bg-[#FAFAFA]">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,edu:c.edu.filter((_,j)=>j!==i)}))} className="absolute top-3.5 right-3.5 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-3">
                          <F label="School / institution"><input className={inp} placeholder="Khayelitsha High" value={e.school} onChange={ev=>{const ed=[...cv.edu];ed[i].school=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                          <F label="Qualification"><input className={inp} placeholder="Matric Certificate" value={e.qualification} onChange={ev=>{const ed=[...cv.edu];ed[i].qualification=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                        </div>
                        <div className="w-36"><F label="Year"><input className={inp} placeholder="2024" value={e.year} onChange={ev=>{const ed=[...cv.edu];ed[i].year=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F></div>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,edu:[...c.edu,{school:'',qualification:'',year:''}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>
                      Add qualification
                    </button>
                  </div>
                </div>
              )}

              {/* ── STEP 3 — SKILLS ── */}
              {step===3&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Skills</h2>
                  <p className="text-black/40 text-sm font-light mb-5">Tap to select — add your own too.</p>
                  <div className="flex flex-wrap gap-2 mb-5">
                    {SKILLS.map(s=>(
                      <button key={s} onClick={()=>setCv(c=>({...c,skills:c.skills.includes(s)?c.skills.filter(x=>x!==s):[...c.skills,s]}))}
                        className={clsx('text-sm px-4 py-2 rounded-full border-2 transition-all font-medium',cv.skills.includes(s)?'text-white border-transparent shadow-sm':'bg-[#F7F3EB] border-transparent text-black/50 hover:border-black/15')}
                        style={cv.skills.includes(s)?{background:opts.color}:{}}>
                        {cv.skills.includes(s)&&<Check size={11} className="inline mr-1.5 -mt-0.5"/>}{s}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <input className={inp} placeholder="Add your own skill…" value={custom} onChange={e=>setCustom(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}}/>
                    <button onClick={()=>{if(custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-semibold hover:opacity-85 transition-opacity whitespace-nowrap">+ Add</button>
                  </div>
                </div>
              )}

              {/* ── STEP 4 — EXPERIENCE ── */}
              {step===4&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Experience</h2>
                  <div className="bg-[#F5A623]/10 border border-[#F5A623]/25 rounded-2xl px-4 py-3.5 mb-5 mt-2">
                    <p className="text-sm font-semibold text-[#1A1A0F] mb-0.5">💡 No work experience? That's fine.</p>
                    <p className="text-sm font-light text-black/50">Family business, school projects, church work — tick "volunteer" and we'll label it correctly.</p>
                  </div>
                  <div className="space-y-4">
                    {cv.exp.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 md:p-5 relative bg-[#FAFAFA]">
                        <button onClick={()=>setCv(c=>({...c,exp:c.exp.filter((_,j)=>j!==i)}))} className="absolute top-3.5 right-3.5 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-3">
                          <F label="Role / title"><input className={inp} placeholder="Shop assistant" value={e.title} onChange={ev=>{const ex=[...cv.exp];ex[i].title=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="Organisation"><input className={inp} placeholder="Shoprite" value={e.org} onChange={ev=>{const ex=[...cv.exp];ex[i].org=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <div className="grid grid-cols-2 gap-4 mb-3">
                          <F label="Start"><input className={inp} placeholder="Jan 2023" value={e.start} onChange={ev=>{const ex=[...cv.exp];ex[i].start=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="End"><input className={inp} placeholder="Present" value={e.end} onChange={ev=>{const ex=[...cv.exp];ex[i].end=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <F label="What you did"><textarea className={inp+' resize-none'} rows={2} value={e.desc} onChange={ev=>{const ex=[...cv.exp];ex[i].desc=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        <label className="flex items-center gap-2 mt-3 cursor-pointer">
                          <input type="checkbox" checked={e.volunteer} className="accent-[#F5A623] w-4 h-4" onChange={ev=>{const ex=[...cv.exp];ex[i].volunteer=ev.target.checked;setCv(c=>({...c,exp:ex}))}}/>
                          <span className="text-sm text-black/50">This was volunteer / informal work</span>
                        </label>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,exp:[...c.exp,{title:'',org:'',start:'',end:'',desc:'',volunteer:false}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>
                      Add experience
                    </button>
                  </div>
                </div>
              )}

              {/* ── STEP 5 — REFERENCES ── */}
              {step===5&&(
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F]">References</h2>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input type="checkbox" checked={opts.showRefs} onChange={e=>setOpt('showRefs',e.target.checked)} className="accent-[#F5A623] w-4 h-4"/>
                      <span className="text-sm text-black/40">Show on CV</span>
                    </label>
                  </div>
                  <p className="text-black/40 text-sm font-light mb-5">A teacher, community leader, or neighbour works fine.</p>
                  <div className="space-y-4">
                    {cv.refs.map((r,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 md:p-5 relative bg-[#FAFAFA]">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,refs:c.refs.filter((_,j)=>j!==i)}))} className="absolute top-3.5 right-3.5 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-3">
                          <F label="Full name"><input className={inp} placeholder="Mrs Dlamini" value={r.name} onChange={e=>{const rf=[...cv.refs];rf[i].name=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                          <F label="Relationship"><input className={inp} placeholder="Former teacher" value={r.relation} onChange={e=>{const rf=[...cv.refs];rf[i].relation=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                        </div>
                        <F label="Contact"><input className={inp} placeholder="072 000 0000" value={r.contact} onChange={e=>{const rf=[...cv.refs];rf[i].contact=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,refs:[...c.refs,{name:'',relation:'',contact:''}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>
                      Add reference
                    </button>
                  </div>

                  {pct()>=60&&(
                    <div className="mt-8 rounded-2xl p-5 md:p-6" style={{ background:`${opts.color}12`, border:`2px solid ${opts.color}30` }}>
                      <div className="text-xl mb-1">🎉</div>
                      <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-1">Your CV is ready!</h3>
                      <p className="text-sm font-light text-black/50 mb-4">Download your professional CV as a PDF and start applying today.</p>
                      <a href="/api/cv/download" target="_blank" className="btn-amber inline-flex items-center gap-2 !py-2.5 !px-5 text-sm">
                        <Download size={14}/> Download CV (PDF)
                      </a>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* ── NAV FOOTER ── */}
            <div className="px-5 md:px-8 py-4 bg-[#FAFAFA] border-t border-black/6 flex items-center justify-between">
              <button onClick={()=>step>0&&setStep(step-1)} disabled={step===0}
                className={clsx('flex items-center gap-1.5 text-sm font-semibold transition-colors',step===0?'text-black/15 cursor-not-allowed':'text-black/40 hover:text-[#1A1A0F]')}>
                <ChevronLeft size={16}/> Back
              </button>
              <div className="flex items-center gap-3">
                <button onClick={save} disabled={saving} className="flex items-center gap-1.5 text-sm font-medium text-black/40 hover:text-[#1A1A0F] transition-colors">
                  {saving?<Loader2 size={13} className="animate-spin"/>:saved?<Check size={13} className="text-green-500"/>:null}
                  {saved?'Saved!':'Save'}
                </button>
                {step<5
                  ?<button onClick={async()=>{await save();setStep(step+1)}} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm">Continue <ChevronRight size={14}/></button>
                  :<button onClick={save} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm">{saving?<Loader2 size={13} className="animate-spin"/>:<Check size={13}/>} Finish</button>
                }
              </div>
            </div>
          </div>
        </div>

        {/* ── DESKTOP PREVIEW PANEL ── */}
        <div className="hidden xl:flex flex-col gap-3 w-[400px] flex-shrink-0 sticky top-20 h-fit">
          {/* Options */}
          <div className="bg-white rounded-2xl border border-black/8 p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-3">
              <Settings size={14} className="text-black/30"/>
              <span className="text-xs font-semibold tracking-wider uppercase text-black/40">Options</span>
            </div>
            <div className="space-y-2.5 mb-4">
              {([['showPhone','Show phone'],['showLoc','Show location'],['showLinkedin','Show LinkedIn'],['showRefs','Show references']] as [keyof Opts, string][]).map(([k,label])=>(
                <label key={k} className="flex items-center justify-between cursor-pointer">
                  <span className="text-sm text-[#1A1A0F]">{label}</span>
                  <div onClick={()=>setOpt(k,!opts[k])} className={clsx('w-10 h-5 rounded-full transition-colors relative cursor-pointer',opts[k]?'bg-[#F5A623]':'bg-black/15')}>
                    <div className={clsx('absolute top-0.5 w-4 h-4 rounded-full bg-white shadow-sm transition-all',opts[k]?'left-5':'left-0.5')}/>
                  </div>
                </label>
              ))}
            </div>
            <div className="flex gap-2 flex-wrap">
              {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-7 h-7 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F]':'border-transparent hover:scale-105')} style={{background:c}}/>)}
            </div>
          </div>

          {/* Preview */}
          <div className="bg-white rounded-2xl border border-black/8 overflow-hidden shadow-sm">
            <div className="px-4 py-2.5 bg-[#F7F3EB] border-b border-black/6 flex items-center justify-between">
              <span className="text-[10px] font-semibold tracking-wider uppercase text-black/40">Live preview</span>
              <span className="text-[10px] text-black/30">{pct()}% · {TEMPLATES.find(t=>t.id===opts.template)?.name}</span>
            </div>
            <div className="overflow-y-auto max-h-[70vh] bg-gray-100 p-2">
              <div style={{ transform:'scale(0.52)', transformOrigin:'top left', width:'192%' }}>
                <Preview cv={previewCv} opts={opts}/>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── MOBILE PREVIEW SHEET ── */}
      {showPreview&&(
        <div className="fixed inset-0 z-50 xl:hidden" onClick={()=>setShowPreview(false)}>
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm"/>
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl overflow-hidden" onClick={e=>e.stopPropagation()} style={{ maxHeight:'85vh' }}>
            <div className="px-5 py-4 border-b border-black/8 flex items-center justify-between bg-[#F7F3EB]">
              <div>
                <div className="text-sm font-semibold text-[#1A1A0F]">CV Preview</div>
                <div className="text-xs text-black/40">{TEMPLATES.find(t=>t.id===opts.template)?.name} · {pct()}% complete</div>
              </div>
              <button onClick={()=>setShowPreview(false)} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center"><X size={16}/></button>
            </div>

            {/* Options strip */}
            <div className="px-5 py-3 border-b border-black/6 flex items-center gap-3 overflow-x-auto">
              {TEMPLATES.map(t=>(
                <button key={t.id} onClick={()=>setOpt('template',t.id)} className={clsx('text-xs font-semibold px-3 py-1.5 rounded-full whitespace-nowrap transition-all border',opts.template===t.id?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/40')} style={opts.template===t.id?{background:opts.color}:{}}>{t.name}</button>
              ))}
              <div className="w-px h-5 bg-black/10 flex-shrink-0"/>
              {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-6 h-6 rounded-full flex-shrink-0 border-2',opts.color===c?'border-[#1A1A0F] scale-110':'border-transparent')} style={{background:c}}/>)}
            </div>

            <div className="overflow-y-auto p-3 bg-gray-100" style={{ maxHeight:'60vh' }}>
              <div style={{ transform:'scale(0.5)', transformOrigin:'top left', width:'200%' }}>
                <Preview cv={previewCv} opts={opts}/>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
EOF

echo "✅ Final CV Builder done!"
npm run dev
