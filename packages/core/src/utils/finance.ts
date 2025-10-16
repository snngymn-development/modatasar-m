import type { AccountWithBalance } from '../entities/Account'
import type { Posting } from '../entities/Transaction'
import type { CreatePostingInput } from '../entities/Transaction'

/**
 * Calculate account balance from postings
 * @param postings Array of postings for the account
 * @returns Balance in TRY cents (DEBIT - CREDIT)
 */
export const calculateAccountBalance = (postings: Posting[]): number => {
  return postings.reduce((balance, posting) => {
    const amountInTRY = posting.amount * posting.rateToTRY
    return posting.dc === 'DEBIT' 
      ? balance + amountInTRY 
      : balance - amountInTRY
  }, 0)
}

/**
 * Convert amount from one currency to TRY
 * @param amount Amount in source currency
 * @param rateToTRY Exchange rate to TRY
 * @returns Amount in TRY cents
 */
export const toTRY = (amount: number, rateToTRY: number): number => {
  return Math.round(amount * rateToTRY)
}

/**
 * Validate double-entry bookkeeping rule
 * @param postings Array of postings to validate
 * @returns true if DEBIT total equals CREDIT total
 */
export const validateDoubleEntry = (postings: CreatePostingInput[]): boolean => {
  const debitTotal = postings
    .filter(p => p.dc === 'DEBIT')
    .reduce((sum, p) => sum + p.amount, 0)
  const creditTotal = postings
    .filter(p => p.dc === 'CREDIT')
    .reduce((sum, p) => sum + p.amount, 0)
  
  return Math.abs(debitTotal - creditTotal) < 0.01
}

/**
 * Calculate total balance for multiple accounts
 * @param accounts Array of accounts with balances
 * @returns Total balance in TRY cents
 */
export const calculateTotalBalance = (accounts: AccountWithBalance[]): number => {
  return accounts.reduce((total, account) => total + account.balanceTRY, 0)
}

/**
 * Format transaction kind for display
 * @param kind Transaction kind
 * @returns Human-readable string
 */
export const formatTransactionKind = (kind: string): string => {
  const kindMap: Record<string, string> = {
    'RECEIVABLE': 'Tahsilat',
    'PAYABLE': 'Ödeme', 
    'INTERNAL_TRANSFER': 'Virman'
  }
  return kindMap[kind] || kind
}

/**
 * Format posting direction for display
 * @param dc Debit or Credit
 * @returns Human-readable string
 */
export const formatPostingDC = (dc: string): string => {
  return dc === 'DEBIT' ? 'Borç' : 'Alacak'
}
