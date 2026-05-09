import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import api from '../lib/api'

interface User { id: string; email: string; full_name: string; province?: string; city?: string; totp_enabled: boolean }
interface AuthState {
  user: User | null; accessToken: string | null; refreshToken: string | null; isLoading: boolean
  login: (email: string, password: string, totp?: string) => Promise<void>
  register: (data: any) => Promise<void>
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null, accessToken: null, refreshToken: null, isLoading: false,
      login: async (email, password, totp) => {
        set({ isLoading: true })
        try {
          const { data } = await api.post('/auth/login', { email, password, totp_code: totp })
          set({ user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token })
        } finally { set({ isLoading: false }) }
      },
      register: async (registerData) => {
        set({ isLoading: true })
        try {
          const { data } = await api.post('/auth/register', registerData)
          set({ user: data.user, accessToken: data.access_token, refreshToken: data.refresh_token })
        } finally { set({ isLoading: false }) }
      },
      logout: () => set({ user: null, accessToken: null, refreshToken: null }),
    }),
    { name: 'firststep-auth', partialize: (s) => ({ user: s.user, accessToken: s.accessToken, refreshToken: s.refreshToken }) }
  )
)
