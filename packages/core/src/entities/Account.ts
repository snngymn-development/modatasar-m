import type { ID } from '../types/common'

/**
 * Account domain entity
 * Represents financial accounts (Cash, Bank, POS, etc.)
 */
export interface Account {
  id: ID
  type: 'CASH' | 'BANK' | 'POS' | 'SUPPLIER_POS' | 'CREDIT_CARD'
  name: string
  currency: 'TRY' | 'USD' | 'EUR'
  isActive: boolean
  parentId?: ID // For hierarchical structure
  parent?: Account // Parent account
  children?: Account[] // Child accounts
  // Bank specific fields
  iban?: string // IBAN for bank accounts
  // Credit card specific fields
  creditLimit?: number // Total credit limit in cents
  usedAmount: number // Used amount in cents
  createdAt: string
  updatedAt: string
}

/**
 * Account with calculated balance
 * Used for chip display and reporting
 */
export interface AccountWithBalance extends Account {
  balanceTRY: number // Calculated balance in TRY cents
  availableCredit?: number // Available credit for credit cards (creditLimit - usedAmount)
}

/**
 * Account type labels for display
 */
export const ACCOUNT_TYPE_LABELS = {
  CASH: 'Kasa',
  BANK: 'Banka',
  POS: 'POS',
  SUPPLIER_POS: 'Tedarikçi POS',
  CREDIT_CARD: 'Kredi Kartı'
} as const

/**
 * Bank names for detailed display
 */
export const BANK_NAMES = {
  GARANTI: 'Garanti',
  ISBANK: 'İşbankası',
  YAPIKREDI: 'Yapıkredi',
  AKBANK: 'Akbank',
  ZIRAAT: 'Ziraat Bankası',
  HALKBANK: 'Halkbank'
} as const
