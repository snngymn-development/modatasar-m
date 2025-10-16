import { z } from 'zod'

export const SgkRecordSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  employeeId: z.string().min(1, 'Employee ID is required'),
  
  // Dönem bilgileri
  period: z.string().regex(/^\d{4}-\d{2}$/, 'Period must be YYYY-MM format'),
  
  // SGK prim tutarları (cents)
  baseAmount: z.number().int().nonnegative('Base amount must be non-negative'),
  employerShare: z.number().int().nonnegative('Employer share must be non-negative'),
  employeeShare: z.number().int().nonnegative('Employee share must be non-negative'),
  total: z.number().int().nonnegative('Total must be non-negative'),
  
  // Ödeme durumu
  status: z.enum(['PAID', 'UNPAID']),
  paymentDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Payment date must be YYYY-MM-DD format').optional(),
  
  // Finans entegrasyonu
  financeTransactionId: z.string().optional(),
  
  // Meta bilgiler
  createdAt: z.string(),
  updatedAt: z.string()
})

export type SgkRecordInput = z.infer<typeof SgkRecordSchema>
