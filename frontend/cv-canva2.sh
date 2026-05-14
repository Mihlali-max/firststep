#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🎨 Building Canva-style CV templates..."

cat > src/components/pages/CVBuilder.tsx << 'EOF'
import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, X, Loader2, Eye, Settings, Camera } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

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
const DEF:Opts = { template:'nova', color:'#1A1A0F', showPhone:true, showLoc:true, showLinkedin:false, showRefs:true, showPhoto:false }

const SKILLS = ['Communication','Microsoft Office','Customer service','Teamwork','Time management','Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling','Basic accounting','Attention to detail','Computer literacy','Adaptability','Leadership','Filing & admin','Telephone etiquette','Forklift licence','First Aid','Report writing']
const COLORS = ['#1A1A0F','#1565C0','#0D47A1','#2E7D32','#4A148C','#B71C1C','#E65100','#004D40','#37474F','#880E4F']
const STEPS  = ['Template','Personal','Education','Skills','Experience','References']
const inp = "w-full bg-[#F7F3EB] border border-black/10 text-[#1A1A0F] placeholder:text-black/30 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/70 focus:bg-white transition-all"
const lbl = "block text-[11px] font-semibold tracking-[2px] uppercase text-black/40 mb-1.5"

// ═══════════════════════════════════════════════
// TEMPLATE 1 — NOVA (Bold geometric sidebar)
// Like the dark sidebar ones in Canva
// ═══════════════════════════════════════════════
function TemplateNova({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  const light = c+'22'; const mid = c+'55'
  return (
    <div style={{ display:'flex', width:'100%', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Sidebar */}
      <div style={{ width:'38%', background:c, color:'white', display:'flex', flexDirection:'column', flexShrink:0 }}>
        {/* Photo + name area */}
        <div style={{ padding:'28px 18px 20px', borderBottom:'1px solid rgba(255,255,255,0.15)', textAlign:'center' }}>
          {opts.showPhoto && p.photo ? (
            <img src={p.photo} alt="" style={{ width:72, height:72, borderRadius:'50%', objectFit:'cover', border:'3px solid rgba(255,255,255,0.4)', margin:'0 auto 12px', display:'block' }}/>
          ) : (
            <div style={{ width:72, height:72, borderRadius:'50%', background:'rgba(255,255,255,0.15)', margin:'0 auto 12px', display:'flex', alignItems:'center', justifyContent:'center', border:'2px solid rgba(255,255,255,0.25)', fontSize:24, fontWeight:800 }}>
              {p.name ? p.name[0].toUpperCase() : 'Y'}
            </div>
          )}
          <div style={{ fontSize:14, fontWeight:800, letterSpacing:'-0.3px', lineHeight:1.2 }}>{p.name||'Your Name'}</div>
          {p.title && <div style={{ fontSize:7.5, opacity:0.65, marginTop:4, letterSpacing:'1.5px', textTransform:'uppercase', fontWeight:500 }}>{p.title}</div>}
        </div>

        {/* Contact */}
        <div style={{ padding:'14px 18px', borderBottom:'1px solid rgba(255,255,255,0.12)' }}>
          <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:8 }}>Contact</div>
          {p.email    && <div style={{ display:'flex', alignItems:'center', gap:6, marginBottom:5, opacity:0.9, fontSize:8, wordBreak:'break-all' }}><div style={{ width:14, height:14, borderRadius:'50%', background:'rgba(255,255,255,0.15)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:7 }}>✉</div>{p.email}</div>}
          {opts.showPhone&&p.phone && <div style={{ display:'flex', alignItems:'center', gap:6, marginBottom:5, opacity:0.9, fontSize:8 }}><div style={{ width:14, height:14, borderRadius:'50%', background:'rgba(255,255,255,0.15)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:7 }}>☏</div>{p.phone}</div>}
          {opts.showLoc&&p.location && <div style={{ display:'flex', alignItems:'center', gap:6, marginBottom:5, opacity:0.9, fontSize:8 }}><div style={{ width:14, height:14, borderRadius:'50%', background:'rgba(255,255,255,0.15)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:7 }}>⊕</div>{p.location}</div>}
          {opts.showLinkedin&&p.linkedin && <div style={{ display:'flex', alignItems:'center', gap:6, marginBottom:5, opacity:0.9, fontSize:8, wordBreak:'break-all' }}><div style={{ width:14, height:14, borderRadius:'50%', background:'rgba(255,255,255,0.15)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:7 }}>in</div>{p.linkedin}</div>}
        </div>

        {/* Skills */}
        {cv.skills.length>0 && (
          <div style={{ padding:'14px 18px', borderBottom:'1px solid rgba(255,255,255,0.12)' }}>
            <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:8 }}>Skills</div>
            {cv.skills.map(s => (
              <div key={s} style={{ marginBottom:6 }}>
                <div style={{ display:'flex', justifyContent:'space-between', marginBottom:2.5, fontSize:8 }}><span>{s}</span></div>
                <div style={{ height:3, background:'rgba(255,255,255,0.2)', borderRadius:2 }}>
                  <div style={{ height:3, background:'rgba(255,255,255,0.7)', borderRadius:2, width:'82%' }}/>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* References */}
        {opts.showRefs && cv.refs.some(r=>r.name) && (
          <div style={{ padding:'14px 18px' }}>
            <div style={{ fontSize:7, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.5, marginBottom:8 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i) => (
              <div key={i} style={{ marginBottom:9 }}>
                <div style={{ fontWeight:700, fontSize:8.5 }}>{r.name}</div>
                <div style={{ opacity:0.65, fontSize:7.5 }}>{r.relation}</div>
                {r.contact && <div style={{ opacity:0.5, fontSize:7 }}>{r.contact}</div>}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Main content */}
      <div style={{ flex:1, padding:'28px 22px', display:'flex', flexDirection:'column', gap:14 }}>
        {p.summary && (
          <div>
            <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:7 }}>
              <div style={{ width:18, height:18, borderRadius:4, background:c, display:'flex', alignItems:'center', justifyContent:'center' }}><div style={{ width:8, height:2, background:'white', borderRadius:1 }}/></div>
              <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c }}>Profile</div>
            </div>
            <p style={{ color:'#374151', lineHeight:1.8, fontSize:8.5 }}>{p.summary}</p>
          </div>
        )}

        {cv.exp.some(e=>e.title) && (
          <div>
            <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:8 }}>
              <div style={{ width:18, height:18, borderRadius:4, background:c }}/>
              <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c }}>Experience</div>
              <div style={{ flex:1, height:1, background:c+'20' }}/>
            </div>
            {cv.exp.filter(e=>e.title).map((e,i) => (
              <div key={i} style={{ marginBottom:11, paddingLeft:10, borderLeft:`2px solid ${c}30` }}>
                <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', marginBottom:1 }}>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                  <div style={{ fontSize:7.5, color:'#9CA3AF', background:'#F3F4F6', padding:'1px 6px', borderRadius:10, whiteSpace:'nowrap' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</div>
                </div>
                {e.org && <div style={{ fontSize:8, color:c, fontWeight:600, marginBottom:2 }}>{e.org}</div>}
                {e.desc && <div style={{ fontSize:8, color:'#6B7280', lineHeight:1.65 }}>{e.desc}</div>}
              </div>
            ))}
          </div>
        )}

        {cv.edu.some(e=>e.school) && (
          <div>
            <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:8 }}>
              <div style={{ width:18, height:18, borderRadius:4, background:c }}/>
              <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color:c }}>Education</div>
              <div style={{ flex:1, height:1, background:c+'20' }}/>
            </div>
            {cv.edu.filter(e=>e.school).map((e,i) => (
              <div key={i} style={{ marginBottom:8, paddingLeft:10, borderLeft:`2px solid ${c}30` }}>
                <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.qualification}</div>
                  {e.year && <div style={{ fontSize:7.5, color:'#9CA3AF', background:'#F3F4F6', padding:'1px 6px', borderRadius:10 }}>{e.year}</div>}
                </div>
                <div style={{ fontSize:8, color:'#6B7280' }}>{e.school}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════
// TEMPLATE 2 — PULSE (Bold top banner, photo circle)
// Like the ones with big coloured headers + photo
// ═══════════════════════════════════════════════
function TemplatePulse({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Header banner */}
      <div style={{ background:c, padding:'0 0 0 0', position:'relative', overflow:'hidden', minHeight:90 }}>
        {/* Geometric shapes */}
        <div style={{ position:'absolute', right:-20, top:-20, width:120, height:120, borderRadius:'50%', background:'rgba(255,255,255,0.07)' }}/>
        <div style={{ position:'absolute', right:60, bottom:-30, width:80, height:80, borderRadius:'50%', background:'rgba(255,255,255,0.05)' }}/>
        <div style={{ position:'absolute', left:-15, bottom:-15, width:70, height:70, transform:'rotate(45deg)', background:'rgba(255,255,255,0.06)' }}/>

        <div style={{ position:'relative', display:'flex', alignItems:'center', gap:18, padding:'20px 24px 20px' }}>
          {opts.showPhoto && p.photo ? (
            <img src={p.photo} alt="" style={{ width:68, height:68, borderRadius:'50%', objectFit:'cover', border:'3px solid rgba(255,255,255,0.5)', flexShrink:0 }}/>
          ) : (
            <div style={{ width:68, height:68, borderRadius:'50%', background:'rgba(255,255,255,0.18)', display:'flex', alignItems:'center', justifyContent:'center', fontSize:22, fontWeight:800, color:'white', border:'2px solid rgba(255,255,255,0.3)', flexShrink:0 }}>
              {p.name ? p.name[0].toUpperCase() : 'Y'}
            </div>
          )}
          <div style={{ color:'white' }}>
            <div style={{ fontSize:20, fontWeight:900, letterSpacing:'-0.5px', lineHeight:1.1 }}>{p.name||'Your Name'}</div>
            {p.title && <div style={{ fontSize:8.5, opacity:0.75, marginTop:3, letterSpacing:'1.5px', textTransform:'uppercase' }}>{p.title}</div>}
            <div style={{ display:'flex', flexWrap:'wrap', gap:10, marginTop:6, fontSize:7.5, opacity:0.8 }}>
              {p.email && <span>✉ {p.email}</span>}
              {opts.showPhone&&p.phone && <span>☏ {p.phone}</span>}
              {opts.showLoc&&p.location && <span>⊕ {p.location}</span>}
            </div>
          </div>
        </div>
      </div>

      {/* Body */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 185px', minHeight:'calc(297mm - 108px)' }}>
        {/* Left */}
        <div style={{ padding:'18px 20px', borderRight:'1px solid #F3F4F6' }}>
          {p.summary && (
            <div style={{ marginBottom:14, paddingBottom:12, borderBottom:'1px solid #F3F4F6' }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:6 }}>About Me</div>
              <p style={{ color:'#374151', lineHeight:1.8 }}>{p.summary}</p>
            </div>
          )}
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Work Experience</div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:11, position:'relative', paddingLeft:12 }}>
                  <div style={{ position:'absolute', left:0, top:4, width:5, height:5, borderRadius:'50%', background:c }}/>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10, lineHeight:1.2 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                  <div style={{ display:'flex', gap:8, alignItems:'center', marginTop:1, marginBottom:2 }}>
                    {e.org && <span style={{ fontSize:8, color:c, fontWeight:600 }}>{e.org}</span>}
                    {(e.start||e.end) && <span style={{ fontSize:7.5, color:'#9CA3AF' }}>· {[e.start,e.end].filter(Boolean).join(' – ')}</span>}
                  </div>
                  {e.desc && <div style={{ fontSize:8, color:'#6B7280', lineHeight:1.65 }}>{e.desc}</div>}
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8, position:'relative', paddingLeft:12 }}>
                  <div style={{ position:'absolute', left:0, top:4, width:5, height:5, borderRadius:'50%', background:c }}/>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.qualification}</div>
                  <div style={{ fontSize:8, color:'#6B7280' }}>{e.school}{e.year&&` · ${e.year}`}</div>
                </div>
              ))}
            </div>
          )}
        </div>
        {/* Right sidebar */}
        <div style={{ padding:'18px 14px', background:'#FAFAFA' }}>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Skills</div>
              <div style={{ display:'flex', flexWrap:'wrap', gap:4 }}>
                {cv.skills.map(s => (
                  <div key={s} style={{ fontSize:7.5, padding:'3px 8px', borderRadius:20, fontWeight:600, background:c+'15', color:c, border:`1px solid ${c}30` }}>{s}</div>
                ))}
              </div>
            </div>
          )}
          {opts.showRefs && cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8, padding:'7px 9px', background:'white', borderRadius:8, border:'1px solid #E5E7EB' }}>
                  <div style={{ fontWeight:700, color:'#111', fontSize:8.5 }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7 }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════
