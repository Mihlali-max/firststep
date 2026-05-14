#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🎨 Building Canva-style CV builder..."

cat > src/components/pages/CVBuilder.tsx << 'EOF'
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Check, ChevronRight, ChevronLeft, Download, Plus, Trash2, Loader2, Eye, Settings, Palette } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface PI { name:string; title:string; email:string; phone:string; location:string; summary:string; linkedin:string }
interface Edu { school:string; qualification:string; year:string }
interface Exp { title:string; org:string; start:string; end:string; desc:string; volunteer:boolean }
interface Ref { name:string; relation:string; contact:string }
interface CV  { pi:PI; edu:Edu[]; skills:string[]; exp:Exp[]; refs:Ref[] }

const EMPTY:CV = {
  pi:{ name:'', title:'', email:'', phone:'', location:'', summary:'', linkedin:'' },
  edu:[{school:'',qualification:'',year:''}],
  skills:[], exp:[], refs:[],
}

const SKILLS = ['Communication','Microsoft Office','Customer service','Teamwork','Time management','Problem solving','Social media','Data entry','Driving (Code 8)','Cash handling','Basic accounting','Attention to detail','Computer literacy','Adaptability','Leadership','Filing & admin','Telephone etiquette','Forklift licence']
const STEPS = ['Template','Personal','Education','Skills','Experience','References']

const inp = "w-full bg-[#F7F3EB] border border-[#1A1A0F]/12 text-[#1A1A0F] placeholder:text-[#7A7260]/40 rounded-xl px-4 py-3 text-sm outline-none focus:border-[#F5A623]/60 transition-colors disabled:opacity-40"
const lbl = "block text-[11px] font-medium tracking-wider uppercase text-[#7A7260] mb-1.5"

// ════════════════════════════════════════════
// CV TEMPLATES — Each is a full styled component
// ════════════════════════════════════════════

// Template 1 — Executive (dark sidebar)
function TemplateExecutive({ cv, color }:{ cv:CV; color:string }) {
  const p = cv.pi
  return (
    <div style={{ display:'flex', width:'100%', minHeight:'297mm', fontFamily:'sans-serif', fontSize:'9px', lineHeight:'1.5' }}>
      {/* Sidebar */}
      <div style={{ width:'34%', background:color, color:'white', padding:'28px 18px', flexShrink:0 }}>
        {/* Avatar placeholder */}
        <div style={{ width:70, height:70, borderRadius:'50%', background:'rgba(255,255,255,0.2)', margin:'0 auto 16px', display:'flex', alignItems:'center', justifyContent:'center', fontSize:24, fontWeight:700, border:'2px solid rgba(255,255,255,0.4)' }}>
          {p.name ? p.name[0].toUpperCase() : 'Y'}
        </div>
        <div style={{ fontSize:13, fontWeight:700, textAlign:'center', marginBottom:2, letterSpacing:'-0.3px' }}>{p.name||'Your Name'}</div>
        {p.title && <div style={{ fontSize:8, textAlign:'center', opacity:0.75, marginBottom:16, letterSpacing:'1px', textTransform:'uppercase' }}>{p.title}</div>}

        <div style={{ borderTop:'1px solid rgba(255,255,255,0.2)', paddingTop:12, marginTop:8, marginBottom:12 }}>
          <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.6, marginBottom:8 }}>Contact</div>
          {p.email    && <div style={{ marginBottom:4, opacity:0.9, wordBreak:'break-all' }}>✉ {p.email}</div>}
          {p.phone    && <div style={{ marginBottom:4, opacity:0.9 }}>📞 {p.phone}</div>}
          {p.location && <div style={{ marginBottom:4, opacity:0.9 }}>📍 {p.location}</div>}
          {p.linkedin && <div style={{ marginBottom:4, opacity:0.9, wordBreak:'break-all' }}>in {p.linkedin}</div>}
        </div>

        {cv.skills.length>0 && (
          <div style={{ borderTop:'1px solid rgba(255,255,255,0.2)', paddingTop:12, marginBottom:12 }}>
            <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.6, marginBottom:8 }}>Skills</div>
            {cv.skills.map(s => (
              <div key={s} style={{ display:'flex', alignItems:'center', gap:6, marginBottom:5 }}>
                <div style={{ flex:1 }}>
                  <div style={{ marginBottom:3 }}>{s}</div>
                  <div style={{ height:3, background:'rgba(255,255,255,0.2)', borderRadius:2 }}>
                    <div style={{ height:3, background:'rgba(255,255,255,0.8)', borderRadius:2, width:'80%' }}/>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {cv.refs.some(r=>r.name) && (
          <div style={{ borderTop:'1px solid rgba(255,255,255,0.2)', paddingTop:12 }}>
            <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', opacity:0.6, marginBottom:8 }}>References</div>
            {cv.refs.filter(r=>r.name).map((r,i) => (
              <div key={i} style={{ marginBottom:8 }}>
                <div style={{ fontWeight:600 }}>{r.name}</div>
                <div style={{ opacity:0.7 }}>{r.relation}</div>
                {r.contact && <div style={{ opacity:0.6, fontSize:8 }}>{r.contact}</div>}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Main */}
      <div style={{ flex:1, padding:'28px 22px' }}>
        {p.summary && (
          <div style={{ marginBottom:18, paddingBottom:14, borderBottom:`2px solid ${color}` }}>
            <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:6 }}>Profile</div>
            <p style={{ color:'#374151', lineHeight:1.7 }}>{p.summary}</p>
          </div>
        )}

        {cv.exp.some(e=>e.title) && (
          <div style={{ marginBottom:16 }}>
            <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8, display:'flex', alignItems:'center', gap:8 }}>
              <span>Experience</span>
              <div style={{ flex:1, height:1, background:`${color}40` }}/>
            </div>
            {cv.exp.filter(e=>e.title).map((e,i) => (
              <div key={i} style={{ marginBottom:10, paddingLeft:10, borderLeft:`2px solid ${color}30` }}>
                <div style={{ display:'flex', justifyContent:'space-between', marginBottom:1 }}>
                  <span style={{ fontWeight:700, color:'#111827', fontSize:10 }}>{e.title}{e.volunteer?' (Volunteer)':''}</span>
                  <span style={{ color:'#9CA3AF', fontSize:8 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
                </div>
                {e.org && <div style={{ color, fontSize:8, marginBottom:2 }}>{e.org}</div>}
                {e.desc && <div style={{ color:'#6B7280' }}>{e.desc}</div>}
              </div>
            ))}
          </div>
        )}

        {cv.edu.some(e=>e.school) && (
          <div>
            <div style={{ fontSize:8, fontWeight:700, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8, display:'flex', alignItems:'center', gap:8 }}>
              <span>Education</span>
              <div style={{ flex:1, height:1, background:`${color}40` }}/>
            </div>
            {cv.edu.filter(e=>e.school).map((e,i) => (
              <div key={i} style={{ marginBottom:8, paddingLeft:10, borderLeft:`2px solid ${color}30` }}>
                <div style={{ display:'flex', justifyContent:'space-between' }}>
                  <span style={{ fontWeight:700, color:'#111827', fontSize:10 }}>{e.qualification}</span>
                  <span style={{ color:'#9CA3AF', fontSize:8 }}>{e.year}</span>
                </div>
                <div style={{ color:'#6B7280' }}>{e.school}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

// Template 2 — Creative (top banner, asymmetric)
function TemplateCreative({ cv, color }:{ cv:CV; color:string }) {
  const p = cv.pi
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'sans-serif', fontSize:'9px', lineHeight:'1.5', background:'#FAFAFA' }}>
      {/* Top banner */}
      <div style={{ background:color, padding:'24px 28px 20px', position:'relative', overflow:'hidden' }}>
        <div style={{ position:'absolute', right:-40, top:-40, width:150, height:150, borderRadius:'50%', background:'rgba(255,255,255,0.08)' }}/>
        <div style={{ position:'absolute', right:40, bottom:-30, width:100, height:100, borderRadius:'50%', background:'rgba(255,255,255,0.06)' }}/>
        <div style={{ position:'relative' }}>
          <div style={{ fontSize:22, fontWeight:900, color:'white', letterSpacing:'-0.5px', marginBottom:2 }}>{p.name||'Your Name'}</div>
          {p.title && <div style={{ fontSize:9, color:'rgba(255,255,255,0.75)', letterSpacing:'2px', textTransform:'uppercase', marginBottom:10 }}>{p.title}</div>}
          <div style={{ display:'flex', flexWrap:'wrap', gap:12, color:'rgba(255,255,255,0.85)', fontSize:8 }}>
            {p.email    && <span>✉ {p.email}</span>}
            {p.phone    && <span>📞 {p.phone}</span>}
            {p.location && <span>📍 {p.location}</span>}
            {p.linkedin && <span>in {p.linkedin}</span>}
          </div>
        </div>
      </div>

      {/* Body grid */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 200px', gap:0 }}>
        {/* Main */}
        <div style={{ padding:'20px 24px', borderRight:'1px solid #E5E7EB' }}>
          {p.summary && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:6 }}>About Me</div>
              <p style={{ color:'#4B5563', lineHeight:1.75 }}>{p.summary}</p>
            </div>
          )}
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8 }}>Work Experience</div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:12, paddingBottom:10, borderBottom:'1px solid #F3F4F6' }}>
                  <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
                    <div>
                      <div style={{ fontWeight:700, fontSize:10, color:'#111827' }}>{e.title}{e.volunteer?' (Volunteer)':''}</div>
                      {e.org && <div style={{ color, fontSize:8, fontWeight:600, marginTop:1 }}>{e.org}</div>}
                    </div>
                    <div style={{ background:`${color}15`, color, fontSize:7.5, padding:'2px 8px', borderRadius:20, whiteSpace:'nowrap', fontWeight:600 }}>
                      {[e.start,e.end].filter(Boolean).join(' – ')}
                    </div>
                  </div>
                  {e.desc && <p style={{ color:'#6B7280', marginTop:4, lineHeight:1.6 }}>{e.desc}</p>}
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8 }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8, display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
                  <div>
                    <div style={{ fontWeight:700, color:'#111827', fontSize:10 }}>{e.qualification}</div>
                    <div style={{ color:'#6B7280' }}>{e.school}</div>
                  </div>
                  {e.year && <div style={{ background:`${color}15`, color, fontSize:7.5, padding:'2px 8px', borderRadius:20, fontWeight:600 }}>{e.year}</div>}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div style={{ padding:'20px 16px', background:'#F9FAFB' }}>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8 }}>Skills</div>
              <div style={{ display:'flex', flexWrap:'wrap', gap:4 }}>
                {cv.skills.map(s => (
                  <div key={s} style={{ background:`${color}18`, color, border:`1px solid ${color}35`, fontSize:7.5, padding:'2px 8px', borderRadius:20, fontWeight:600 }}>{s}</div>
                ))}
              </div>
            </div>
          )}
          {cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:8, fontWeight:800, letterSpacing:'2px', textTransform:'uppercase', color, marginBottom:8 }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8, paddingBottom:6, borderBottom:'1px solid #E5E7EB' }}>
                  <div style={{ fontWeight:700, color:'#111827' }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:8 }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Template 3 — Minimal Pro (clean typography, no sidebars)
