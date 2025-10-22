import React, { useState, useEffect } from 'react'
import { invoke } from '@tauri-apps/api/tauri'
import { open } from '@tauri-apps/api/shell'
import { writeTextFile, readTextFile } from '@tauri-apps/api/fs'
import { appWindow } from '@tauri-apps/api/window'

interface Customer {
  id: string
  name: string
  phone: string
  email: string
  city: string
  stars: number
  status: string
  createdAt: string
}

interface AppState {
  customers: Customer[]
  loading: boolean
  error: string | null
}

export default function App() {
  const [state, setState] = useState<AppState>({
    customers: [],
    loading: true,
    error: null
  })

  const [newCustomer, setNewCustomer] = useState({
    name: '',
    phone: '',
    email: '',
    city: ''
  })

  useEffect(() => {
    loadCustomers()
  }, [])

  const loadCustomers = async () => {
    try {
      setState(prev => ({ ...prev, loading: true, error: null }))
      
      // Mock data for now - will be replaced with real API calls
      const mockCustomers: Customer[] = [
        {
          id: '1',
          name: 'Ahmet Yılmaz',
          phone: '+90 532 123 45 67',
          email: 'ahmet@example.com',
          city: 'İstanbul',
          stars: 5,
          status: 'ACTIVE',
          createdAt: new Date().toISOString()
        },
        {
          id: '2',
          name: 'Ayşe Demir',
          phone: '+90 533 987 65 43',
          email: 'ayse@example.com',
          city: 'Ankara',
          stars: 4,
          status: 'ACTIVE',
          createdAt: new Date().toISOString()
        }
      ]
      
      setState(prev => ({ ...prev, customers: mockCustomers, loading: false }))
    } catch (error) {
      setState(prev => ({ 
        ...prev, 
        error: error instanceof Error ? error.message : 'Bilinmeyen hata',
        loading: false 
      }))
    }
  }

  const addCustomer = async () => {
    if (!newCustomer.name.trim()) return

    try {
      const customer: Customer = {
        id: Date.now().toString(),
        name: newCustomer.name,
        phone: newCustomer.phone,
        email: newCustomer.email,
        city: newCustomer.city,
        stars: 0,
        status: 'ACTIVE',
        createdAt: new Date().toISOString()
      }

      setState(prev => ({
        ...prev,
        customers: [...prev.customers, customer]
      }))

      setNewCustomer({ name: '', phone: '', email: '', city: '' })
    } catch (error) {
      setState(prev => ({ 
        ...prev, 
        error: error instanceof Error ? error.message : 'Müşteri eklenirken hata'
      }))
    }
  }

  const exportCustomers = async () => {
    try {
      const csvContent = [
        'ID,Ad,Telefon,E-posta,Şehir,Yıldız,Durum,Kayıt Tarihi',
        ...state.customers.map(c => 
          `${c.id},${c.name},${c.phone},${c.email},${c.city},${c.stars},${c.status},${c.createdAt}`
        )
      ].join('\n')

      await writeTextFile('customers.csv', csvContent)
      alert('Müşteri listesi CSV olarak dışa aktarıldı!')
    } catch (error) {
      alert('Dışa aktarma hatası: ' + (error instanceof Error ? error.message : 'Bilinmeyen hata'))
    }
  }

  const openWebsite = async () => {
    await open('https://github.com/tauri-apps/tauri')
  }

  const minimizeWindow = () => {
    appWindow.minimize()
  }

  const closeWindow = () => {
    appWindow.close()
  }

  return (
    <div className="container">
      {/* Custom Title Bar */}
      <div className="titlebar">
        <div className="titlebar-title">Deneme1 Desktop</div>
        <div className="titlebar-controls">
          <button className="titlebar-button" onClick={minimizeWindow}>−</button>
          <button className="titlebar-button close" onClick={closeWindow}>×</button>
        </div>
      </div>

      {/* Main Content */}
      <div className="main-content">
        <header className="header">
          <h1>🏢 Müşteri Yönetimi</h1>
          <div className="header-actions">
            <button className="btn btn-secondary" onClick={exportCustomers}>
              📊 CSV Dışa Aktar
            </button>
            <button className="btn btn-primary" onClick={openWebsite}>
              🌐 Website
            </button>
          </div>
        </header>

        {/* Add Customer Form */}
        <div className="form-section">
          <h2>Yeni Müşteri Ekle</h2>
          <div className="form-grid">
            <input
              type="text"
              placeholder="Ad Soyad"
              value={newCustomer.name}
              onChange={(e) => setNewCustomer(prev => ({ ...prev, name: e.target.value }))}
              className="form-input"
            />
            <input
              type="text"
              placeholder="Telefon"
              value={newCustomer.phone}
              onChange={(e) => setNewCustomer(prev => ({ ...prev, phone: e.target.value }))}
              className="form-input"
            />
            <input
              type="email"
              placeholder="E-posta"
              value={newCustomer.email}
              onChange={(e) => setNewCustomer(prev => ({ ...prev, email: e.target.value }))}
              className="form-input"
            />
            <input
              type="text"
              placeholder="Şehir"
              value={newCustomer.city}
              onChange={(e) => setNewCustomer(prev => ({ ...prev, city: e.target.value }))}
              className="form-input"
            />
            <button className="btn btn-success" onClick={addCustomer}>
              ➕ Müşteri Ekle
            </button>
          </div>
        </div>

        {/* Customers List */}
        <div className="customers-section">
          <h2>Müşteri Listesi ({state.customers.length})</h2>
          
          {state.loading && <div className="loading">Yükleniyor...</div>}
          {state.error && <div className="error">Hata: {state.error}</div>}
          
          <div className="customers-grid">
            {state.customers.map(customer => (
              <div key={customer.id} className="customer-card">
                <div className="customer-header">
                  <h3>{customer.name}</h3>
                  <div className="stars">
                    {'★'.repeat(customer.stars)}
                    {'☆'.repeat(5 - customer.stars)}
                  </div>
                </div>
                <div className="customer-details">
                  <p><strong>📞</strong> {customer.phone}</p>
                  <p><strong>📧</strong> {customer.email}</p>
                  <p><strong>🏙️</strong> {customer.city}</p>
                  <p><strong>📅</strong> {new Date(customer.createdAt).toLocaleDateString('tr-TR')}</p>
                </div>
                <div className="customer-status">
                  <span className={`status ${customer.status.toLowerCase()}`}>
                    {customer.status === 'ACTIVE' ? '✅ Aktif' : '❌ Pasif'}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        .container {
          height: 100vh;
          display: flex;
          flex-direction: column;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        .titlebar {
          height: 30px;
          background: rgba(0, 0, 0, 0.1);
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0 10px;
          -webkit-app-region: drag;
        }

        .titlebar-title {
          color: white;
          font-size: 12px;
          font-weight: 500;
        }

        .titlebar-controls {
          display: flex;
          -webkit-app-region: no-drag;
        }

        .titlebar-button {
          width: 30px;
          height: 30px;
          border: none;
          background: transparent;
          color: white;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .titlebar-button:hover {
          background: rgba(255, 255, 255, 0.1);
        }

        .titlebar-button.close:hover {
          background: #e81123;
        }

        .main-content {
          flex: 1;
          padding: 20px;
          overflow-y: auto;
        }

        .header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 30px;
        }

        .header h1 {
          color: white;
          font-size: 28px;
          font-weight: 700;
        }

        .header-actions {
          display: flex;
          gap: 10px;
        }

        .btn {
          padding: 10px 20px;
          border: none;
          border-radius: 8px;
          cursor: pointer;
          font-weight: 600;
          transition: all 0.2s;
        }

        .btn-primary {
          background: #007AFF;
          color: white;
        }

        .btn-primary:hover {
          background: #0056CC;
        }

        .btn-secondary {
          background: rgba(255, 255, 255, 0.2);
          color: white;
          border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .btn-secondary:hover {
          background: rgba(255, 255, 255, 0.3);
        }

        .btn-success {
          background: #34C759;
          color: white;
        }

        .btn-success:hover {
          background: #28A745;
        }

        .form-section, .customers-section {
          background: rgba(255, 255, 255, 0.95);
          border-radius: 12px;
          padding: 20px;
          margin-bottom: 20px;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .form-section h2, .customers-section h2 {
          color: #333;
          margin-bottom: 20px;
          font-size: 20px;
        }

        .form-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 15px;
          align-items: end;
        }

        .form-input {
          padding: 12px;
          border: 2px solid #E5E5EA;
          border-radius: 8px;
          font-size: 14px;
          transition: border-color 0.2s;
        }

        .form-input:focus {
          outline: none;
          border-color: #007AFF;
        }

        .customers-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
          gap: 20px;
        }

        .customer-card {
          background: white;
          border-radius: 12px;
          padding: 20px;
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
          transition: transform 0.2s;
        }

        .customer-card:hover {
          transform: translateY(-2px);
        }

        .customer-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 15px;
        }

        .customer-header h3 {
          color: #333;
          font-size: 18px;
        }

        .stars {
          color: #FFD700;
          font-size: 16px;
        }

        .customer-details p {
          margin-bottom: 8px;
          color: #666;
          font-size: 14px;
        }

        .customer-status {
          margin-top: 15px;
          text-align: center;
        }

        .status {
          padding: 6px 12px;
          border-radius: 20px;
          font-size: 12px;
          font-weight: 600;
        }

        .status.active {
          background: #D4EDDA;
          color: #155724;
        }

        .status.inactive {
          background: #F8D7DA;
          color: #721C24;
        }

        .loading, .error {
          text-align: center;
          padding: 20px;
          font-size: 16px;
        }

        .loading {
          color: #666;
        }

        .error {
          color: #DC3545;
          background: #F8D7DA;
          border-radius: 8px;
        }
      `}</style>
    </div>
  )
}
