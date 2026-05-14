import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, X, Loader2, Eye, Settings, Camera, Palette } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

// ── Types
interface PI  { name:string; title:string; email:string; phone:string; location:string; summary:string; linkedin:string; photo:string; languages:string }
interface Edu { school:string; qualification:string; year:string }
interface Exp { title:string; org:string; start:string; end:string; bullets:string; volunteer:boolean }
interface Ref { name:string; relation:string; contact:string }
interface CV  { pi:PI; edu:Edu[]; skills:string[]; exp:Exp[]; refs:Ref[] }
interface Opts { template:string; color:string; showPhone:boolean; showLoc:boolean; showLinkedin:boolean; showRefs:boolean; showPhoto:boolean; showLanguages:boolean }

const EMPTY:CV = {
  pi:{ name:'', title:'', email:'', phone:'', location:'', summary:'', linkedin:'', photo:'', languages:'English, IsiXhosa' },
  edu:[{school:'',qualification:'',year:''}],
  skills:[], exp:[], refs:[],
}
const DEF:Opts = { template:'canva1', color:'#8FA3B1', showPhone:true, showLoc:true, showLinkedin:false, showRefs:true, showPhoto:true, showLanguages:true }

const SKILLS = ['Communication','Microsoft Office','Customer service','Teamwork','Time management','Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling','Basic accounting','Attention to detail','Computer literacy','Adaptability','Leadership','Filing & admin','Telephone etiquette','First Aid','Report writing','Stock management']
const ACCENT_COLORS = ['#8FA3B1','#1565C0','#2E7D32','#4A148C','#B71C1C','#E65100','#004D40','#37474F','#1A1A0F','#880E4F']
const STEPS = ['Template','Personal','Education','Skills','Experience','References']
const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/25 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/70 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

