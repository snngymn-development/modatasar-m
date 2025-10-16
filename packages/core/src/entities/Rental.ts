import type { ID, DateRange } from '../types/common'

export interface Rental {
  id: ID
  orderId: ID // Link to Order (1-to-1)
  productId: ID // Which product is rented
  period: DateRange
  organization?: string
}

