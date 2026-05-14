import axios from 'axios'

const api = axios.create({ baseURL: (import.meta.env.VITE_API_BASE || '') + '/api', timeout: 15000 })

api.interceptors.request.use((config) => {
  const raw = localStorage.getItem('firststep-auth')
  if (raw) {
    try {
      const { state } = JSON.parse(raw)
      if (state?.accessToken) config.headers.Authorization = `Bearer ${state.accessToken}`
    } catch {}
  }
  return config
})

export default api
