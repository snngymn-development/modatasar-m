import type { ID } from '../types/common'

/**
 * StockCard domain entity
 * Represents stock items (materials, supplies, etc.)
 */
export interface StockCard {
  id: ID
  code: string
  name: string
  description?: string
  
  // Category information
  category?: string
  type?: string
  kind?: string
  group?: string
  
  // Stock information
  unit: string
  criticalQty: number
  location: string
  
  // Relations
  supplierId?: ID
  
  // Meta
  tags: string // Comma-separated tags
  status: StockCardStatus
  createdAt: string // ISO 8601 date
  updatedAt: string // ISO 8601 date
}

export type StockCardStatus = 'ACTIVE' | 'PASSIVE'
