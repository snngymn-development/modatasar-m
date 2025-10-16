import { z } from 'zod'

export const PayrollItemSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  payrollRunId: z.string().min(1, 'Payroll run ID is required'),
  employeeId: z.string().min(1, 'Employee ID is required'),
  
  // Maaş hesaplamaları (cents)
  grossSalary: z.number().int().nonnegative('Gross salary must be non-negative'),
  
  // Mesai hesaplamaları
  normalHours: z.number().nonnegative('Normal hours must be non-negative'),
  overtimeHours: z.number().nonnegative('Overtime hours must be non-negative'),
  overtimeRate: z.number().positive('Overtime rate must be positive'),
  overtimeAmount: z.number().int().nonnegative('Overtime amount must be non-negative'),
  
  // Ek ödemeler ve kesintiler
  allowancesTotal: z.number().int().nonnegative('Allowances total must be non-negative'),
  deductionsTotal: z.number().int().nonnegative('Deductions total must be non-negative'),
  
  // Net ödeme
  netPay: z.number().int().nonnegative('Net pay must be non-negative'),
  
  // Finans entegrasyonu
  postedFinanceTransactionId: z.string().optional(),
  
  // Meta bilgiler
  createdAt: z.string(),
  updatedAt: z.string()
})

export type PayrollItemInput = z.infer<typeof PayrollItemSchema>