function TemplateMinimal({ cv, color }:{ cv:CV; color:string }) {
  const p = cv.pi
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'Georgia, serif', fontSize:'9px', lineHeight:'1.65', padding:'40px 44px', background:'white' }}>
      {/* Header */}
      <div style={{ marginBottom:24, paddingBottom:16, borderBottom:`1px solid #E5E7EB` }}>
        <div style={{ fontSize:26, fontWeight:300, letterSpacing:'0.05em', color:'#111827', marginBottom:4, fontFamily:'sans-serif' }}>{p.name||'Your Name'}</div>
        {p.title && <div style={{ fontSize:10, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', marginBottom:8, fontFamily:'sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex', flexWrap:'wrap', gap:16, color:'#6B7280', fontSize:8, fontFamily:'sans-serif' }}>
          {p.email    && <span>{p.email}</span>}
          {p.phone    && <span>{p.phone}</span>}
          {p.location && <span>{p.location}</span>}
          {p.linkedin && <span>{p.linkedin}</span>}
        </div>
        {p.summary && <p style={{ marginTop:10, color:'#4B5563', lineHeight:1.8, fontStyle:'italic', maxWidth:'85%' }}>{p.summary}</p>}
      </div>

      {/* Sections */}
      {cv.exp.some(e=>e.title) && (
        <div style={{ marginBottom:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:10 }}>
            <div style={{ fontSize:8, fontWeight:600, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', fontFamily:'sans-serif' }}>Experience</div>
            <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
          </div>
          {cv.exp.filter(e=>e.title).map((e,i) => (
            <div key={i} style={{ display:'grid', gridTemplateColumns:'110px 1fr', gap:16, marginBottom:12 }}>
              <div style={{ color:'#9CA3AF', fontSize:8, paddingTop:1, fontFamily:'sans-serif' }}>{[e.start,e.end].filter(Boolean).join('–') || '—'}</div>
              <div>
                <div style={{ fontWeight:700, color:'#111827', fontSize:10, fontFamily:'sans-serif' }}>{e.title}{e.volunteer?' (Volunteer)':''}</div>
                {e.org && <div style={{ color, fontSize:8, fontFamily:'sans-serif', marginBottom:2 }}>{e.org}</div>}
                {e.desc && <p style={{ color:'#6B7280', marginTop:2 }}>{e.desc}</p>}
              </div>
            </div>
          ))}
        </div>
      )}

      {cv.edu.some(e=>e.school) && (
        <div style={{ marginBottom:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:10 }}>
            <div style={{ fontSize:8, fontWeight:600, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', fontFamily:'sans-serif' }}>Education</div>
            <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
          </div>
          {cv.edu.filter(e=>e.school).map((e,i) => (
            <div key={i} style={{ display:'grid', gridTemplateColumns:'110px 1fr', gap:16, marginBottom:8 }}>
              <div style={{ color:'#9CA3AF', fontSize:8, paddingTop:1, fontFamily:'sans-serif' }}>{e.year||'—'}</div>
              <div>
                <div style={{ fontWeight:700, color:'#111827', fontSize:10, fontFamily:'sans-serif' }}>{e.qualification}</div>
                <div style={{ color:'#6B7280', fontFamily:'sans-serif' }}>{e.school}</div>
              </div>
            </div>
          ))}
        </div>
      )}

      {cv.skills.length>0 && (
        <div style={{ marginBottom:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:10 }}>
            <div style={{ fontSize:8, fontWeight:600, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', fontFamily:'sans-serif' }}>Skills</div>
            <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
          </div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:6 }}>
            {cv.skills.map(s => <span key={s} style={{ color:'#4B5563', fontSize:8, fontFamily:'sans-serif' }}>· {s}</span>)}
          </div>
        </div>
      )}

      {cv.refs.some(r=>r.name) && (
        <div>
          <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:10 }}>
            <div style={{ fontSize:8, fontWeight:600, letterSpacing:'3px', textTransform:'uppercase', color:'#9CA3AF', fontFamily:'sans-serif' }}>References</div>
            <div style={{ flex:1, height:1, background:'#E5E7EB' }}/>
          </div>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
            {cv.refs.filter(r=>r.name).map((r,i) => (
              <div key={i}>
                <div style={{ fontWeight:700, color:'#111827', fontFamily:'sans-serif' }}>{r.name}</div>
                <div style={{ color:'#9CA3AF', fontSize:8, fontFamily:'sans-serif' }}>{r.relation}</div>
                {r.contact && <div style={{ color:'#9CA3AF', fontSize:8, fontFamily:'sans-serif' }}>{r.contact}</div>}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

// Template 4 — Corporate (header band, structured grid)
function TemplateCorporate({ cv, color }:{ cv:CV; color:string }) {
  const p = cv.pi
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'sans-serif', fontSize:'9px', lineHeight:'1.5', background:'white' }}>
      {/* Top bar */}
      <div style={{ height:6, background:`linear-gradient(90deg, ${color}, ${color}99)` }}/>

      {/* Header */}
      <div style={{ padding:'20px 28px 16px', borderBottom:'1px solid #E5E7EB', display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
        <div>
          <div style={{ fontSize:22, fontWeight:800, color:'#111827', letterSpacing:'-0.5px', marginBottom:2 }}>{p.name||'Your Name'}</div>
          {p.title && <div style={{ fontSize:9, color, fontWeight:600, letterSpacing:'1px', textTransform:'uppercase' }}>{p.title}</div>}
        </div>
        <div style={{ textAlign:'right', color:'#6B7280', fontSize:8, lineHeight:1.8 }}>
          {p.email    && <div>{p.email}</div>}
          {p.phone    && <div>{p.phone}</div>}
          {p.location && <div>{p.location}</div>}
          {p.linkedin && <div>{p.linkedin}</div>}
        </div>
      </div>

      {p.summary && (
        <div style={{ padding:'12px 28px', background:`${color}08`, borderBottom:'1px solid #E5E7EB' }}>
          <p style={{ color:'#374151', lineHeight:1.75 }}>{p.summary}</p>
        </div>
      )}

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:0, padding:'16px 28px' }}>
        <div style={{ paddingRight:20, borderRight:'1px solid #F3F4F6' }}>
          {cv.exp.some(e=>e.title) && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:9, fontWeight:800, color, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${color}` }}>Experience</div>
              {cv.exp.filter(e=>e.title).map((e,i) => (
                <div key={i} style={{ marginBottom:10 }}>
                  <div style={{ fontWeight:700, color:'#111827', fontSize:10 }}>{e.title}{e.volunteer?' (Vol.)':''}</div>
                  <div style={{ display:'flex', justifyContent:'space-between', marginTop:1 }}>
                    {e.org && <span style={{ color, fontSize:8, fontWeight:600 }}>{e.org}</span>}
                    <span style={{ color:'#9CA3AF', fontSize:7.5 }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
                  </div>
                  {e.desc && <p style={{ color:'#6B7280', marginTop:3, lineHeight:1.6 }}>{e.desc}</p>}
                </div>
              ))}
            </div>
          )}
          {cv.edu.some(e=>e.school) && (
            <div>
              <div style={{ fontSize:9, fontWeight:800, color, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${color}` }}>Education</div>
              {cv.edu.filter(e=>e.school).map((e,i) => (
                <div key={i} style={{ marginBottom:8 }}>
                  <div style={{ fontWeight:700, color:'#111827', fontSize:10 }}>{e.qualification}</div>
                  <div style={{ display:'flex', justifyContent:'space-between' }}>
                    <span style={{ color:'#6B7280' }}>{e.school}</span>
                    <span style={{ color:'#9CA3AF', fontSize:7.5 }}>{e.year}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div style={{ paddingLeft:20 }}>
          {cv.skills.length>0 && (
            <div style={{ marginBottom:16 }}>
              <div style={{ fontSize:9, fontWeight:800, color, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${color}` }}>Skills</div>
              <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:'4px 8px' }}>
                {cv.skills.map(s => (
                  <div key={s} style={{ display:'flex', alignItems:'center', gap:6 }}>
                    <div style={{ width:5, height:5, borderRadius:'50%', background:color, flexShrink:0 }}/>
                    <span style={{ color:'#374151' }}>{s}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
          {cv.refs.some(r=>r.name) && (
            <div>
              <div style={{ fontSize:9, fontWeight:800, color, letterSpacing:'1.5px', textTransform:'uppercase', marginBottom:8, paddingBottom:4, borderBottom:`2px solid ${color}` }}>References</div>
              {cv.refs.filter(r=>r.name).map((r,i) => (
                <div key={i} style={{ marginBottom:8, padding:'6px 8px', background:'#F9FAFB', borderRadius:6 }}>
                  <div style={{ fontWeight:700, color:'#111827' }}>{r.name}</div>
                  <div style={{ color:'#9CA3AF', fontSize:8 }}>{r.relation}</div>
                  {r.contact && <div style={{ color:'#9CA3AF', fontSize:7.5 }}>{r.contact}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Template 5 — Elegant (serif, bottom-accent, premium feel)
function TemplateElegant({ cv, color }:{ cv:CV; color:string }) {
  const p = cv.pi
  return (
    <div style={{ width:'100%', minHeight:'297mm', fontFamily:'Georgia, serif', fontSize:'9px', lineHeight:'1.65', background:'white' }}>
      {/* Header */}
      <div style={{ padding:'32px 36px 24px', textAlign:'center', borderBottom:`3px solid ${color}`, position:'relative' }}>
        <div style={{ fontSize:28, fontWeight:400, letterSpacing:'0.12em', color:'#111827', marginBottom:4, fontFamily:'Georgia, serif', textTransform:'uppercase' }}>{p.name||'Your Name'}</div>
        {p.title && <div style={{ fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color:'#9CA3AF', marginBottom:10, fontFamily:'sans-serif' }}>{p.title}</div>}
        <div style={{ display:'flex', justifyContent:'center', flexWrap:'wrap', gap:16, color:'#6B7280', fontSize:8, fontFamily:'sans-serif' }}>
          {p.email    && <span>{p.email}</span>}
          {p.phone    && <span>{p.phone}</span>}
          {p.location && <span>{p.location}</span>}
          {p.linkedin && <span>{p.linkedin}</span>}
        </div>
        {/* decorative corners */}
        <div style={{ position:'absolute', top:12, left:20, width:20, height:20, borderTop:`2px solid ${color}`, borderLeft:`2px solid ${color}` }}/>
        <div style={{ position:'absolute', top:12, right:20, width:20, height:20, borderTop:`2px solid ${color}`, borderRight:`2px solid ${color}` }}/>
      </div>

      <div style={{ padding:'20px 36px' }}>
        {p.summary && (
          <div style={{ marginBottom:18, textAlign:'center' }}>
            <p style={{ color:'#4B5563', fontStyle:'italic', lineHeight:1.8, maxWidth:'80%', margin:'0 auto' }}>{p.summary}</p>
          </div>
        )}

        <div style={{ display:'grid', gridTemplateColumns:'1fr 180px', gap:24 }}>
          <div>
            {cv.exp.some(e=>e.title) && (
              <div style={{ marginBottom:16 }}>
                <div style={{ textAlign:'center', fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color, marginBottom:10, fontFamily:'sans-serif', display:'flex', alignItems:'center', gap:8 }}>
                  <div style={{ flex:1, height:1, background:`${color}30` }}/>
                  <span>Experience</span>
                  <div style={{ flex:1, height:1, background:`${color}30` }}/>
                </div>
                {cv.exp.filter(e=>e.title).map((e,i) => (
                  <div key={i} style={{ marginBottom:10 }}>
                    <div style={{ display:'flex', justifyContent:'space-between' }}>
                      <span style={{ fontWeight:700, color:'#111827', fontFamily:'sans-serif', fontSize:10 }}>{e.title}{e.volunteer?' (Volunteer)':''}</span>
                      <span style={{ color:'#9CA3AF', fontSize:8, fontFamily:'sans-serif' }}>{[e.start,e.end].filter(Boolean).join(' – ')}</span>
                    </div>
                    {e.org && <div style={{ color, fontSize:8, fontFamily:'sans-serif', fontStyle:'italic' }}>{e.org}</div>}
                    {e.desc && <p style={{ color:'#6B7280', marginTop:2 }}>{e.desc}</p>}
                  </div>
                ))}
              </div>
            )}
            {cv.edu.some(e=>e.school) && (
              <div>
                <div style={{ fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color, marginBottom:10, fontFamily:'sans-serif', display:'flex', alignItems:'center', gap:8 }}>
                  <div style={{ flex:1, height:1, background:`${color}30` }}/>
                  <span>Education</span>
                  <div style={{ flex:1, height:1, background:`${color}30` }}/>
                </div>
                {cv.edu.filter(e=>e.school).map((e,i) => (
                  <div key={i} style={{ marginBottom:8 }}>
                    <div style={{ display:'flex', justifyContent:'space-between' }}>
                      <span style={{ fontWeight:700, color:'#111827', fontFamily:'sans-serif', fontSize:10 }}>{e.qualification}</span>
                      <span style={{ color:'#9CA3AF', fontSize:8, fontFamily:'sans-serif' }}>{e.year}</span>
                    </div>
                    <div style={{ color:'#6B7280', fontFamily:'sans-serif' }}>{e.school}</div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div>
            {cv.skills.length>0 && (
              <div style={{ marginBottom:16 }}>
                <div style={{ fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color, marginBottom:8, fontFamily:'sans-serif' }}>Skills</div>
                {cv.skills.map(s => (
                  <div key={s} style={{ marginBottom:4, display:'flex', alignItems:'center', gap:6 }}>
                    <div style={{ width:4, height:4, background:color, flexShrink:0, transform:'rotate(45deg)' }}/>
                    <span style={{ color:'#374151', fontFamily:'sans-serif' }}>{s}</span>
                  </div>
                ))}
              </div>
            )}
            {cv.refs.some(r=>r.name) && (
              <div>
                <div style={{ fontSize:8, letterSpacing:'4px', textTransform:'uppercase', color, marginBottom:8, fontFamily:'sans-serif' }}>References</div>
                {cv.refs.filter(r=>r.name).map((r,i) => (
                  <div key={i} style={{ marginBottom:8 }}>
                    <div style={{ fontWeight:700, color:'#111827', fontFamily:'sans-serif' }}>{r.name}</div>
                    <div style={{ color:'#9CA3AF', fontSize:8, fontFamily:'sans-serif', fontStyle:'italic' }}>{r.relation}</div>
                    {r.contact && <div style={{ color:'#9CA3AF', fontSize:7.5, fontFamily:'sans-serif' }}>{r.contact}</div>}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
      {/* Bottom accent */}
      <div style={{ height:4, background:`linear-gradient(90deg, transparent, ${color}, transparent)`, marginTop:'auto' }}/>
    </div>
  )
}

const TEMPLATES = [
  { id:'executive', name:'Executive',  desc:'Dark sidebar, skill bars',     premium:false },
  { id:'creative',  name:'Creative',   desc:'Banner header, badge skills',  premium:false },
  { id:'minimal',   name:'Minimal Pro',desc:'Clean typography, date grid',  premium:false },
  { id:'corporate', name:'Corporate',  desc:'Two-column, structured grid',  premium:false },
  { id:'elegant',   name:'Elegant',    desc:'Serif, decorative, premium feel', premium:false },
]
const COLORS = ['#1A1A0F','#F5A623','#2A5C3F','#1565C0','#7B1FA2','#C62828','#00838F','#795548','#546E7A','#E91E63']

function Toggle({ value, onChange, label }:{ value:boolean; onChange:(v:boolean)=>void; label:string }) {
  return (
    <label className="flex items-center justify-between cursor-pointer py-2 border-b border-[#1A1A0F]/6 last:border-0">
      <span className="text-sm text-[#1A1A0F]">{label}</span>
      <div onClick={()=>onChange(!value)} className={clsx('w-10 h-5 rounded-full transition-colors relative',value?'bg-[#F5A623]':'bg-[#1A1A0F]/15')}>
        <div className={clsx('absolute top-0.5 w-4 h-4 rounded-full bg-white shadow transition-all',value?'left-5':'left-0.5')}/>
      </div>
    </label>
  )
}

export default function CVBuilder() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [step, setStep]       = useState(0)
  const [cv, setCv]           = useState<CV>(EMPTY)
  const [template, setTemplate] = useState('executive')
  const [color, setColor]     = useState('#1A1A0F')
  const [showPhone, setShowPhone] = useState(true)
  const [showLoc, setShowLoc]   = useState(true)
  const [showLinkedin, setShowLinkedin] = useState(false)
  const [showRefs, setShowRefs] = useState(true)
  const [saving, setSaving]   = useState(false)
  const [saved, setSaved]     = useState(false)
  const [customSkill, setCustomSkill] = useState('')
  const [rightTab, setRightTab] = useState<'preview'|'options'>('preview')

  useEffect(() => { if (!user) navigate('/register') }, [user])
  useEffect(() => {
    api.get('/cv').then(res => {
      const d = res.data
      if (d.personal_info) setCv(c => ({ ...c, pi: d.personal_info }))
      if (d.education?.length) setCv(c => ({ ...c, edu: d.education }))
      if (d.skills?.length)    setCv(c => ({ ...c, skills: d.skills }))
      if (d.experience?.length) setCv(c => ({ ...c, exp: d.experience.map((e:any) => ({ title:e.title||'', org:e.organisation||'', start:e.start_date||'', end:e.end_date||'', desc:e.description||'', volunteer:e.is_volunteer||false })) }))
      if (d.references?.length) setCv(c => ({ ...c, refs: d.references }))
    }).catch(()=>{})
  }, [])

  const completion = () => {
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
        education: cv.edu.filter(e=>e.school),
        skills: cv.skills,
        experience: cv.exp.filter(e=>e.title).map(e=>({ title:e.title, organisation:e.org, start_date:e.start, end_date:e.end, description:e.desc, is_volunteer:e.volunteer })),
        references: cv.refs.filter(r=>r.name),
      })
      setSaved(true); setTimeout(()=>setSaved(false),2000)
    } catch(e){ console.error(e) }
    finally{ setSaving(false) }
  }

  const cvForPreview:CV = {
    ...cv,
    pi: { ...cv.pi, phone: showPhone ? cv.pi.phone : '', location: showLoc ? cv.pi.location : '', linkedin: showLinkedin ? cv.pi.linkedin : '' },
    refs: showRefs ? cv.refs : [],
  }

  const renderPreview = () => {
    if (template==='executive') return <TemplateExecutive cv={cvForPreview} color={color}/>
    if (template==='creative')  return <TemplateCreative  cv={cvForPreview} color={color}/>
    if (template==='minimal')   return <TemplateMinimal   cv={cvForPreview} color={color}/>
    if (template==='corporate') return <TemplateCorporate cv={cvForPreview} color={color}/>
    if (template==='elegant')   return <TemplateElegant   cv={cvForPreview} color={color}/>
    return <TemplateExecutive cv={cvForPreview} color={color}/>
  }

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Header */}
      <div className="bg-[#1A1A0F] px-6 md:px-12 py-7">
        <div className="flex items-end justify-between gap-4 flex-wrap max-w-7xl mx-auto">
          <div>
            <p className="text-[#F5A623] text-[11px] font-medium tracking-[3px] uppercase mb-1">CV Builder</p>
            <h1 className="font-display text-2xl md:text-3xl font-bold text-[#FFFDF7] tracking-tight">Design your <em className="not-italic text-[#F5A623]">perfect CV.</em></h1>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-xs text-[#FFFDF7]/40">{completion()}% complete</span>
            <div className="w-28 h-1.5 bg-[#FFFDF7]/10 rounded-full overflow-hidden">
              <div className="h-full rounded-full transition-all duration-700" style={{ width:completion()+'%', background:'#F5A623' }}/>
            </div>
          </div>
        </div>
        <div className="mt-4 flex gap-1 flex-wrap max-w-7xl mx-auto">
          {STEPS.map((s,i) => (
            <button key={s} onClick={()=>setStep(i)}
              className={clsx('flex items-center gap-1.5 text-[11px] font-medium px-3 py-1.5 rounded-full transition-all',
                i===step?'bg-[#F5A623] text-[#1A1A0F]':i<step?'bg-[#2A5C3F] text-[#FFFDF7]':'bg-[#FFFDF7]/8 text-[#FFFDF7]/45 hover:bg-[#FFFDF7]/15')}>
              {i<step?<Check size={11}/>:<span>{i+1}</span>}{s}
            </button>
          ))}
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 md:px-6 py-6 grid grid-cols-1 xl:grid-cols-[1fr_440px] gap-6">
        {/* ── FORM ── */}
        <div className="bg-[#FFFDF7] rounded-2xl border border-[#1A1A0F]/10 p-6 md:p-8">

          {/* Step 0 — Template picker */}
          {step===0 && (
            <div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-1">Choose your template</h2>
              <p className="text-[#7A7260] text-sm font-light mb-6">Pick a design that suits the job you're going for.</p>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
                {TEMPLATES.map(t => (
                  <button key={t.id} onClick={()=>setTemplate(t.id)}
                    className={clsx('border-2 rounded-2xl p-4 text-left transition-all relative overflow-hidden group',template===t.id?'border-[#F5A623] bg-[#F5A623]/5 shadow-[0_0_0_3px_rgba(245,166,35,0.15)]':'border-[#1A1A0F]/10 hover:border-[#F5A623]/40 hover:shadow-sm')}>
                    {/* Mini template preview */}
                    <div className="w-full h-32 rounded-xl mb-3 overflow-hidden bg-white shadow-sm border border-[#1A1A0F]/5">
                      {t.id==='executive'&&<div style={{display:'flex',height:'100%',fontSize:'5px'}}>
                        <div style={{width:'35%',background:color,padding:'6px 4px'}}>
                          <div style={{width:14,height:14,borderRadius:'50%',background:'rgba(255,255,255,0.3)',margin:'0 auto 4px'}}/>
                          <div style={{height:2,background:'rgba(255,255,255,0.5)',marginBottom:3,borderRadius:1}}/>
                          {[80,60,70,50].map((w,i)=><div key={i} style={{height:1.5,background:'rgba(255,255,255,0.3)',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}
                        </div>
                        <div style={{flex:1,padding:'6px 5px'}}>
                          <div style={{height:2,background:'#111',marginBottom:2,width:'70%',borderRadius:1}}/>
                          <div style={{height:1.5,background:'#ccc',marginBottom:4,width:'50%',borderRadius:1}}/>
                          {[90,70,80,60,75].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}
                        </div>
                      </div>}
                      {t.id==='creative'&&<div style={{fontSize:'5px'}}>
                        <div style={{height:28,background:color,padding:'6px 8px',position:'relative'}}>
                          <div style={{height:3,background:'rgba(255,255,255,0.8)',width:40,borderRadius:1,marginBottom:2}}/>
                          <div style={{height:1.5,background:'rgba(255,255,255,0.5)',width:60,borderRadius:1}}/>
                        </div>
                        <div style={{display:'grid',gridTemplateColumns:'1fr 30%',padding:'4px 6px',gap:6,height:'calc(100% - 28px)'}}>
                          <div>{[80,60,70,90,50].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
                          <div style={{background:'#f9f9f9',padding:'2px 3px'}}>{[60,80,50,70].map((w,i)=><div key={i} style={{height:1.5,background:`${color}30`,marginBottom:2,borderRadius:8,width:w+'%'}}/>)}</div>
                        </div>
                      </div>}
                      {t.id==='minimal'&&<div style={{padding:'8px 10px',fontSize:'5px'}}>
                        <div style={{height:3,background:'#333',width:50,borderRadius:1,marginBottom:2}}/>
                        <div style={{height:1.5,background:'#bbb',width:70,borderRadius:1,marginBottom:6}}/>
                        {[90,70,80,60,85,65].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}
                      </div>}
                      {t.id==='corporate'&&<div style={{fontSize:'5px'}}>
                        <div style={{height:3,background:color,width:'100%'}}/>
                        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',padding:'4px 6px',gap:6}}>
                          <div>{[80,60,70,50,85].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
                          <div>{[60,80,50,70,40].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
                        </div>
                      </div>}
                      {t.id==='elegant'&&<div style={{padding:'8px 10px',textAlign:'center',fontSize:'5px'}}>
                        <div style={{height:2.5,background:'#333',width:50,borderRadius:1,margin:'0 auto 2px'}}/>
                        <div style={{height:1.5,background:'#ccc',width:70,borderRadius:1,margin:'0 auto 4px'}}/>
                        <div style={{height:1,background:color,width:'100%',marginBottom:6}}/>
                        <div style={{display:'grid',gridTemplateColumns:'1fr 35%',gap:4}}>
                          <div>{[90,70,80,60].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
                          <div>{[80,60,70].map((w,i)=><div key={i} style={{height:1.5,background:'#eee',marginBottom:2,borderRadius:1,width:w+'%'}}/>)}</div>
                        </div>
                      </div>}
                    </div>
                    <div className="font-display font-bold text-sm text-[#1A1A0F] mb-0.5">{t.name}</div>
                    <div className="text-xs text-[#7A7260]">{t.desc}</div>
                    {template===t.id && <div className="flex items-center gap-1 text-xs text-[#C47D0A] mt-1.5 font-medium"><Check size={11}/>Selected</div>}
                  </button>
                ))}
              </div>

              <h3 className="font-display font-bold text-[#1A1A0F] mb-3">Accent colour</h3>
              <div className="flex gap-3 flex-wrap mb-2">
                {COLORS.map(c => (
                  <button key={c} onClick={()=>setColor(c)}
                    className={clsx('w-9 h-9 rounded-full transition-all border-2',color===c?'scale-110 border-[#1A1A0F] shadow-md':'border-transparent hover:scale-105')}
                    style={{ background:c }}/>
                ))}
              </div>
            </div>
          )}

          {/* Step 1 — Personal */}
          {step===1 && (
            <div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-1">Personal info</h2>
              <p className="text-[#7A7260] text-sm font-light mb-6">Only include what you're comfortable sharing.</p>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div><label className={lbl}>Full name *</label><input className={inp} placeholder="e.g. Lebo Sithole" value={cv.pi.name} onChange={e=>setCv(c=>({...c,pi:{...c.pi,name:e.target.value}}))} /></div>
                  <div><label className={lbl}>Job title / role you want</label><input className={inp} placeholder="e.g. Retail Assistant, Admin Clerk" value={cv.pi.title} onChange={e=>setCv(c=>({...c,pi:{...c.pi,title:e.target.value}}))} /></div>
                </div>
                <div><label className={lbl}>Email *</label><input className={inp} type="email" placeholder="lebo@gmail.com" value={cv.pi.email} onChange={e=>setCv(c=>({...c,pi:{...c.pi,email:e.target.value}}))} /></div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className={lbl.replace('mb-1.5','')}>Phone</label>
                      <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={showPhone} onChange={e=>setShowPhone(e.target.checked)} className="accent-[#F5A623]"/><span className="text-xs text-[#7A7260]">Show on CV</span></label>
                    </div>
                    <input className={inp} placeholder="071 234 5678" value={cv.pi.phone} onChange={e=>setCv(c=>({...c,pi:{...c.pi,phone:e.target.value}}))} />
                  </div>
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className={lbl.replace('mb-1.5','')}>Location</label>
                      <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={showLoc} onChange={e=>setShowLoc(e.target.checked)} className="accent-[#F5A623]"/><span className="text-xs text-[#7A7260]">Show on CV</span></label>
                    </div>
                    <input className={inp} placeholder="Cape Town, Western Cape" value={cv.pi.location} onChange={e=>setCv(c=>({...c,pi:{...c.pi,location:e.target.value}}))} />
                  </div>
                </div>
                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <label className={lbl.replace('mb-1.5','')}>LinkedIn</label>
                    <label className="flex items-center gap-1.5 cursor-pointer"><input type="checkbox" checked={showLinkedin} onChange={e=>setShowLinkedin(e.target.checked)} className="accent-[#F5A623]"/><span className="text-xs text-[#7A7260]">Show on CV</span></label>
                  </div>
                  <input className={inp} placeholder="linkedin.com/in/yourname" value={cv.pi.linkedin} onChange={e=>setCv(c=>({...c,pi:{...c.pi,linkedin:e.target.value}}))} />
                </div>
                <div><label className={lbl}>Professional summary</label><textarea className={inp+' resize-none'} rows={3} placeholder="A brief intro — who you are, what you're looking for…" value={cv.pi.summary} onChange={e=>setCv(c=>({...c,pi:{...c.pi,summary:e.target.value}}))}/></div>
              </div>
            </div>
          )}

          {/* Step 2 — Education */}
          {step===2 && (
            <div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-1">Education</h2>
              <p className="text-[#7A7260] text-sm font-light mb-6">Matric, courses, learnerships, anything counts.</p>
              <div className="space-y-4">
                {cv.edu.map((e,i)=>(
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    {i>0&&<button onClick={()=>setCv(c=>({...c,edu:c.edu.filter((_,j)=>j!==i)}))} className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500"><Trash2 size={14}/></button>}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div><label className={lbl}>School / institution</label><input className={inp} placeholder="Khayelitsha High School" value={e.school} onChange={ev=>{const ed=[...cv.edu];ed[i].school=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></div>
                      <div><label className={lbl}>Qualification</label><input className={inp} placeholder="Matric Certificate" value={e.qualification} onChange={ev=>{const ed=[...cv.edu];ed[i].qualification=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></div>
                    </div>
                    <div className="mt-3 w-36"><label className={lbl}>Year</label><input className={inp} placeholder="2024" value={e.year} onChange={ev=>{const ed=[...cv.edu];ed[i].year=ev.target.value;setCv(c=>({...c,edu:ed}))}}/></div>
                  </div>
                ))}
                <button onClick={()=>setCv(c=>({...c,edu:[...c.edu,{school:'',qualification:'',year:''}]}))} className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors"><Plus size={15}/>Add qualification</button>
              </div>
            </div>
          )}

          {/* Step 3 — Skills */}
          {step===3 && (
            <div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-1">Skills</h2>
              <p className="text-[#7A7260] text-sm font-light mb-6">Click to select — add your own too.</p>
              <div className="flex flex-wrap gap-2 mb-5">
                {SKILLS.map(s=>(
                  <button key={s} onClick={()=>setCv(c=>({...c,skills:c.skills.includes(s)?c.skills.filter(x=>x!==s):[...c.skills,s]}))}
                    className={clsx('text-sm px-4 py-2 rounded-full border transition-all',cv.skills.includes(s)?'text-white font-medium border-transparent':'bg-[#F7F3EB] border-[#1A1A0F]/10 text-[#7A7260] hover:border-[#1A1A0F]/25')}
                    style={cv.skills.includes(s)?{background:color,borderColor:color}:{}}>
                    {cv.skills.includes(s)&&<Check size={11} className="inline mr-1.5 -mt-0.5"/>}{s}
                  </button>
                ))}
              </div>
              <div className="flex gap-2">
                <input className={inp} placeholder="Add your own…" value={customSkill} onChange={e=>setCustomSkill(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&customSkill.trim()){setCv(c=>({...c,skills:[...c.skills,customSkill.trim()]}));setCustomSkill('')}}}/>
                <button onClick={()=>{if(customSkill.trim()){setCv(c=>({...c,skills:[...c.skills,customSkill.trim()]}));setCustomSkill('')}}} className="bg-[#1A1A0F] text-white px-5 py-3 rounded-xl text-sm font-medium hover:opacity-85 transition-opacity whitespace-nowrap">Add</button>
              </div>
            </div>
          )}

          {/* Step 4 — Experience */}
          {step===4 && (
            <div>
              <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-1">Experience</h2>
              <div className="bg-[#F5A623]/8 border border-[#F5A623]/20 rounded-xl px-5 py-4 mb-5 mt-3">
                <p className="text-sm font-medium text-[#1A1A0F] mb-1">💡 No work experience? That's fine.</p>
                <p className="text-sm font-light text-[#7A7260]">Family business, school projects, community work — tick "volunteer" and we'll label it correctly.</p>
              </div>
              <div className="space-y-4">
                {cv.exp.map((e,i)=>(
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    <button onClick={()=>setCv(c=>({...c,exp:c.exp.filter((_,j)=>j!==i)}))} className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500"><Trash2 size={14}/></button>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3">
                      <div><label className={lbl}>Role / title</label><input className={inp} placeholder="Shop assistant" value={e.title} onChange={ev=>{const ex=[...cv.exp];ex[i].title=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></div>
                      <div><label className={lbl}>Organisation</label><input className={inp} placeholder="Shoprite" value={e.org} onChange={ev=>{const ex=[...cv.exp];ex[i].org=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></div>
                    </div>
                    <div className="grid grid-cols-2 gap-4 mb-3">
                      <div><label className={lbl}>Start</label><input className={inp} placeholder="Jan 2023" value={e.start} onChange={ev=>{const ex=[...cv.exp];ex[i].start=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></div>
                      <div><label className={lbl}>End</label><input className={inp} placeholder="Present" value={e.end} onChange={ev=>{const ex=[...cv.exp];ex[i].end=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></div>
                    </div>
                    <div><label className={lbl}>Description</label><textarea className={inp+' resize-none'} rows={2} value={e.desc} onChange={ev=>{const ex=[...cv.exp];ex[i].desc=ev.target.value;setCv(c=>({...c,exp:ex}))}}/></div>
                    <label className="flex items-center gap-2 mt-3 cursor-pointer"><input type="checkbox" checked={e.volunteer} className="accent-[#F5A623]" onChange={ev=>{const ex=[...cv.exp];ex[i].volunteer=ev.target.checked;setCv(c=>({...c,exp:ex}))}}/><span className="text-sm text-[#7A7260]">Volunteer / informal</span></label>
                  </div>
                ))}
                <button onClick={()=>setCv(c=>({...c,exp:[...c.exp,{title:'',org:'',start:'',end:'',desc:'',volunteer:false}]}))} className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors"><Plus size={15}/>Add experience</button>
              </div>
            </div>
          )}

          {/* Step 5 — References */}
          {step===5 && (
            <div>
              <div className="flex items-center justify-between mb-1">
                <h2 className="font-display text-2xl font-bold text-[#1A1A0F]">References</h2>
                <label className="flex items-center gap-2 cursor-pointer"><input type="checkbox" checked={showRefs} onChange={e=>setShowRefs(e.target.checked)} className="accent-[#F5A623]"/><span className="text-sm text-[#7A7260]">Show on CV</span></label>
              </div>
              <p className="text-[#7A7260] text-sm font-light mb-5">A teacher, community leader, or neighbour works fine.</p>
              <div className="space-y-4">
                {cv.refs.map((r,i)=>(
                  <div key={i} className="border border-[#1A1A0F]/10 rounded-xl p-5 relative">
                    {i>0&&<button onClick={()=>setCv(c=>({...c,refs:c.refs.filter((_,j)=>j!==i)}))} className="absolute top-4 right-4 text-[#7A7260] hover:text-red-500"><Trash2 size={14}/></button>}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3">
                      <div><label className={lbl}>Full name</label><input className={inp} placeholder="Mrs Dlamini" value={r.name} onChange={e=>{const rf=[...cv.refs];rf[i].name=e.target.value;setCv(c=>({...c,refs:rf}))}}/></div>
                      <div><label className={lbl}>Relationship</label><input className={inp} placeholder="Former teacher" value={r.relation} onChange={e=>{const rf=[...cv.refs];rf[i].relation=e.target.value;setCv(c=>({...c,refs:rf}))}}/></div>
                    </div>
                    <div><label className={lbl}>Contact</label><input className={inp} placeholder="072 000 0000" value={r.contact} onChange={e=>{const rf=[...cv.refs];rf[i].contact=e.target.value;setCv(c=>({...c,refs:rf}))}}/></div>
                  </div>
                ))}
                <button onClick={()=>setCv(c=>({...c,refs:[...c.refs,{name:'',relation:'',contact:''}]}))} className="flex items-center gap-2 text-sm font-medium text-[#C47D0A] hover:text-[#F5A623] transition-colors"><Plus size={15}/>Add reference</button>
              </div>
              {completion()>=60 && (
                <div className="mt-8 p-6 rounded-2xl" style={{ background:`${color}12`, border:`1.5px solid ${color}30` }}>
                  <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-2">🎉 Your CV is ready!</h3>
                  <p className="text-sm font-light text-[#7A7260] mb-4">Download your professional CV and start applying today.</p>
                  <a href="/api/cv/download" target="_blank" className="btn-amber inline-flex items-center gap-2"><Download size={15}/>Download CV (PDF)</a>
                </div>
              )}
            </div>
          )}

          {/* Nav */}
          <div className="flex items-center justify-between mt-8 pt-6 border-t border-[#1A1A0F]/8">
            <button onClick={()=>step>0&&setStep(step-1)} disabled={step===0} className={clsx('flex items-center gap-2 text-sm font-medium',step===0?'text-[#1A1A0F]/20 cursor-not-allowed':'text-[#7A7260] hover:text-[#1A1A0F]')}><ChevronLeft size={16}/>Back</button>
            <div className="flex items-center gap-3">
              <button onClick={save} disabled={saving} className="text-sm font-medium text-[#7A7260] hover:text-[#1A1A0F] flex items-center gap-1.5">
                {saving?<Loader2 size={13} className="animate-spin"/>:saved?<Check size={13} className="text-green-500"/>:null}
                {saved?'Saved!':'Save'}
              </button>
              {step<5
                ? <button onClick={async()=>{await save();setStep(step+1)}} className="btn-amber flex items-center gap-2 !py-2.5 !px-5 text-sm">Continue <ChevronRight size={14}/></button>
                : <button onClick={save} className="btn-amber flex items-center gap-2 !py-2.5 !px-5 text-sm">{saving?<Loader2 size={14} className="animate-spin"/>:<Check size={14}/>}Finish</button>
              }
            </div>
          </div>
        </div>

        {/* ── RIGHT PANEL ── */}
        <div className="sticky top-20 h-fit flex flex-col gap-3">
          <div className="flex gap-1">
            <button onClick={()=>setRightTab('preview')} className={clsx('flex items-center gap-1.5 text-xs font-medium px-4 py-2 rounded-lg transition-all',rightTab==='preview'?'bg-[#1A1A0F] text-white':'bg-white border border-[#1A1A0F]/10 text-[#7A7260] hover:text-[#1A1A0F]')}><Eye size={13}/>Preview</button>
            <button onClick={()=>setRightTab('options')} className={clsx('flex items-center gap-1.5 text-xs font-medium px-4 py-2 rounded-lg transition-all',rightTab==='options'?'bg-[#1A1A0F] text-white':'bg-white border border-[#1A1A0F]/10 text-[#7A7260] hover:text-[#1A1A0F]')}><Settings size={13}/>Options</button>
          </div>

          {rightTab==='preview' && (
            <div className="bg-white rounded-2xl border border-[#1A1A0F]/10 overflow-hidden shadow-sm">
              <div className="px-4 py-2.5 bg-[#F7F3EB] border-b border-[#1A1A0F]/8 flex items-center justify-between">
                <span className="text-[11px] font-medium text-[#7A7260] uppercase tracking-wider">Live preview · {TEMPLATES.find(t=>t.id===template)?.name}</span>
                <span className="text-[11px] text-[#7A7260]">{completion()}%</span>
              </div>
              <div className="overflow-y-auto max-h-[78vh] p-1 bg-gray-100">
                <div className="transform origin-top-left" style={{ transform:'scale(0.55)', width:'182%' }}>
                  {renderPreview()}
                </div>
              </div>
            </div>
          )}

          {rightTab==='options' && (
            <div className="bg-white rounded-2xl border border-[#1A1A0F]/10 p-5">
              <h3 className="font-display font-bold text-[#1A1A0F] mb-4">Options</h3>
              <div className="space-y-0.5 mb-5">
                <Toggle value={showPhone}   onChange={setShowPhone}   label="Show phone number"/>
                <Toggle value={showLoc}     onChange={setShowLoc}     label="Show location"/>
                <Toggle value={showLinkedin} onChange={setShowLinkedin} label="Show LinkedIn"/>
                <Toggle value={showRefs}    onChange={setShowRefs}    label="Show references"/>
              </div>
              <p className="text-xs font-medium text-[#7A7260] uppercase tracking-wider mb-2">Colour</p>
              <div className="flex gap-2 flex-wrap mb-4">
                {COLORS.map(c=><button key={c} onClick={()=>setColor(c)} className={clsx('w-8 h-8 rounded-full transition-all border-2',color===c?'scale-110 border-[#1A1A0F]':'border-transparent hover:scale-105')} style={{background:c}}/>)}
              </div>
              <p className="text-xs font-medium text-[#7A7260] uppercase tracking-wider mb-2">Template</p>
              <div className="space-y-1">
                {TEMPLATES.map(t=><button key={t.id} onClick={()=>setTemplate(t.id)} className={clsx('w-full text-left px-3 py-2 rounded-lg text-sm transition-all',template===t.id?'font-medium text-[#C47D0A]':'text-[#7A7260] hover:bg-[#F7F3EB]')}>{template===t.id&&<Check size={11} className="inline mr-1.5 -mt-0.5 text-[#F5A623]"/>}{t.name}</button>)}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
EOF

echo "✅ Canva-style CV Builder done!"
npm run dev
