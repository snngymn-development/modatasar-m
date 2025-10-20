import type { ID, Currency } from '../types/common'
import { OrderType, RecordStatus } from '../types/enums'
import type { OrderDetail, OrderFitting, OrderStatus } from './OrderDetail'

export interface Order {
  id: ID
  type: OrderType
  customerId: ID
  organization?: string
  deliveryDate?: string // For TAILORING orders
  total: Currency // Amount in cents
  collected: Currency // Amount collected in cents
  status: RecordStatus
  stage?: string // Business process stage (e.g., 'IN_PROGRESS_50', 'BOOKED')
  tagPrice?: Currency // Tag price for rental orders in cents
  details: OrderDetail[]
  fittings: OrderFitting[]
  statusHistory: OrderStatus[]
  createdAt: string
}

