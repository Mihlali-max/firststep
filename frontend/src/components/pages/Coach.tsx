import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { Send, Bot, User, Loader2, Plus, Trash2, ChevronDown, Sparkles, Mic } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'
import clsx from 'clsx'

interface Message { role: 'user' | 'assistant'; content: string }
interface Session { id: string; preview: string; date: string }

const STARTERS = [
  { icon:'📝', text:'Help me write a cover letter for a retail job' },
  { icon:'🎯', text:'What should I say in a job interview?' },
  { icon:'📄', text:'How do I make my CV stand out with no experience?' },
  { icon:'💡', text:'What learnerships are available for matric holders?' },
  { icon:'🤝', text:'How do I ask someone to be my reference?' },
  { icon:'💰', text:'What is the YES Programme and how do I apply?' },
]

function TypingIndicator() {
  return (
    <div className="flex items-end gap-2.5 mb-4">
      <div className="w-8 h-8 rounded-full bg-[#F5A623] flex items-center justify-center flex-shrink-0">
        <Bot size={16} className="text-[#1A1A0F]"/>
      </div>
      <div className="bg-white border border-black/8 rounded-2xl rounded-bl-sm px-4 py-3 shadow-sm">
        <div className="flex gap-1.5 items-center h-5">
          <div className="w-2 h-2 rounded-full bg-black/25 animate-bounce" style={{animationDelay:'0ms'}}/>
          <div className="w-2 h-2 rounded-full bg-black/25 animate-bounce" style={{animationDelay:'150ms'}}/>
          <div className="w-2 h-2 rounded-full bg-black/25 animate-bounce" style={{animationDelay:'300ms'}}/>
        </div>
      </div>
    </div>
  )
}

function MessageBubble({ msg }:{ msg:Message }) {
  const isUser = msg.role === 'user'
  return (
    <div className={clsx('flex items-end gap-2.5 mb-4', isUser && 'flex-row-reverse')}>
      {/* Avatar */}
      <div className={clsx('w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0',
        isUser ? 'bg-[#1A1A0F]' : 'bg-[#F5A623]')}>
        {isUser ? <User size={15} className="text-white"/> : <Bot size={15} className="text-[#1A1A0F]"/>}
      </div>
      {/* Bubble */}
      <div className={clsx('max-w-[75%] px-4 py-3 rounded-2xl shadow-sm text-sm leading-relaxed',
        isUser
          ? 'bg-[#1A1A0F] text-white rounded-br-sm'
          : 'bg-white border border-black/8 text-[#1A1A0F] rounded-bl-sm'
      )}>
        {msg.content.split('\n').map((line, i) => (
          <span key={i}>
            {line}
            {i < msg.content.split('\n').length - 1 && <br/>}
          </span>
        ))}
      </div>
    </div>
  )
}

