import { useState, useEffect } from 'react'
import { Order } from '@deneme1/shared'

interface UseOrdersReturn {
  orders: Order[]
  loading: boolean
  error: string | null
  refresh: () => void
  addOrder: (order: Omit<Order, 'id'>) => Promise<void>
  updateOrder: (id: string, order: Partial<Order>) => Promise<void>
  deleteOrder: (id: string) => Promise<void>
}

export function useOrders(): UseOrdersReturn {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchOrders = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Mock data - gerçek API'ye bağlanacak
      const mockOrders: Order[] = [
        {
          id: '1',
          type: 'TAILORING',
          customerId: '1',
          organization: 'Düğün Organizasyonu',
          deliveryDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
          total: 250000, // 2500 TL in cents
          collected: 125000, // 1250 TL in cents
          status: 'IN_PROGRESS',
          stage: 'KESIM',
          createdAt: new Date().toISOString(),
          customer: {
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
          details: [],
          fittings: [],
          statusHistory: [],
        },
        {
          id: '2',
          type: 'RENTAL',
          customerId: '2',
          organization: 'Gala Gecesi',
          deliveryDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
          total: 150000, // 1500 TL in cents
          collected: 150000, // 1500 TL in cents
          status: 'COMPLETED',
          stage: 'TESLIM',
          createdAt: new Date().toISOString(),
          customer: {
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
          details: [],
          fittings: [],
          statusHistory: [],
        },
      ]
      
      setOrders(mockOrders)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Bilinmeyen hata')
    } finally {
      setLoading(false)
    }
  }

  const addOrder = async (orderData: Omit<Order, 'id'>) => {
    try {
      const newOrder: Order = {
        ...orderData,
        id: Date.now().toString(),
        createdAt: new Date().toISOString(),
      }
      
      setOrders(prev => [...prev, newOrder])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sipariş eklenirken hata')
    }
  }

  const updateOrder = async (id: string, orderData: Partial<Order>) => {
    try {
      setOrders(prev => 
        prev.map(order => 
          order.id === id 
            ? { ...order, ...orderData }
            : order
        )
      )
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sipariş güncellenirken hata')
    }
  }

  const deleteOrder = async (id: string) => {
    try {
      setOrders(prev => prev.filter(order => order.id !== id))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sipariş silinirken hata')
    }
  }

  const refresh = () => {
    fetchOrders()
  }

  useEffect(() => {
    fetchOrders()
  }, [])

  return {
    orders,
    loading,
    error,
    refresh,
    addOrder,
    updateOrder,
    deleteOrder,
  }
}
