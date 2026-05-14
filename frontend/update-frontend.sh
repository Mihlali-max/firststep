#!/bin/bash
set -e
cd ~/firststep/frontend
echo "📝 Updating frontend files..."

# Tailwind config
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        amber: { DEFAULT: '#F5A623', dark: '#C47D0A', pale: '#FFF6E3' },
        forest: { DEFAULT: '#2A5C3F', light: '#3A7A54' },
        ink: { DEFAULT: '#1A1A0F', mid: '#2E2E1F' },
        warm: '#FFFDF7',
        offwhite: '#F7F3EB',
        muted: '#7A7260',
      },
      fontFamily: {
        display: ['Fraunces', 'Georgia', 'serif'],
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
EOF

# Install clsx if not present
npm install clsx react-router-dom lucide-react 2>/dev/null || true

# Create directories
mkdir -p src/components/{layout,pages,ui} src/hooks src/lib src/store

# index.css
cat > src/index.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,300;0,400;0,700;1,300;1,400&family=DM+Sans:wght@300;400;500&display=swap');
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html { scroll-behavior: smooth; }
  body { background: #FFFDF7; color: #1A1A0F; font-family: 'DM Sans', sans-serif; }
}
@layer components {
  .btn-amber { @apply bg-[#F5A623] text-[#1A1A0F] font-medium px-6 py-3 rounded-lg transition-all duration-200 hover:bg-[#C47D0A] hover:-translate-y-0.5 shadow-[0_2px_8px_rgba(245,166,35,0.25)]; }
  .btn-outline { @apply border border-[#1A1A0F]/20 text-[#1A1A0F]/80 font-medium px-6 py-3 rounded-lg transition-all duration-200 hover:border-[#1A1A0F]/60; }
  .btn-ink { @apply bg-[#1A1A0F] text-[#FFFDF7] font-medium px-6 py-3 rounded-lg transition-all duration-200 hover:opacity-85 hover:-translate-y-0.5; }
  .section-eyebrow { @apply text-[#C47D0A] text-xs font-medium tracking-[3px] uppercase flex items-center gap-2; }
  .section-title { @apply font-display text-4xl font-bold text-[#1A1A0F] tracking-tight leading-tight; }
  .card { @apply bg-[#FFFDF7] border border-[#1A1A0F]/10 rounded-2xl p-6 transition-all duration-200 hover:border-[#F5A623]/30 hover:shadow-[0_8px_32px_rgba(245,166,35,0.1)] hover:-translate-y-1; }
}
.reveal { opacity: 0; transform: translateY(24px); transition: opacity .7s ease, transform .7s ease; }
.reveal.in { opacity: 1; transform: none; }
#scroll-bar { position: fixed; top: 68px; left: 0; height: 2px; background: #F5A623; z-index: 300; width: 0%; transition: width .1s linear; box-shadow: 0 0 10px rgba(245,166,35,0.7); }
EOF

echo "✅ Base files done. Now copying components..."