// ════════════════════════════════════════════
// TEMPLATE 1 — CANVA CLASSIC (exactly like mom's CV)
// Big photo, light blue sidebar, bullet points
// ════════════════════════════════════════════
function TemplateCanva1({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const langs = p.languages ? p.languages.split(',').map(l=>l.trim()).filter(Boolean) : []

  return (
    <div style={{ width:'210mm', minHeight:'297mm', fontFamily:'"Helvetica Neue", Arial, sans-serif', background:'white', fontSize:'9px' }}>
      {/* ── HEADER BANNER */}
      <div style={{ background:c+'33', padding:'0', display:'flex', alignItems:'flex-end', minHeight:'80px', position:'relative' }}>
        {/* Photo circle — overlaps header */}
        <div style={{ position:'relative', marginLeft:28, marginBottom:-20, zIndex:2, flexShrink:0 }}>
          {opts.showPhoto && p.photo
            ? <img src={p.photo} style={{ width:110, height:110, borderRadius:'50%', objectFit:'cover', objectPosition:'top', border:'4px solid white', display:'block', boxShadow:'0 2px 12px rgba(0,0,0,0.15)' }}/>
            : <div style={{ width:110, height:110, borderRadius:'50%', background:c+'66', border:'4px solid white', display:'flex', alignItems:'center', justifyContent:'center', fontSize:36, fontWeight:800, color:c, boxShadow:'0 2px 12px rgba(0,0,0,0.12)' }}>{p.name?p.name[0].toUpperCase():'?'}</div>
          }
        </div>
        {/* Name area */}
        <div style={{ paddingLeft:24, paddingBottom:16, paddingTop:16, flex:1 }}>
          <div style={{ fontSize:28, fontWeight:900, letterSpacing:'-0.5px', lineHeight:1.1, color:'#1a1a1a', textTransform:'uppercase' }}>{p.name||'YOUR NAME'}</div>
          {p.title && <div style={{ fontSize:13, color:'#555', marginTop:4, fontWeight:400 }}>{p.title}</div>}
        </div>
      </div>

      {/* ── BODY — two columns */}
      <div style={{ display:'grid', gridTemplateColumns:'72mm 1fr', minHeight:'calc(297mm - 80px)', paddingTop:28 }}>

        {/* LEFT COLUMN */}
        <div style={{ padding:'0 20px 24px 28px' }}>
          {/* Contact card */}
          <div style={{ background:c+'22', borderRadius:14, padding:'16px 14px', marginBottom:20, marginTop:8 }}>
            {opts.showPhone && p.phone && (
              <div style={{ display:'flex', alignItems:'flex-start', gap:8, marginBottom:10 }}>
                <span style={{ fontSize:12, flexShrink:0, marginTop:1 }}>📞</span>
                <span style={{ fontSize:9, color:'#333', lineHeight:1.5 }}>{p.phone}</span>
              </div>
            )}
            {p.email && (
              <div style={{ display:'flex', alignItems:'flex-start', gap:8, marginBottom:10 }}>
                <span style={{ fontSize:12, flexShrink:0, marginTop:1 }}>✉</span>
                <span style={{ fontSize:9, color:'#333', lineHeight:1.5, wordBreak:'break-all' }}>{p.email}</span>
              </div>
            )}
            {opts.showLoc && p.location && (
              <div style={{ display:'flex', alignItems:'flex-start', gap:8 }}>
                <span style={{ fontSize:12, flexShrink:0, marginTop:1 }}>📍</span>
                <span style={{ fontSize:9, color:'#333', lineHeight:1.5 }}>{p.location}</span>
              </div>
            )}
            {opts.showLinkedin && p.linkedin && (
              <div style={{ display:'flex', alignItems:'flex-start', gap:8, marginTop:10 }}>
                <span style={{ fontSize:12, flexShrink:0, marginTop:1 }}>🔗</span>
                <span style={{ fontSize:9, color:'#333', lineHeight:1.5, wordBreak:'break-all' }}>{p.linkedin}</span>
              </div>
            )}
          </div>

          {/* Education */}
          {cv.edu.some(e=>e.school) && (
            <div style={{ marginBottom:20 }}>
              <div style={{ fontSize:11, fontWeight:800, letterSpacing:'1.5px', textTransform:'uppercase', color:'#1a1a1a', marginBottom:6 }}>EDUCATION</div>
              <div style={{ height:1, background:'#ccc', marginBottom:10 }}/>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:10 }}>
                  {e.year && <div style={{ fontSize:8.5, color:'#777', marginBottom:2 }}>{e.year}</div>}
                  <div style={{ fontSize:9.5, fontWeight:700, color:'#1a1a1a', lineHeight:1.4 }}>{e.qualification}</div>
                  <div style={{ fontSize:8.5, fontWeight:600, color:'#444' }}>{e.school}</div>
                </div>
              ))}
            </div>
          )}

          {/* Skills */}
          {cv.skills.length > 0 && (
            <div style={{ marginBottom:20 }}>
              <div style={{ fontSize:11, fontWeight:800, letterSpacing:'1.5px', textTransform:'uppercase', color:'#1a1a1a', marginBottom:6 }}>SKILLS</div>
              <div style={{ height:1, background:'#ccc', marginBottom:10 }}/>
              {cv.skills.map(s => (
                <div key={s} style={{ display:'flex', alignItems:'center', gap:7, marginBottom:5, fontSize:9 }}>
                  <div style={{ width:5, height:5, borderRadius:'50%', background:'#888', flexShrink:0 }}/>
                  <span style={{ color:'#333' }}>{s}</span>
                </div>
              ))}
            </div>
          )}

          {/* Languages */}
          {opts.showLanguages && langs.length > 0 && (
            <div>
              <div style={{ fontSize:11, fontWeight:800, letterSpacing:'1.5px', textTransform:'uppercase', color:'#1a1a1a', marginBottom:6 }}>LANGUAGE</div>
              <div style={{ height:1, background:'#ccc', marginBottom:10 }}/>
              {langs.map(l => (
                <div key={l} style={{ fontSize:9.5, color:'#333', marginBottom:5 }}>{l}</div>
              ))}
            </div>
          )}
        </div>

        {/* RIGHT COLUMN */}
        <div style={{ padding:'0 28px 24px 20px', borderLeft:'1px solid #eee' }}>
          {/* About Me */}
          {p.summary && (
            <div style={{ marginBottom:20 }}>
              <div style={{ fontSize:14, fontWeight:800, color:'#1a1a1a', marginBottom:6 }}>About Me</div>
              <div style={{ height:1.5, background:'#1a1a1a', marginBottom:10 }}/>
              <p style={{ fontSize:9, color:'#444', lineHeight:1.8, textAlign:'justify' }}>{p.summary}</p>
            </div>
          )}

          {/* Work Experience */}
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:20 }}>
              <div style={{ fontSize:14, fontWeight:800, color:'#1a1a1a', marginBottom:6 }}>WORK EXPERIENCE</div>
              <div style={{ height:1.5, background:'#1a1a1a', marginBottom:12 }}/>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:14 }}>
                  {/* Date range */}
                  {(e.start || e.end) && (
                    <div style={{ fontSize:9, fontWeight:700, color:c==='#8FA3B1'?'#7a8f9e':c, marginBottom:2 }}>
                      {[e.start, e.end].filter(Boolean).join(' – ')}{e.volunteer ? ' (Volunteer)' : ''}
                    </div>
                  )}
                  {/* Title — Org */}
                  <div style={{ fontSize:11, fontWeight:700, color:'#1a1a1a', marginBottom:5 }}>
                    {e.title}{e.org ? ` — ${e.org}` : ''}
                  </div>
                  {/* Bullet points */}
                  {e.bullets && e.bullets.split('\n').filter(b=>b.trim()).map((b,j) => (
                    <div key={j} style={{ display:'flex', alignItems:'flex-start', gap:6, marginBottom:3 }}>
                      <span style={{ fontSize:9, color:'#555', flexShrink:0, marginTop:1 }}>•</span>
                      <span style={{ fontSize:9, color:'#444', lineHeight:1.65 }}>{b.trim().replace(/^[-•]\s*/,'')}</span>
                    </div>
                  ))}
                  {/* If no bullets, show plain desc */}
                  {!e.bullets && e.title && (
                    <div style={{ fontSize:9, color:'#666', fontStyle:'italic' }}>Add bullet points below to describe your responsibilities.</div>
                  )}
                </div>
              ))}
            </div>
          )}

          {/* References */}
          {opts.showRefs && cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:14, fontWeight:800, color:'#1a1a1a', marginBottom:6 }}>REFERENCES</div>
              <div style={{ height:1.5, background:'#1a1a1a', marginBottom:12 }}/>
              <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:14 }}>
                {cv.refs.filter(r=>r.name).map((r,i) => (
                  <div key={i}>
                    <div style={{ fontSize:11, fontWeight:800, color:'#1a1a1a' }}>{r.name}</div>
                    {r.relation && <div style={{ fontSize:9, color:'#555', marginBottom:2 }}>{r.relation}</div>}
                    {r.contact && <div style={{ fontSize:9, color:'#555' }}><strong>Phone: </strong>{r.contact}</div>}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// ════════════════════════════════════════════
// TEMPLATE 2 — DARK SIDEBAR PRO
// Dark coloured sidebar, white text, photo at top
// ════════════════════════════════════════════
function TemplateCanva2({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const langs = p.languages ? p.languages.split(',').map(l=>l.trim()).filter(Boolean) : []
  return (
    <div style={{ display:'flex', width:'210mm', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Dark sidebar */}
      <div style={{ width:'70mm', background:c, color:'white', padding:'28px 18px', display:'flex', flexDirection:'column', gap:16, flexShrink:0 }}>
        {/* Photo */}
        <div style={{ textAlign:'center', paddingBottom:16, borderBottom:'1px solid rgba(255,255,255,0.2)' }}>
          {opts.showPhoto && p.photo
            ? <img src={p.photo} style={{ width:80,height:80,borderRadius:'50%',objectFit:'cover',objectPosition:'top',border:'3px solid rgba(255,255,255,0.5)',margin:'0 auto 10px',display:'block' }}/>
            : <div style={{ width:80,height:80,borderRadius:'50%',background:'rgba(255,255,255,0.2)',margin:'0 auto 10px',display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,fontWeight:800,border:'2px solid rgba(255,255,255,0.3)' }}>{p.name?p.name[0].toUpperCase():'?'}</div>
          }
          <div style={{ fontSize:14,fontWeight:800,lineHeight:1.2,letterSpacing:'-0.3px' }}>{p.name||'Your Name'}</div>
          {p.title&&<div style={{ fontSize:8,opacity:0.7,marginTop:4,letterSpacing:'1px',textTransform:'uppercase' }}>{p.title}</div>}
        </div>
        {/* Contact */}
        <div>
          <div style={{ fontSize:8,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.55,marginBottom:8 }}>Contact</div>
          {p.email&&<div style={{ display:'flex',gap:6,marginBottom:5,fontSize:8.5,wordBreak:'break-all' }}><span>✉</span>{p.email}</div>}
          {opts.showPhone&&p.phone&&<div style={{ display:'flex',gap:6,marginBottom:5,fontSize:8.5 }}><span>☏</span>{p.phone}</div>}
          {opts.showLoc&&p.location&&<div style={{ display:'flex',gap:6,marginBottom:5,fontSize:8.5 }}><span>⊕</span>{p.location}</div>}
          {opts.showLinkedin&&p.linkedin&&<div style={{ display:'flex',gap:6,marginBottom:5,fontSize:8.5,wordBreak:'break-all' }}><span>in</span>{p.linkedin}</div>}
        </div>
        {/* Education */}
        {cv.edu.some(e=>e.school)&&<div>
          <div style={{ fontSize:8,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.55,marginBottom:8 }}>Education</div>
          {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8 }}>
            <div style={{ fontSize:9,fontWeight:700,lineHeight:1.3 }}>{e.qualification}</div>
            <div style={{ fontSize:8,opacity:0.7 }}>{e.school}</div>
            {e.year&&<div style={{ fontSize:7.5,opacity:0.55 }}>{e.year}</div>}
          </div>)}
        </div>}
        {/* Skills */}
        {cv.skills.length>0&&<div>
          <div style={{ fontSize:8,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.55,marginBottom:8 }}>Skills</div>
          {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5 }}>
            <div style={{ height:2.5,flex:1,background:'rgba(255,255,255,0.15)',borderRadius:2 }}><div style={{ height:2.5,background:'rgba(255,255,255,0.7)',borderRadius:2,width:'80%' }}/></div>
            <span style={{ fontSize:8,opacity:0.85,width:60,flexShrink:0,textAlign:'right' }}>{s}</span>
          </div>)}
        </div>}
        {/* Languages */}
        {opts.showLanguages&&langs.length>0&&<div>
          <div style={{ fontSize:8,fontWeight:700,letterSpacing:'2px',textTransform:'uppercase',opacity:0.55,marginBottom:8 }}>Languages</div>
          {langs.map(l=><div key={l} style={{ fontSize:9,opacity:0.85,marginBottom:4 }}>{l}</div>)}
        </div>}
      </div>
      {/* Main */}
      <div style={{ flex:1, padding:'28px 24px', display:'flex', flexDirection:'column', gap:16 }}>
        {p.summary&&<div>
          <div style={{ fontSize:12,fontWeight:800,color:'#1a1a1a',marginBottom:5,display:'flex',alignItems:'center',gap:8 }}>
            <span>About Me</span><div style={{ flex:1,height:1.5,background:'#1a1a1a' }}/>
          </div>
          <p style={{ fontSize:9,color:'#444',lineHeight:1.8 }}>{p.summary}</p>
        </div>}
        {cv.exp.some(e=>e.title)&&<div>
          <div style={{ fontSize:12,fontWeight:800,color:'#1a1a1a',marginBottom:8,display:'flex',alignItems:'center',gap:8 }}>
            <span>Work Experience</span><div style={{ flex:1,height:1.5,background:'#1a1a1a' }}/>
          </div>
          {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:12,paddingLeft:10,borderLeft:`3px solid ${c}` }}>
            {(e.start||e.end)&&<div style={{ fontSize:8.5,fontWeight:700,color:c,marginBottom:2 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</div>}
            <div style={{ fontSize:11,fontWeight:800,color:'#111',marginBottom:4 }}>{e.title}{e.org?` — ${e.org}`:''}{e.volunteer?' (Vol.)':''}</div>
            {e.bullets&&e.bullets.split('\n').filter(b=>b.trim()).map((b,j)=><div key={j} style={{ display:'flex',gap:5,marginBottom:2.5 }}>
              <span style={{ fontSize:9,color:'#666',flexShrink:0,marginTop:1 }}>•</span>
              <span style={{ fontSize:9,color:'#444',lineHeight:1.65 }}>{b.trim().replace(/^[-•]\s*/,'')}</span>
            </div>)}
          </div>)}
        </div>}
        {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
          <div style={{ fontSize:12,fontWeight:800,color:'#1a1a1a',marginBottom:8,display:'flex',alignItems:'center',gap:8 }}>
            <span>References</span><div style={{ flex:1,height:1.5,background:'#1a1a1a' }}/>
          </div>
          <div style={{ display:'grid',gridTemplateColumns:'1fr 1fr',gap:12 }}>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ padding:'8px 10px',background:'#F9FAFB',borderRadius:8,border:'1px solid #E5E7EB' }}>
              <div style={{ fontWeight:800,fontSize:10,color:'#111' }}>{r.name}</div>
              {r.relation&&<div style={{ fontSize:8.5,color:'#666' }}>{r.relation}</div>}
              {r.contact&&<div style={{ fontSize:8.5,color:'#666' }}><strong>Phone:</strong> {r.contact}</div>}
            </div>)}
          </div>
        </div>}
      </div>
    </div>
  )
}

