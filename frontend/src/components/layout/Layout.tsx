import { useEffect } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import Navbar from './Navbar'
import Footer from './Footer'

export default function Layout() {
  const { pathname } = useLocation()
  useEffect(() => { window.scrollTo({ top: 0, behavior: 'smooth' }) }, [pathname])
  useEffect(() => {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); obs.unobserve(e.target) } })
    }, { threshold: 0.1 })
    setTimeout(() => document.querySelectorAll('.reveal:not(.in)').forEach(el => obs.observe(el)), 100)
    return () => obs.disconnect()
  }, [pathname])
  useEffect(() => {
    const bar = document.getElementById('scroll-bar')
    if (!bar) return
    const h = () => { const t = document.body.scrollHeight - window.innerHeight; bar.style.width = t > 0 ? (window.scrollY/t*100)+'%' : '0%' }
    window.addEventListener('scroll', h)
    return () => window.removeEventListener('scroll', h)
  }, [])
  return (
    <>
      <div id="scroll-bar" />
      <Navbar />
      <main><Outlet /></main>
      <Footer />
    </>
  )
}
