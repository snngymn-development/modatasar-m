import type { ID, Currency } from '../types/common'
import { SgkStatus } from '../types/enums'

/**
 * SgkRecord domain entity
 * SGK prim kayıtları (dönem bazlı)
 */
export interface SgkRecord {
  id: ID
  employeeId: ID
  
  // Dönem bilgileri
  period: string                  // Dönem (YYYY-MM format)
  
  // SGK prim tutarları (cents)
  baseAmount: Currency           // Brüt ücret (prim matrahı)
  employerShare: Currency        // İşveren payı
  employeeShare: Currency        // İşçi payı
  total: Currency                // Toplam prim
  
  // Ödeme durumu
  status: SgkStatus              // PAID | UNPAID
  paymentDate?: string           // Ödeme tarihi (ISO date)
  
  // Finans entegrasyonu
  financeTransactionId?: ID      // Finans işlem ID'si
  
  // Meta bilgiler
  createdAt: string              // Oluşturulma tarihi (ISO date-time)
  updatedAt: string              // Güncellenme tarihi (ISO date-time)
}