// ════════════════════════════════════════════
// TEMPLATE 3 — CLEAN MINIMALIST (white, no sidebar)
// Like Canva's clean white full-width templates
// ════════════════════════════════════════════
function TemplateCanva3({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const langs = p.languages ? p.languages.split(',').map(l=>l.trim()).filter(Boolean) : []
  return (
    <div style={{ width:'210mm', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white', padding:'28px 32px' }}>
      {/* Header */}
      <div style={{ display:'flex', alignItems:'center', gap:20, marginBottom:20, paddingBottom:18, borderBottom:`3px solid ${c}` }}>
        {opts.showPhoto && p.photo && (
          <img src={p.photo} style={{ width:80,height:80,borderRadius:'50%',objectFit:'cover',objectPosition:'top',border:`2px solid ${c}`,flexShrink:0 }}/>
        )}
        <div style={{ flex:1 }}>
          <div style={{ fontSize:26,fontWeight:900,letterSpacing:'-0.5px',color:'#111',lineHeight:1,textTransform:'uppercase' }}>{p.name||'YOUR NAME'}</div>
          {p.title&&<div style={{ fontSize:11,color:c,fontWeight:600,marginTop:4,letterSpacing:'1px' }}>{p.title}</div>}
          <div style={{ display:'flex',flexWrap:'wrap',gap:12,marginTop:8,fontSize:8.5,color:'#666' }}>
            {p.email&&<span>✉ {p.email}</span>}
            {opts.showPhone&&p.phone&&<span>☏ {p.phone}</span>}
            {opts.showLoc&&p.location&&<span>⊕ {p.location}</span>}
            {opts.showLinkedin&&p.linkedin&&<span>🔗 {p.linkedin}</span>}
          </div>
        </div>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:24 }}>
        {/* Left */}
        <div style={{ display:'flex',flexDirection:'column',gap:16 }}>
          {p.summary&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:6,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Profile</div>
            <p style={{ fontSize:9,color:'#444',lineHeight:1.8 }}>{p.summary}</p>
          </div>}
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:6,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8 }}>
              <div style={{ fontSize:10,fontWeight:800,color:'#111' }}>{e.qualification}</div>
              <div style={{ fontSize:9,color:'#555' }}>{e.school}{e.year&&` · ${e.year}`}</div>
            </div>)}
          </div>}
          {cv.skills.length>0&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:6,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Skills</div>
            <div style={{ display:'grid',gridTemplateColumns:'1fr 1fr',gap:'4px 8px' }}>
              {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:5,fontSize:8.5,color:'#444' }}>
                <div style={{ width:4,height:4,borderRadius:'50%',background:c,flexShrink:0 }}/>{s}
              </div>)}
            </div>
          </div>}
          {opts.showLanguages&&langs.length>0&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:6,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Languages</div>
            <div style={{ display:'flex',flexWrap:'wrap',gap:5 }}>
              {langs.map(l=><span key={l} style={{ fontSize:9,background:`${c}18`,color:c,padding:'2px 8px',borderRadius:20,border:`1px solid ${c}30` }}>{l}</span>)}
            </div>
          </div>}
        </div>
        {/* Right */}
        <div style={{ display:'flex',flexDirection:'column',gap:16 }}>
          {cv.exp.some(e=>e.title)&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:8,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Work Experience</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:12 }}>
              {(e.start||e.end)&&<div style={{ fontSize:8.5,fontWeight:700,color:c,marginBottom:1 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</div>}
              <div style={{ fontSize:11,fontWeight:800,color:'#111',marginBottom:4 }}>{e.title}{e.org?` — ${e.org}`:''}</div>
              {e.bullets&&e.bullets.split('\n').filter(b=>b.trim()).map((b,j)=><div key={j} style={{ display:'flex',gap:5,marginBottom:2.5 }}>
                <span style={{ fontSize:9,color:'#777',flexShrink:0 }}>•</span>
                <span style={{ fontSize:9,color:'#444',lineHeight:1.65 }}>{b.trim().replace(/^[-•]\s*/,'')}</span>
              </div>)}
            </div>)}
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:11,fontWeight:800,textTransform:'uppercase',letterSpacing:'1.5px',color:c,marginBottom:8,paddingBottom:4,borderBottom:`2px solid ${c}` }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:8 }}>
              <div style={{ fontWeight:800,fontSize:10,color:'#111' }}>{r.name}</div>
              {r.relation&&<div style={{ fontSize:8.5,color:'#666' }}>{r.relation}</div>}
              {r.contact&&<div style={{ fontSize:8.5,color:'#666' }}><strong>Phone:</strong> {r.contact}</div>}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

