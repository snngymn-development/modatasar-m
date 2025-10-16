import { z } from 'zod'

export const PayrollRunSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  
  // Dönem bilgileri
  periodStart: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Period start must be YYYY-MM-DD format'),
  periodEnd: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Period end must be YYYY-MM-DD format'),
  
  // Kapsam
  scope: z.enum(['ALL', 'SELECTED']),
  employeeIds: z.array(z.string()).optional(),
  
  // Toplam tutarlar (cents)
  totals: z.object({
    gross: z.number().int().nonnegative('Gross must be non-negative'),
    overtime: z.number().int().nonnegative('Overtime must be non-negative'),
    allowances: z.number().int().nonnegative('Allowances must be non-negative'),
    deductions: z.number().int().nonnegative('Deductions must be non-negative'),
    net: z.number().int().nonnegative('Net must be non-negative')
  }),
  
  // Durum
  status: z.enum(['DRAFT', 'POSTED']),
  
  // Meta bilgiler
  createdBy: z.string().min(1, 'Created by is required'),
  createdAt: z.string(),
  updatedAt: z.string(),
  postedAt: z.string().optional(),
  postedBy: z.string().optional()
})

export type PayrollRunInput = z.infer<typeof PayrollRunSchema>
