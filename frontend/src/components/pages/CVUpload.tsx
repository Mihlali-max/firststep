import { useState, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Upload, FileText, Image, ArrowRight, Loader2, Check, Sparkles, X } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

type Stage = 'idle' | 'uploading' | 'extracting' | 'saving' | 'done' | 'error'

const STEPS = [
  { id:'uploading',  label:'Reading your CV...' },
  { id:'extracting', label:'AI extracting your info...' },
  { id:'saving',     label:'Saving to your profile...' },
  { id:'done',       label:'Done! Ready to redesign.' },
]

export default function CVUpload() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const fileRef = useRef<HTMLInputElement>(null)
  const [file, setFile] = useState<File | null>(null)
  const [preview, setPreview] = useState<string | null>(null)
  const [stage, setStage] = useState<Stage>('idle')
  const [error, setError] = useState('')
  const [extracted, setExtracted] = useState<any>(null)
  const [drag, setDrag] = useState(false)

  const handleFile = (f: File) => {
    if (!f) return
    const allowed = ['application/pdf','image/jpeg','image/png','image/jpg','image/webp']
    if (!allowed.includes(f.type)) {
      setError('Please upload a PDF or image file (JPG, PNG, WebP).')
      return
    }
    if (f.size > 10 * 1024 * 1024) {
      setError('File must be under 10MB.')
      return
    }
    setFile(f)
    setError('')
    setStage('idle')
    // Generate preview for images
    if (f.type.startsWith('image/')) {
      const reader = new FileReader()
      reader.onload = e => setPreview(e.target?.result as string)
      reader.readAsDataURL(f)
    } else {
      setPreview(null)
    }
  }

  const process = async () => {
    if (!file) return
    setError('')
    setStage('uploading')

    try {
      // Convert file to base64
      const base64 = await new Promise<string>((res, rej) => {
        const reader = new FileReader()
        reader.onload = e => res((e.target?.result as string).split(',')[1])
        reader.onerror = rej
        reader.readAsDataURL(file)
      })

      setStage('extracting')

      // Send to backend for AI extraction
      const response = await api.post('/cv/extract', {
        file_data: base64,
        file_type: file.type,
        file_name: file.name,
      })

      const data = response.data
      setExtracted(data)
      setStage('saving')

      // Save extracted data to CV
      await api.patch('/cv', {
        personal_info: data.personal_info,
        education:     data.education,
        skills:        data.skills,
        experience:    data.experience,
        references:    data.references,
      })

      setStage('done')
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Something went wrong. Please try again.')
      setStage('error')
    }
  }

  const currentStepIdx = STEPS.findIndex(s => s.id === stage)
  const isProcessing = ['uploading','extracting','saving'].includes(stage)

  return (
    <div className="min-h-[calc(100vh-68px)] bg-[#F7F3EB]">
      {/* Header */}
      <div className="bg-[#1A1A0F] px-4 md:px-12 py-8">
        <div className="max-w-3xl mx-auto">
          <p className="text-[#F5A623] text-[10px] font-semibold tracking-[3px] uppercase mb-1">Smart Import</p>
          <h1 className="font-display text-2xl md:text-3xl font-bold text-white tracking-tight mb-1">
            Already have a CV? <em className="not-italic text-[#F5A623]">Upgrade it.</em>
          </h1>
          <p className="text-white/45 text-sm font-light">Upload your existing CV and our AI will extract all your info, then you redesign it in minutes.</p>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 md:px-6 py-8">

        {stage === 'done' ? (
          // ── SUCCESS STATE
          <div className="bg-white rounded-3xl border border-black/6 p-8 md:p-12 text-center shadow-sm">
            <div className="w-16 h-16 rounded-full bg-green-50 border-2 border-green-200 flex items-center justify-center mx-auto mb-5">
              <Check size={28} className="text-green-500"/>
            </div>
            <h2 className="font-display text-2xl font-bold text-[#1A1A0F] mb-2">All done! 🎉</h2>
            <p className="text-black/45 text-sm mb-2">We extracted your info from your CV.</p>

            {extracted && (
              <div className="bg-[#F7F3EB] rounded-2xl p-5 text-left mt-6 mb-8 space-y-2 text-sm">
                {extracted.personal_info?.name && <div className="flex gap-2"><span className="text-black/40 w-24 flex-shrink-0">Name</span><span className="font-medium text-[#1A1A0F]">{extracted.personal_info.name}</span></div>}
                {extracted.personal_info?.title && <div className="flex gap-2"><span className="text-black/40 w-24 flex-shrink-0">Title</span><span className="font-medium text-[#1A1A0F]">{extracted.personal_info.title}</span></div>}
                {extracted.skills?.length > 0 && <div className="flex gap-2"><span className="text-black/40 w-24 flex-shrink-0">Skills</span><span className="font-medium text-[#1A1A0F]">{extracted.skills.slice(0,5).join(', ')}{extracted.skills.length > 5 ? ` +${extracted.skills.length-5} more` : ''}</span></div>}
                {extracted.experience?.length > 0 && <div className="flex gap-2"><span className="text-black/40 w-24 flex-shrink-0">Experience</span><span className="font-medium text-[#1A1A0F]">{extracted.experience.length} job{extracted.experience.length > 1 ? 's' : ''} found</span></div>}
                {extracted.education?.length > 0 && <div className="flex gap-2"><span className="text-black/40 w-24 flex-shrink-0">Education</span><span className="font-medium text-[#1A1A0F]">{extracted.education.length} qualification{extracted.education.length > 1 ? 's' : ''} found</span></div>}
              </div>
            )}

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <button onClick={() => navigate('/cv')} className="btn-amber flex items-center justify-center gap-2">
                <Sparkles size={16}/> Open CV Builder <ArrowRight size={15}/>
              </button>
              <button onClick={() => { setStage('idle'); setFile(null); setPreview(null) }} className="btn-outline flex items-center justify-center gap-2 text-sm">
                Upload another CV
              </button>
            </div>
          </div>
        ) : (
          <>
            {/* ── UPLOAD AREA */}
            <div
              className={clsx('relative border-2 border-dashed rounded-3xl transition-all cursor-pointer bg-white',
                drag ? 'border-[#F5A623] bg-[#F5A623]/5 scale-[1.01]' :
                file ? 'border-[#2A5C3F] bg-green-50/30' :
                'border-black/15 hover:border-[#F5A623]/60 hover:bg-[#F7F3EB]/50'
              )}
              onClick={() => !isProcessing && fileRef.current?.click()}
              onDragOver={e => { e.preventDefault(); setDrag(true) }}
              onDragLeave={() => setDrag(false)}
              onDrop={e => { e.preventDefault(); setDrag(false); const f = e.dataTransfer.files[0]; if (f) handleFile(f) }}
            >
              <input ref={fileRef} type="file" accept=".pdf,.jpg,.jpeg,.png,.webp" className="hidden" onChange={e => { const f = e.target.files?.[0]; if (f) handleFile(f) }}/>

              {!file ? (
                <div className="py-16 px-8 text-center">
                  <div className="w-16 h-16 rounded-2xl bg-[#F7F3EB] border border-black/8 flex items-center justify-center mx-auto mb-5">
                    <Upload size={24} className="text-[#F5A623]"/>
                  </div>
                  <h3 className="font-display text-lg font-bold text-[#1A1A0F] mb-2">Drop your CV here</h3>
                  <p className="text-black/40 text-sm mb-4">PDF, JPG, or PNG — up to 10MB</p>
                  <div className="inline-flex items-center gap-2 bg-[#1A1A0F] text-white text-sm font-semibold px-5 py-2.5 rounded-xl hover:opacity-85 transition-opacity">
                    <Upload size={14}/> Browse files
                  </div>
                  <div className="flex items-center justify-center gap-6 mt-8">
                    {[['📄','PDF'], ['🖼️','JPG'], ['🖼️','PNG']].map(([icon, label]) => (
                      <div key={label} className="flex items-center gap-2 text-xs text-black/30 font-medium">
                        <span>{icon}</span>{label}
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="p-6 flex items-center gap-5">
                  {/* File preview */}
                  {preview ? (
                    <img src={preview} alt="CV preview" className="w-24 h-32 object-cover object-top rounded-xl border border-black/10 flex-shrink-0 shadow-sm"/>
                  ) : (
                    <div className="w-24 h-32 bg-[#F7F3EB] rounded-xl border border-black/10 flex items-center justify-center flex-shrink-0">
                      <FileText size={28} className="text-[#F5A623]"/>
                    </div>
                  )}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-3 mb-1">
                      <div className="font-semibold text-[#1A1A0F] text-sm truncate">{file.name}</div>
                      {!isProcessing && (
                        <button onClick={e => { e.stopPropagation(); setFile(null); setPreview(null); setStage('idle') }} className="w-7 h-7 rounded-full bg-black/8 hover:bg-red-50 hover:text-red-400 flex items-center justify-center flex-shrink-0 transition-colors">
                          <X size={14}/>
                        </button>
                      )}
                    </div>
                    <div className="text-xs text-black/40 mb-3">{(file.size / 1024).toFixed(0)} KB · {file.type.includes('pdf') ? 'PDF' : 'Image'}</div>
                    <div className="flex items-center gap-2">
                      <div className="w-2 h-2 rounded-full bg-green-400"/>
                      <span className="text-xs text-green-600 font-medium">Ready to extract</span>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {error && (
              <div className="mt-3 bg-red-50 border border-red-200 rounded-2xl px-4 py-3 text-sm text-red-600 flex items-center gap-2">
                <X size={14} className="flex-shrink-0"/>{error}
              </div>
            )}

            {/* ── HOW IT WORKS */}
            {!file && !isProcessing && (
              <div className="mt-8 grid grid-cols-1 sm:grid-cols-3 gap-4">
                {[
                  { n:'1', title:'Upload your CV', desc:'Drop your existing PDF or take a photo of it', icon:'📤' },
                  { n:'2', title:'AI reads it', desc:'Claude extracts your name, experience, skills, everything', icon:'🤖' },
                  { n:'3', title:'Pick a new look', desc:'Choose a modern template and download in seconds', icon:'✨' },
                ].map(s => (
                  <div key={s.n} className="bg-white rounded-2xl border border-black/6 p-5 text-center shadow-sm">
                    <div className="text-2xl mb-3">{s.icon}</div>
                    <div className="font-bold text-sm text-[#1A1A0F] mb-1">{s.title}</div>
                    <div className="text-xs text-black/40 leading-relaxed">{s.desc}</div>
                  </div>
                ))}
              </div>
            )}

            {/* ── PROGRESS STEPS */}
            {isProcessing && (
              <div className="mt-6 bg-white rounded-2xl border border-black/6 p-6 shadow-sm">
                <div className="space-y-4">
                  {STEPS.slice(0,-1).map((s, i) => {
                    const done  = currentStepIdx > i
                    const active = currentStepIdx === i
                    return (
                      <div key={s.id} className="flex items-center gap-4">
                        <div className={clsx('w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 transition-all',
                          done  ? 'bg-green-500' :
                          active ? 'bg-[#F5A623]' :
                          'bg-black/8')}>
                          {done  ? <Check size={14} className="text-white"/> :
                           active ? <Loader2 size={14} className="text-white animate-spin"/> :
                           <span className="text-xs text-black/30 font-bold">{i+1}</span>}
                        </div>
                        <div className={clsx('text-sm font-medium transition-colors',
                          done ? 'text-green-600' : active ? 'text-[#1A1A0F]' : 'text-black/30')}>
                          {s.label}
                        </div>
                      </div>
                    )
                  })}
                </div>
              </div>
            )}

            {/* ── ACTION BUTTON */}
            {file && !isProcessing && stage !== 'done' && (
              <button onClick={process} className="btn-amber w-full flex items-center justify-center gap-2 mt-5 !py-4 text-base font-bold">
                <Sparkles size={18}/> Extract my info with AI <ArrowRight size={16}/>
              </button>
            )}

            {/* ── OR SKIP */}
            <div className="mt-5 text-center">
              <span className="text-xs text-black/30">— or — </span>
              <button onClick={() => navigate('/cv')} className="text-xs font-semibold text-[#C47D0A] hover:text-[#F5A623] transition-colors">
                Start the CV builder from scratch
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