// ════════════════════════════════════════════
// TEMPLATE 4 — BOLD HEADER (full-width dark header)
// ════════════════════════════════════════════
function TemplateCanva4({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const langs = p.languages ? p.languages.split(',').map(l=>l.trim()).filter(Boolean) : []
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'"Helvetica Neue",Arial,sans-serif',fontSize:'9px',background:'white' }}>
      {/* Full-width header */}
      <div style={{ background:c,padding:'24px 32px',display:'flex',alignItems:'center',gap:20,position:'relative',overflow:'hidden' }}>
        <div style={{ position:'absolute',right:-40,top:-40,width:180,height:180,borderRadius:'50%',background:'rgba(255,255,255,0.07)' }}/>
        {opts.showPhoto&&p.photo
          ?<img src={p.photo} style={{ width:80,height:80,borderRadius:'50%',objectFit:'cover',objectPosition:'top',border:'3px solid rgba(255,255,255,0.5)',flexShrink:0 }}/>
          :<div style={{ width:80,height:80,borderRadius:'50%',background:'rgba(255,255,255,0.18)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,fontWeight:800,color:'white',border:'2px solid rgba(255,255,255,0.3)',flexShrink:0 }}>{p.name?p.name[0].toUpperCase():'?'}</div>
        }
        <div style={{ color:'white',position:'relative' }}>
          <div style={{ fontSize:24,fontWeight:900,letterSpacing:'-0.5px',lineHeight:1,textTransform:'uppercase' }}>{p.name||'YOUR NAME'}</div>
          {p.title&&<div style={{ fontSize:9.5,opacity:0.72,marginTop:4,letterSpacing:'2px',textTransform:'uppercase' }}>{p.title}</div>}
          <div style={{ display:'flex',flexWrap:'wrap',gap:12,marginTop:8,fontSize:8.5,opacity:0.85 }}>
            {p.email&&<span>✉ {p.email}</span>}
            {opts.showPhone&&p.phone&&<span>☏ {p.phone}</span>}
            {opts.showLoc&&p.location&&<span>⊕ {p.location}</span>}
          </div>
        </div>
      </div>
      <div style={{ height:4,background:`linear-gradient(90deg,${c},${c}50,transparent)` }}/>
      {/* Body */}
      <div style={{ display:'grid',gridTemplateColumns:'72mm 1fr',minHeight:'calc(297mm - 120px)' }}>
        <div style={{ padding:'18px 18px 18px 24px',borderRight:'1px solid #eee',display:'flex',flexDirection:'column',gap:14 }}>
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:10,fontWeight:800,textTransform:'uppercase',color:'#1a1a1a',marginBottom:5,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Education</div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8 }}>
              <div style={{ fontSize:9.5,fontWeight:800,color:'#111' }}>{e.qualification}</div>
              <div style={{ fontSize:8.5,color:'#555' }}>{e.school}</div>
              {e.year&&<div style={{ fontSize:8,color:'#888' }}>{e.year}</div>}
            </div>)}
          </div>}
          {cv.skills.length>0&&<div>
            <div style={{ fontSize:10,fontWeight:800,textTransform:'uppercase',color:'#1a1a1a',marginBottom:5,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Skills</div>
            {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:6,marginBottom:4 }}>
              <div style={{ width:4,height:4,borderRadius:'50%',background:c,flexShrink:0 }}/>
              <span style={{ fontSize:9,color:'#444' }}>{s}</span>
            </div>)}
          </div>}
          {opts.showLanguages&&langs.length>0&&<div>
            <div style={{ fontSize:10,fontWeight:800,textTransform:'uppercase',color:'#1a1a1a',marginBottom:5,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Languages</div>
            {langs.map(l=><div key={l} style={{ fontSize:9.5,color:'#333',marginBottom:4 }}>{l}</div>)}
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:10,fontWeight:800,textTransform:'uppercase',color:'#1a1a1a',marginBottom:5,paddingBottom:4,borderBottom:`2px solid ${c}` }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i)=><div key={i} style={{ marginBottom:8 }}>
              <div style={{ fontWeight:800,fontSize:9.5,color:'#111' }}>{r.name}</div>
              {r.relation&&<div style={{ fontSize:8.5,color:'#666' }}>{r.relation}</div>}
              {r.contact&&<div style={{ fontSize:8.5,color:'#666' }}>{r.contact}</div>}
            </div>)}
          </div>}
        </div>
        <div style={{ padding:'18px 24px 18px 20px',display:'flex',flexDirection:'column',gap:14 }}>
          {p.summary&&<div>
            <div style={{ fontSize:12,fontWeight:800,color:'#1a1a1a',marginBottom:5,paddingBottom:4,borderBottom:`2px solid ${c}` }}>About Me</div>
            <p style={{ fontSize:9,color:'#444',lineHeight:1.8 }}>{p.summary}</p>
          </div>}
          {cv.exp.some(e=>e.title)&&<div>
            <div style={{ fontSize:12,fontWeight:800,color:'#1a1a1a',marginBottom:8,paddingBottom:4,borderBottom:`2px solid ${c}` }}>Work Experience</div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:13 }}>
              {(e.start||e.end)&&<div style={{ fontSize:8.5,fontWeight:700,color:c,marginBottom:1 }}>{[e.start,e.end].filter(Boolean).join(' – ')}{e.volunteer?' (Vol.)':''}</div>}
              <div style={{ fontSize:11,fontWeight:800,color:'#111',marginBottom:4 }}>{e.title}{e.org?` — ${e.org}`:''}</div>
              {e.bullets&&e.bullets.split('\n').filter(b=>b.trim()).map((b,j)=><div key={j} style={{ display:'flex',gap:5,marginBottom:2.5 }}>
                <span style={{ fontSize:9,color:'#777',flexShrink:0 }}>•</span>
                <span style={{ fontSize:9,color:'#444',lineHeight:1.65 }}>{b.trim().replace(/^[-•]\s*/,'')}</span>
              </div>)}
            </div>)}
          </div>}
        </div>
      </div>
    </div>
  )
}

