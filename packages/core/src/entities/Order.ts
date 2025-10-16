import type { ID, Currency } from '../types/common'
import { OrderType, RecordStatus } from '../types/enums'

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
  createdAt: string
}