// TEMPLATE 3 — SLATE (Dark full-width header, clean body)
// Like the dark navy professional ones
// ═══════════════════════════════════════════════
function TemplateSlate({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Full-width dark header */}
      <div style={{ background:c, padding:'24px 28px', display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
        <div style={{ color:'white' }}>
          <div style={{ fontSize:24, fontWeight:900, letterSpacing:'-0.5px', lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
          {p.title && <div style={{ fontSize:9, letterSpacing:'3px', textTransform:'uppercase', opacity:0.65, marginTop:5, fontWeight:400 }}>{p.title}</div>}
        </div>
        <div style={{ textAlign:'right', color:'rgba(255,255,255,0.75)', fontSize:7.5, lineHeight:1.9 }}>
          {p.email    && <div>{p.email}</div>}
          {opts.showPhone&&p.phone    && <div>{p.phone}</div>}
          {opts.showLoc&&p.location && <div>{p.location}</div>}
          {opts.showLinkedin&&p.linkedin && <div>{p.linkedin}</div>}
        </div>
      </div>

      {/* Accent bar */}
      <div style={{ height:4, background:`linear-gradient(90deg, ${c}, ${c}80)` }}/>

      {/* Summary */}
      {p.summary && (
        <div style={{ padding:'12px 28px', background:`${c}08`, borderBottom:'1px solid #E5E7EB' }}>
          <p style={{ color:'#374151', lineHeight:1.75, fontStyle:'italic', fontSize:8.5 }}>{p.summary}</p>
        </div>
      )}

      {/* Body - two columns */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', padding:'16px 28px', gap:24 }}>
        <div>
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:9, fontWeight:800, color:c, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${c}` }}>Experience</div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:10 }}>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                  <div style={{ display:'flex', justifyContent:'space-between', marginTop:1 }}>
                    {e.org && <span style={{ fontSize:8, color:c, fontWeight:600 }}>{e.org}</span>}
                    <span style={{ fontSize:7.5, color:'#9CA3AF' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
                  </div>
                  {e.desc && <p style={{ fontSize:8, color:'#6B7280', marginTop:3, lineHeight:1.65 }}>{e.desc}</p>}
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:9, fontWeight:800, color:c, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${c}` }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8 }}>
                  <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.qualification}</div>
                  <div style={{ display:'flex', justifyContent:'space-between' }}>
                    <span style={{ fontSize:8, color:'#6B7280' }}>{e.school}</span>
                    <span style={{ fontSize:7.5, color:'#9CA3AF' }}>{e.year}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
        <div>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:9, fontWeight:800, color:c, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${c}` }}>Skills</div>
              <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:'4px 8px' }}>
                {cv.skills.map(s => (
                  <div key={s} style={{ display:'flex', alignItems:'center', gap:5, fontSize:8 }}>
                    <div style={{ width:5, height:5, borderRadius:'50%', background:c, flexShrink:0 }}/>{s}
                  </div>
                ))}
              </div>
            </div>
          )}
          {opts.showRefs && cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:9, fontWeight:800, color:c, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${c}` }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8, padding:'6px 8px', background:'#F9FAFB', borderRadius:6, border:'1px solid #E5E7EB' }}>
                  <div style={{ fontWeight:700, color:'#111', fontSize:8.5 }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7 }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════
