import { z } from 'zod'

export const AccountSchema = z.object({
  id: z.string().min(1),
  type: z.enum(['CASH', 'BANK', 'POS']),
  name: z.string().min(1, 'Account name is required'),
  currency: z.enum(['TRY', 'USD', 'EUR']),
  isActive: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string()
})

export const CreateAccountSchema = z.object({
  type: z.enum(['CASH', 'BANK', 'POS']),
  name: z.string().min(1, 'Account name is required'),
  currency: z.enum(['TRY', 'USD', 'EUR']).default('TRY'),
  isActive: z.boolean().default(true)
})

export const AccountWithBalanceSchema = AccountSchema.extend({
  balanceTRY: z.number()
})

export type AccountInput = z.infer<typeof AccountSchema>
export type CreateAccountInput = z.infer<typeof CreateAccountSchema>
export type AccountWithBalanceInput = z.infer<typeof AccountWithBalanceSchema>
