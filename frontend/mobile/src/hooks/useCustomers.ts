import { useState, useEffect } from 'react'
import { Customer } from '@deneme1/shared'

interface UseCustomersReturn {
  customers: Customer[]
  loading: boolean
  error: string | null
  refresh: () => void
  addCustomer: (customer: Omit<Customer, 'id'>) => Promise<void>
  updateCustomer: (id: string, customer: Partial<Customer>) => Promise<void>
  deleteCustomer: (id: string) => Promise<void>
}

export function useCustomers(): UseCustomersReturn {
  const [customers, setCustomers] = useState<Customer[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchCustomers = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Mock data - gerçek API'ye bağlanacak
      const mockCustomers: Customer[] = [
        {
          id: '1',
          name: 'Ahmet Yılmaz',
          phone: '+90 532 123 45 67',
          email: 'ahmet@example.com',
          city: 'İstanbul',
          isProtocol: false,
          stars: 5,
          priority: 'HIGH',
          tags: 'VIP,Müşteri',
          status: 'ACTIVE',
          lastActivityAt: new Date(),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        {
          id: '2',
          name: 'Ayşe Demir',
          phone: '+90 533 987 65 43',
          email: 'ayse@example.com',
          city: 'Ankara',
          isProtocol: true,
          stars: 4,
          priority: 'NORMAL',
          tags: 'Protokol',
          status: 'ACTIVE',
          lastActivityAt: new Date(),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      ]
      
      setCustomers(mockCustomers)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Bilinmeyen hata')
    } finally {
      setLoading(false)
    }
  }

  const addCustomer = async (customerData: Omit<Customer, 'id'>) => {
    try {
      const newCustomer: Customer = {
        ...customerData,
        id: Date.now().toString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }
      
      setCustomers(prev => [...prev, newCustomer])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Müşteri eklenirken hata')
    }
  }

  const updateCustomer = async (id: string, customerData: Partial<Customer>) => {
    try {
      setCustomers(prev => 
        prev.map(customer => 
          customer.id === id 
            ? { ...customer, ...customerData, updatedAt: new Date().toISOString() }
            : customer
        )
      )
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Müşteri güncellenirken hata')
    }
  }

  const deleteCustomer = async (id: string) => {
    try {
      setCustomers(prev => prev.filter(customer => customer.id !== id))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Müşteri silinirken hata')
    }
  }

  const refresh = () => {
    fetchCustomers()
  }

  useEffect(() => {
    fetchCustomers()
  }, [])

  return {
    customers,
    loading,
    error,
    refresh,
    addCustomer,
    updateCustomer,
    deleteCustomer,
  }
}
