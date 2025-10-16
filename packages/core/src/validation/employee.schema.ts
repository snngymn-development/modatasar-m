import { z } from 'zod'

export const EmployeeSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  firstName: z.string().min(2, 'First name must be at least 2 characters'),
  lastName: z.string().min(2, 'Last name must be at least 2 characters'),
  tcNo: z.string().regex(/^\d{11}$/, 'TC No must be 11 digits').optional(),
  status: z.enum(['ACTIVE', 'PASSIVE', 'PROBATION']),
  
  // Departman ve pozisyon
  departmentId: z.string().optional(),
  department: z.string().optional(),
  position: z.string().optional(),
  
  // İş sözleşmesi tarihleri
  hireDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Hire date must be YYYY-MM-DD format'),
  terminationDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Termination date must be YYYY-MM-DD format').optional(),
  
  // Ücret bilgileri
  wageType: z.enum(['FIXED', 'HOURLY']),
  baseWageAmount: z.number().int().nonnegative('Base wage must be non-negative'),
  baseWageCurrency: z.string().default('TRY'),
  
  // Çalışma saatleri
  normalWeeklyHours: z.number().int().min(1).max(60, 'Normal weekly hours must be between 1-60'),
  
  // İletişim bilgileri
  phone: z.string().optional(),
  email: z.string().email('Invalid email format').optional(),
  address: z.string().optional(),
  
  // Banka bilgileri
  iban: z.string().regex(/^TR\d{2}\d{4}\d{16}$/, 'Invalid IBAN format').optional(),
  
  // SGK bilgileri
  sgkNo: z.string().optional(),
  
  // Vardiya bilgileri
  shiftId: z.string().optional(),
  shiftName: z.string().optional(),
  
  // Avans politikası
  advancePolicy: z.string().optional(),
  
  // Meta bilgiler
  createdAt: z.string(),
  updatedAt: z.string()
})

export type EmployeeInput = z.infer<typeof EmployeeSchema>
