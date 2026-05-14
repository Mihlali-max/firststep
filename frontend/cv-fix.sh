#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🔧 Fixing CV Builder UI..."

# Fix tailwind config to include custom scrollbar hide
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        amber: { DEFAULT: '#F5A623', dark: '#C47D0A', pale: '#FFF6E3' },
        forest: { DEFAULT: '#2A5C3F' },
        ink: { DEFAULT: '#1A1A0F' },
        warm: '#FFFDF7',
        offwhite: '#F7F3EB',
        muted: '#7A7260',
      },
      fontFamily: {
        display: ['Fraunces', 'Georgia', 'serif'],
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
EOF

cat > src/components/pages/CVBuilder.tsx << 'EOF'
import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, X, Loader2, Eye, Settings, Camera, Palette } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

// ── Types
interface PI  { name:string; title:string; email:string; phone:string; location:string; summary:string; linkedin:string; photo:string }
interface Edu { school:string; qualification:string; year:string }
interface Exp { title:string; org:string; start:string; end:string; desc:string; volunteer:boolean }
interface Ref { name:string; relation:string; contact:string }
interface CV  { pi:PI; edu:Edu[]; skills:string[]; exp:Exp[]; refs:Ref[] }
interface Opts { template:string; color:string; showPhone:boolean; showLoc:boolean; showLinkedin:boolean; showRefs:boolean; showPhoto:boolean }

const EMPTY:CV = {
  pi:{ name:'', title:'', email:'', phone:'', location:'', summary:'', linkedin:'', photo:'' },
  edu:[{school:'',qualification:'',year:''}],
  skills:[], exp:[], refs:[],
}
const DEF:Opts = { template:'nova', color:'#1565C0', showPhone:true, showLoc:true, showLinkedin:false, showRefs:true, showPhoto:false }

const SKILLS = ['Communication','Microsoft Office','Customer service','Teamwork','Time management','Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling','Basic accounting','Attention to detail','Computer literacy','Adaptability','Leadership','Filing & admin','Telephone etiquette','Forklift licence','First Aid','Report writing']
const COLORS = ['#1A1A0F','#1565C0','#0D47A1','#2E7D32','#4A148C','#B71C1C','#E65100','#004D40','#455A64','#880E4F']
const STEPS  = ['Template','Personal','Education','Skills','Experience','References']
const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/30 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/70 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

// ════════════════════════════════════════════
// ACTUAL CV TEMPLATE COMPONENTS
// These render the real CV — scaled in preview
// ════════════════════════════════════════════

