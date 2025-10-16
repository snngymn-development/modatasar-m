import type { ID } from '../types/common'

/**
 * StockMovement domain entity
 * Represents stock movements (IN, OUT, ADJUST)
 */
export interface StockMovement {
  id: ID
  type: StockMovementType
  productId?: ID
  stockCardId?: ID
  
  qty: number
  unit: string
  warehouse: string
  date: string // ISO 8601 date
  note?: string
  
  // Audit fields
  referenceType?: ReferenceType
  referenceId?: ID
  createdBy?: ID
}

export type StockMovementType = 'IN' | 'OUT' | 'ADJUST'
export type ReferenceType = 'TAILORING' | 'RENTAL' | 'ORDER' | 'OTHER'
