import type { ID } from '../types/common'

/**
 * Transaction domain entity
 * Represents a financial transaction (Receivable, Payable, Transfer, etc.)
 */
export interface Transaction {
  id: ID
  date: string // ISO date string
  kind: 'RECEIVABLE' | 'PAYABLE' | 'INTERNAL_TRANSFER'
  amount: number // Main transaction amount in transaction currency
  currency: 'TRY' | 'USD' | 'EUR'
  rateToTRY: number // Exchange rate to TRY at transaction time
  note?: string
  customerId?: ID // Optional customer reference
  supplierId?: ID // Optional supplier reference
  createdBy: ID // User who created the transaction
  createdAt: string
  updatedAt: string
  // Relations
  postings: Posting[]
}

/**
 * Posting domain entity
 * Represents a single debit/credit entry in double-entry bookkeeping
 */
export interface Posting {
  id: ID
  transactionId: ID
  accountId: ID
  dc: 'DEBIT' | 'CREDIT'
  amount: number // Amount in posting currency
  currency: 'TRY' | 'USD' | 'EUR'
  rateToTRY: number // Exchange rate to TRY at posting time
  createdAt: string
}

/**
 * Transaction creation input
 * Used for creating new transactions
 */
export interface CreateTransactionInput {
  kind: 'RECEIVABLE' | 'PAYABLE' | 'INTERNAL_TRANSFER'
  amount: number
  currency: 'TRY' | 'USD' | 'EUR'
  rateToTRY: number
  note?: string
  customerId?: ID
  supplierId?: ID
  createdBy: ID
  // Posting details
  postings: CreatePostingInput[]
}

/**
 * Posting creation input
 */
export interface CreatePostingInput {
  accountId: ID
  dc: 'DEBIT' | 'CREDIT'
  amount: number
  currency: 'TRY' | 'USD' | 'EUR'
  rateToTRY: number
}