// ════════════════════════════════════════════
// TEMPLATE 5 — ELEGANT SERIF
// ════════════════════════════════════════════
function TemplateCanva5({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const langs = p.languages ? p.languages.split(',').map(l=>l.trim()).filter(Boolean) : []
  return (
    <div style={{ width:'210mm',minHeight:'297mm',fontFamily:'Georgia,"Times New Roman",serif',fontSize:'9px',background:'#FDFCFB' }}>
      <div style={{ padding:'28px 36px 0',textAlign:'center' }}>
        <div style={{ display:'flex',alignItems:'center',gap:10,marginBottom:12 }}>
          <div style={{ flex:1,height:2,background:c }}/><div style={{ width:8,height:8,transform:'rotate(45deg)',background:c,flexShrink:0 }}/><div style={{ flex:1,height:2,background:c }}/>
        </div>
        {opts.showPhoto&&p.photo&&<img src={p.photo} style={{ width:76,height:76,borderRadius:'50%',objectFit:'cover',objectPosition:'top',border:`2px solid ${c}`,margin:'0 auto 10px',display:'block' }}/>}
        <div style={{ fontSize:26,fontWeight:400,letterSpacing:'0.12em',textTransform:'uppercase',color:'#111',lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
        {p.title&&<div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:'#888',marginTop:5,fontFamily:'sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex',justifyContent:'center',flexWrap:'wrap',gap:14,marginTop:8,color:'#666',fontSize:8.5,fontFamily:'sans-serif' }}>
          {p.email&&<span>{p.email}</span>}
          {opts.showPhone&&p.phone&&<span>{p.phone}</span>}
          {opts.showLoc&&p.location&&<span>{p.location}</span>}
        </div>
        <div style={{ display:'flex',alignItems:'center',gap:10,marginTop:12 }}>
          <div style={{ flex:1,height:1,background:'#ddd' }}/><div style={{ width:5,height:5,transform:'rotate(45deg)',background:c,flexShrink:0 }}/><div style={{ flex:1,height:1,background:'#ddd' }}/>
        </div>
      </div>
      {p.summary&&<div style={{ padding:'12px 36px',textAlign:'center' }}>
        <p style={{ color:'#555',lineHeight:1.85,fontStyle:'italic',fontSize:9.5 }}>{p.summary}</p>
      </div>}
      <div style={{ padding:'4px 36px 28px',display:'grid',gridTemplateColumns:'60mm 1fr',gap:24 }}>
        <div style={{ display:'flex',flexDirection:'column',gap:14 }}>
          {cv.edu.some(e=>e.school)&&<div>
            <div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:c,marginBottom:8,fontFamily:'sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}40` }}/><span>Education</span><div style={{ flex:1,height:1,background:`${c}40` }}/>
            </div>
            {cv.edu.filter(e=>e.school).map((e,i)=><div key={i} style={{ marginBottom:8 }}>
              <div style={{ fontWeight:700,color:'#111',fontSize:10,fontFamily:'sans-serif' }}>{e.qualification}</div>
              <div style={{ color:'#666',fontFamily:'sans-serif',fontSize:8.5 }}>{e.school}</div>
              {e.year&&<div style={{ color:'#999',fontFamily:'sans-serif',fontSize:8 }}>{e.year}</div>}
            </div>)}
          </div>}
          {cv.skills.length>0&&<div>
            <div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:c,marginBottom:8,fontFamily:'sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}40` }}/><span>Skills</span><div style={{ flex:1,height:1,background:`${c}40` }}/>
            </div>
            {cv.skills.map(s=><div key={s} style={{ display:'flex',alignItems:'center',gap:6,marginBottom:5,fontFamily:'sans-serif',fontSize:9,color:'#444' }}>
              <div style={{ width:4,height:4,transform:'rotate(45deg)',background:c,flexShrink:0 }}/>{s}
            </div>)}
          </div>}
          {opts.showLanguages&&langs.length>0&&<div>
            <div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:c,marginBottom:8,fontFamily:'sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}40` }}/><span>Languages</span><div style={{ flex:1,height:1,background:`${c}40` }}/>
            </div>
            {langs.map(l=><div key={l} style={{ fontSize:9.5,color:'#444',fontFamily:'sans-serif',marginBottom:4 }}>{l}</div>)}
          </div>}
        </div>
        <div style={{ display:'flex',flexDirection:'column',gap:14 }}>
          {cv.exp.some(e=>e.title)&&<div>
            <div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:c,marginBottom:8,fontFamily:'sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}40` }}/><span>Experience</span><div style={{ flex:1,height:1,background:`${c}40` }}/>
            </div>
            {cv.exp.filter(e=>e.title).map((e,i)=><div key={i} style={{ marginBottom:11 }}>
              {(e.start||e.end)&&<div style={{ fontSize:8.5,fontWeight:700,color:c,fontFamily:'sans-serif',marginBottom:1 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</div>}
              <div style={{ fontWeight:700,color:'#111',fontSize:11,fontFamily:'sans-serif' }}>{e.title}{e.org?` — ${e.org}`:''}</div>
              {e.bullets&&e.bullets.split('\n').filter(b=>b.trim()).map((b,j)=><div key={j} style={{ display:'flex',gap:5,marginBottom:2.5 }}>
                <span style={{ fontSize:9,color:'#888',flexShrink:0,fontFamily:'sans-serif' }}>•</span>
                <span style={{ fontSize:9,color:'#555',lineHeight:1.7,fontFamily:'sans-serif' }}>{b.trim().replace(/^[-•]\s*/,'')}</span>
              </div>)}
            </div>)}
          </div>}
          {opts.showRefs&&cv.refs.some(r=>r.name)&&<div>
            <div style={{ fontSize:9,letterSpacing:'3px',textTransform:'uppercase',color:c,marginBottom:8,fontFamily:'sans-serif',display:'flex',alignItems:'center',gap:8 }}>
              <div style={{ flex:1,height:1,background:`${c}40` }}/><span>References</span><div style={{ flex:1,height:1,background:`${c}40` }}/>
            </div>
            <div style={{ display:'grid',gridTemplateColumns:'1fr 1fr',gap:10 }}>
              {cv.refs.filter(r=>r.name).map((r,i)=><div key={i}>
                <div style={{ fontWeight:700,color:'#111',fontFamily:'sans-serif',fontSize:9.5 }}>{r.name}</div>
                {r.relation&&<div style={{ color:'#888',fontFamily:'sans-serif',fontSize:8.5,fontStyle:'italic' }}>{r.relation}</div>}
                {r.contact&&<div style={{ color:'#888',fontFamily:'sans-serif',fontSize:8.5 }}>{r.contact}</div>}
              </div>)}
            </div>
          </div>}
        </div>
      </div>
    </div>
  )
}

// ─────────────────────────────────────────
// Preview router
// ─────────────────────────────────────────
function Preview({ cv, opts }:{ cv:CV; opts:Opts }) {
  switch(opts.template) {
    case 'canva2': return <TemplateCanva2 cv={cv} opts={opts}/>
    case 'canva3': return <TemplateCanva3 cv={cv} opts={opts}/>
    case 'canva4': return <TemplateCanva4 cv={cv} opts={opts}/>
    case 'canva5': return <TemplateCanva5 cv={cv} opts={opts}/>
    default:       return <TemplateCanva1 cv={cv} opts={opts}/>
  }
}

// ─────────────────────────────────────────
// Template thumbnail card — renders real CV
// ─────────────────────────────────────────
const DUMMY:CV = {
  pi:{ name:'Sipokazi Momoza', title:'Sales Assistant', email:'sipokazi@gmail.com', phone:'073 380 8914', location:'Cape Town, 7784', summary:'A hardworking professional with experience in retail and customer service. I take pride in maintaining high standards and contributing positively to my team.', linkedin:'', photo:'', languages:'English, IsiXhosa, Zulu' },
  edu:[{ school:'Ngangelizwe High School', qualification:'Grade 11 / Matric', year:'2009' }],
  skills:['Customer service','Teamwork','Cash handling','Stock management','Communication','Problem solving'],
  exp:[{
    title:'Shop Assistant', org:'Shoprite', start:'Jan 2020', end:'Present',
    bullets:'Assisted customers with product queries and purchases.\nMaintained stock levels and product rotation.\nOperated cash register and POS systems.',
    volunteer:false
  }],
  refs:[{ name:'Mr Mangena', relation:'Sales Manager', contact:'0213601380' },{ name:'Mrs Dlamini', relation:'HR', contact:'0213601380' }],
}

const TEMPLATES = [
  { id:'canva1', name:'Classic',   desc:'Light sidebar · Photo banner' },
  { id:'canva2', name:'Pro Dark',  desc:'Dark sidebar · Skill bars' },
  { id:'canva3', name:'Clean',     desc:'Two column · No sidebar' },
  { id:'canva4', name:'Bold',      desc:'Full header · Structured' },
  { id:'canva5', name:'Elegant',   desc:'Serif · Decorative' },
]

function TemplateCard({ id, name, desc, color, selected, onSelect }:{ id:string; name:string; desc:string; color:string; selected:boolean; onSelect:()=>void }) {
  const dummyOpts:Opts = { template:id, color, showPhone:true, showLoc:true, showLinkedin:false, showRefs:true, showPhoto:false, showLanguages:true }
  return (
    <button onClick={onSelect} className={clsx('relative border-2 rounded-2xl overflow-hidden text-left transition-all group hover:shadow-lg',selected?'border-[#F5A623] shadow-[0_0_0_3px_rgba(245,166,35,0.2)]':'border-black/8 hover:border-[#F5A623]/50')}>
      <div className="w-full overflow-hidden bg-white" style={{ height:200 }}>
        <div style={{ transform:'scale(0.27)', transformOrigin:'top left', width:'370%', pointerEvents:'none', userSelect:'none' }}>
          <Preview cv={DUMMY} opts={dummyOpts}/>
        </div>
      </div>
      <div className="p-3 bg-white border-t border-black/6">
        <div className="font-bold text-sm text-[#1A1A0F]">{name}</div>
        <div className="text-[11px] text-black/35 mt-0.5">{desc}</div>
      </div>
      {selected&&<div className="absolute top-2.5 right-2.5 w-6 h-6 rounded-full bg-[#F5A623] flex items-center justify-center shadow"><Check size={12} className="text-[#1A1A0F]"/></div>}
    </button>
  )
}

function Toggle({ on, onChange, label }:{ on:boolean; onChange:(v:boolean)=>void; label:string }) {
  return (
    <label className="flex items-center justify-between py-2.5 border-b border-black/5 last:border-0 cursor-pointer">
      <span className="text-sm text-[#1A1A0F]">{label}</span>
      <div onClick={()=>onChange(!on)} className={clsx('w-10 h-[22px] rounded-full transition-all relative flex-shrink-0',on?'bg-[#F5A623]':'bg-black/12')}>
        <div className={clsx('absolute top-[3px] w-4 h-4 rounded-full bg-white shadow-sm transition-all duration-200',on?'left-5':'left-[3px]')}/>
      </div>
    </label>
  )
}

function F({ label, children }:{ label:string; children:React.ReactNode }) {
  return <div><label className={lbl}>{label}</label>{children}</div>
}

// ════════════════════════════════════════════
// MAIN PAGE
// ════════════════════════════════════════════
export default function CVBuilder() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [step, setStep] = useState(0)
  const [cv, setCv] = useState<CV>(EMPTY)
  const [opts, setOpts] = useState<Opts>(DEF)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [custom, setCustom] = useState('')
  const [showPreview, setShowPreview] = useState(false)
  const [showOpts, setShowOpts] = useState(false)
  const fileRef = useRef<HTMLInputElement>(null)

  useEffect(() => { if (!user) navigate('/register') }, [user])
  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      setCv({
        pi: { ...(d.personal_info || EMPTY.pi), photo: d.personal_info?.photo || '', languages: d.personal_info?.languages || 'English, IsiXhosa' },
        edu: d.education?.length ? d.education : EMPTY.edu,
        skills: d.skills || [],
        exp: (d.experience || []).map((e:any) => ({ title:e.title||'', org:e.organisation||'', start:e.start_date||'', end:e.end_date||'', bullets:e.description||'', volunteer:e.is_volunteer||false })),
        refs: d.references || [],
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
        education: cv.edu.filter(e=>e.school),
        skills: cv.skills,
        experience: cv.exp.filter(e=>e.title).map(e=>({ title:e.title, organisation:e.org, start_date:e.start, end_date:e.end, description:e.bullets, is_volunteer:e.volunteer })),
        references: cv.refs.filter(r=>r.name),
      })
      setSaved(true); setTimeout(()=>setSaved(false),2000)
    } catch(e){ console.error(e) }
    finally{ setSaving(false) }
  }
  const handlePhoto = (e:React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]; if (!file) return
    const reader = new FileReader()
    reader.onload = ev => setCv(c=>({...c,pi:{...c.pi,photo:ev.target?.result as string}}))
    reader.readAsDataURL(file)
  }
  const previewCv:CV = { ...cv, pi:{ ...cv.pi, phone:opts.showPhone?cv.pi.phone:'', location:opts.showLoc?cv.pi.location:'', linkedin:opts.showLinkedin?cv.pi.linkedin:'', photo:opts.showPhoto?cv.pi.photo:'' }, refs:opts.showRefs?cv.refs:[] }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Header */}
      <div className="bg-[#1A1A0F] px-4 md:px-10 py-5">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-between gap-3 mb-3">
            <div>
              <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-0.5">CV Builder</p>
              <h1 className="font-display text-xl md:text-2xl font-bold text-white tracking-tight">Design your <em className="not-italic text-[#F5A623]">perfect CV.</em></h1>
            </div>
            <div className="xl:hidden flex gap-2">
              <button onClick={()=>{setShowOpts(true);setShowPreview(false)}} className="flex items-center gap-1.5 bg-white/10 border border-white/15 text-white text-xs font-semibold px-3 py-2 rounded-xl"><Palette size={13}/> Options</button>
              <button onClick={()=>{setShowPreview(true);setShowOpts(false)}} className="flex items-center gap-1.5 bg-[#F5A623] text-[#1A1A0F] text-xs font-semibold px-3 py-2 rounded-xl"><Eye size={13}/> Preview</button>
            </div>
          </div>
          <div className="flex items-center gap-3 mb-3">
            <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden"><div className="h-full rounded-full transition-all duration-700 bg-[#F5A623]" style={{width:pct()+'%'}}/></div>
            <span className="text-white/40 text-xs whitespace-nowrap">{pct()}%</span>
          </div>
          <div className="flex gap-1.5 overflow-x-auto pb-0.5" style={{scrollbarWidth:'none'}}>
            {STEPS.map((s,i)=>(
              <button key={s} onClick={()=>setStep(i)} className={clsx('flex items-center gap-1.5 text-[11px] font-semibold px-3 py-1.5 rounded-full whitespace-nowrap transition-all flex-shrink-0 border',i===step?'bg-[#F5A623] text-[#1A1A0F] border-transparent':i<step?'bg-[#2A5C3F] text-white border-transparent':'bg-white/5 text-white/40 border-white/10 hover:bg-white/12')}>
                {i<step?<Check size={10}/>:<span>{i+1}</span>}{s}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-3 md:px-6 py-5 xl:flex gap-5">
        {/* Form */}
        <div className="flex-1 min-w-0 mb-5 xl:mb-0">
          <div className="bg-white rounded-2xl border border-black/6 shadow-sm overflow-hidden">
            <div className="p-5 md:p-7">

              {/* STEP 0 — TEMPLATE */}
              {step===0&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Choose your template</h2>
                  <p className="text-black/40 text-sm mb-6">5 professional designs — each one fully filled out so you see exactly what your CV will look like.</p>
                  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 mb-7">
                    {TEMPLATES.map(t=>(
                      <TemplateCard key={t.id} id={t.id} name={t.name} desc={t.desc} color={opts.color} selected={opts.template===t.id} onSelect={()=>setOpt('template',t.id)}/>
                    ))}
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-[#1A1A0F] mb-3">Accent colour</h3>
                    <div className="flex gap-3 flex-wrap">
                      {ACCENT_COLORS.map(c=>(
                        <button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-9 h-9 rounded-full transition-all border-2',opts.color===c?'scale-125 border-white ring-2 ring-[#1A1A0F] shadow-md':'border-white/60 hover:scale-110 shadow-sm')} style={{background:c}}/>
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
                  {/* Photo */}
                  <div className="flex items-center gap-4 p-4 bg-[#F7F3EB] rounded-2xl border border-black/6 mb-5">
                    <div className="w-16 h-16 rounded-full bg-white border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center overflow-hidden cursor-pointer hover:border-[#F5A623] transition-colors flex-shrink-0" onClick={()=>fileRef.current?.click()}>
                      {cv.pi.photo?<img src={cv.pi.photo} className="w-full h-full object-cover object-top"/>:<Camera size={20} className="text-[#F5A623]/50"/>}
                    </div>
                    <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handlePhoto}/>
                    <div className="flex-1">
                      <div className="text-sm font-semibold text-[#1A1A0F] mb-0.5">Profile photo</div>
                      <div className="text-xs text-black/40 mb-2">Upload a professional headshot</div>
                      <div className="flex items-center gap-3">
                        <button onClick={()=>fileRef.current?.click()} className="text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623]">Upload photo</button>
                        {cv.pi.photo&&<><span className="text-black/20 text-xs">·</span><button onClick={()=>setCv(c=>({...c,pi:{...c.pi,photo:''}}))} className="text-xs font-semibold text-red-400">Remove</button></>}
                      </div>
                    </div>
                    <Toggle on={opts.showPhoto} onChange={v=>setOpt('showPhoto',v)} label=""/>
                  </div>
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <F label="Full name *"><input className={inp} placeholder="e.g. Sipokazi Momoza" value={cv.pi.name} onChange={e=>setCv(c=>({...c,pi:{...c.pi,name:e.target.value}}))}/></F>
                      <F label="Job title"><input className={inp} placeholder="e.g. Deli Controller" value={cv.pi.title} onChange={e=>setCv(c=>({...c,pi:{...c.pi,title:e.target.value}}))}/></F>
                    </div>
                    <F label="Email *"><input className={inp} type="email" placeholder="you@gmail.com" value={cv.pi.email} onChange={e=>setCv(c=>({...c,pi:{...c.pi,email:e.target.value}}))}/></F>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>Phone</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showPhone} onChange={e=>setOpt('showPhone',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                        <input className={inp} placeholder="073 380 8914" value={cv.pi.phone} onChange={e=>setCv(c=>({...c,pi:{...c.pi,phone:e.target.value}}))}/>
                      </div>
                      <div>
                        <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>Location</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLoc} onChange={e=>setOpt('showLoc',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                        <input className={inp} placeholder="Cape Town, Western Cape" value={cv.pi.location} onChange={e=>setCv(c=>({...c,pi:{...c.pi,location:e.target.value}}))}/>
                      </div>
                    </div>
                    <div>
                      <div className="flex items-center justify-between mb-1.5"><label className={lbl.replace('mb-1.5','')}>LinkedIn (optional)</label><label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={opts.showLinkedin} onChange={e=>setOpt('showLinkedin',e.target.checked)} className="accent-[#F5A623]"/><span className="text-[11px] text-black/35">Show</span></label></div>
                      <input className={inp} placeholder="linkedin.com/in/yourname" value={cv.pi.linkedin} onChange={e=>setCv(c=>({...c,pi:{...c.pi,linkedin:e.target.value}}))}/>
                    </div>
                    <F label="Languages (comma separated)">
                      <input className={inp} placeholder="English, IsiXhosa, Zulu" value={cv.pi.languages} onChange={e=>setCv(c=>({...c,pi:{...c.pi,languages:e.target.value}}))}/>
                    </F>
                    <F label="About me / summary"><textarea className={inp+' resize-none'} rows={4} placeholder="I am a hardworking professional with experience in…" value={cv.pi.summary} onChange={e=>setCv(c=>({...c,pi:{...c.pi,summary:e.target.value}}))}/></F>
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
                        {i>0&&<button onClick={()=>setCv(c=>({...c,edu:c.edu.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="School / institution"><input className={inp} placeholder="Ngangelizwe High School" value={e.school} onChange={ev=>{const ed=[...cv.edu];ed[i].school=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                          <F label="Qualification"><input className={inp} placeholder="Matric Certificate / Grade 11" value={e.qualification} onChange={ev=>{const ed=[...cv.edu];ed[i].qualification=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F>
                        </div>
                        <div className="w-36"><F label="Year completed"><input className={inp} placeholder="2024" value={e.year} onChange={ev=>{const ed=[...cv.edu];ed[i].year=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></F></div>
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
                        className={clsx('text-sm px-4 py-2 rounded-full border-2 font-medium transition-all',cv.skills.includes(s)?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/50 hover:border-black/12')}
                        style={cv.skills.includes(s)?{background:opts.color}:{}}>
                        {cv.skills.includes(s)&&<Check size={11} className="inline mr-1 -mt-0.5"/>}{s}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <input className={inp} placeholder="Add your own skill…" value={custom} onChange={e=>setCustom(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}}/>
                    <button onClick={()=>{if(custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-semibold hover:opacity-85 whitespace-nowrap">+ Add</button>
                  </div>
                </div>
              )}

              {/* STEP 4 — EXPERIENCE */}
              {step===4&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Work Experience</h2>
                  <div className="bg-[#F5A623]/10 border border-[#F5A623]/20 rounded-2xl px-4 py-3.5 mb-5 mt-2">
                    <p className="text-sm font-semibold text-[#1A1A0F] mb-1">💡 Pro tip — use bullet points!</p>
                    <p className="text-sm text-black/45">In the "What you did" box, put each responsibility on a new line. They'll appear as proper bullet points on your CV — just like your mom's!</p>
                  </div>
                  <div className="space-y-3">
                    {cv.exp.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 bg-[#FAFAFA] relative">
                        <button onClick={()=>setCv(c=>({...c,exp:c.exp.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="Job title"><input className={inp} placeholder="Deli Controller" value={e.title} onChange={ev=>{const ex=[...cv.exp];ex[i].title=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="Company / organisation"><input className={inp} placeholder="Shoprite" value={e.org} onChange={ev=>{const ex=[...cv.exp];ex[i].org=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <div className="grid grid-cols-2 gap-3 mb-3">
                          <F label="Start date"><input className={inp} placeholder="January 2015" value={e.start} onChange={ev=>{const ex=[...cv.exp];ex[i].start=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                          <F label="End date"><input className={inp} placeholder="Present" value={e.end} onChange={ev=>{const ex=[...cv.exp];ex[i].end=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></F>
                        </div>
                        <F label="What you did (one bullet per line)">
                          <textarea className={inp+' resize-none'} rows={4} placeholder={"Managed daily operations in the deli department.\nMaintained high standards of food hygiene and safety.\nProvided excellent customer service."} value={e.bullets} onChange={ev=>{const ex=[...cv.exp];ex[i].bullets=ev.target.value;setCv(c=>({...c,exp:ex}))}}/>
                        </F>
                        <label className="flex items-center gap-2 mt-3 cursor-pointer">
                          <input type="checkbox" checked={e.volunteer} className="accent-[#F5A623] w-4 h-4" onChange={ev=>{const ex=[...cv.exp];ex[i].volunteer=ev.target.checked;setCv(c=>({...c,exp:ex}))}}/>
                          <span className="text-sm text-black/45">This was volunteer / informal work</span>
                        </label>
                      </div>
                    ))}
                    <button onClick={()=>setCv(c=>({...c,exp:[...c.exp,{title:'',org:'',start:'',end:'',bullets:'',volunteer:false}]}))} className="flex items-center gap-2 text-sm font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                      <div className="w-7 h-7 rounded-full border-2 border-dashed border-[#F5A623]/50 flex items-center justify-center"><Plus size={13}/></div>Add job
                    </button>
                  </div>
                </div>
              )}

              {/* STEP 5 — REFERENCES */}
              {step===5&&(
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F]">References</h2>
                    <label className="flex items-center gap-2 cursor-pointer"><input type="checkbox" checked={opts.showRefs} onChange={e=>setOpt('showRefs',e.target.checked)} className="accent-[#F5A623] w-4 h-4"/><span className="text-sm text-black/40">Show on CV</span></label>
                  </div>
                  <p className="text-black/40 text-sm mb-5">A teacher, community leader, or previous employer.</p>
                  <div className="space-y-3">
                    {cv.refs.map((r,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 bg-[#FAFAFA] relative">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,refs:c.refs.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
                          <F label="Full name"><input className={inp} placeholder="Mr Mangena" value={r.name} onChange={e=>{const rf=[...cv.refs];rf[i].name=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                          <F label="Relationship / title"><input className={inp} placeholder="Sales Manager" value={r.relation} onChange={e=>{const rf=[...cv.refs];rf[i].relation=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
                        </div>
                        <F label="Phone number"><input className={inp} placeholder="0213601380" value={r.contact} onChange={e=>{const rf=[...cv.refs];rf[i].contact=e.target.value;setCv(c=>({...c,refs:rf}))}}/></F>
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
                      <a href="/api/cv/download" target="_blank" className="btn-amber inline-flex items-center gap-2 !py-2.5 !px-5 text-sm"><Download size={14}/> Download CV (PDF)</a>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Nav footer */}
            <div className="px-5 md:px-7 py-4 bg-[#FAFAFA] border-t border-black/6 flex items-center justify-between">
              <button onClick={()=>step>0&&setStep(step-1)} disabled={step===0} className={clsx('flex items-center gap-1.5 text-sm font-semibold',step===0?'text-black/15 cursor-not-allowed':'text-black/40 hover:text-[#1A1A0F]')}>
                <ChevronLeft size={15}/> Back
              </button>
              <div className="flex items-center gap-3">
                <button onClick={save} disabled={saving} className="flex items-center gap-1.5 text-sm text-black/40 hover:text-[#1A1A0F]">
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

        {/* Desktop right panel */}
        <div className="hidden xl:flex flex-col gap-3 w-[380px] flex-shrink-0 sticky top-20 h-fit">
          <div className="bg-white rounded-2xl border border-black/8 p-5 shadow-sm">
            <div className="flex items-center gap-2 mb-4"><Settings size={14} className="text-black/30"/><span className="text-[11px] font-bold tracking-[2px] uppercase text-black/30">Customise</span></div>
            <Toggle on={opts.showPhoto}     onChange={v=>setOpt('showPhoto',v)}     label="Show profile photo"/>
            <Toggle on={opts.showPhone}     onChange={v=>setOpt('showPhone',v)}     label="Show phone number"/>
            <Toggle on={opts.showLoc}       onChange={v=>setOpt('showLoc',v)}       label="Show location"/>
            <Toggle on={opts.showLinkedin}  onChange={v=>setOpt('showLinkedin',v)}  label="Show LinkedIn"/>
            <Toggle on={opts.showLanguages} onChange={v=>setOpt('showLanguages',v)} label="Show languages"/>
            <Toggle on={opts.showRefs}      onChange={v=>setOpt('showRefs',v)}      label="Show references"/>
            <div className="pt-3 mt-1">
              <div className="text-[11px] font-bold tracking-[2px] uppercase text-black/30 mb-2.5">Colour</div>
              <div className="flex gap-2.5 flex-wrap">
                {ACCENT_COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-8 h-8 rounded-full transition-all border-2',opts.color===c?'scale-125 border-white ring-2 ring-[#1A1A0F] shadow-md':'border-white/60 hover:scale-110 shadow-sm')} style={{background:c}}/>)}
              </div>
            </div>
          </div>
          <div className="bg-white rounded-2xl border border-black/8 overflow-hidden shadow-sm">
            <div className="px-4 py-3 bg-[#F7F3EB] border-b border-black/6 flex justify-between items-center">
              <div className="flex items-center gap-2"><Eye size={13} className="text-black/30"/><span className="text-[11px] font-bold tracking-[2px] uppercase text-black/30">Live Preview</span></div>
              <span className="text-[10px] text-black/25">{TEMPLATES.find(t=>t.id===opts.template)?.name} · {pct()}%</span>
            </div>
            <div className="overflow-hidden bg-gray-100" style={{height:460}}>
              <div style={{transform:'scale(0.43)',transformOrigin:'top left',width:'233%',pointerEvents:'none'}}>
                <Preview cv={previewCv} opts={opts}/>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile sheet */}
      {(showPreview||showOpts)&&(
        <div className="fixed inset-0 z-50 xl:hidden" onClick={()=>{setShowPreview(false);setShowOpts(false)}}>
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl overflow-hidden" style={{maxHeight:'90vh'}} onClick={e=>e.stopPropagation()}>
            <div className="px-5 py-4 border-b border-black/8 flex items-center justify-between bg-[#F7F3EB]">
              <div className="flex gap-2">
                <button onClick={()=>{setShowPreview(true);setShowOpts(false)}} className={clsx('text-sm font-semibold px-4 py-1.5 rounded-full',showPreview?'bg-[#1A1A0F] text-white':'text-black/40')}>Preview</button>
                <button onClick={()=>{setShowOpts(true);setShowPreview(false)}} className={clsx('text-sm font-semibold px-4 py-1.5 rounded-full',showOpts?'bg-[#1A1A0F] text-white':'text-black/40')}>Options</button>
              </div>
              <button onClick={()=>{setShowPreview(false);setShowOpts(false)}} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center"><X size={16}/></button>
            </div>
            {showPreview&&(
              <>
                <div className="px-4 py-2.5 border-b border-black/6 flex items-center gap-2 overflow-x-auto" style={{scrollbarWidth:'none'}}>
                  {TEMPLATES.map(t=><button key={t.id} onClick={()=>setOpt('template',t.id)} className={clsx('text-xs font-semibold px-3 py-1.5 rounded-full whitespace-nowrap border-2',opts.template===t.id?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/40')} style={opts.template===t.id?{background:opts.color}:{}}>{t.name}</button>)}
                  <div className="w-px h-4 bg-black/10 flex-shrink-0 mx-1"/>
                  {ACCENT_COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-6 h-6 rounded-full flex-shrink-0 border-2',opts.color===c?'border-[#1A1A0F] scale-110':'border-white shadow-sm')} style={{background:c}}/>)}
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
                <Toggle on={opts.showPhoto}     onChange={v=>setOpt('showPhoto',v)}     label="Show profile photo"/>
                <Toggle on={opts.showPhone}     onChange={v=>setOpt('showPhone',v)}     label="Show phone number"/>
                <Toggle on={opts.showLoc}       onChange={v=>setOpt('showLoc',v)}       label="Show location"/>
                <Toggle on={opts.showLinkedin}  onChange={v=>setOpt('showLinkedin',v)}  label="Show LinkedIn"/>
                <Toggle on={opts.showLanguages} onChange={v=>setOpt('showLanguages',v)} label="Show languages"/>
                <Toggle on={opts.showRefs}      onChange={v=>setOpt('showRefs',v)}      label="Show references"/>
                <div className="mt-4 pt-4 border-t border-black/6">
                  <div className="text-[11px] font-bold tracking-[2px] uppercase text-black/30 mb-3">Colour</div>
                  <div className="flex gap-3 flex-wrap">
                    {ACCENT_COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-10 h-10 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F] shadow-md':'border-white shadow-sm')} style={{background:c}}/>)}
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
