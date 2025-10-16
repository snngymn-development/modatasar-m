import type { ID, Currency } from '../types/common'

/**
 * PayrollItem domain entity
 * Kişiye özel bordro kalemleri
 */
export interface PayrollItem {
  id: ID
  payrollRunId: ID
  employeeId: ID
  
  // Maaş hesaplamaları (cents)
  grossSalary: Currency           // Dönemde hak ettiği sabit/orantılanmış maaş
  
  // Mesai hesaplamaları
  normalHours: number             // Normal çalışma saati
  overtimeHours: number           // Fazla mesai saati
  overtimeRate: number            // Fazla mesai katsayısı (1.5, 2.0)
  overtimeAmount: Currency        // Fazla mesai tutarı
  
  // Ek ödemeler ve kesintiler
  allowancesTotal: Currency       // Toplam ek ödemeler (yol/yemek)
  deductionsTotal: Currency       // Toplam kesintiler (avans, ceza)
  
  // Net ödeme
  netPay: Currency                // Net ödenecek tutar
  
  // Finans entegrasyonu
  postedFinanceTransactionId?: ID // Finans işlem ID'si (ödeme yapıldığında)
  
  // Meta bilgiler
  createdAt: string               // Oluşturulma tarihi (ISO date-time)
  updatedAt: string               // Güncellenme tarihi (ISO date-time)
}