function TemplateNova({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ display:'flex', width:'210mm', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'10px', lineHeight:'1.5', background:'white' }}>
      <div style={{ width:'76mm', background:c, color:'white', padding:'28px 18px', flexShrink:0, display:'flex', flexDirection:'column', gap:14 }}>
        <div style={{ textAlign:'center', paddingBottom:16, borderBottom:'1px solid rgba(255,255,255,0.2)' }}>
          {opts.showPhoto && p.photo
            ? <img src={p.photo} style={{ width:72,height:72,borderRadius:'50%',objectFit:'cover',border:'3px solid rgba(255,255,255,0.4)',margin:'0 auto 12px',display:'block' }}/>
            : <div style={{ width:72,height:72,borderRadius:'50%',background:'rgba(255,255,255,0.18)',margin:'0 auto 12px',display:'flex',alignItems:'center',justifyContent:'center',fontSize:26,fontWeight:800,border:'2px solid rgba(255,255,255,0.3)' }}>{p.name?p.name[0].toUpperCase():'?'}</div>
          }
          <div style={{ fontSize:15,fontWeight:800,lineHeight:1.2,letterSpacing:'-0.3px' }}>{p.name||'Your Name'}</div>
          {p.title&&<div style={{ fontSize:8,opacity:0.65,marginTop:4,letterSpacing:'1.5px',textTransform:'uppercase',fontWeight:500 }}>{p.title}</div>}
        </div>
        <div>
          <div style={{ fontSize:7.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.5,marginBottom:8 }}>Contact</div>
          {p.email&&<div style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5,fontSize:8,wordBreak:'break-all' }}><span style={{ width:16,height:16,borderRadius:'50%',background:'rgba(255,255,255,0.15)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontSize:8,flexShrink:0 }}>✉</span>{p.email}</div>}
          {opts.showPhone&&p.phone&&<div style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5,fontSize:8 }}><span style={{ width:16,height:16,borderRadius:'50%',background:'rgba(255,255,255,0.15)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontSize:8,flexShrink:0 }}>☏</span>{p.phone}</div>}
          {opts.showLoc&&p.location&&<div style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5,fontSize:8 }}><span style={{ width:16,height:16,borderRadius:'50%',background:'rgba(255,255,255,0.15)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontSize:8,flexShrink:0 }}>⊕</span>{p.location}</div>}
          {opts.showLinkedin&&p.linkedin&&<div style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5,fontSize:8,wordBreak:'break-all' }}><span style={{ width:16,height:16,borderRadius:'50%',background:'rgba(255,255,255,0.15)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontSize:8,flexShrink:0 }}>in</span>{p.linkedin}</div>}
        </div>
        {cv.skills.length>0&&<div>
          <div style={{ fontSize:7.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.5,marginBottom:10 }}>Skills</div>
          {cv.skills.map(s=><div key={s} style={{ marginBottom:7 }}>
            <div style={{ fontSize:8.5,marginBottom:3 }}>{s}</div>
            <div style={{ height:3,background:'rgba(255,255,255,0.2)',borderRadius:2 }}><div style={{ height:3,background:'rgba(255,255,255,0.75)',borderRadius:2,width:'80%' }}/></div>
          </div>)}
        </div>}
        {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
          <div style={{ fontSize:7.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.5,marginBottom:8 }}>References</div>
          {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:9 }}>
            <div style={{ fontWeight:700,fontSize:9 }}>{r.name}</div>
            <div style={{ opacity:0.65,fontSize:8 }}>{r.relation}</div>
            {r.contact&&<div style={{ opacity:0.5,fontSize:7.5 }}>{r.contact}</div>}
          </div>)}
        </div>}
      </div>
      <div style={{ flex:1,padding:'28px 22px',display:'flex',flexDirection:'column',gap:16 }}>
        {p.summary&&<div>
          <div style={{ display:'flex',alignItems:'center',gap:8,marginBottom:8 }}>
            <div style={{ width:4,height:16,background:c,borderRadius:2 }}/>
            <div style={{ fontSize:8.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',color:c }}>Profile</div>
          </div>
          <p style={{ color:'#374151',lineHeight:1.8,fontSize:9 }}>{p.summary}</p>
        </div>}
        {cv.exp.some(e=>e.title)&&<div>
          <div style={{ display:'flex',alignItems:'center',gap:8,marginBottom:10 }}>
            <div style={{ width:4,height:16,background:c,borderRadius:2 }}/>
            <div style={{ fontSize:8.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',color:c }}>Experience</div>
            <div style={{ flex:1,height:1,background:`${c}25` }}/>
          </div>
          {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:12,paddingLeft:12,borderLeft:`2px solid ${c}30` }}>
            <div style={{ display:'flex',justifyContent:'space-between',alignItems:'flex-start' }}>
              <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
              <div style={{ fontSize:8,color:'#9CA3AF',background:'#F3F4F6',padding:'1px 7px',borderRadius:12,whiteSpace:'nowrap',marginLeft:6 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</div>
            </div>
            {e.org&&<div style={{ fontSize:8.5,color:c,fontWeight:600,marginTop:1,marginBottom:2 }}>{e.org}</div>}
            {e.desc&&<div style={{ fontSize:8.5,color:'#6B7280',lineHeight:1.65 }}>{e.desc}</div>}
          </div>)}
        </div>}
        {cv.edu.some(e=>e.school)&&<div>
          <div style={{ display:'flex',alignItems:'center',gap:8,marginBottom:10 }}>
            <div style={{ width:4,height:16,background:c,borderRadius:2 }}/>
            <div style={{ fontSize:8.5,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',color:c }}>Education</div>
            <div style={{ flex:1,height:1,background:`${c}25` }}/>
          </div>
          {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:9,paddingLeft:12,borderLeft:`2px solid ${c}30` }}>
            <div style={{ display:'flex',justifyContent:'space-between',alignItems:'flex-start' }}>
              <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.qualification}</div>
              {e.year&&<div style={{ fontSize:8,color:'#9CA3AF',background:'#F3F4F6',padding:'1px 7px',borderRadius:12,marginLeft:6 }}>{e.year}</div>}
            </div>
            <div style={{ fontSize:8.5,color:'#6B7280' }}>{e.school}</div>
          </div>)}
        </div>}
      </div>
    </div>
  )
}

function TemplatePulse({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'"Helvetica Neue",Arial,sans-serif',fontSize:'10px',background:'white' }}>
      <div style={{ background:c,padding:'24px 28px',position:'relative',overflow:'hidden' }}>
        <div style={{ position:'absolute',right:-30,top:-30,width:160,height:160,borderRadius:'50%',background:'rgba(255,255,255,0.07)' }}/>
        <div style={{ position:'absolute',right:60,bottom:-40,width:100,height:100,borderRadius:'50%',background:'rgba(255,255,255,0.05)' }}/>
        <div style={{ position:'relative',display:'flex',alignItems:'center',gap:18 }}>
          {opts.showPhoto&&p.photo
            ?<img src={p.photo} style={{ width:72,height:72,borderRadius:'50%',objectFit:'cover',border:'3px solid rgba(255,255,255,0.5)',flexShrink:0 }}/>
            :<div style={{ width:72,height:72,borderRadius:'50%',background:'rgba(255,255,255,0.18)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:26,fontWeight:800,color:'white',border:'2px solid rgba(255,255,255,0.3)',flexShrink:0 }}>{p.name?p.name[0].toUpperCase():'?'}</div>
          }
          <div style={{ color:'white' }}>
            <div style={{ fontSize:22,fontWeight:900,letterSpacing:'-0.5px',lineHeight:1.1 }}>{p.name||'Your Name'}</div>
            {p.title&&<div style={{ fontSize:9,opacity:0.7,marginTop:3,letterSpacing:'2px',textTransform:'uppercase' }}>{p.title}</div>}
            <div style={{ display:'flex',flexWrap:'wrap',gap:12,marginTop:7,fontSize:8,opacity:0.82 }}>
              {p.email&&<span>✉ {p.email}</span>}
              {opts.showPhone&&p.phone&&<span>☏ {p.phone}</span>}
              {opts.showLoc&&p.location&&<span>⊕ {p.location}</span>}
            </div>
          </div>
        </div>
      </div>
      <div style={{ display:'grid',gridTemplateColumns:'1fr 58mm' }}>
        <div style={{ padding:'18px 22px 18px 28px',borderRight:'1px solid #F3F4F6' }}>
          {p.summary&&<div style={{ marginBottom:14,paddingBottom:12,borderBottom:'1px solid #F3F4F6' }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:6 }}>About Me</div>
            <p style={{ color:'#4B5563',lineHeight:1.8 }}>{p.summary}</p>
          </div>}
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Work Experience</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:11,paddingBottom:9,borderBottom:'1px solid #F9FAFB',position:'relative',paddingLeft:12 }}>
              <div style={{ position:'absolute',left:0,top:5,width:6,height:6,borderRadius:'50%',background:c }}/>
              <div style={{ fontWeight:800,color:'#111',fontSize:11,lineHeight:1.2 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
              <div style={{ display:'flex',gap:8,alignItems:'center',marginTop:2,marginBottom:2 }}>
                {e.org&&<span style={{ fontSize:8.5,color:c,fontWeight:600 }}>{e.org}</span>}
                {(e.start||e.end)&&<span style={{ fontSize:8,color:'#9CA3AF' }}>· {[e.start,e.end].filter(Boolean).join(' – ')}</span>}
              </div>
              {e.desc&&<div style={{ fontSize:8.5,color:'#6B7280',lineHeight:1.65 }}>{e.desc}</div>}
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8,position:'relative',paddingLeft:12 }}>
              <div style={{ position:'absolute',left:0,top:5,width:6,height:6,borderRadius:'50%',background:c }}/>
              <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.qualification}</div>
              <div style={{ fontSize:8.5,color:'#6B7280' }}>{e.school}{e.year&&` · ${e.year}`}</div>
            </div>)}
          </div>}
        </div>
        <div style={{ padding:'18px 16px',background:'#FAFAFA' }}>
          {cv.skills.length>0&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Skills</div>
            <div style={{ display:'flex',flexWrap:'wrap',gap:4 }}>
              {cv.skills.map(s=><div key={s} style={{ fontSize:8,padding:'3px 9px',borderRadius:20,fontWeight:600,background:`${c}15`,color:c,border:`1px solid ${c}30` }}>{s}</div>)}
            </div>
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:8,padding:'8px 10px',background:'white',borderRadius:8,border:'1px solid #E5E7EB' }}>
              <div style={{ fontWeight:700,color:'#111',fontSize:9 }}>{r.name}</div>
              <div style={{ color:'#9CA3AF',fontSize:8 }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF',fontSize:7.5 }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

function TemplateSlate({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'"Helvetica Neue",Arial,sans-serif',fontSize:'10px',background:'white' }}>
      <div style={{ background:c,padding:'22px 28px',display:'flex',justifyContent:'space-between',alignItems:'flex-end' }}>
        <div style={{ color:'white' }}>
          <div style={{ fontSize:26,fontWeight:900,letterSpacing:'-0.5px',lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
          {p.title&&<div style={{ fontSize:9.5,letterSpacing:'3px',textTransform:'uppercase',opacity:0.65,marginTop:5,fontWeight:400 }}>{p.title}</div>}
        </div>
        <div style={{ textAlign:'right',color:'rgba(255,255,255,0.75)',fontSize:8.5,lineHeight:2 }}>
          {p.email&&<div>{p.email}</div>}
          {opts.showPhone&&p.phone&&<div>{p.phone}</div>}
          {opts.showLoc&&p.location&&<div>{p.location}</div>}
        </div>
      </div>
      <div style={{ height:4,background:`linear-gradient(90deg,${c},${c}60)` }}/>
      {p.summary&&<div style={{ padding:'12px 28px',background:`${c}08`,borderBottom:'1px solid #E5E7EB' }}>
        <p style={{ color:'#374151',lineHeight:1.8,fontStyle:'italic' }}>{p.summary}</p>
      </div>}
      <div style={{ display:'grid',gridTemplateColumns:'1fr 1fr',padding:'18px 28px',gap:28 }}>
        <div>
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:18 }}>
            <div style={{ fontSize:9,fontWeight:800,color:c,letterSpacing:'2px',textTransform:'uppercase',marginBottom:10,paddingBottom:5,borderBottom:`2px solid ${c}` }}>Experience</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:11 }}>
              <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
              <div style={{ display:'flex',justifyContent:'space-between',marginTop:1 }}>
                {e.org&&<span style={{ fontSize:8.5,color:c,fontWeight:600 }}>{e.org}</span>}
                <span style={{ fontSize:8,color:'#9CA3AF' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
              </div>
              {e.desc&&<p style={{ fontSize:8.5,color:'#6B7280',marginTop:3,lineHeight:1.65 }}>{e.desc}</p>}
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:9,fontWeight:800,color:c,letterSpacing:'2px',textTransform:'uppercase',marginBottom:10,paddingBottom:5,borderBottom:`2px solid ${c}` }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:9 }}>
              <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.qualification}</div>
              <div style={{ display:'flex',justifyContent:'space-between' }}>
                <span style={{ fontSize:8.5,color:'#6B7280' }}>{e.school}</span>
                <span style={{ fontSize:8,color:'#9CA3AF' }}>{e.year}</span>
              </div>
            </div>)}
          </div>}
        </div>
        <div>
          {cv.skills.length>0&&<div style={{ marginBottom:18 }}>
            <div style={{ fontSize:9,fontWeight:800,color:c,letterSpacing:'2px',textTransform:'uppercase',marginBottom:10,paddingBottom:5,borderBottom:`2px solid ${c}` }}>Skills</div>
            <div style={{ display:'grid',gridTemplateColumns:'1fr 1fr',gap:'5px 10px' }}>
              {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:6,fontSize:9 }}>
                <div style={{ width:5,height:5,borderRadius:'50%',background:c,flexShrink:0 }}/>{s}
              </div>)}
            </div>
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:9,fontWeight:800,color:c,letterSpacing:'2px',textTransform:'uppercase',marginBottom:10,paddingBottom:5,borderBottom:`2px solid ${c}` }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:9,padding:'7px 9px',background:'#F9FAFB',borderRadius:7,border:'1px solid #E5E7EB' }}>
              <div style={{ fontWeight:700,color:'#111',fontSize:9 }}>{r.name}</div>
              <div style={{ color:'#9CA3AF',fontSize:8 }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF',fontSize:7.5 }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

function TemplateImpact({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ display:'flex',width:'210mm',minHeight:'297mm',fontFamily:'"Helvetica Neue",Arial,sans-serif',fontSize:'10px',background:'white' }}>
      <div style={{ width:8,background:c,flexShrink:0 }}/>
      <div style={{ flex:1,display:'flex',flexDirection:'column' }}>
        <div style={{ padding:'22px 24px 16px',borderBottom:`3px solid ${c}` }}>
          <div style={{ display:'flex',justifyContent:'space-between',alignItems:'flex-start' }}>
            <div>
              <div style={{ fontSize:26,fontWeight:900,color:'#111',letterSpacing:'-0.5px',lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
              {p.title&&<div style={{ fontSize:9.5,color:c,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',marginTop:4 }}>{p.title}</div>}
            </div>
            {opts.showPhoto&&p.photo&&<img src={p.photo} style={{ width:60,height:60,borderRadius:'50%',objectFit:'cover',border:`2px solid ${c}`,flexShrink:0 }}/>}
          </div>
          <div style={{ display:'flex',flexWrap:'wrap',gap:14,marginTop:10,fontSize:8.5,color:'#6B7280' }}>
            {p.email&&<span>✉ {p.email}</span>}
            {opts.showPhone&&p.phone&&<span>☏ {p.phone}</span>}
            {opts.showLoc&&p.location&&<span>⊕ {p.location}</span>}
          </div>
        </div>
        <div style={{ display:'grid',gridTemplateColumns:'1fr 58mm',flex:1 }}>
          <div style={{ padding:'16px 20px 16px 24px',borderRight:'1px solid #F3F4F6' }}>
            {p.summary&&<div style={{ marginBottom:14,paddingBottom:12,borderBottom:'1px solid #F3F4F6' }}>
              <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:6 }}>Summary</div>
              <p style={{ color:'#4B5563',lineHeight:1.8 }}>{p.summary}</p>
            </div>}
            {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Experience</div>
              {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:10,paddingBottom:8,borderBottom:'1px solid #F9FAFB' }}>
                <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                <div style={{ display:'flex',gap:8,alignItems:'center',marginTop:2,marginBottom:2 }}>
                  {e.org&&<span style={{ fontSize:8.5,color:c,fontWeight:600 }}>{e.org}</span>}
                  {(e.start||e.end)&&<span style={{ fontSize:8,color:'#9CA3AF' }}>· {[e.start,e.end].filter(Boolean).join(' – ')}</span>}
                </div>
                {e.desc&&<div style={{ fontSize:8.5,color:'#6B7280',lineHeight:1.65 }}>{e.desc}</div>}
              </div>)}
            </div>}
            {cv.edu.some(e=>e.school)&&<div>
              <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8 }}>
                <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.qualification}</div>
                <div style={{ display:'flex',justifyContent:'space-between' }}>
                  <span style={{ fontSize:8.5,color:'#6B7280' }}>{e.school}</span>
                  <span style={{ fontSize:8,color:'#9CA3AF' }}>{e.year}</span>
                </div>
              </div>)}
            </div>}
          </div>
          <div style={{ padding:'16px',background:'#FAFAFA' }}>
            {cv.skills.length>0&&<div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Skills</div>
              {cv.skills.map(s=><div key={s} style={{ marginBottom:6 }}>
                <div style={{ fontSize:9,color:'#374151',marginBottom:3 }}>{s}</div>
                <div style={{ height:3,background:'#E5E7EB',borderRadius:2 }}><div style={{ height:3,background:c,borderRadius:2,width:'78%' }}/></div>
              </div>)}
            </div>}
            {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
              <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:8,padding:'7px 9px',background:'white',borderRadius:7,border:'1px solid #E5E7EB' }}>
                <div style={{ fontWeight:700,color:'#111',fontSize:9 }}>{r.name}</div>
                <div style={{ color:'#9CA3AF',fontSize:8 }}>{r.relation}</div>
                {r.contact&&<div style={{ color:'#9CA3AF',fontSize:7.5 }}>{r.contact}</div>}
              </div>)}
            </div>}
          </div>
        </div>
      </div>
    </div>
  )
}