// TEMPLATE 4 — SERIF (Elegant, editorial, serif fonts)
// Like the elegant beige/cream ones with serif headings
// ═══════════════════════════════════════════════
function TemplateSerif({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'Georgia, "Times New Roman", serif', fontSize:'9px', background:'#FDFCFB' }}>
      {/* Header */}
      <div style={{ padding:'32px 36px 20px', textAlign:'center', position:'relative' }}>
        {/* Top decorative line */}
        <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:14 }}>
          <div style={{ flex:1, height:2, background:c }}/>
          <div style={{ width:6, height:6, transform:'rotate(45deg)', background:c, flexShrink:0 }}/>
          <div style={{ flex:1, height:2, background:c }}/>
        </div>

        {opts.showPhoto && p.photo ? (
          <img src={p.photo} alt="" style={{ width:70, height:70, borderRadius:'50%', objectFit:'cover', border:`2px solid ${c}`, margin:'0 auto 10px', display:'block' }}/>
        ) : null}

        <div style={{ fontSize:26, fontWeight:400, letterSpacing:'0.12em', textTransform:'uppercase', color:'#111', lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
        {p.title && <div style={{ fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color:'#9CA3AF', marginTop:5, fontFamily:'"Helvetica Neue",sans-serif' }}>{p.title}</div>}

        <div style={{ display:'flex', justifyContent:'center', flexWrap:'wrap', gap:16, marginTop:8, color:'#6B7280', fontSize:7.5, fontFamily:'"Helvetica Neue",sans-serif' }}>
          {p.email    && <span>{p.email}</span>}
          {opts.showPhone&&p.phone    && <span>{p.phone}</span>}
          {opts.showLoc&&p.location && <span>{p.location}</span>}
          {opts.showLinkedin&&p.linkedin && <span>{p.linkedin}</span>}
        </div>

        <div style={{ display:'flex', alignItems:'center', gap:10, marginTop:14 }}>
          <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
          <div style={{ width:4, height:4, transform:'rotate(45deg)', background:c, flexShrink:0 }}/>
          <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
        </div>
      </div>

      {/* Body */}
      <div style={{ padding:'0 36px 28px', display:'grid', gridTemplateColumns:'1fr 170px', gap:24 }}>
        <div>
          {p.summary && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:7, letterSpacing:'4px', textTransform:'uppercase', color:c, marginBottom:6, fontFamily:'"Helvetica Neue",sans-serif', display:'flex', alignItems:'center', gap:8 }}>
                <div style={{ flex:1, height:1, background:`${c}30` }}/><span>Profile</span><div style={{ flex:1, height:1, background:`${c}30` }}/>
              </div>
              <p style={{ color:'#4B5563', lineHeight:1.85, fontStyle:'italic' }}>{p.summary}</p>
            </div>
          )}
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:7, letterSpacing:'4px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'"Helvetica Neue",sans-serif', display:'flex', alignItems:'center', gap:8 }}>
                <div style={{ flex:1, height:1, background:`${c}30` }}/><span>Experience</span><div style={{ flex:1, height:1, background:`${c}30` }}/>
              </div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:10 }}>
                  <div style={{ display:'flex', justifyContent:'space-between' }}>
                    <span style={{ fontWeight:700, color:'#111', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</span>
                    <span style={{ fontSize:7.5, color:'#9CA3AF', fontFamily:'"Helvetica Neue",sans-serif' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
                  </div>
                  {e.org && <div style={{ color:c, fontSize:8, fontStyle:'italic', fontFamily:'"Helvetica Neue",sans-serif' }}>{e.org}</div>}
                  {e.desc && <p style={{ color:'#6B7280', marginTop:2, lineHeight:1.7, fontFamily:'"Helvetica Neue",sans-serif', fontSize:8 }}>{e.desc}</p>}
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:7, letterSpacing:'4px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'"Helvetica Neue",sans-serif', display:'flex', alignItems:'center', gap:8 }}>
                <div style={{ flex:1, height:1, background:`${c}30` }}/><span>Education</span><div style={{ flex:1, height:1, background:`${c}30` }}/>
              </div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8 }}>
                  <div style={{ display:'flex', justifyContent:'space-between' }}>
                    <span style={{ fontWeight:700, color:'#111', fontSize:10 }}>{e.qualification}</span>
                    <span style={{ fontSize:7.5, color:'#9CA3AF', fontFamily:'"Helvetica Neue",sans-serif' }}>{e.year}</span>
                  </div>
                  <div style={{ color:'#6B7280', fontFamily:'"Helvetica Neue",sans-serif', fontSize:8 }}>{e.school}</div>
                </div>
              ))}
            </div>
          )}
        </div>
        <div>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:14 }}>
              <div style={{ fontSize:7, letterSpacing:'4px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'"Helvetica Neue",sans-serif' }}>Skills</div>
              {cv.skills.map(s => (
                <div key={s} style={{ display:'flex', alignItems:'center', gap:5, marginBottom:5, fontFamily:'"Helvetica Neue",sans-serif', fontSize:8, color:'#374151' }}>
                  <div style={{ width:4, height:4, transform:'rotate(45deg)', background:c, flexShrink:0 }}/>{s}
                </div>
              ))}
            </div>
          )}
          {opts.showRefs && cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:7, letterSpacing:'4px', textTransform:'uppercase', color:c, marginBottom:8, fontFamily:'"Helvetica Neue",sans-serif' }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8 }}>
                  <div style={{ fontWeight:700, color:'#111', fontSize:8.5 }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:7.5, fontStyle:'italic', fontFamily:'"Helvetica Neue",sans-serif' }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7, fontFamily:'"Helvetica Neue",sans-serif' }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════
