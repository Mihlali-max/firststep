import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Send, Bot, User, Loader2, Plus, Sparkles, ChevronDown, X } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface Message { role: 'user' | 'assistant'; content: string }

const STARTERS = [
  { icon:'📝', text:'Write me a cover letter for a retail job' },
  { icon:'🎯', text:'How do I prepare for a job interview?' },
  { icon:'📄', text:'How do I make my CV stand out with no experience?' },
  { icon:'💡', text:'What learnerships can I apply for with matric?' },
  { icon:'🤝', text:'How do I ask someone to be my reference?' },
  { icon:'💰', text:'What is the YES Programme and how do I apply?' },
]

function TypingIndicator() {
  return (
    <div className="flex items-end gap-3 mb-5">
      <div className="w-8 h-8 rounded-full flex-shrink-0 flex items-center justify-center" style={{background:'linear-gradient(135deg,#F5A623,#C47D0A)'}}>
        <Bot size={15} className="text-white"/>
      </div>
      <div className="bg-[#1E1E14] border border-white/8 rounded-2xl rounded-bl-sm px-4 py-3.5">
        <div className="flex gap-1.5 items-center">
          <div className="w-2 h-2 rounded-full bg-[#F5A623]/60 animate-bounce" style={{animationDelay:'0ms'}}/>
          <div className="w-2 h-2 rounded-full bg-[#F5A623]/60 animate-bounce" style={{animationDelay:'160ms'}}/>
          <div className="w-2 h-2 rounded-full bg-[#F5A623]/60 animate-bounce" style={{animationDelay:'320ms'}}/>
        </div>
      </div>
    </div>
  )
}

function MessageBubble({ msg, isNew }:{ msg:Message; isNew?:boolean }) {
  const isUser = msg.role === 'user'
  return (
    <div className={clsx('flex items-end gap-3 mb-5', isUser && 'flex-row-reverse')}>
      <div className={clsx('w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 shadow-sm',
        isUser ? 'bg-white/10 border border-white/15' : '')}
        style={!isUser ? {background:'linear-gradient(135deg,#F5A623,#C47D0A)'} : {}}>
        {isUser
          ? <User size={14} className="text-white/70"/>
          : <Bot size={14} className="text-white"/>}
      </div>
      <div className={clsx('max-w-[85%] md:max-w-[75%] px-4 py-3.5 rounded-2xl text-sm leading-relaxed shadow-sm',
        isUser
          ? 'text-white rounded-br-sm border border-white/10'
          : 'text-white/90 rounded-bl-sm border border-white/8',
        isUser
          ? 'bg-[#F5A623] text-[#1A1A0F]'
          : 'bg-[#1E1E14]'
      )}>
        {msg.content.split('\n').map((line, i, arr) => (
          <span key={i}>{line}{i < arr.length-1 && <br/>}</span>
        ))}
      </div>
    </div>
  )
}

