import type { ID, Currency } from '../types/common'
import { AllowanceKind } from '../types/enums'

/**
 * Allowance domain entity
 * Yol, yemek ve diğer ek ödemeler
 */
export interface Allowance {
  id: ID
  employeeId: ID
  
  // Ödeme bilgileri
  date: string                    // Tarih (YYYY-MM-DD)
  kind: AllowanceKind            // MEAL | TRANSPORT | OTHER
  amount: Currency               // Tutar (cents)
  currency: string               // Para birimi (TRY)
  
  // Açıklama ve notlar
  note?: string                  // Açıklama/not
  
  // Meta bilgiler
  createdBy: ID                  // Kaydı oluşturan kişi
  createdAt: string              // Oluşturulma tarihi (ISO date-time)
  updatedAt: string              // Güncellenme tarihi (ISO date-time)
}
