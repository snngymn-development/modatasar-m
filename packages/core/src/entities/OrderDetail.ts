import type { ID, Currency } from '../types/common'

export interface OrderDetail {
  id: ID
  orderId: ID
  description?: string
  amount: Currency // Base amount in cents
  charges: OrderCharge[]
  discounts: OrderDiscount[]
  importantNote?: string
  totalAmount: Currency // Calculated: amount + charges - discounts
  createdAt: string
  updatedAt: string
}

export interface OrderCharge {
  id: ID
  orderDetailId: ID
  label: string
  amount: Currency
  description?: string
  createdAt: string
}

export interface OrderDiscount {
  id: ID
  orderDetailId: ID
  label: string
  amount: Currency
  description?: string
  createdAt: string
}

export interface OrderFitting {
  id: ID
  orderId: ID
  fittingNumber: number
  fittingDate: string
  notes?: string
  status: 'SCHEDULED' | 'COMPLETED' | 'CANCELLED'
  createdAt: string
}

export interface OrderStatus {
  id: ID
  orderId: ID
  status: 'STARTED' | 'PROGRESS_50' | 'PROGRESS_80' | 'READY' | 'DELIVERED'
  percentage: number
  notes?: string
  createdAt: string
  updatedAt: string
}

export interface CustomerBodyMeasurements {
  id: ID
  customerId: ID
  chest: number // cm
  waist: number // cm
  hip: number // cm
  shoulder: number // cm
  armLength: number // cm
  legLength: number // cm
  neck: number // cm
  notes?: string
  measuredAt: string
  createdAt: string
}