export default function Coach() {
  const { user } = useAuthStore()
  const navigate = useNavigate()
  const [messages, setMessages]   = useState<Message[]>([])
  const [input, setInput]         = useState('')
  const [loading, setLoading]     = useState(false)
  const [sessionId, setSessionId] = useState<string|null>(null)
  const [sessions, setSessions]   = useState<Session[]>([])
  const [showSessions, setShowSessions] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef  = useRef<HTMLTextAreaElement>(null)

  useEffect(() => { if (!user) navigate('/register') }, [user])

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  useEffect(() => {
    if (user) {
      api.get('/coach/sessions').then(res => setSessions(res.data || [])).catch(()=>{})
    }
  }, [user])

  const send = async (text?: string) => {
    const msg = (text || input).trim()
    if (!msg || loading) return
    setInput('')
    setMessages(m => [...m, { role:'user', content:msg }])
    setLoading(true)
    try {
      const res = await api.post('/coach/chat', { message: msg, session_id: sessionId })
      setMessages(m => [...m, { role:'assistant', content: res.data.reply }])
      if (!sessionId) setSessionId(res.data.session_id)
    } catch {
      setMessages(m => [...m, { role:'assistant', content:"Sorry, I'm having trouble connecting right now. Please check that your backend is running and your GROQ_API_KEY is set in .env." }])
    } finally { setLoading(false) }
  }

  const newChat = () => {
    setMessages([])
    setSessionId(null)
    setShowSessions(false)
  }

  const loadSession = async (id: string) => {
    setShowSessions(false)
    setSessionId(id)
    setMessages([])
    setLoading(true)
    try {
      // Load session history from backend
      const res = await api.post('/coach/chat', { message: '...resume', session_id: id })
      setMessages(m => [...m])
    } catch {}
    setLoading(false)
  }

  const handleKey = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send() }
  }

  const isEmpty = messages.length === 0

  return (
    <div className="flex h-[calc(100vh-68px)] bg-[#F7F3EB] overflow-hidden">

      {/* ── SIDEBAR (desktop) ── */}
      <div className="hidden md:flex flex-col w-64 bg-white border-r border-black/8 flex-shrink-0">
        <div className="p-4 border-b border-black/8">
          <button onClick={newChat} className="w-full flex items-center justify-center gap-2 bg-[#F5A623] text-[#1A1A0F] font-semibold text-sm py-2.5 px-4 rounded-xl hover:bg-[#C47D0A] transition-colors">
            <Plus size={15}/> New chat
          </button>
        </div>
        <div className="flex-1 overflow-y-auto p-3">
          {sessions.length > 0 ? (
            <div>
              <p className="text-[10px] font-semibold tracking-[2px] uppercase text-black/30 px-2 mb-2">Recent chats</p>
              {sessions.map(s => (
                <button key={s.id} onClick={()=>loadSession(s.id)}
                  className={clsx('w-full text-left px-3 py-2.5 rounded-xl text-sm transition-colors mb-1',
                    sessionId===s.id ? 'bg-[#F5A623]/15 text-[#C47D0A]' : 'text-black/55 hover:bg-[#F7F3EB]')}>
                  <div className="truncate font-medium">{s.preview || 'Chat session'}</div>
                  <div className="text-[11px] text-black/30 mt-0.5">{s.date}</div>
                </button>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-black/30">
              <Bot size={28} className="mx-auto mb-2 opacity-30"/>
              <p className="text-xs">No previous chats</p>
            </div>
          )}
        </div>
        {/* Tips */}
        <div className="p-3 border-t border-black/8">
          <div className="bg-[#F7F3EB] rounded-xl p-3">
            <p className="text-[11px] font-semibold text-[#1A1A0F] mb-1">💡 Try asking about</p>
            <ul className="text-[11px] text-black/45 space-y-1">
              <li>• Interview preparation</li>
              <li>• CV writing tips</li>
              <li>• SA learnerships</li>
              <li>• Cover letter help</li>
            </ul>
          </div>
        </div>
      </div>

      {/* ── MAIN CHAT ── */}
      <div className="flex-1 flex flex-col min-w-0">

        {/* Chat header */}
        <div className="bg-white border-b border-black/8 px-4 md:px-6 py-3.5 flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-[#F5A623] flex items-center justify-center">
              <Bot size={18} className="text-[#1A1A0F]"/>
            </div>
            <div>
              <div className="font-semibold text-sm text-[#1A1A0F]">FirstStep AI Coach</div>
              <div className="flex items-center gap-1.5">
                <div className="w-1.5 h-1.5 rounded-full bg-green-400"/>
                <span className="text-[11px] text-black/40">Online · Powered by Groq</span>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            {/* Mobile: new chat + history */}
            <button onClick={newChat} className="md:hidden flex items-center gap-1.5 text-xs font-semibold text-black/50 hover:text-black px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-colors">
              <Plus size={13}/> New
            </button>
            <button onClick={()=>setShowSessions(!showSessions)} className="md:hidden flex items-center gap-1.5 text-xs font-semibold text-black/50 hover:text-black px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-colors">
              History <ChevronDown size={13}/>
            </button>
            <button onClick={newChat} className="hidden md:flex items-center gap-1.5 text-xs font-semibold text-black/40 hover:text-black px-3 py-1.5 rounded-xl hover:bg-[#F7F3EB] transition-colors">
              <Plus size={13}/> New chat
            </button>
          </div>
        </div>

        {/* Mobile sessions dropdown */}
        {showSessions && (
          <div className="md:hidden bg-white border-b border-black/8 p-3 max-h-48 overflow-y-auto">
            {sessions.length > 0 ? sessions.map(s => (
              <button key={s.id} onClick={()=>loadSession(s.id)} className="w-full text-left px-3 py-2.5 rounded-xl text-sm text-black/55 hover:bg-[#F7F3EB] transition-colors">
                <div className="truncate font-medium">{s.preview || 'Chat session'}</div>
              </button>
            )) : <p className="text-xs text-black/30 text-center py-4">No previous chats</p>}
          </div>
        )}

        {/* Messages area */}
        <div className="flex-1 overflow-y-auto px-4 md:px-6 py-5">

          {isEmpty ? (
            /* Empty state */
            <div className="h-full flex flex-col items-center justify-center text-center max-w-lg mx-auto">
              <div className="w-16 h-16 rounded-2xl bg-[#F5A623] flex items-center justify-center mb-4 shadow-[0_4px_20px_rgba(245,166,35,0.3)]">
                <Sparkles size={28} className="text-[#1A1A0F]"/>
              </div>
              <h2 className="font-display text-xl md:text-2xl font-bold text-[#1A1A0F] mb-2">
                Hi {user?.full_name?.split(' ')[0] || 'there'}! 👋
              </h2>
              <p className="text-black/45 text-sm mb-8 leading-relaxed">
                I'm your AI career coach. I know the SA job market — learnerships, YES Programme, interview tips, CV advice — ask me anything.
              </p>
              {/* Starter prompts */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 w-full">
                {STARTERS.map(s => (
                  <button key={s.text} onClick={()=>send(s.text)}
                    className="flex items-center gap-3 bg-white border border-black/8 rounded-2xl px-4 py-3.5 text-left hover:border-[#F5A623]/40 hover:bg-[#F5A623]/5 transition-all group text-sm text-black/60 hover:text-black">
                    <span className="text-lg flex-shrink-0">{s.icon}</span>
                    <span className="leading-snug">{s.text}</span>
                  </button>
                ))}
              </div>
            </div>
          ) : (
            /* Messages */
            <div className="max-w-2xl mx-auto">
              {messages.map((msg, i) => <MessageBubble key={i} msg={msg}/>)}
              {loading && <TypingIndicator/>}
              <div ref={bottomRef}/>
            </div>
          )}
        </div>

        {/* Input area */}
        <div className="bg-white border-t border-black/8 px-4 md:px-6 py-4 flex-shrink-0">
          <div className="max-w-2xl mx-auto">
            <div className="flex items-end gap-3 bg-[#F7F3EB] border border-black/10 rounded-2xl px-4 py-3 focus-within:border-[#F5A623]/50 focus-within:bg-white transition-all">
              <textarea
                ref={inputRef}
                value={input}
                onChange={e=>setInput(e.target.value)}
                onKeyDown={handleKey}
                placeholder="Ask about jobs, interviews, CV tips…"
                rows={1}
                className="flex-1 bg-transparent text-[#1A1A0F] placeholder:text-black/30 text-sm outline-none resize-none max-h-32 leading-relaxed"
                style={{ minHeight:'24px' }}
                onInput={e => {
                  const t = e.target as HTMLTextAreaElement
                  t.style.height = 'auto'
                  t.style.height = Math.min(t.scrollHeight, 128) + 'px'
                }}
              />
              <button onClick={()=>send()} disabled={!input.trim()||loading}
                className={clsx('w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 transition-all',
                  input.trim()&&!loading ? 'bg-[#F5A623] text-[#1A1A0F] hover:bg-[#C47D0A] shadow-sm' : 'bg-black/8 text-black/25 cursor-not-allowed')}>
                {loading ? <Loader2 size={16} className="animate-spin"/> : <Send size={15}/>}
              </button>
            </div>
            <p className="text-[11px] text-black/25 text-center mt-2">Press Enter to send · Shift+Enter for new line</p>
          </div>
        </div>
      </div>
    </div>
  )
}
