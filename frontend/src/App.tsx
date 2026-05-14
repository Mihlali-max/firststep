import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/layout/Layout'
import Home from './components/pages/Home'
import { Login, Register } from './components/pages/Auth'
import LAP from './components/pages/LAP'
import Coach from './components/pages/Coach'
import Learnerships from './components/pages/Learnerships'
import CVBuilder from './components/pages/CVBuilder'
import CVUpload from './components/pages/CVUpload'

const Soon = ({ title }: { title: string }) => (
  <div className="min-h-[60vh] flex items-center justify-center">
    <div className="text-center">
      <h1 className="font-display text-4xl font-bold text-[#1A1A0F] mb-3">{title}</h1>
      <p className="text-[#7A7260] text-sm">Coming soon — building this next.</p>
    </div>
  </div>
)

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
          <Route path="/lap" element={<LAP />} />
          <Route path="/cv" element={<CVBuilder />} />
          <Route path="/cv/upload" element={<CVUpload />} />
          <Route path="/learnerships" element={<Learnerships />} />
          <Route path="/coach" element={<Coach />} />
          <Route path="/contact" element={<Soon title="Contact" />} />
        </Route>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  )
}
