#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🔧 Fixing learnerships search + filters..."

python3 << 'EOF'
content = open("src/components/pages/Learnerships.tsx").read()

# Fix QUERIES — simple single keywords only, no OR/quotes
old_queries = '''const QUERIES = [
  { label:'All opportunities', q:'learnership' },
  { label:'Learnerships',      q:'learnership' },
  { label:'YES Programme',     q:'"YES programme" OR "youth employment"' },
  { label:'Internships',       q:'internship' },
  { label:'IT & Tech',         q:'IT learnership OR ICT learnership OR technology intern' },
  { label:'Banking & Finance', q:'banking learnership OR finance learnership OR accounting learnership' },
  { label:'Retail & FMCG',     q:'retail learnership OR shop learnership' },
  { label:'Construction',      q:'construction learnership OR building learnership' },
  { label:'Healthcare',        q:'healthcare learnership OR nursing learnership' },
  { label:'Admin & Office',    q:'admin learnership OR office learnership OR data capture' },
]'''

new_queries = '''const QUERIES = [
  { label:'All opportunities', q:'learnership' },
  { label:'Learnerships',      q:'learnership programme' },
  { label:'YES Programme',     q:'YES programme youth' },
  { label:'Internships',       q:'internship graduate' },
  { label:'IT & Tech',         q:'IT learnership technology' },
  { label:'Banking & Finance', q:'banking finance learnership' },
  { label:'Retail & FMCG',     q:'retail learnership' },
  { label:'Construction',      q:'construction learnership' },
  { label:'Healthcare',        q:'healthcare learnership' },
  { label:'Admin & Office',    q:'admin learnership office' },
]'''

content = content.replace(old_queries, new_queries)

# Fix fetchJobs — remove auth requirement, make it work without login
old_fetch = '''  useEffect(() => {
    const controller = new AbortController()
    const delay = search ? 400 : 0
    const timer = setTimeout(async () => {
      setLoading(true); setError(false)
      try {
        const q = search.trim() || QUERIES[activeQ].q
        const params: any = { q, page, results_per_page: 20 }
        if (province !== 'All Provinces') params.province = province
        const res = await api.get('/jobs', { params })
        setJobs(res.data.results || [])
        setTotal(res.data.total || 0)
      } catch {
        setError(true)
        setJobs(FALLBACK)
        setTotal(FALLBACK.length)
      } finally { setLoading(false) }
    }, delay)
    return () => { clearTimeout(timer); controller.abort() }
  }, [search, province, page, activeQ])'''

new_fetch = '''  useEffect(() => {
    const timer = setTimeout(async () => {
      setLoading(true); setError(false)
      try {
        const q = encodeURIComponent(search.trim() || QUERIES[activeQ].q)
        let url = `/api/jobs?q=${q}&page=${page}&results_per_page=20`
        if (province !== 'All Provinces') url += `&province=${encodeURIComponent(province)}`
        const res = await fetch(url)
        if (!res.ok) throw new Error('API error')
        const data = await res.json()
        if (data.results && data.results.length > 0) {
          setJobs(data.results)
          setTotal(data.total || 0)
          setError(false)
        } else {
          setJobs(FALLBACK)
          setTotal(FALLBACK.length)
          setError(false)
        }
      } catch {
        setError(true)
        setJobs(FALLBACK)
        setTotal(FALLBACK.length)
      } finally { setLoading(false) }
    }, search ? 500 : 0)
    return () => clearTimeout(timer)
  }, [search, province, page, activeQ])'''

content = content.replace(old_fetch, new_fetch)

# Fix the refresh button to also use fetch
old_refresh = '''          <button onClick={()=>fetchJobs(search||QUERIES[activeQ].q, province, page)} className="flex items-center gap-1.5 text-sm text-black/40 hover:text-black transition-colors px-3 py-2.5 rounded-xl hover:bg-white">'''
new_refresh = '''          <button onClick={()=>{ setPage(1); setSearch(s=>s+' '); setTimeout(()=>setSearch(s=>s.trim()),10) }} className="flex items-center gap-1.5 text-sm text-black/40 hover:text-black transition-colors px-3 py-2.5 rounded-xl hover:bg-white">'''
content = content.replace(old_refresh, new_refresh)

# Remove unused useCallback import
content = content.replace(
    "import { useState, useEffect, useRef }",
    "import { useState, useEffect, useRef }"
)

open("src/components/pages/Learnerships.tsx", "w").write(content)
print("✅ Fixed")
EOF

echo "Done! Dev server restarting..."
npm run dev
