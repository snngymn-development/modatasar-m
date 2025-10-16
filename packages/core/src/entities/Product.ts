import type { ID } from '../types/common'

/**
 * Product domain entity
 * Represents rentable items (suits, accessories, etc.)
 */
export interface Product {
  id: ID
  name: string
  model?: string
  color?: string
  size?: string
  category?: string
  tags: string // Comma-separated tags
  status: ProductStatus
  createdAt: string // ISO 8601 date
}

export type ProductStatus = 'AVAILABLE' | 'IN_USE' | 'MAINTENANCE' | 'OUT_OF_SERVICE'

