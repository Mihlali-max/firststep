/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        amber: { DEFAULT: '#F5A623', dark: '#C47D0A', pale: '#FFF6E3' },
        forest: { DEFAULT: '#2A5C3F' },
        ink: { DEFAULT: '#1A1A0F' },
        warm: '#FFFDF7',
        offwhite: '#F7F3EB',
        muted: '#7A7260',
      },
      fontFamily: {
        display: ['Clash Display', 'Georgia', 'serif'],
        sans: ['Plus Jakarta Sans', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
