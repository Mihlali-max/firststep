#!/bin/bash
echo "🎤 Building Interview Prep page..."

cat > frontend/src/components/pages/InterviewPrep.tsx << 'EOF'
import { useState, useRef, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useAuthStore } from '../../store/authStore'
import api from '../../lib/api'

const SECTORS = [
  'Retail & Customer Service',
  'Banking & Finance',
  'IT & Technology',
  'Construction & Trades',
  'Healthcare & Social Work',
  'Administration & Office',
  'Logistics & Supply Chain',
  'Hospitality & Tourism',
  'General Worker',
]

const STARTER_QUESTIONS = [
  'Tell me about yourself',
  'Why do you want this job?',
  'What are your strengths?',
  'Where do you see yourself in 5 years?',
  'Why should we hire you?',
]

type Stage = 'select' | 'question' | 'feedback' | 'done'
type Message = { role: 'ai' | 'user'; content: string }

export default function InterviewPrep() {
  const { user } = useAuthStore()
  const [stage, setStage] = useState<Stage>('select')
  const [sector, setSector] = useState('')
  const [qIndex, setQIndex] = useState(0)
  const [questions, setQuestions] = useState<string[]>([])
  const [answer, setAnswer] = useState('')
  const [messages, setMessages] = useState<Message[]>([])
  const [loading, setLoading] = useState(false)
  const [score, setScore] = useState(0)
  const bottomRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  const startSession = async () => {
    setLoading(true)
    try {
      const res = await api.post('/coach/chat', {
        message: `I want to practice for a job interview in the ${sector} sector in South Africa. Give me 5 common interview questions for this sector, numbered 1-5. Just the questions, no answers.`,
        session_id: null
      })
      const text = res.data.reply
      const qs = text.split('\n')
        .filter((l: string) => /^\d\./.test(l.trim()))
        .map((l: string) => l.replace(/^\d\.\s*/, '').trim())
      setQuestions(qs.length >= 3 ? qs : STARTER_QUESTIONS)
      setStage('question')
      setMessages([{ role: 'ai', content: `Great! Let's practice for a ${sector} interview. I'll ask you ${qs.length || 5} questions. Take your time — answer like you're in a real interview.\n\n**Question 1:** ${qs[0] || STARTER_QUESTIONS[0]}` }])
    } catch {
      setQuestions(STARTER_QUESTIONS)
      setStage('question')
      setMessages([{ role: 'ai', content: `Let's practice for a ${sector} interview!\n\n**Question 1:** ${STARTER_QUESTIONS[0]}` }])
    }
    setLoading(false)
  }

  const submitAnswer = async () => {
    if (!answer.trim()) return
    const userMsg: Message = { role: 'user', content: answer }
    setMessages(m => [...m, userMsg])
    setAnswer('')
    setLoading(true)

    const currentQ = questions[qIndex] || STARTER_QUESTIONS[qIndex]
    const isLast = qIndex >= questions.length - 1

    try {
      const res = await api.post('/coach/chat', {
        message: `Interview question: "${currentQ}"\nCandidate answer: "${answer}"\n\nGive brief feedback (2-3 sentences) on this answer for a South African job seeker. Rate it 1-10. Be encouraging but honest. ${isLast ? 'This was the last question. End with "Interview practice complete!"' : `Then ask question ${qIndex + 2}: "${questions[qIndex + 1] || STARTER_QUESTIONS[qIndex + 1]}"`}`,
        session_id: null
      })
      const feedback = res.data.reply
      setMessages(m => [...m, { role: 'ai', content: feedback }])

      const scoreMatch = feedback.match(/(\d+)\/10|(\d+) out of 10/i)
      if (scoreMatch) setScore(s => s + parseInt(scoreMatch[1] || scoreMatch[2]))

      if (isLast) {
        setStage('done')
      } else {
        setQIndex(q => q + 1)
        setStage('question')
      }
    } catch {
      setMessages(m => [...m, { role: 'ai', content: "Eish, something went wrong. Try again!" }])
    }
    setLoading(false)
  }

  const avgScore = questions.length > 0 ? Math.round(score / Math.max(qIndex, 1)) : 0

  return (
    <div className="min-h-screen" style={{ background: '#0F0F0A' }}>
      {/* Header */}
      <div style={{ background: '#1A1A0F', borderBottom: '1px solid rgba(245,166,35,0.15)', padding: '20px 24px' }}>
        <div style={{ maxWidth: 700, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <p style={{ color: '#F5A623', fontSize: 11, fontWeight: 600, letterSpacing: 3, textTransform: 'uppercase', marginBottom: 4 }}>Interview Prep</p>
            <h1 className="font-display" style={{ color: '#FFFDF7', fontSize: 22, fontWeight: 700, margin: 0 }}>Practice makes perfect.</h1>
          </div>
          {stage !== 'select' && (
            <button onClick={() => { setStage('select'); setMessages([]); setQIndex(0); setScore(0); setSector('') }}
              style={{ background: 'rgba(255,253,247,0.06)', border: '1px solid rgba(255,253,247,0.12)', color: 'rgba(255,253,247,0.6)', padding: '8px 16px', borderRadius: 10, fontSize: 13, cursor: 'pointer' }}>
              Start over
            </button>
          )}
        </div>
      </div>

      <div style={{ maxWidth: 700, margin: '0 auto', padding: 24 }}>

        {/* Select sector */}
        {stage === 'select' && (
          <div>
            <p style={{ color: 'rgba(255,253,247,0.5)', fontSize: 14, marginBottom: 24, lineHeight: 1.6 }}>
              Pick your target job sector and I'll ask you real interview questions. Answer like you're in a real interview and I'll give you feedback.
            </p>
            <p style={{ color: 'rgba(255,253,247,0.4)', fontSize: 12, fontWeight: 600, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 12 }}>Choose your sector</p>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 10, marginBottom: 24 }}>
              {SECTORS.map(s => (
                <button key={s} onClick={() => setSector(s)}
                  style={{
                    background: sector === s ? 'rgba(245,166,35,0.15)' : 'rgba(255,253,247,0.04)',
                    border: `1px solid ${sector === s ? 'rgba(245,166,35,0.5)' : 'rgba(255,253,247,0.08)'}`,
                    color: sector === s ? '#F5A623' : 'rgba(255,253,247,0.6)',
                    padding: '12px 16px', borderRadius: 12, fontSize: 13, cursor: 'pointer', textAlign: 'left', fontWeight: sector === s ? 600 : 400,
                    transition: 'all 0.2s'
                  }}>
                  {s}
                </button>
              ))}
            </div>
            {!user && (
              <div style={{ background: 'rgba(245,166,35,0.08)', border: '1px solid rgba(245,166,35,0.2)', borderRadius: 12, padding: '12px 16px', marginBottom: 16, fontSize: 13, color: 'rgba(255,253,247,0.6)' }}>
                <Link to="/register" style={{ color: '#F5A623', fontWeight: 600 }}>Create a free account</Link> to save your practice history.
              </div>
            )}
            <button onClick={startSession} disabled={!sector || loading}
              style={{
                background: sector ? '#F5A623' : 'rgba(245,166,35,0.2)',
                color: '#1A1A0F', border: 'none', padding: '14px 28px', borderRadius: 100,
                fontSize: 14, fontWeight: 700, cursor: sector ? 'pointer' : 'not-allowed', opacity: sector ? 1 : 0.5
              }}>
              {loading ? 'Preparing questions...' : 'Start practice session →'}
            </button>
          </div>
        )}

        {/* Chat */}
        {(stage === 'question' || stage === 'feedback' || stage === 'done') && (
          <div>
            {/* Progress */}
            {stage !== 'done' && questions.length > 0 && (
              <div style={{ display: 'flex', gap: 6, marginBottom: 20 }}>
                {questions.map((_, i) => (
                  <div key={i} style={{ flex: 1, height: 3, borderRadius: 2, background: i < qIndex ? '#F5A623' : i === qIndex ? 'rgba(245,166,35,0.5)' : 'rgba(255,253,247,0.1)' }}/>
                ))}
              </div>
            )}

            {/* Messages */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 20 }}>
              {messages.map((m, i) => (
                <div key={i} style={{ display: 'flex', justifyContent: m.role === 'user' ? 'flex-end' : 'flex-start', gap: 10 }}>
                  {m.role === 'ai' && (
                    <div style={{ width: 32, height: 32, borderRadius: 10, background: 'linear-gradient(135deg,#F5A623,#C47D0A)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, flexShrink: 0 }}>🎤</div>
                  )}
                  <div style={{
                    maxWidth: '80%', padding: '12px 16px', borderRadius: m.role === 'user' ? '18px 18px 4px 18px' : '18px 18px 18px 4px',
                    background: m.role === 'user' ? '#F5A623' : '#1E1E14',
                    color: m.role === 'user' ? '#1A1A0F' : 'rgba(255,253,247,0.85)',
                    fontSize: 14, lineHeight: 1.6, whiteSpace: 'pre-wrap'
                  }}>
                    {m.content}
                  </div>
                </div>
              ))}
              {loading && (
                <div style={{ display: 'flex', gap: 10 }}>
                  <div style={{ width: 32, height: 32, borderRadius: 10, background: 'linear-gradient(135deg,#F5A623,#C47D0A)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>🎤</div>
                  <div style={{ background: '#1E1E14', padding: '12px 16px', borderRadius: '18px 18px 18px 4px', display: 'flex', gap: 6, alignItems: 'center' }}>
                    {[0,1,2].map(i => <div key={i} style={{ width: 6, height: 6, borderRadius: '50%', background: '#F5A623', animation: `bounce 1s ${i*0.2}s infinite` }}/>)}
                  </div>
                </div>
              )}
              <div ref={bottomRef}/>
            </div>

            {/* Done state */}
            {stage === 'done' && (
              <div style={{ background: 'rgba(245,166,35,0.08)', border: '1px solid rgba(245,166,35,0.2)', borderRadius: 16, padding: 24, textAlign: 'center', marginBottom: 20 }}>
                <div style={{ fontSize: 40, marginBottom: 12 }}>🎉</div>
                <h2 className="font-display" style={{ color: '#FFFDF7', fontSize: 20, fontWeight: 700, marginBottom: 8 }}>Practice complete!</h2>
                <p style={{ color: 'rgba(255,253,247,0.5)', fontSize: 14, marginBottom: 20 }}>You answered all {questions.length} questions. Keep practising to build confidence.</p>
                <div style={{ display: 'flex', gap: 10, justifyContent: 'center', flexWrap: 'wrap' }}>
                  <button onClick={() => { setStage('select'); setMessages([]); setQIndex(0); setScore(0); setSector('') }}
                    style={{ background: '#F5A623', color: '#1A1A0F', border: 'none', padding: '12px 24px', borderRadius: 100, fontSize: 14, fontWeight: 700, cursor: 'pointer' }}>
                    Practice again
                  </button>
                  <Link to="/cv" style={{ background: 'rgba(255,253,247,0.06)', color: 'rgba(255,253,247,0.7)', border: '1px solid rgba(255,253,247,0.12)', padding: '12px 24px', borderRadius: 100, fontSize: 14, textDecoration: 'none' }}>
                    Build your CV →
                  </Link>
                </div>
              </div>
            )}

            {/* Answer input */}
            {stage === 'question' && !loading && (
              <div style={{ background: '#1A1A0F', border: '1px solid rgba(255,253,247,0.1)', borderRadius: 16, padding: 16 }}>
                <textarea
                  value={answer}
                  onChange={e => setAnswer(e.target.value)}
                  onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); submitAnswer() } }}
                  placeholder="Type your answer here... (Enter to submit)"
                  rows={4}
                  style={{ width: '100%', background: 'transparent', border: 'none', color: '#FFFDF7', fontSize: 14, lineHeight: 1.6, resize: 'none', outline: 'none', fontFamily: 'inherit' }}
                />
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12, paddingTop: 12, borderTop: '1px solid rgba(255,253,247,0.08)' }}>
                  <span style={{ fontSize: 12, color: 'rgba(255,253,247,0.3)' }}>Question {qIndex + 1} of {questions.length}</span>
                  <button onClick={submitAnswer} disabled={!answer.trim()}
                    style={{ background: answer.trim() ? '#F5A623' : 'rgba(245,166,35,0.2)', color: '#1A1A0F', border: 'none', padding: '10px 20px', borderRadius: 100, fontSize: 13, fontWeight: 700, cursor: answer.trim() ? 'pointer' : 'not-allowed' }}>
                    Submit answer →
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      <style>{`@keyframes bounce { 0%,100%{transform:translateY(0)}50%{transform:translateY(-4px)} }`}</style>
    </div>
  )
}
EOF

echo "✅ Interview prep page done!"
