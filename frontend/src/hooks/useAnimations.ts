import { useEffect } from 'react'

export function useParticleCanvas(canvasRef: React.RefObject<HTMLCanvasElement>, heroRef: React.RefObject<HTMLElement>) {
  useEffect(() => {
    const canvas = canvasRef.current, hero = heroRef.current
    if (!canvas || !hero) return
    const ctx = canvas.getContext('2d')!
    let W = canvas.width = hero.offsetWidth
    let H = canvas.height = hero.offsetHeight
    const dots = Array.from({ length: 60 }, () => ({
      x: Math.random() * W, y: Math.random() * H,
      r: Math.random() * 1.8 + 0.3,
      vx: (Math.random() - .5) * .28, vy: (Math.random() - .5) * .28,
    }))
    const resize = () => { W = canvas.width = hero.offsetWidth; H = canvas.height = hero.offsetHeight }
    window.addEventListener('resize', resize)
    let raf: number
    const draw = () => {
      ctx.clearRect(0, 0, W, H)
      for (let i = 0; i < dots.length; i++)
        for (let j = i + 1; j < dots.length; j++) {
          const dx = dots[i].x - dots[j].x, dy = dots[i].y - dots[j].y
          const d = Math.sqrt(dx * dx + dy * dy)
          if (d < 140) {
            ctx.beginPath()
            ctx.strokeStyle = `rgba(245,166,35,${0.18 * (1 - d / 140)})`
            ctx.lineWidth = 0.6
            ctx.moveTo(dots[i].x, dots[i].y)
            ctx.lineTo(dots[j].x, dots[j].y)
            ctx.stroke()
          }
        }
      dots.forEach(d => {
        ctx.beginPath(); ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2)
        ctx.fillStyle = 'rgba(245,166,35,0.6)'; ctx.fill()
        d.x += d.vx; d.y += d.vy
        if (d.x < 0 || d.x > W) d.vx *= -1
        if (d.y < 0 || d.y > H) d.vy *= -1
      })
      raf = requestAnimationFrame(draw)
    }
    draw()
    return () => { cancelAnimationFrame(raf); window.removeEventListener('resize', resize) }
  }, [])
}

export function useParallax(heroRef: React.RefObject<HTMLElement>, photoRef: React.RefObject<HTMLImageElement>) {
  useEffect(() => {
    const hero = heroRef.current, photo = photoRef.current
    if (!hero || !photo) return
    photo.style.transition = 'transform 0.45s cubic-bezier(0.16,1,0.3,1)'
    const move = (e: MouseEvent) => {
      const r = hero.getBoundingClientRect()
      const x = (e.clientX - r.left) / r.width - 0.5
      const y = (e.clientY - r.top) / r.height - 0.5
      photo.style.transform = `scale(1.06) translate(${x * -16}px, ${y * -11}px)`
    }
    const leave = () => { photo.style.transform = 'scale(1) translate(0,0)' }
    hero.addEventListener('mousemove', move)
    hero.addEventListener('mouseleave', leave)
    return () => { hero.removeEventListener('mousemove', move); hero.removeEventListener('mouseleave', leave) }
  }, [])
}

export function useMagneticButtons() {
  useEffect(() => {
    const btns = document.querySelectorAll<HTMLElement>('.magnetic')
    const handlers: Array<() => void> = []
    btns.forEach(btn => {
      const move = (e: MouseEvent) => {
        const r = btn.getBoundingClientRect()
        const x = e.clientX - r.left - r.width / 2
        const y = e.clientY - r.top - r.height / 2
        btn.style.transform = `translate(${x * 0.22}px, ${y * 0.22}px) scale(1.03)`
      }
      const leave = () => {
        btn.style.transform = ''
        btn.style.transition = 'transform 0.5s cubic-bezier(0.16,1,0.3,1), background 0.2s, box-shadow 0.2s'
      }
      btn.addEventListener('mousemove', move)
      btn.addEventListener('mouseleave', leave)
      handlers.push(() => { btn.removeEventListener('mousemove', move); btn.removeEventListener('mouseleave', leave) })
    })
    return () => handlers.forEach(h => h())
  })
}

export function useCardTilt() {
  useEffect(() => {
    const cards = document.querySelectorAll<HTMLElement>('.tilt-card')
    const handlers: Array<() => void> = []
    cards.forEach(card => {
      const move = (e: MouseEvent) => {
        const r = card.getBoundingClientRect()
        const x = (e.clientX - r.left) / r.width - 0.5
        const y = (e.clientY - r.top) / r.height - 0.5
        card.style.transform = `perspective(700px) rotateX(${-y * 7}deg) rotateY(${x * 7}deg) translateY(-4px)`
        card.style.transition = 'transform 0.1s ease'
      }
      const leave = () => {
        card.style.transform = ''
        card.style.transition = 'transform 0.5s cubic-bezier(0.16,1,0.3,1), border-color 0.2s, box-shadow 0.2s'
      }
      card.addEventListener('mousemove', move)
      card.addEventListener('mouseleave', leave)
      handlers.push(() => { card.removeEventListener('mousemove', move); card.removeEventListener('mouseleave', leave) })
    })
    return () => handlers.forEach(h => h())
  })
}

export function useRipple() {
  useEffect(() => {
    const btns = document.querySelectorAll<HTMLElement>('.ripple')
    const handlers: Array<() => void> = []
    btns.forEach(btn => {
      const click = (e: MouseEvent) => {
        const r = btn.getBoundingClientRect()
        const size = Math.max(r.width, r.height) * 2
        const span = document.createElement('span')
        span.style.cssText = `position:absolute;width:${size}px;height:${size}px;left:${e.clientX-r.left-size/2}px;top:${e.clientY-r.top-size/2}px;background:rgba(255,255,255,0.25);border-radius:50%;transform:scale(0);animation:ripple .55s ease-out forwards;pointer-events:none;`
        btn.style.position = 'relative'
        btn.style.overflow = 'hidden'
        btn.appendChild(span)
        setTimeout(() => span.remove(), 600)
      }
      btn.addEventListener('click', click as EventListener)
      handlers.push(() => btn.removeEventListener('click', click as EventListener))
    })
    const style = document.createElement('style')
    style.textContent = '@keyframes ripple{to{transform:scale(1);opacity:0}}'
    document.head.appendChild(style)
    return () => { handlers.forEach(h => h()); style.remove() }
  })
}

export function useScrollReveal() {
  useEffect(() => {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (!e.isIntersecting) return
        const el = e.target as HTMLElement
        const delay = el.dataset.delay ? parseInt(el.dataset.delay) : 0
        setTimeout(() => el.classList.add('in'), delay)
        obs.unobserve(el)
      })
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' })
    document.querySelectorAll('.reveal:not(.in)').forEach(el => obs.observe(el))
    return () => obs.disconnect()
  })
}

export function useCursorGlow() {
  useEffect(() => {
    const glow = document.createElement('div')
    glow.style.cssText = `
      position:fixed;width:400px;height:400px;border-radius:50%;
      background:radial-gradient(circle,rgba(245,166,35,0.06) 0%,transparent 70%);
      pointer-events:none;z-index:9998;transform:translate(-50%,-50%);
      transition:left .15s ease,top .15s ease;
    `
    document.body.appendChild(glow)
    const move = (e: MouseEvent) => { glow.style.left = e.clientX + 'px'; glow.style.top = e.clientY + 'px' }
    window.addEventListener('mousemove', move)
    return () => { window.removeEventListener('mousemove', move); glow.remove() }
  }, [])
}
