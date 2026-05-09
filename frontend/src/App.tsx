import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from './store/authStore'

function Home() {
  const { user, logout } = useAuthStore()
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '600px', margin: '0 auto' }}>
      <h1 style={{ color: '#F5A623' }}>🚀 FirstStep</h1>
      <p>Your first job starts here.</p>
      {user ? (
        <div>
          <p>Welcome, <strong>{user.full_name}</strong>!</p>
          <button onClick={logout} style={{ background: '#1A1A0F', color: '#fff', padding: '8px 16px', border: 'none', borderRadius: '6px', cursor: 'pointer' }}>
            Log out
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', gap: '12px' }}>
          <a href="/login" style={{ background: '#F5A623', color: '#1A1A0F', padding: '10px 20px', borderRadius: '8px', textDecoration: 'none', fontWeight: 500 }}>Log in</a>
          <a href="/register" style={{ background: '#1A1A0F', color: '#fff', padding: '10px 20px', borderRadius: '8px', textDecoration: 'none', fontWeight: 500 }}>Get started</a>
        </div>
      )}
    </div>
  )
}

function Login() {
  const { login, isLoading } = useAuthStore()
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const form = new FormData(e.currentTarget)
    await login(form.get('email') as string, form.get('password') as string)
    window.location.href = '/'
  }
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '400px', margin: '4rem auto' }}>
      <h2>Log in to FirstStep</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '1.5rem' }}>
        <input name="email" type="email" placeholder="Email" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="password" type="password" placeholder="Password" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <button type="submit" disabled={isLoading} style={{ background: '#F5A623', color: '#1A1A0F', padding: '12px', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}>
          {isLoading ? 'Logging in...' : 'Log in'}
        </button>
      </form>
      <p style={{ marginTop: '1rem', fontSize: '0.875rem' }}>No account? <a href="/register">Get started free</a></p>
    </div>
  )
}

function Register() {
  const { register, isLoading } = useAuthStore()
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const form = new FormData(e.currentTarget)
    await register({ email: form.get('email'), password: form.get('password'), full_name: form.get('full_name') })
    window.location.href = '/'
  }
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem', maxWidth: '400px', margin: '4rem auto' }}>
      <h2>Create your free profile</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '1.5rem' }}>
        <input name="full_name" placeholder="Full name" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="email" type="email" placeholder="Email" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <input name="password" type="password" placeholder="Password (min 8 chars)" required style={{ padding: '10px', borderRadius: '6px', border: '1.5px solid #ddd' }} />
        <button type="submit" disabled={isLoading} style={{ background: '#F5A623', color: '#1A1A0F', padding: '12px', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}>
          {isLoading ? 'Creating account...' : 'Get started free'}
        </button>
      </form>
      <p style={{ marginTop: '1rem', fontSize: '0.875rem' }}>Already have an account? <a href="/login">Log in</a></p>
    </div>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  )
}
