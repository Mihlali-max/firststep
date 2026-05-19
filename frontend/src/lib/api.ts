import axios from 'axios'

const api = axios.create({ baseURL: (import.meta.env.VITE_API_BASE || '') + '/api', timeout: 15000 })

const getTokens = () => {
  try {
    const raw = localStorage.getItem('firststep-auth')
    if (raw) { const { state } = JSON.parse(raw); return state }
  } catch {}
  return {}
}

const setTokens = (accessToken: string) => {
  try {
    const raw = localStorage.getItem('firststep-auth')
    if (raw) {
      const parsed = JSON.parse(raw)
      parsed.state.accessToken = accessToken
      localStorage.setItem('firststep-auth', JSON.stringify(parsed))
    }
  } catch {}
}

api.interceptors.request.use((config) => {
  const { accessToken } = getTokens()
  if (accessToken) config.headers.Authorization = `Bearer ${accessToken}`
  return config
})

api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true
      try {
        const { refreshToken } = getTokens()
        if (!refreshToken) throw new Error('No refresh token')
        const { data } = await axios.post(
          (import.meta.env.VITE_API_BASE || '') + '/api/auth/refresh',
          { refresh_token: refreshToken }
        )
        setTokens(data.access_token)
        original.headers.Authorization = `Bearer ${data.access_token}`
        return api(original)
      } catch {
        const raw = localStorage.getItem('firststep-auth')
        const wasLoggedIn = raw && JSON.parse(raw)?.state?.user
        if (wasLoggedIn) {
          localStorage.removeItem('firststep-auth')
          window.location.href = '/login'
        }
        return Promise.reject(error)
      }
    }
    return Promise.reject(error)
  }
)

export default api