function TemplateSerif({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'Georgia,"Times New Roman",serif',fontSize:'10px',lineHeight:'1.65',background:'#FDFCFB' }}>
      <div style={{ padding:'30px 36px 20px',textAlign:'center' }}>
        <div style={{ display:'flex',alignItems:'center',gap:10,marginBottom:12 }}>
          <div style={{ flex:1,height:2,background:c }}/><div style={{ width:7,height:7,transform:'rotate(45deg)',background:c,flexShrink:0 }}/><div style={{ flex:1,height:2,background:c }}/>
        </div>
        {opts.showPhoto&&p.photo&&<img src={p.photo} style={{ width:70,height:70,borderRadius:'50%',objectFit:'cover',border:`2px solid ${c}`,margin:'0 auto 10px',display:'block' }}/>}
        <div style={{ fontSize:26,fontWeight:400,letterSpacing:'0.12em',textTransform:'uppercase',color:'#111',lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
        {p.title&&<div style={{ fontSize:8.5,letterSpacing:'4px',textTransform:'uppercase',color:'#9CA3AF',marginTop:5,fontFamily:'"Helvetica Neue",sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex',justifyContent:'center',flexWrap:'wrap',gap:16,marginTop:9,color:'#6B7280',fontSize:8.5,fontFamily:'"Helvetica Neue",sans-serif' }}>
          {p.email&&<span>{p.email}</span>}
          {opts.showPhone&&p.phone&&<span>{p.phone}</span>}
          {opts.showLoc&&p.location&&<span>{p.location}</span>}
        </div>
        {p.summary&&<p style={{ marginTop:10,color:'#4B5563',lineHeight:1.85,fontStyle:'italic',maxWidth:'85%',margin:'10px auto 0',fontFamily:'"Helvetica Neue",sans-serif',fontSize:9 }}>{p.summary}</p>}
        <div style={{ display:'flex',alignItems:'center',gap:10,marginTop:14 }}>
          <div style={{ flex:1,height:1,background:'#E5E7EB' }}/><div style={{ width:5,height:5,transform:'rotate(45deg)',background:c,flexShrink:0 }}/><div style={{ flex:1,height:1,background:'#E5E7EB' }}/>
        </div>
      </div>
      <div style={{ padding:'0 36px 28px',display:'grid',gridTemplateColumns:'1fr 54mm',gap:26 }}>
        <div>
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:16 }}>
            <div style={{ fontSize:8,letterSpacing:'4px',textTransform:'uppercase',color:c,marginBottom:10,fontFamily:'"Helvetica Neue",sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}30` }}/><span>Experience</span><div style={{ flex:1,height:1,background:`${c}30` }}/>
            </div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:11 }}>
              <div style={{ display:'flex',justifyContent:'space-between' }}>
                <span style={{ fontWeight:700,color:'#111',fontSize:11 }}>{e.title}{e.volunteer?' (Vol.)':''}</span>
                <span style={{ fontSize:8.5,color:'#9CA3AF',fontFamily:'"Helvetica Neue",sans-serif' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
              </div>
              {e.org&&<div style={{ color:c,fontSize:8.5,fontFamily:'"Helvetica Neue",sans-serif',fontStyle:'italic' }}>{e.org}</div>}
              {e.desc&&<p style={{ color:'#6B7280',marginTop:2,lineHeight:1.7,fontFamily:'"Helvetica Neue",sans-serif',fontSize:8.5 }}>{e.desc}</p>}
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:8,letterSpacing:'4px',textTransform:'uppercase',color:c,marginBottom:10,fontFamily:'"Helvetica Neue",sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}30` }}/><span>Education</span><div style={{ flex:1,height:1,background:`${c}30` }}/>
            </div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:9 }}>
              <div style={{ display:'flex',justifyContent:'space-between' }}>
                <span style={{ fontWeight:700,color:'#111',fontSize:11 }}>{e.qualification}</span>
                <span style={{ fontSize:8.5,color:'#9CA3AF',fontFamily:'"Helvetica Neue",sans-serif' }}>{e.year}</span>
              </div>
              <div style={{ color:'#6B7280',fontFamily:'"Helvetica Neue",sans-serif',fontSize:8.5 }}>{e.school}</div>
            </div>)}
          </div>}
        </div>
        <div>
          {cv.skills.length>0&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:8,letterSpacing:'4px',textTransform:'uppercase',color:c,marginBottom:9,fontFamily:'"Helvetica Neue",sans-serif' }}>Skills</div>
            {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:6,marginBottom:6,fontFamily:'"Helvetica Neue",sans-serif',fontSize:9,color:'#374151' }}>
              <div style={{ width:4,height:4,transform:'rotate(45deg)',background:c,flexShrink:0 }}/>{s}
            </div>)}
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:8,letterSpacing:'4px',textTransform:'uppercase',color:c,marginBottom:9,fontFamily:'"Helvetica Neue",sans-serif' }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:9 }}>
              <div style={{ fontWeight:700,color:'#111',fontSize:9.5 }}>{r.name}</div>
              <div style={{ color:'#9CA3AF',fontSize:8.5,fontStyle:'italic',fontFamily:'"Helvetica Neue",sans-serif' }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF',fontSize:8,fontFamily:'"Helvetica Neue",sans-serif' }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

function TemplateScript({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'"Helvetica Neue",Arial,sans-serif',fontSize:'10px',background:'white' }}>
      <div style={{ background:`linear-gradient(135deg,${c} 0%,${c}cc 100%)`,padding:'22px 28px',position:'relative',overflow:'hidden',color:'white' }}>
        <div style={{ position:'absolute',right:-40,top:-40,width:180,height:180,borderRadius:'50%',background:'rgba(255,255,255,0.06)' }}/>
        <div style={{ position:'relative',display:'flex',justifyContent:'space-between',alignItems:'flex-end' }}>
          <div>
            <div style={{ fontSize:28,fontWeight:900,letterSpacing:'-1px',lineHeight:1 }}>{p.name||'Your Name'}</div>
            {p.title&&<div style={{ fontSize:9.5,opacity:0.7,letterSpacing:'2px',textTransform:'uppercase',marginTop:5,fontWeight:400 }}>{p.title}</div>}
            <div style={{ display:'flex',flexWrap:'wrap',gap:14,marginTop:9,fontSize:8.5,opacity:0.82 }}>
              {p.email&&<span>✉ {p.email}</span>}
              {opts.showPhone&&p.phone&&<span>☏ {p.phone}</span>}
              {opts.showLoc&&p.location&&<span>⊕ {p.location}</span>}
            </div>
          </div>
          {opts.showPhoto&&p.photo
            ?<img src={p.photo} style={{ width:68,height:68,borderRadius:'50%',objectFit:'cover',border:'3px solid rgba(255,255,255,0.45)',flexShrink:0 }}/>
            :<div style={{ width:68,height:68,borderRadius:'50%',background:'rgba(255,255,255,0.18)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:24,fontWeight:800,border:'2px solid rgba(255,255,255,0.25)',flexShrink:0 }}>{p.name?p.name[0].toUpperCase():'?'}</div>
          }
        </div>
      </div>
      <div style={{ height:5,background:`linear-gradient(90deg,${c},${c}40,transparent)` }}/>
      <div style={{ display:'grid',gridTemplateColumns:'1fr 60mm' }}>
        <div style={{ padding:'16px 22px 16px 28px',borderRight:'1px solid #F3F4F6' }}>
          {p.summary&&<div style={{ marginBottom:14,paddingBottom:12,borderBottom:'1px solid #F3F4F6' }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:6 }}>About</div>
            <p style={{ color:'#4B5563',lineHeight:1.8 }}>{p.summary}</p>
          </div>}
          {cv.exp.some(e=>e.title)&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Work History</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:10,display:'grid',gridTemplateColumns:'22mm 1fr',gap:10 }}>
              <div style={{ color:'#9CA3AF',fontSize:8,lineHeight:1.6 }}>{e.start||''}{e.start&&e.end&&<br/>}{e.end||''}</div>
              <div>
                <div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                {e.org&&<div style={{ fontSize:8.5,color:c,fontWeight:600 }}>{e.org}</div>}
                {e.desc&&<div style={{ fontSize:8.5,color:'#6B7280',marginTop:2,lineHeight:1.65 }}>{e.desc}</div>}
              </div>
            </div>)}
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8,display:'grid',gridTemplateColumns:'22mm 1fr',gap:10 }}>
              <div style={{ color:'#9CA3AF',fontSize:8 }}>{e.year}</div>
              <div><div style={{ fontWeight:800,color:'#111',fontSize:11 }}>{e.qualification}</div><div style={{ fontSize:8.5,color:'#6B7280' }}>{e.school}</div></div>
            </div>)}
          </div>}
        </div>
        <div style={{ padding:'16px',background:'#F9FAFB' }}>
          {cv.skills.length>0&&<div style={{ marginBottom:14 }}>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>Skills</div>
            <div style={{ display:'flex',flexWrap:'wrap',gap:4 }}>
              {cv.skills.map(s=><div key={s} style={{ fontSize:8,padding:'3px 9px',borderRadius:20,background:`${c}15`,color:c,border:`1px solid ${c}25`,fontWeight:600 }}>{s}</div>)}
            </div>
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:8.5,fontWeight:800,letterSpacing:'2px',textTransform:'uppercase',color:c,marginBottom:9 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:8,padding:'7px 9px',background:'white',borderRadius:8,border:'1px solid #E5E7EB' }}>
              <div style={{ fontWeight:700,color:'#111',fontSize:9 }}>{r.name}</div>
              <div style={{ color:'#9CA3AF',fontSize:8 }}>{r.relation}</div>
              {r.contact&&<div style={{ color:'#9CA3AF',fontSize:7.5 }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

// ── Preview renderer
function Preview({ cv, opts }:{ cv:CV; opts:Opts }) {
  switch(opts.template) {
    case 'pulse':  return <TemplatePulse  cv={cv} opts={opts}/>
    case 'slate':  return <TemplateSlate  cv={cv} opts={opts}/>
    case 'impact': return <TemplateImpact cv={cv} opts={opts}/>
    case 'serif':  return <TemplateSerif  cv={cv} opts={opts}/>
    case 'script': return <TemplateScript cv={cv} opts={opts}/>
    default:       return <TemplateNova   cv={cv} opts={opts}/>
  }
}

// ── Template card thumbnails — actual mini renders using the real template
function TemplateCard({ id, name, desc, color, selected, onSelect }:{ id:string; name:string; desc:string; color:string; selected:boolean; onSelect:()=>void }) {
  const dummyCv:CV = {
    pi:{ name:'Alex Ndlovu', title:'Sales Assistant', email:'alex@email.com', phone:'071 000 0000', location:'Cape Town', summary:'Motivated professional.', linkedin:'', photo:'' },
    edu:[{ school:'Westridge High', qualification:'Matric', year:'2023' }],
    skills:['Customer service','Teamwork','MS Office','Communication'],
    exp:[{ title:'Shop Assistant', org:'Shoprite', start:'2023', end:'Present', desc:'Assisted customers.', volunteer:false }],
    refs:[{ name:'Mrs Dlamini', relation:'Teacher', contact:'072 000 0000' }],
  }
  const dummyOpts:Opts = { template:id, color, showPhone:true, showLoc:true, showLinkedin:false, showRefs:true, showPhoto:false }

  return (
    <button onClick={onSelect} className={clsx('relative border-2 rounded-2xl overflow-hidden transition-all text-left group',selected?'border-[#F5A623] shadow-[0_0_0_3px_rgba(245,166,35,0.2)]':'border-black/8 hover:border-[#F5A623]/50 hover:shadow-md')}>
      {/* Thumbnail — scaled down real CV */}
      <div className="w-full bg-gray-50 overflow-hidden" style={{ height:180 }}>
        <div style={{ transform:'scale(0.27)', transformOrigin:'top left', width:'370%', pointerEvents:'none', userSelect:'none' }}>
          <Preview cv={dummyCv} opts={dummyOpts}/>
        </div>
      </div>
      {/* Label */}
      <div className="p-3 bg-white border-t border-black/6">
        <div className="font-bold text-sm text-[#1A1A0F]">{name}</div>
        <div className="text-[11px] text-black/35 mt-0.5">{desc}</div>
      </div>
      {selected&&<div className="absolute top-2.5 right-2.5 w-6 h-6 rounded-full bg-[#F5A623] flex items-center justify-center shadow-sm"><Check size={12} className="text-[#1A1A0F]"/></div>}
    </button>
  )
}

// ── Toggle
function Toggle({ on, onChange, label }:{ on:boolean; onChange:(v:boolean)=>void; label:string }) {
  return (
    <label className="flex items-center justify-between py-2.5 border-b border-black/5 last:border-0 cursor-pointer group">
      <span className="text-sm text-[#1A1A0F] group-hover:text-black transition-colors">{label}</span>
      <div onClick={()=>onChange(!on)} className={clsx('w-10 h-[22px] rounded-full transition-all relative flex-shrink-0',on?'bg-[#F5A623]':'bg-black/12')}>
        <div className={clsx('absolute top-[3px] w-4 h-4 rounded-full bg-white shadow-sm transition-all duration-200',on?'left-5':'left-[3px]')}/>
      </div>
    </label>
  )
}

function F({ label, children }:{ label:string; children:React.ReactNode }) {
  return <div><label className={lbl}>{label}</label>{children}</div>
}

const TEMPLATES = [
  { id:'nova',   name:'Nova',    desc:'Sidebar + skills bars' },
  { id:'pulse',  name:'Pulse',   desc:'Bold header + photo' },
  { id:'slate',  name:'Slate',   desc:'Two-column corporate' },
  { id:'impact', name:'Impact',  desc:'Accent strip + bars' },
  { id:'serif',  name:'Serif',   desc:'Elegant + decorative' },
  { id:'script', name:'Script',  desc:'Timeline + gradient' },
]

export default function CVBuilder() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [step, setStep]     = useState(0)
  const [cv, setCv]         = useState<CV>(EMPTY)
  const [opts, setOpts]     = useState<Opts>(DEF)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved]   = useState(false)
  const [custom, setCustom] = useState('')
  const [showPreview, setShowPreview] = useState(false)
  const [showOpts, setShowOpts] = useState(false)
  const fileRef = useRef<HTMLInputElement>(null)

  useEffect(() => { if (!user) navigate('/register') }, [user])
  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      setCv({
        pi:     { ...(d.personal_info || EMPTY.pi), photo: d.personal_info?.photo || '' },
        edu:    d.education?.length ? d.education : EMPTY.edu,
        skills: d.skills || [],
        exp:    (d.experience || []).map((e:any) => ({ title:e.title||'', org:e.organisation||'', start:e.start_date||'', end:e.end_date||'', desc:e.description||'', volunteer:e.is_volunteer||false })),
        refs:   d.references || [],
      })
    }).catch(()=>{})
  }, [])

  const setOpt = (k:keyof Opts, v:any) => setOpts(o=>({...o,[k]:v}))
  const pct = () => {
    let s=0
    if(cv.pi?.name) s+=25; if(cv.edu?.some(e=>e.school)) s+=20
    if(cv.skills?.length) s+=20; if(cv.exp?.some(e=>e.title)) s+=20
    if(cv.refs?.some(r=>r.name)) s+=15; return s
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

  const handlePhoto = (e:React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]; if (!file) return
    const reader = new FileReader()
    reader.onload = ev => setCv(c=>({...c, pi:{...c.pi, photo:ev.target?.result as string}}))
    reader.readAsDataURL(file)
  }

  const previewCv:CV = {
    ...cv,
    pi:{ ...cv.pi,
      phone:    opts.showPhone    ? cv.pi.phone    : '',
      location: opts.showLoc      ? cv.pi.location : '',
      linkedin: opts.showLinkedin ? cv.pi.linkedin : '',
      photo:    opts.showPhoto    ? cv.pi.photo    : '',
    },
    refs: opts.showRefs ? cv.refs : [],
  }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* ── TOP HEADER ── */}
      <div className="bg-[#1A1A0F] px-4 md:px-10 py-5 md:py-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-between gap-3 mb-3">
            <div>
              <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-0.5">CV Builder</p>
              <h1 className="font-display text-xl md:text-2xl font-bold text-white tracking-tight">Design your <em className="not-italic text-[#F5A623]">perfect CV.</em></h1>
            </div>
            {/* Mobile action buttons */}
            <div className="xl:hidden flex items-center gap-2">
              <button onClick={()=>{ setShowOpts(true); setShowPreview(false) }} className="flex items-center gap-1.5 bg-white/10 border border-white/15 text-white text-xs font-medium px-3 py-2 rounded-xl hover:bg-white/20 transition-colors">
                <Palette size={13}/> Options
              </button>
              <button onClick={()=>{ setShowPreview(true); setShowOpts(false) }} className="flex items-center gap-1.5 bg-[#F5A623] text-[#1A1A0F] text-xs font-semibold px-3 py-2 rounded-xl hover:bg-[#C47D0A] transition-colors">
                <Eye size={13}/> Preview
              </button>
            </div>
          </div>
          {/* Progress */}
          <div className="flex items-center gap-3 mb-3">
            <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
              <div className="h-full rounded-full transition-all duration-700 bg-[#F5A623]" style={{ width:pct()+'%' }}/>
            </div>
            <span className="text-white/40 text-xs whitespace-nowrap">{pct()}% complete</span>
          </div>
          {/* Steps */}
          <div className="flex gap-1.5 overflow-x-auto pb-0.5" style={{ scrollbarWidth:'none' }}>
            {STEPS.map((s,i)=>(
              <button key={s} onClick={()=>setStep(i)}
                className={clsx('flex items-center gap-1.5 text-[11px] font-semibold px-3 py-1.5 rounded-full whitespace-nowrap transition-all flex-shrink-0 border',
                  i===step?'bg-[#F5A623] text-[#1A1A0F] border-transparent':
                  i<step?'bg-[#2A5C3F] text-white border-transparent':
                  'bg-white/5 text-white/40 border-white/10 hover:bg-white/12')}>
                {i<step?<Check size={10}/>:<span>{i+1}</span>}{s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* ── BODY ── */}
      <div className="max-w-7xl mx-auto px-3 md:px-6 py-5 xl:flex gap-5">

        {/* ── FORM PANEL ── */}
        <div className="flex-1 min-w-0 mb-5 xl:mb-0">
          <div className="bg-white rounded-2xl border border-black/6 shadow-sm overflow-hidden">
            <div className="p-5 md:p-7">

              {/* STEP 0 — TEMPLATE PICKER */}
              {step===0&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Choose your template</h2>
                  <p className="text-black/40 text-sm mb-6">Pick a design that suits the job you're going for.</p>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-7">
                    {TEMPLATES.map(t=>(
                      <TemplateCard
                        key={t.id}
                        id={t.id}
                        name={t.name}
                        desc={t.desc}
                        color={opts.color}
                        selected={opts.template===t.id}
                        onSelect={()=>setOpt('template',t.id)}
                      />
                    ))}
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-[#1A1A0F] mb-3">Accent colour</h3>
                    <div className="flex gap-3 flex-wrap">
                      {COLORS.map(c=>(
                        <button key={c} onClick={()=>setOpt('color',c)}
                          className={clsx('w-9 h-9 rounded-full transition-all border-2 shadow-sm',opts.color===c?'scale-125 border-white ring-2 ring-[#1A1A0F]':'border-white/60 hover:scale-110')}
                          style={{background:c}}/>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* STEP 1 — PERSONAL */}
              {step===1&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Personal info</h2>
                  <p className="text-black/40 text-sm mb-5">Your details — toggle what shows on the final CV.</p>
                  {/* Photo upload */}
                  <div className="flex items-center gap-4 p-4 bg-[#F7F3EB] rounded-2xl border border-black/6 mb-5">
                    <div className="w-16 h-16 rounded-full bg-white border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center overflow-hidden cursor-pointer hover:border-[#F5A623] transition-colors flex-shrink-0" onClick={()=>fileRef.current?.click()}>
                      {cv.pi.photo?<img src={cv.pi.photo} className="w-full h-full object-cover"/>:<Camera size={22} className="text-[#F5A623]/50"/>}
                    </div>
                    <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handlePhoto}/>
                    <div className="flex-1">
                      <div className="text-sm font-semibold text-[#1A1A0F] mb-0.5">Profile photo</div>
                      <div className="text-xs text-black/40 mb-2">Optional — supported by most templates</div>
                      <div className="flex items-center gap-3">
                        <button onClick={()=>fileRef.current?.click()} className="text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623]">Upload</button>
                        {cv.pi.photo&&<><span className="text-black/20 text-xs">·</span><button onClick={()=>setCv(c=>({...c,pi:{...c.pi,photo:''}}))} className="text-xs font-semibold text-red-400 hover:text-red-500">Remove</button></>}
                      </div>
                    </div>
                    <Toggle on={opts.showPhoto} onChange={v=>setOpt('showPhoto',v)} label=""/>
                  </div>
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <F label="Full name *"><input className={inp} placeholder="e.g. Lebo Sithole" value={cv.pi.name} onChange={e=>setCv(c=>({...c,pi:{...c.pi,name:e.target.value}}))}/></F>
                      <F label="Job title you want"><input className={inp} placeholder="e.g. Retail Assistant" value={cv.pi.title} onChange={e=>setCv(c=>({...c,pi:{...c.pi,title:e.target.value}}))}/></F>
                    </div>
                    <F label="Email *"><input className={inp} type="email" placeholder="lebo@gmail.com" value={cv.pi.email} onChange={e=>setCv(c=>({...c,pi:{...c.pi,email:e.target.value}}))}/></F>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>Phone</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showPhone} onChange={e=>setOpt('showPhone',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                        <input className={inp} placeholder="071 234 5678" value={cv.pi.phone} onChange={e=>setCv(c=>({...c,pi:{...c.pi,phone:e.target.value}}))}/>
                      </div>
                      <div>
                        <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>Location</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLoc} onChange={e=>setOpt('showLoc',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                        <input className={inp} placeholder="Cape Town, WC" value={cv.pi.location} onChange={e=>setCv(c=>({...c,pi:{...c.pi,location:e.target.value}}))}/>
                      </div>
                    </div>
                    <div>
                      <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>LinkedIn</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLinkedin} onChange={e=>setOpt('showLinkedin',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                      <input className={inp} placeholder="linkedin.com/in/yourname" value={cv.pi.linkedin} onChange={e=>setCv(c=>({...c,pi:{...c.pi,linkedin:e.target.value}}))}/>
                    </div>
                    <F label="Professional summary"><textarea className={inp+' resize-none'} rows={3} placeholder="A brief intro — who you are and what you're looking for…" value={cv.pi.summary} onChange={e=>setCv(c=>({...c,pi:{...c.pi,summary:e.target.value}}))}/></F>
                  </div>
                </div>
              )}

              {/* STEP 2 — EDUCATION */}
              {step===2&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Education</h2>
                  <p className="text-black/40 text-sm mb-5">Matric, courses, learnerships — all count.</p>
                  <div className="space-y-3">
                    {cv.edu.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 bg-[#FAFAFA] relative">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,edu:c.edu.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="School"><input className={inp} placeholder="Khayelitsha High" value={e.school} onChange={ev=>{const ed=[...cv.edu];ed[i].school=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                          <F label="Qualification"><input className={inp} placeholder="Matric Certificate" value={e.qualification} onChange={ev=>{const ed=[...cv.edu];ed[i].qualification=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                        </div>
                        <div className="w-32"><F label="Year"><input className={inp} placeholder="2024" value={e.year} onChange={ev=>{const ed=[...cv.edu];ed[i].year=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F></div>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,edu:[...c.edu,{school:'',qualification:'',year:''}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>Add qualification
                    </button>
                  </div>
                </div>
              )}

              {/* STEP 3 — SKILLS */}
              {step===3&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Skills</h2>
                  <p className="text-black/40 text-sm mb-5">Tap to select — add your own too.</p>
                  <div className="flex flex-wrap gap-2 mb-5">
                    {SKILLS.map(s=>(
                      <button key={s} onClick={()=>setCv(c=>({...c,skills:c.skills.includes(s)?c.skills.filter(x=>x!==s):[...c.skills,s]}))}
                        className={clsx('text-sm px-4 py-2 rounded-full border-2 transition-all font-medium',cv.skills.includes(s)?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/50 hover:border-black/12')}
                        style={cv.skills.includes(s)?{background:opts.color,borderColor:opts.color}:{}}>
                        {cv.skills.includes(s)&&<Check size={11} className="inline mr-1 -mt-0.5"/>}{s}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <input className={inp} placeholder="Add your own…" value={custom} onChange={e=>setCustom(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}}/>
                    <button onClick={()=>{if(custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-semibold hover:opacity-85 transition-opacity whitespace-nowrap">+ Add</button>
                  </div>
                </div>
              )}

              {/* STEP 4 — EXPERIENCE */}
              {step===4&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Experience</h2>
                  <div className="bg-[#F5A623]/10 border border-[#F5A623]/20 rounded-2xl px-4 py-3.5 mb-5 mt-2">
                    <p className="text-sm font-semibold text-[#1A1A0F] mb-0.5">💡 No work experience? That's fine.</p>
                    <p className="text-sm text-black/45">Family business, school projects, church work — tick "volunteer" and we'll label it correctly.</p>
                  </div>
                  <div className="space-y-3">
                    {cv.exp.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 bg-[#FAFAFA] relative">
                        <button onClick={()=>setCv(c=>({...c,exp:c.exp.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="Role"><input className={inp} placeholder="Shop assistant" value={e.title} onChange={ev=>{const ex=[...cv.exp];ex[i].title=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="Organisation"><input className={inp} placeholder="Shoprite" value={e.org} onChange={ev=>{const ex=[...cv.exp];ex[i].org=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <div className="grid grid-cols-2 gap-3 mb-3">
                          <F label="Start"><input className={inp} placeholder="Jan 2023" value={e.start} onChange={ev=>{const ex=[...cv.exp];ex[i].start=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="End"><input className={inp} placeholder="Present" value={e.end} onChange={ev=>{const ex=[...cv.exp];ex[i].end=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <F label="Description"><textarea className={inp+' resize-none'} rows={2} value={e.desc} onChange={ev=>{const ex=[...cv.exp];ex[i].desc=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        <label className="flex items-center gap-2 mt-3 cursor-pointer">
                          <input type="checkbox" checked={e.volunteer} className="accent-[#F5A623] w-4 h-4" onChange={ev=>{const ex=[...cv.exp];ex[i].volunteer=ev.target.checked;setCv(c=>({...c,exp:ex}))}}/>
                          <span className="text-sm text-black/45">Volunteer / informal work</span>
                        </label>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,exp:[...c.exp,{title:'',org:'',start:'',end:'',desc:'',volunteer:false}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>Add experience
                    </button>
                  </div>
                </div>
              )}

              {/* STEP 5 — REFERENCES */}
              {step===5&&(
                <div>
                  <div className="flex items-center justify-between mb-0.5">
                    <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F]">References</h2>
                    <label className="flex items-center gap-2 cursor-pointer"><input type="checkbox" checked={opts.showRefs} onChange={e=>setOpt('showRefs',e.target.checked)} className="accent-[#F5A623] w-4 h-4"/><span className="text-sm text-black/40">Show on CV</span></label>
                  </div>
                  <p className="text-black/40 text-sm mb-5">A teacher, community leader, or neighbour works fine.</p>
                  <div className="space-y-3">
                    {cv.refs.map((r,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 bg-[#FAFAFA] relative">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,refs:c.refs.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center transition-colors"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="Full name"><input className={inp} placeholder="Mrs Dlamini" value={r.name} onChange={e=>{const rf=[...cv.refs];rf[i].name=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                          <F label="Relationship"><input className={inp} placeholder="Former teacher" value={r.relation} onChange={e=>{const rf=[...cv.refs];rf[i].relation=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                        </div>
                        <F label="Contact"><input className={inp} placeholder="072 000 0000" value={r.contact} onChange={e=>{const rf=[...cv.refs];rf[i].contact=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,refs:[...c.refs,{name:'',relation:'',contact:''}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>Add reference
                    </button>
                  </div>
                  {pct()>=60&&(
                    <div className="mt-8 rounded-2xl p-5 border-2" style={{background:`${opts.color}10`,borderColor:`${opts.color}30`}}>
                      <div className="text-2xl mb-1.5">🎉</div>
                      <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-1">Your CV is ready!</h3>
                      <p className="text-sm text-black/45 mb-4">Download your professional CV as a PDF and start applying.</p>
                      <a href="/api/cv/download" target="_blank" className="btn-amber inline-flex items-center gap-2 !py-2.5 !px-5 text-sm">
                        <Download size={14}/> Download CV (PDF)
                      </a>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Nav footer */}
            <div className="px-5 md:px-7 py-4 bg-[#FAFAFA] border-t border-black/6 flex items-center justify-between">
              <button onClick={()=>step>0&&setStep(step-1)} disabled={step===0} className={clsx('flex items-center gap-1.5 text-sm font-semibold transition-colors',step===0?'text-black/15 cursor-not-allowed':'text-black/40 hover:text-[#1A1A0F]')}>
                <ChevronLeft size={15}/> Back
              </button>
              <div className="flex items-center gap-3">
                <button onClick={save} disabled={saving} className="flex items-center gap-1.5 text-sm text-black/40 hover:text-[#1A1A0F] transition-colors">
                  {saving?<Loader2 size={13} className="animate-spin"/>:saved?<Check size={13} className="text-green-500"/>:null}
                  {saved?'Saved!':'Save'}
                </button>
                {step<5
                  ?<button onClick={async()=>{await save();setStep(step+1)}} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm font-semibold">Continue <ChevronRight size={13}/></button>
                  :<button onClick={save} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm font-semibold">{saving?<Loader2 size={13} className="animate-spin"/>:<Check size={13}/>}Finish</button>
                }
              </div>
            </div>
          </div>
        </div>

        {/* ── DESKTOP RIGHT PANEL ── */}
        <div className="hidden xl:flex flex-col gap-3 w-[380px] flex-shrink-0 sticky top-20 h-fit">
          {/* Options card */}
          <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
            <div className="flex items-center gap-2 mb-4"><Settings size={14} className="text-black/30"/><span className="text-[11px] font-bold tracking-[2px] uppercase text-black/30">Customise</span></div>
            <Toggle on={opts.showPhoto}    onChange={v=>setOpt('showPhoto',v)}    label="Show profile photo"/>
            <Toggle on={opts.showPhone}    onChange={v=>setOpt('showPhone',v)}    label="Show phone number"/>
            <Toggle on={opts.showLoc}      onChange={v=>setOpt('showLoc',v)}      label="Show location"/>
            <Toggle on={opts.showLinkedin} onChange={v=>setOpt('showLinkedin',v)} label="Show LinkedIn"/>
            <Toggle on={opts.showRefs}     onChange={v=>setOpt('showRefs',v)}     label="Show references"/>
            <div className="pt-3 mt-1">
              <div className="text-[11px] font-bold tracking-[2px] uppercase text-black/30 mb-2.5">Colour</div>
              <div className="flex gap-2 flex-wrap">
                {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-8 h-8 rounded-full transition-all border-2',opts.color===c?'scale-125 border-white ring-2 ring-[#1A1A0F] shadow':'border-white/60 hover:scale-110 shadow-sm')} style={{background:c}}/>)}
              </div>
            </div>
          </div>

          {/* Live preview card */}
          <div className="bg-white rounded-2xl border border-black/8 overflow-hidden shadow-sm">
            <div className="px-4 py-3 bg-[#F7F3EB] border-b border-black/6 flex justify-between items-center">
              <div className="flex items-center gap-2"><Eye size={13} className="text-black/30"/><span className="text-[11px] font-bold tracking-[2px] uppercase text-black/30">Live Preview</span></div>
              <span className="text-[10px] text-black/25 font-medium">{TEMPLATES.find(t=>t.id===opts.template)?.name} · {pct()}%</span>
            </div>
            {/* Preview area — uses real CV template scaled down */}
            <div className="overflow-hidden bg-gray-100" style={{ height:460 }}>
              <div style={{ transform:'scale(0.43)', transformOrigin:'top left', width:'233%', pointerEvents:'none' }}>
                <Preview cv={previewCv} opts={opts}/>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── MOBILE PREVIEW SHEET ── */}
      {(showPreview||showOpts)&&(
        <div className="fixed inset-0 z-50 xl:hidden" onClick={()=>{ setShowPreview(false); setShowOpts(false) }}>
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl overflow-hidden" style={{maxHeight:'90vh'}} onClick={e=>e.stopPropagation()}>
            <div className="px-5 py-4 border-b border-black/8 flex items-center justify-between bg-[#F7F3EB]">
              <div className="flex gap-2">
                <button onClick={()=>{setShowPreview(true);setShowOpts(false)}} className={clsx('text-sm font-semibold px-4 py-1.5 rounded-full transition-all',showPreview?'bg-[#1A1A0F] text-white':'text-black/40 hover:text-black')}>Preview</button>
                <button onClick={()=>{setShowOpts(true);setShowPreview(false)}} className={clsx('text-sm font-semibold px-4 py-1.5 rounded-full transition-all',showOpts?'bg-[#1A1A0F] text-white':'text-black/40 hover:text-black')}>Options</button>
              </div>
              <button onClick={()=>{setShowPreview(false);setShowOpts(false)}} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center"><X size={16}/></button>
            </div>

            {showPreview&&(
              <>
                {/* Template switcher */}
                <div className="px-4 py-2.5 border-b border-black/6 flex items-center gap-2 overflow-x-auto" style={{scrollbarWidth:'none'}}>
                  {TEMPLATES.map(t=>(
                    <button key={t.id} onClick={()=>setOpt('template',t.id)} className={clsx('text-xs font-semibold px-3 py-1.5 rounded-full whitespace-nowrap border-2 transition-all',opts.template===t.id?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/40')} style={opts.template===t.id?{background:opts.color}:{}}>{t.name}</button>
                  ))}
                  <div className="w-px h-4 bg-black/10 flex-shrink-0 mx-1"/>
                  {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-6 h-6 rounded-full flex-shrink-0 border-2',opts.color===c?'border-[#1A1A0F] scale-110 shadow':'border-white shadow-sm')} style={{background:c}}/>)}
                </div>
                <div className="overflow-y-auto bg-gray-100 p-3" style={{maxHeight:'68vh'}}>
                  <div style={{transform:'scale(0.48)',transformOrigin:'top left',width:'208%',pointerEvents:'none'}}>
                    <Preview cv={previewCv} opts={opts}/>
                  </div>
                </div>
              </>
            )}

            {showOpts&&(
              <div className="p-5 overflow-y-auto" style={{maxHeight:'75vh'}}>
                <Toggle on={opts.showPhoto}    onChange={v=>setOpt('showPhoto',v)}    label="Show profile photo"/>
                <Toggle on={opts.showPhone}    onChange={v=>setOpt('showPhone',v)}    label="Show phone number"/>
                <Toggle on={opts.showLoc}      onChange={v=>setOpt('showLoc',v)}      label="Show location"/>
                <Toggle on={opts.showLinkedin} onChange={v=>setOpt('showLinkedin',v)} label="Show LinkedIn"/>
                <Toggle on={opts.showRefs}     onChange={v=>setOpt('showRefs',v)}     label="Show references"/>
                <div className="mt-4 pt-4 border-t border-black/6">
                  <div className="text-[11px] font-bold tracking-[2px] uppercase text-black/30 mb-3">Accent colour</div>
                  <div className="flex gap-3 flex-wrap">
                    {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-10 h-10 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F] shadow-md':'border-white shadow-sm hover:scale-105')} style={{background:c}}/>)}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
EOF

echo "✅ CV Builder fixed!"
npm run dev
