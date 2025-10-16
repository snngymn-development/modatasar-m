import type { ID } from '../types/common'

/**
 * Account domain entity
 * Represents financial accounts (Cash, Bank, POS, etc.)
 */
export interface Account {
  id: ID
  type: 'CASH' | 'BANK' | 'POS'
  name: string
  currency: 'TRY' | 'USD' | 'EUR'
  isActive: boolean
  createdAt: string
  updatedAt: string
}

/**
 * Account with calculated balance
 * Used for chip display and reporting
 */
export interface AccountWithBalance extends Account {
  balanceTRY: number // Calculated balance in TRY cents
}
