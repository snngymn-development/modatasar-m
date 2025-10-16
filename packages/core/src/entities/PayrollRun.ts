import type { ID, Currency } from '../types/common'
import { PayrollStatus } from '../types/enums'

/**
 * PayrollRun domain entity
 * Haftalık/aylık bordro hesaplama çalıştırması
 */
export interface PayrollRun {
  id: ID
  
  // Dönem bilgileri
  periodStart: string             // Dönem başlangıcı (YYYY-MM-DD)
  periodEnd: string               // Dönem bitişi (YYYY-MM-DD)
  
  // Kapsam
  scope: 'ALL' | 'SELECTED'       // Tüm personel | Seçili personel
  employeeIds?: ID[]              // Seçili personel ID'leri (scope=SELECTED ise)
  
  // Toplam tutarlar (cents)
  totals: {
    gross: Currency               // Toplam brüt
    overtime: Currency            // Toplam fazla mesai
    allowances: Currency          // Toplam ek ödemeler
    deductions: Currency          // Toplam kesintiler
    net: Currency                 // Toplam net
  }
  
  // Durum
  status: PayrollStatus           // DRAFT | POSTED
  
  // Meta bilgiler
  createdBy: ID                   // Oluşturan kişi
  createdAt: string               // Oluşturulma tarihi (ISO date-time)
  updatedAt: string               // Güncellenme tarihi (ISO date-time)
  postedAt?: string               // Kilitleme tarihi (ISO date-time)
  postedBy?: ID                   // Kilitleyen kişi
}
