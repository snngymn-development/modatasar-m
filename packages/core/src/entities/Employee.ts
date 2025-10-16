import type { ID, Currency } from '../types/common'
import { EmployeeStatus, WageType } from '../types/enums'

/**
 * Employee domain entity
 * Personel bilgileri ve temel iş sözleşmesi verileri
 */
export interface Employee {
  id: ID
  firstName: string
  lastName: string
  tcNo?: string                    // TC Kimlik No
  status: EmployeeStatus          // EMPLOYEE_ACTIVE | EMPLOYEE_PASSIVE | EMPLOYEE_PROBATION
  
  // Departman ve pozisyon
  departmentId?: ID
  department?: string             // Departman adı (normalize edilmemiş)
  position?: string               // Pozisyon/Unvan
  
  // İş sözleşmesi tarihleri
  hireDate: string               // İşe giriş tarihi (ISO date)
  terminationDate?: string       // İşten çıkış tarihi (ISO date)
  
  // Ücret bilgileri
  wageType: WageType             // FIXED | HOURLY
  baseWageAmount: Currency       // Sabit maaş (aylık) veya saatlik ücret (cents)
  baseWageCurrency: string       // Para birimi (TRY)
  
  // Çalışma saatleri
  normalWeeklyHours: number      // Haftalık normal çalışma saati (örn. 45)
  
  // İletişim bilgileri
  phone?: string
  email?: string
  address?: string
  
  // Banka bilgileri
  iban?: string                  // IBAN (ödeme için)
  
  // SGK bilgileri
  sgkNo?: string                 // SGK sicil no
  
  // Vardiya bilgileri (gelecekte)
  shiftId?: ID
  shiftName?: string
  
  // Avans politikası
  advancePolicy?: string         // Avans alma kuralları (JSON string)
  
  // Meta bilgiler
  createdAt: string
  updatedAt: string
}
