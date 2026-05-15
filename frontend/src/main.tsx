import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

const loader = document.getElementById('app-loader'); if(loader) loader.style.display='none';
ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