export default function Coach() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [messages, setMessages]     = useState<Message[]>([])
  const [input, setInput]           = useState('')
  const [loading, setLoading]       = useState(false)
  const [sessionId, setSessionId]   = useState<string|null>(null)
  const [showHistory, setShowHistory] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef  = useRef<HTMLTextAreaElement>(null)
  const newMsgIdx = useRef(-1)

  // Guest allowed — no redirect
  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior:'smooth' }) }, [messages, loading])

  const send = async (text?: string) => {
    const msg = (text || input).trim()
    if (!msg || loading) return
    setInput('')
    newMsgIdx.current = messages.length + 1
    setMessages(m => [...m, { role:'user', content:msg }])
    setLoading(true)
    if (inputRef.current) { inputRef.current.style.height = 'auto' }
    try {
      let res
      try {
        res = await api.post('/coach/chat', { message: msg, session_id: sessionId })
      } catch(err: any) {
        if (err?.response?.status === 401) {
          const authMsg = { id: Date.now()+1, role:'assistant' as const, content:'To chat with the AI Coach you need a free account. [Create one here](/register) — it takes 30 seconds.' }
          setMsgs(m => [...m, authMsg]); setLoading(false); return
        }
        throw err
      }
      setMessages(m => [...m, { role:'assistant', content: res.data.reply }])
      if (!sessionId && res.data.session_id) setSessionId(res.data.session_id)
    } catch(err: any) {
      const msg = err?.response?.status === 401
        ? "To chat with the AI Coach you need a free account. [Create one here](/register) — it takes 30 seconds."
        : "Eish, something went wrong on my end. Try again in a moment!"
      setMessages(m => [...m, { role:'assistant', content: msg }])
    } finally { setLoading(false) }
  }

  const handleKey = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send() }
  }

  const newChat = () => { setMessages([]); setSessionId(null) }
  const firstName = user?.full_name?.split(' ')[0] || 'there'

  return (
    <div className="flex flex-col h-[calc(100dvh-68px)] pb-safe" style={{background:'#0F0F0A'}}>

      {/* ── TOP BAR ── */}
      <div className="flex items-center justify-between px-4 md:px-8 py-4 border-b flex-shrink-0" style={{borderColor:'rgba(255,255,255,0.08)',background:'#141410'}}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-lg" style={{background:'linear-gradient(135deg,#F5A623,#C47D0A)'}}>
            <Sparkles size={18} className="text-white"/>
          </div>
          <div>
            <div className="font-display font-bold text-white text-sm">FirstStep AI Coach</div>
            <div className="flex items-center gap-1.5 mt-0.5">
              <div className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse"/>
              <span className="text-[11px] text-white/35">Online · Groq LLaMA 3.3</span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={newChat} className="flex items-center gap-1.5 text-xs font-semibold text-white/40 hover:text-white px-3 py-2 rounded-xl transition-colors hover:bg-white/8">
            <Plus size={13}/> New chat
          </button>
        </div>
      </div>

      {/* ── MESSAGES ── */}
      <div className="flex-1 overflow-y-auto px-4 md:px-8 py-6">
        <div className="max-w-2xl mx-auto">

          {messages.length === 0 ? (
            /* Empty state */
            <div className="flex flex-col items-center justify-center min-h-[60vh] text-center">
              <div className="w-16 h-16 md:w-20 md:h-20 rounded-3xl flex items-center justify-center mb-5 shadow-[0_8px_32px_rgba(245,166,35,0.25)]" style={{background:'linear-gradient(135deg,#F5A623,#C47D0A)'}}>
                <Sparkles size={36} className="text-white"/>
              </div>
              <h2 className="font-display text-2xl md:text-3xl font-bold text-white mb-2">
                Sawubona, {firstName}! 👋
              </h2>
              <p className="text-white/40 text-sm mb-10 max-w-sm leading-relaxed">
                I'm your AI career coach. Ask me about learnerships, CV writing, interview prep, or anything about finding your first job in SA.
              </p>
              {/* Starter prompts */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 w-full max-w-xl">
                {STARTERS.map(s => (
                  <button key={s.text} onClick={()=>send(s.text)}
                    className="flex items-center gap-3 rounded-2xl px-4 py-3.5 text-left transition-all group text-sm border"
                    style={{background:'#1A1A10',borderColor:'rgba(255,255,255,0.08)'}}>
                    <span className="text-xl flex-shrink-0">{s.icon}</span>
                    <span className="text-white/60 group-hover:text-white/90 leading-snug transition-colors">{s.text}</span>
                  </button>
                ))}
              </div>
            </div>
          ) : (
            <>
              {messages.map((msg, i) => <MessageBubble key={i} msg={msg} isNew={i===newMsgIdx.current}/>)}
              {loading && <TypingIndicator/>}
              <div ref={bottomRef}/>
            </>
          )}
        </div>
      </div>

      {/* ── INPUT ── */}
      <div className="flex-shrink-0 px-4 md:px-8 py-4 border-t" style={{borderColor:'rgba(255,255,255,0.08)',background:'#141410'}}>
        <div className="max-w-2xl mx-auto">
          <div className="flex items-end gap-3 rounded-2xl px-4 py-3 border transition-all"
            style={{background:'#1A1A10',borderColor:'rgba(255,255,255,0.1)'}}>
            <textarea
              ref={inputRef}
              value={input}
              onChange={e=>setInput(e.target.value)}
              onKeyDown={handleKey}
              placeholder="Ask me anything about jobs in SA…"
              rows={1}
              className="flex-1 bg-transparent text-white placeholder:text-white/25 text-sm outline-none resize-none max-h-32 leading-relaxed"
              style={{minHeight:'24px'}}
              onInput={e=>{
                const t = e.target as HTMLTextAreaElement
                t.style.height = 'auto'
                t.style.height = Math.min(t.scrollHeight,128)+'px'
              }}
            />
            <button onClick={()=>send()} disabled={!input.trim()||loading}
              className={clsx('w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 transition-all',
                input.trim()&&!loading
                  ? 'shadow-[0_2px_12px_rgba(245,166,35,0.4)]'
                  : 'opacity-30 cursor-not-allowed'
              )}
              style={input.trim()&&!loading?{background:'linear-gradient(135deg,#F5A623,#C47D0A)'}:{background:'rgba(255,255,255,0.1)'}}>
              {loading ? <Loader2 size={15} className="animate-spin text-white"/> : <Send size={14} className="text-white"/>}
            </button>
          </div>
          <p className="text-[11px] text-white/20 text-center mt-2">Enter to send · Shift+Enter for new line</p>
        </div>
      </div>
    </div>
  )
}
