import type { ID } from '../types/common'

/**
 * AgendaEvent domain entity
 * Represents non-rental events (maintenance, cleaning, out of service)
 */
export interface AgendaEvent {
  id: ID
  productId: ID
  type: AgendaEventType
  start: string // ISO 8601 date
  end: string // ISO 8601 date
  note?: string
  createdAt: string
}

export type AgendaEventType = 'DRY_CLEANING' | 'ALTERATION' | 'OUT_OF_SERVICE'