// TEMPLATE 5 — IMPACT (Bold name, accent strip, modern)
// Like the ones with big name + colour strip on left
// ═══════════════════════════════════════════════
function TemplateImpact({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ display:'flex', width:'100%', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Thin accent strip */}
      <div style={{ width:8, background:c, flexShrink:0 }}/>

      {/* Content */}
      <div style={{ flex:1, display:'flex', flexDirection:'column' }}>
        {/* Name header */}
        <div style={{ padding:'24px 24px 18px', borderBottom:`3px solid ${c}` }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', gap:16 }}>
            <div>
              <div style={{ fontSize:26, fontWeight:900, color:'#111', letterSpacing:'-0.5px', lineHeight:1 }}>{p.name||'YOUR NAME'}</div>
              {p.title && <div style={{ fontSize:9, color:c, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', marginTop:4 }}>{p.title}</div>}
            </div>
            {opts.showPhoto && p.photo ? (
              <img src={p.photo} alt="" style={{ width:60, height:60, borderRadius:'50%', objectFit:'cover', border:`2px solid ${c}`, flexShrink:0 }}/>
            ) : null}
          </div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:14, marginTop:10, fontSize:7.5, color:'#6B7280' }}>
            {p.email    && <span>✉ {p.email}</span>}
            {opts.showPhone&&p.phone    && <span>☏ {p.phone}</span>}
            {opts.showLoc&&p.location && <span>⊕ {p.location}</span>}
            {opts.showLinkedin&&p.linkedin && <span>in {p.linkedin}</span>}
          </div>
        </div>

        {/* Body */}
        <div style={{ display:'grid', gridTemplateColumns:'1fr 180px', flex:1 }}>
          <div style={{ padding:'16px 20px 16px 24px', borderRight:'1px solid #F3F4F6' }}>
            {p.summary && (
              <div style={{ marginBottom:14, paddingBottom:12, borderBottom:'1px solid #F3F4F6' }}>
                <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:5 }}>Summary</div>
                <p style={{ color:'#4B5563', lineHeight:1.75 }}>{p.summary}</p>
              </div>
            )}
            {cv.exp.some(e=>e.title) && (
              <div style={{ marginBottom:14 }}>
                <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Experience</div>
                {cv.exp.filter(e=>e.title).map((e,i) => (
                  <div key={i} style={{ marginBottom:10, paddingBottom:8, borderBottom:'1px solid #F9FAFB' }}>
                    <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                    <div style={{ display:'flex', gap:6, alignItems:'center', marginTop:1.5, marginBottom:2 }}>
                      {e.org && <span style={{ fontSize:8, color:c, fontWeight:600 }}>{e.org}</span>}
                      {(e.start||e.end) && <span style={{ fontSize:7.5, color:'#9CA3AF' }}>· {[e.start,e.end].filter(Boolean).join(' – ')}</span>}
                    </div>
                    {e.desc && <div style={{ fontSize:8, color:'#6B7280', lineHeight:1.65 }}>{e.desc}</div>}
                  </div>
                ))}
              </div>
            )}
            {cv.edu.some(e=>e.school) && (
              <div>
                <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Education</div>
                {cv.edu.filter(e=>e.school).map((e,i) => (
                  <div key={i} style={{ marginBottom:8 }}>
                    <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.qualification}</div>
                    <div style={{ display:'flex', justifyContent:'space-between' }}>
                      <span style={{ fontSize:8, color:'#6B7280' }}>{e.school}</span>
                      <span style={{ fontSize:7.5, color:'#9CA3AF' }}>{e.year}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          <div style={{ padding:'16px 16px', background:'#FAFAFA' }}>
            {cv.skills.length>0 && (
              <div style={{ marginBottom:14 }}>
                <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Skills</div>
                {cv.skills.map(s => (
                  <div key={s} style={{ marginBottom:5 }}>
                    <div style={{ fontSize:8, color:'#374151', marginBottom:2.5 }}>{s}</div>
                    <div style={{ height:3, background:'#E5E7EB', borderRadius:2 }}>
                      <div style={{ height:3, background:c, borderRadius:2, width:'78%' }}/>
                    </div>
                  </div>
                ))}
              </div>
            )}
            {opts.showRefs && cv.refs.some(r=>r.name) && (
              <div>
                <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>References</div>
                {cv.refs.filter(r=>r.name).map((r,i) => (
                  <div key={i} style={{ marginBottom:8, padding:'6px 8px', background:'white', borderRadius:6, border:'1px solid #E5E7EB' }}>
                    <div style={{ fontWeight:700, color:'#111', fontSize:8.5 }}>{r.name}</div>
                    <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.relation}</div>
                    {r.contact && <div style={{ color:'#9CA3AF', fontSize:7 }}>{r.contact}</div>}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

// ═══════════════════════════════════════════════
// TEMPLATE 6 — SCRIPT (Script/brush name, modern body)
// Like the ones with stylised name at top
// ═══════════════════════════════════════════════
function TemplateScript({ cv, opts }:{ cv:CV; opts:Opts }) {
  const p = cv.pi; const c = opts.color
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'"Helvetica Neue",Arial,sans-serif', fontSize:'9px', background:'white' }}>
      {/* Header */}
      <div style={{ padding:'20px 28px 16px', background:`linear-gradient(135deg, ${c} 0%, ${c}dd 100%)`, color:'white', position:'relative', overflow:'hidden' }}>
        <div style={{ position:'absolute', right:-40, top:-40, width:160, height:160, borderRadius:'50%', background:'rgba(255,255,255,0.06)' }}/>
        <div style={{ position:'absolute', right:40, bottom:-50, width:120, height:120, borderRadius:'50%', background:'rgba(255,255,255,0.04)' }}/>
        <div style={{ position:'relative', display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
          <div>
            <div style={{ fontSize:28, fontWeight:900, letterSpacing:'-1px', lineHeight:1 }}>{p.name||'Your Name'}</div>
            {p.title && <div style={{ fontSize:9, opacity:0.7, letterSpacing:'2px', textTransform:'uppercase', marginTop:4, fontWeight:400 }}>{p.title}</div>}
          </div>
          {opts.showPhoto && p.photo ? (
            <img src={p.photo} alt="" style={{ width:64, height:64, borderRadius:'50%', objectFit:'cover', border:'3px solid rgba(255,255,255,0.45)' }}/>
          ) : (
            <div style={{ width:64, height:64, borderRadius:'50%', background:'rgba(255,255,255,0.15)', display:'flex', alignItems:'center', justifyContent:'center', fontSize:20, fontWeight:800, border:'2px solid rgba(255,255,255,0.25)' }}>{p.name?p.name[0].toUpperCase():'Y'}</div>
          )}
        </div>
        <div style={{ display:'flex', flexWrap:'wrap', gap:12, marginTop:10, fontSize:7.5, opacity:0.8 }}>
          {p.email    && <span>✉ {p.email}</span>}
          {opts.showPhone&&p.phone    && <span>☏ {p.phone}</span>}
          {opts.showLoc&&p.location && <span>⊕ {p.location}</span>}
          {opts.showLinkedin&&p.linkedin && <span>in {p.linkedin}</span>}
        </div>
      </div>

      {/* Wave divider */}
      <div style={{ height:6, background:`linear-gradient(90deg, ${c}, ${c}40, transparent)` }}/>

      {/* Body */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 190px' }}>
        <div style={{ padding:'16px 22px 16px 28px', borderRight:'1px solid #F3F4F6' }}>
          {p.summary && (
            <div style={{ marginBottom:14, paddingBottom:12, borderBottom:'1px solid #F3F4F6' }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:5 }}>About</div>
              <p style={{ color:'#4B5563', lineHeight:1.8 }}>{p.summary}</p>
            </div>
          )}
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Work History</div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:10, display:'grid', gridTemplateColumns:'80px 1fr', gap:10 }}>
                  <div style={{ color:'#9CA3AF', fontSize:7.5, paddingTop:1, lineHeight:1.5 }}>{e.start||''}{e.start&&e.end&&<br/>}{e.end||''}</div>
                  <div>
                    <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                    {e.org && <div style={{ fontSize:8, color:c, fontWeight:600 }}>{e.org}</div>}
                    {e.desc && <div style={{ fontSize:8, color:'#6B7280', marginTop:2, lineHeight:1.65 }}>{e.desc}</div>}
                  </div>
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8, display:'grid', gridTemplateColumns:'80px 1fr', gap:10 }}>
                  <div style={{ color:'#9CA3AF', fontSize:7.5, paddingTop:1 }}>{e.year}</div>
                  <div>
                    <div style={{ fontWeight:800, color:'#111', fontSize:10 }}>{e.qualification}</div>
                    <div style={{ fontSize:8, color:'#6B7280' }}>{e.school}</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
        <div style={{ padding:'16px 16px', background:'#F9FAFB' }}>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:14 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>Skills</div>
              <div style={{ display:'flex', flexWrap:'wrap', gap:4 }}>
                {cv.skills.map(s => (
                  <div key={s} style={{ fontSize:7.5, padding:'3px 9px', borderRadius:20, background:`${c}15`, color:c, border:`1px solid ${c}25`, fontWeight:600 }}>{s}</div>
                ))}
              </div>
            </div>
          )}
          {opts.showRefs && cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color:c, marginBottom:8 }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8, padding:'7px 9px', background:'white', borderRadius:8, border:'1px solid #E5E7EB' }}>
                  <div style={{ fontWeight:700, color:'#111', fontSize:8.5 }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7 }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

const TEMPLATES = [
  { id:'nova',   name:'Nova',   desc:'Dark sidebar · Skill bars · Pro' },
  { id:'pulse',  name:'Pulse',  desc:'Bold banner · Photo · Modern' },
  { id:'slate',  name:'Slate',  desc:'Full header · Two column · Corporate' },
  { id:'serif',  name:'Serif',  desc:'Elegant · Decorative · Premium' },
  { id:'impact', name:'Impact', desc:'Accent strip · Skills bars · Clean' },
  { id:'script', name:'Script', desc:'Timeline body · Badge skills' },
]

const COLORS = ['#1A1A0F','#1565C0','#0D47A1','#1B5E20','#4A148C','#B71C1C','#E65100','#004D40','#37474F','#880E4F','#F57F17','#1A237E']

function Preview({ cv, opts }:{ cv:CV; opts:Opts }) {
  const props = { cv, opts }
  switch(opts.template) {
    case 'pulse':  return <TemplatePulse  {...props}/>
    case 'slate':  return <TemplateSlate  {...props}/>
    case 'serif':  return <TemplateSerif  {...props}/>
    case 'impact': return <TemplateImpact {...props}/>
    case 'script': return <TemplateScript {...props}/>
    default:       return <TemplateNova   {...props}/>
  }
}

// ── Mini template thumbnails
function TemplateMini({ id, color }:{ id:string; color:string }) {
  const c = color
  return (
    <div style={{ width:'100%', height:'100%', overflow:'hidden', background:'white', fontFamily:'sans-serif' }}>
      {id==='nova'&&<div style={{display:'flex',height:'100%'}}>
        <div style={{width:'37%',background:c,padding:'6px 4px'}}>
          <div style={{width:14,height:14,borderRadius:'50%',background:'rgba(255,255,255,0.25)',margin:'0 auto 4px'}}/>
          <div style={{height:2,background:'rgba(255,255,255,0.5)',margin:'0 4px 3px',borderRadius:1}}/>
          {[80,60,70,50,65].map((w,i)=><div key={i} style={{height:2,background:'rgba(255,255,255,0.25)',marginBottom:2.5,borderRadius:1,width:w+'%'}}/>)}
        </div>
        <div style={{flex:1,padding:'6px 5px'}}>
          <div style={{height:2.5,background:'#111',width:'65%',marginBottom:2,borderRadius:1}}/>
          <div style={{height:1.5,background:c,width:'45%',marginBottom:5,borderRadius:1}}/>
          {[90,70,80,60,75,55].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}
        </div>
      </div>}
      {id==='pulse'&&<div>
        <div style={{background:c,padding:'7px 8px',display:'flex',alignItems:'center',gap:5}}>
          <div style={{width:16,height:16,borderRadius:'50%',background:'rgba(255,255,255,0.25)',flexShrink:0}}/>
          <div><div style={{height:2.5,background:'rgba(255,255,255,0.8)',width:40,borderRadius:1,marginBottom:2}}/><div style={{height:1.5,background:'rgba(255,255,255,0.4)',width:55,borderRadius:1}}/></div>
        </div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 35%',padding:'4px 6px',gap:5}}>
          <div>{[80,60,90,55,75].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2.5,borderRadius:1,width:w+'%'}}/>)}</div>
          <div style={{background:'#f5f5f5',padding:'2px 3px'}}>{[70,50,80].map((w,i)=><div key={i} style={{height:7,background:`${c}20`,marginBottom:2,borderRadius:3,width:w+'%'}}/>)}</div>
        </div>
      </div>}
      {id==='slate'&&<div>
        <div style={{background:c,padding:'6px 8px',display:'flex',justifyContent:'space-between',alignItems:'flex-end'}}>
          <div style={{height:3,background:'rgba(255,255,255,0.8)',width:40,borderRadius:1}}/>
          <div style={{textAlign:'right'}}>{[0,1,2].map(i=><div key={i} style={{height:1.5,background:'rgba(255,255,255,0.4)',width:35,marginBottom:1.5,borderRadius:1}}/>)}</div>
        </div>
        <div style={{height:2,background:`linear-gradient(90deg,${c},${c}50)`}}/>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',padding:'4px 6px',gap:5}}>
          {[0,1].map(col=><div key={col}>{[80,60,70,55,85].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>)}
        </div>
      </div>}
      {id==='serif'&&<div style={{padding:'6px 8px',fontFamily:'Georgia,serif'}}>
        <div style={{display:'flex',alignItems:'center',gap:5,marginBottom:4}}><div style={{flex:1,height:1.5,background:c}}/><div style={{width:4,height:4,transform:'rotate(45deg)',background:c}}/><div style={{flex:1,height:1.5,background:c}}/></div>
        <div style={{height:3,background:'#333',width:'55%',margin:'0 auto 2px',borderRadius:1}}/>
        <div style={{height:1.5,background:'#ccc',width:'40%',margin:'0 auto 5px',borderRadius:1}}/>
        <div style={{display:'grid',gridTemplateColumns:'1fr 38%',gap:5}}>
          <div>{[85,65,75,55,80].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
          <div>{[70,50,65,45].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
        </div>
      </div>}
      {id==='impact'&&<div style={{display:'flex',height:'100%'}}>
        <div style={{width:5,background:c,flexShrink:0}}/>
        <div style={{flex:1,padding:'4px 5px'}}>
          <div style={{height:3,background:'#111',width:'60%',marginBottom:1.5,borderRadius:1}}/>
          <div style={{height:1.5,background:c,width:'40%',marginBottom:1.5,borderRadius:1}}/>
          <div style={{height:1,background:c,width:'100%',marginBottom:4}}/>
          <div style={{display:'grid',gridTemplateColumns:'1fr 35%',gap:4}}>
            <div>{[85,65,75,55,80].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
            <div style={{background:'#f5f5f5',padding:'2px 3px'}}>{[70,50,65].map((w,i)=><div key={i} style={{height:2.5,background:`${c}25`,marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
          </div>
        </div>
      </div>}
      {id==='script'&&<div>
        <div style={{background:c,padding:'7px 8px',display:'flex',justifyContent:'space-between',alignItems:'flex-end'}}>
          <div style={{height:4,background:'rgba(255,255,255,0.8)',width:50,borderRadius:1}}/>
          <div style={{width:14,height:14,borderRadius:'50%',background:'rgba(255,255,255,0.25)'}}/>
        </div>
        <div style={{height:2,background:`linear-gradient(90deg,${c},transparent)`}}/>
        <div style={{display:'grid',gridTemplateColumns:'1fr 35%',padding:'4px 6px',gap:4}}>
          <div>{[80,60,70,55,75,50].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
          <div style={{background:'#f5f5f5',padding:'2px 3px'}}>{[90,70,85,60].map((w,i)=><div key={i} style={{height:5,background:`${c}20`,marginBottom:1.5,borderRadius:8,width:w+'%'}}/>)}</div>
        </div>
      </div>}
    </div>
  )
}

// ── Toggle switch component
function Toggle({ on, onChange, label }:{ on:boolean; onChange:(v:boolean)=>void; label:string }) {
  return (
    <label className="flex items-center justify-between py-2 border-b border-black/5 last:border-0 cursor-pointer">
      <span className="text-sm text-[#1A1A0F]">{label}</span>
      <div onClick={()=>onChange(!on)} className={clsx('w-9 h-5 rounded-full transition-colors relative',on?'bg-[#F5A623]':'bg-black/15')}>
        <div className={clsx('absolute top-0.5 w-4 h-4 rounded-full bg-white shadow-sm transition-all',on?'left-4':'left-0.5')}/>
      </div>
    </label>
  )
}

// ── Field helper
function F({ label, children }:{ label:string; children:React.ReactNode }) {
  return <div><label className={lbl}>{label}</label>{children}</div>
}

// ══════════════════════════════
// MAIN PAGE
// ══════════════════════════════
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
  const fileRef = useRef<HTMLInputElement>(null)

  useEffect(() => { if (!user) navigate('/register') }, [user])
  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      setCv({
        pi:    { ...(d.personal_info || EMPTY.pi), photo: d.personal_info?.photo || '' },
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

  const previewCv:CV = { ...cv, pi:{ ...cv.pi, phone:opts.showPhone?cv.pi.phone:'', location:opts.showLoc?cv.pi.location:'', linkedin:opts.showLinkedin?cv.pi.linkedin:'', photo:opts.showPhoto?cv.pi.photo:'' }, refs:opts.showRefs?cv.refs:[] }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">

      {/* Header */}
      <div className="bg-[#1A1A0F] px-4 md:px-10 py-5 md:py-7">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-between gap-3 mb-3">
            <div>
              <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-0.5">CV Builder</p>
              <h1 className="font-display text-xl md:text-2xl font-bold text-white tracking-tight">Design your <em className="not-italic text-[#F5A623]">perfect CV.</em></h1>
            </div>
            <button onClick={()=>setShowPreview(true)} className="xl:hidden flex items-center gap-2 bg-white/10 border border-white/15 text-white text-sm font-medium px-4 py-2 rounded-xl transition-colors hover:bg-white/20">
              <Eye size={14}/> Preview
            </button>
          </div>
          <div className="flex items-center gap-3 mb-3">
            <div className="flex-1 h-1.5 bg-white/10 rounded-full overflow-hidden">
              <div className="h-full rounded-full transition-all duration-700 bg-[#F5A623]" style={{ width:pct()+'%' }}/>
            </div>
            <span className="text-white/40 text-xs whitespace-nowrap">{pct()}%</span>
          </div>
          <div className="flex gap-1.5 overflow-x-auto pb-1">
            {STEPS.map((s,i)=>(
              <button key={s} onClick={()=>setStep(i)}
                className={clsx('flex items-center gap-1.5 text-[11px] font-semibold px-3 py-1.5 rounded-full whitespace-nowrap transition-all flex-shrink-0 border',
                  i===step?'bg-[#F5A623] text-[#1A1A0F] border-transparent':i<step?'bg-[#2A5C3F] text-white border-transparent':'bg-white/5 text-white/40 border-white/10 hover:bg-white/12')}>
                {i<step?<Check size={10}/>:<span>{i+1}</span>}{s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Body */}
      <div className="max-w-7xl mx-auto px-3 md:px-6 py-5 flex gap-5">

        {/* Form */}
        <div className="flex-1 min-w-0">
          <div className="bg-white rounded-2xl border border-black/6 shadow-sm overflow-hidden">
            <div className="p-5 md:p-7">

              {/* Step 0 — Template */}
              {step===0&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Choose your template</h2>
                  <p className="text-black/40 text-sm mb-6">6 professional designs — pick the one that suits your style.</p>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mb-7">
                    {TEMPLATES.map(t=>(
                      <button key={t.id} onClick={()=>setOpt('template',t.id)}
                        className={clsx('border-2 rounded-2xl p-2.5 text-left transition-all relative overflow-hidden',
                          opts.template===t.id?'border-[#F5A623] shadow-[0_0_0_3px_rgba(245,166,35,0.15)]':'border-black/8 hover:border-[#F5A623]/40')}>
                        <div className="w-full aspect-[3/4] rounded-xl mb-2 overflow-hidden bg-gray-50 border border-black/5">
                          <TemplateMini id={t.id} color={opts.color}/>
                        </div>
                        <div className="font-bold text-[12px] text-[#1A1A0F]">{t.name}</div>
                        <div className="text-[10px] text-black/35 mt-0.5 leading-tight">{t.desc}</div>
                        {opts.template===t.id&&<div className="absolute top-2 right-2 w-5 h-5 rounded-full bg-[#F5A623] flex items-center justify-center shadow"><Check size={10} className="text-[#1A1A0F]"/></div>}
                      </button>
                    ))}
                  </div>
                  <h3 className="font-bold text-sm text-[#1A1A0F] mb-3">Accent colour</h3>
                  <div className="flex gap-2.5 flex-wrap">
                    {COLORS.map(c=>(
                      <button key={c} onClick={()=>setOpt('color',c)}
                        className={clsx('w-8 h-8 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F] shadow-md':'border-transparent hover:scale-105')}
                        style={{background:c}}/>
                    ))}
                  </div>
                </div>
              )}

              {/* Step 1 — Personal */}
              {step===1&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Personal info</h2>
                  <p className="text-black/40 text-sm mb-6">Your contact details — toggle what appears on the CV.</p>

                  {/* Photo upload */}
                  <div className="flex items-center gap-4 mb-6 p-4 bg-[#F7F3EB] rounded-2xl">
                    <div className="relative flex-shrink-0">
                      <div className="w-16 h-16 rounded-full bg-white border-2 border-dashed border-[#F5A623]/40 flex items-center justify-center overflow-hidden cursor-pointer hover:border-[#F5A623] transition-colors" onClick={()=>fileRef.current?.click()}>
                        {cv.pi.photo ? <img src={cv.pi.photo} alt="" className="w-full h-full object-cover"/> : <Camera size={20} className="text-[#F5A623]/60"/>}
                      </div>
                      <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handlePhoto}/>
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-[#1A1A0F] mb-0.5">Profile photo</div>
                      <div className="text-xs text-black/40 mb-2">Optional — supported by most templates</div>
                      <div className="flex gap-2">
                        <button onClick={()=>fileRef.current?.click()} className="text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">Upload photo</button>
                        {cv.pi.photo && <><span className="text-black/20">·</span><button onClick={()=>setCv(c=>({...c,pi:{...c.pi,photo:''}}))} className="text-xs font-semibold text-red-400 hover:text-red-500">Remove</button></>}
                      </div>
                    </div>
                    <div className="ml-auto">
                      <Toggle on={opts.showPhoto} onChange={v=>setOpt('showPhoto',v)} label=""/>
                    </div>
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
                    <F label="Professional summary"><textarea className={inp+' resize-none'} rows={3} placeholder="A brief intro about yourself and what you're looking for…" value={cv.pi.summary} onChange={e=>setCv(c=>({...c,pi:{...c.pi,summary:e.target.value}}))}/></F>
                  </div>
                </div>
              )}

              {/* Step 2 — Education */}
              {step===2&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Education</h2>
                  <p className="text-black/40 text-sm mb-6">Matric, courses, learnerships — all count.</p>
                  <div className="space-y-3">
                    {cv.edu.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 relative bg-[#FAFAFA]">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,edu:c.edu.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>}
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

              {/* Step 3 — Skills */}
              {step===3&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Skills</h2>
                  <p className="text-black/40 text-sm mb-5">Tap to select — add your own too.</p>
                  <div className="flex flex-wrap gap-2 mb-5">
                    {SKILLS.map(s=>(
                      <button key={s} onClick={()=>setCv(c=>({...c,skills:c.skills.includes(s)?c.skills.filter(x=>x!==s):[...c.skills,s]}))}
                        className={clsx('text-sm px-4 py-2 rounded-full border-2 transition-all font-medium select-none',
                          cv.skills.includes(s)?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/50 hover:border-black/12')}
                        style={cv.skills.includes(s)?{background:opts.color,borderColor:opts.color}:{}}>
                        {cv.skills.includes(s)&&<Check size={11} className="inline mr-1 -mt-0.5"/>}{s}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <input className={inp} placeholder="Add your own skill…" value={custom} onChange={e=>setCustom(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}}/>
                    <button onClick={()=>{if(custom.trim()){setCv(c=>({...c,skills:[...c.skills,custom.trim()]}));setCustom('')}}} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-semibold hover:opacity-85 transition-opacity whitespace-nowrap">+ Add</button>
                  </div>
                </div>
              )}

              {/* Step 4 — Experience */}
              {step===4&&(
                <div>
                  <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-1">Experience</h2>
                  <div className="bg-[#F5A623]/10 border border-[#F5A623]/20 rounded-2xl px-4 py-3 mb-5 mt-2">
                    <p className="text-sm font-semibold text-[#1A1A0F] mb-0.5">💡 No work experience? That's fine.</p>
                    <p className="text-sm text-black/45">Family business, school projects, church work — tick "volunteer" and we'll label it correctly.</p>
                  </div>
                  <div className="space-y-3">
                    {cv.exp.map((e,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 relative bg-[#FAFAFA]">
                        <button onClick={()=>setCv(c=>({...c,exp:c.exp.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>
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

              {/* Step 5 — References */}
              {step===5&&(
                <div>
                  <div className="flex items-center justify-between mb-0.5">
                    <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F]">References</h2>
                    <label className="flex items-center gap-2 cursor-pointer"><input type="checkbox" checked={opts.showRefs} onChange={e=>setOpt('showRefs',e.target.checked)} className="accent-[#F5A623] w-4 h-4"/><span className="text-sm text-black/40">Show on CV</span></label>
                  </div>
                  <p className="text-black/40 text-sm mb-5">A teacher, community leader, or neighbour works fine.</p>
                  <div className="space-y-3">
                    {cv.refs.map((r,i)=>(
                      <div key={i} className="border border-black/8 rounded-2xl p-4 relative bg-[#FAFAFA]">
                        {i>0&&<button onClick={()=>setCv(c=>({...c,refs:c.refs.filter((_,j)=>j!==i)}))} className="absolute top-3 right-3 w-7 h-7 rounded-full bg-red-50 text-red-400 hover:bg-red-100 flex items-center justify-center"><X size={13}/></button>}
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
                    <div className="mt-8 rounded-2xl p-5" style={{background:`${opts.color}10`,border:`2px solid ${opts.color}30`}}>
                      <div className="text-2xl mb-1">🎉</div>
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

            {/* Footer nav */}
            <div className="px-5 md:px-7 py-4 bg-[#FAFAFA] border-t border-black/6 flex items-center justify-between">
              <button onClick={()=>step>0&&setStep(step-1)} disabled={step===0} className={clsx('flex items-center gap-1.5 text-sm font-semibold',step===0?'text-black/15 cursor-not-allowed':'text-black/40 hover:text-[#1A1A0F]')}>
                <ChevronLeft size={15}/> Back
              </button>
              <div className="flex items-center gap-3">
                <button onClick={save} disabled={saving} className="flex items-center gap-1.5 text-sm font-medium text-black/40 hover:text-[#1A1A0F]">
                  {saving?<Loader2 size={13} className="animate-spin"/>:saved?<Check size={13} className="text-green-500"/>:null}
                  {saved?'Saved!':'Save'}
                </button>
                {step<5
                  ?<button onClick={async()=>{await save();setStep(step+1)}} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm">Continue <ChevronRight size={13}/></button>
                  :<button onClick={save} className="btn-amber flex items-center gap-1.5 !py-2 !px-5 text-sm">{saving?<Loader2 size={13} className="animate-spin"/>:<Check size={13}/>}Finish</button>
                }
              </div>
            </div>
          </div>
        </div>

        {/* Desktop right panel */}
        <div className="hidden xl:flex flex-col gap-3 w-[400px] flex-shrink-0 sticky top-20 h-fit">
          {/* Options */}
          <div className="bg-white rounded-2xl border border-black/8 p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-3"><Settings size={13} className="text-black/30"/><span className="text-[11px] font-semibold tracking-wider uppercase text-black/35">Customise</span></div>
            <div className="mb-3">
              <Toggle on={opts.showPhoto}   onChange={v=>setOpt('showPhoto',v)}   label="Show profile photo"/>
              <Toggle on={opts.showPhone}   onChange={v=>setOpt('showPhone',v)}   label="Show phone number"/>
              <Toggle on={opts.showLoc}     onChange={v=>setOpt('showLoc',v)}     label="Show location"/>
              <Toggle on={opts.showLinkedin} onChange={v=>setOpt('showLinkedin',v)} label="Show LinkedIn"/>
              <Toggle on={opts.showRefs}    onChange={v=>setOpt('showRefs',v)}    label="Show references"/>
            </div>
            <div className="text-[10px] font-semibold tracking-wider uppercase text-black/35 mb-2">Colour</div>
            <div className="flex gap-2 flex-wrap">
              {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-7 h-7 rounded-full transition-all border-2',opts.color===c?'scale-110 border-[#1A1A0F] shadow':`border-transparent hover:scale-105`)} style={{background:c}}/>)}
            </div>
          </div>

          {/* Preview */}
          <div className="bg-white rounded-2xl border border-black/8 overflow-hidden shadow-sm">
            <div className="px-4 py-2.5 bg-[#F7F3EB] border-b border-black/6 flex justify-between items-center">
              <span className="text-[10px] font-semibold tracking-wider uppercase text-black/35">Live preview</span>
              <span className="text-[10px] text-black/25">{TEMPLATES.find(t=>t.id===opts.template)?.name} · {pct()}%</span>
            </div>
            <div className="overflow-y-auto max-h-[74vh] bg-gray-100 p-2">
              <div style={{ transform:'scale(0.52)', transformOrigin:'top left', width:'192%' }}>
                <Preview cv={previewCv} opts={opts}/>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile preview sheet */}
      {showPreview&&(
        <div className="fixed inset-0 z-50 xl:hidden" onClick={()=>setShowPreview(false)}>
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"/>
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl overflow-hidden" style={{maxHeight:'88vh'}} onClick={e=>e.stopPropagation()}>
            <div className="px-5 py-4 border-b border-black/8 flex items-center justify-between bg-[#F7F3EB]">
              <div><div className="text-sm font-bold text-[#1A1A0F]">CV Preview</div><div className="text-xs text-black/40">{TEMPLATES.find(t=>t.id===opts.template)?.name} · {pct()}%</div></div>
              <button onClick={()=>setShowPreview(false)} className="w-8 h-8 rounded-full bg-black/8 flex items-center justify-center"><X size={16}/></button>
            </div>
            {/* Template + colour strip */}
            <div className="px-4 py-2.5 border-b border-black/6 flex items-center gap-2 overflow-x-auto">
              {TEMPLATES.map(t=>(
                <button key={t.id} onClick={()=>setOpt('template',t.id)} className={clsx('text-xs font-semibold px-3 py-1.5 rounded-full whitespace-nowrap border',opts.template===t.id?'text-white border-transparent':'bg-[#F7F3EB] border-transparent text-black/40')} style={opts.template===t.id?{background:opts.color}:{}}>{t.name}</button>
              ))}
              <div className="w-px h-4 bg-black/10 flex-shrink-0"/>
              {COLORS.map(c=><button key={c} onClick={()=>setOpt('color',c)} className={clsx('w-6 h-6 rounded-full flex-shrink-0 border-2',opts.color===c?'border-[#1A1A0F] scale-110':'border-transparent')} style={{background:c}}/>)}
            </div>
            <div className="overflow-y-auto p-3 bg-gray-100" style={{maxHeight:'65vh'}}>
              <div style={{transform:'scale(0.49)',transformOrigin:'top left',width:'204%'}}>
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

echo "✅ Canva-style CV Builder complete!"
npm run dev
