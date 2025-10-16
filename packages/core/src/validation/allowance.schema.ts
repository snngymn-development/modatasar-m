import { z } from 'zod'

export const AllowanceSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  employeeId: z.string().min(1, 'Employee ID is required'),
  
  // Ödeme bilgileri
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD format'),
  kind: z.enum(['MEAL', 'TRANSPORT', 'OTHER']),
  amount: z.number().int().nonnegative('Amount must be non-negative'),
  currency: z.string().default('TRY'),
  
  // Açıklama ve notlar
  note: z.string().optional(),
  
  // Meta bilgiler
  createdBy: z.string().min(1, 'Created by is required'),
  createdAt: z.string(),
  updatedAt: z.string()
})

export type AllowanceInput = z.infer<typeof AllowanceSchema>
