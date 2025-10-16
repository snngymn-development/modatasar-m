import { z } from 'zod'

export const PostingSchema = z.object({
  id: z.string().min(1),
  transactionId: z.string().min(1),
  accountId: z.string().min(1),
  dc: z.enum(['DEBIT', 'CREDIT']),
  amount: z.number().positive('Amount must be positive'),
  currency: z.enum(['TRY', 'USD', 'EUR']),
  rateToTRY: z.number().positive('Rate must be positive'),
  createdAt: z.string()
})

export const CreatePostingSchema = z.object({
  accountId: z.string().min(1, 'Account ID is required'),
  dc: z.enum(['DEBIT', 'CREDIT']),
  amount: z.number().positive('Amount must be positive'),
  currency: z.enum(['TRY', 'USD', 'EUR']).default('TRY'),
  rateToTRY: z.number().positive('Rate must be positive').default(1)
})

export const TransactionSchema = z.object({
  id: z.string().min(1),
  date: z.string().min(1),
  kind: z.enum(['RECEIVABLE', 'PAYABLE', 'INTERNAL_TRANSFER', 'PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND']),
  amount: z.number().positive('Amount must be positive'),
  currency: z.enum(['TRY', 'USD', 'EUR']),
  rateToTRY: z.number().positive('Rate must be positive'),
  note: z.string().optional(),
  customerId: z.string().optional(),
  supplierId: z.string().optional(),
  createdBy: z.string().min(1, 'Created by is required'),
  createdAt: z.string(),
  updatedAt: z.string(),
  postings: z.array(PostingSchema)
})

export const CreateTransactionSchema = z.object({
  kind: z.enum(['RECEIVABLE', 'PAYABLE', 'INTERNAL_TRANSFER', 'PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND']),
  amount: z.number().positive('Amount must be positive'),
  currency: z.enum(['TRY', 'USD', 'EUR']).default('TRY'),
  rateToTRY: z.number().positive('Rate must be positive').default(1),
  note: z.string().optional(),
  customerId: z.string().optional(),
  supplierId: z.string().optional(),
  createdBy: z.string().min(1, 'Created by is required'),
  postings: z.array(CreatePostingSchema).min(2, 'At least 2 postings required')
}).refine((data) => {
  // Double-entry validation: DEBIT total = CREDIT total
  const debitTotal = data.postings
    .filter(p => p.dc === 'DEBIT')
    .reduce((sum, p) => sum + p.amount, 0)
  const creditTotal = data.postings
    .filter(p => p.dc === 'CREDIT')
    .reduce((sum, p) => sum + p.amount, 0)
  return Math.abs(debitTotal - creditTotal) < 0.01 // Allow small floating point differences
}, {
  message: 'DEBIT total must equal CREDIT total',
  path: ['postings']
})

export type TransactionInput = z.infer<typeof TransactionSchema>
export type PostingInput = z.infer<typeof PostingSchema>
