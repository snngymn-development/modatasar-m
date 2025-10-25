import type { ID } from '../types/common'

// Contract Template Entity
export interface ContractTemplate {
  id: ID
  name: string
  type: 'DİKİM' | 'KİRALAMA' | 'GENEL'
  content: string // HTML template içeriği
  version: string // "1.0", "1.1", "2.0"
  isActive: boolean
  createdAt: Date
  updatedAt: Date
}

// Contract Entity
export interface Contract {
  id: ID
  orderId: ID
  templateId: ID
  contractNumber: string // GGAAYY-D001 formatı
  status: ContractStatus
  content: string // Final sözleşme içeriği (placeholder'lar değiştirilmiş)
  pdfUrl?: string // PDF dosya yolu
  signedAt?: Date
  approvedAt?: Date
  createdAt: Date
  updatedAt: Date
}

// Contract Status Enum
export type ContractStatus = 
  | 'PENDING'     // Beklemede
  | 'SENT'        // Gönderildi
  | 'SIGNED'      // İmzalandı
  | 'APPROVED'    // Onaylandı
  | 'EXPIRED'     // Süresi doldu
  | 'CANCELLED'   // İptal edildi

// Customer Consent Entity
export interface CustomerConsent {
  id: ID
  customerId: ID
  contractId?: ID
  type: ConsentType
  status: ConsentStatus
  signedAt?: Date
  createdAt: Date
}

// Consent Types
export type ConsentType = 
  | 'GENERAL'        // Genel onaylar (KVKK, pazarlama)
  | 'MARKETING'      // Pazarlama onayları
  | 'ORDER_CONTRACT' // Sipariş sözleşmesi onayı

// Consent Status
export type ConsentStatus = 
  | 'PENDING'   // Beklemede
  | 'SIGNED'    // İmzalandı
  | 'REJECTED'  // Reddedildi
  | 'EXPIRED'   // Süresi doldu

// Contract Creation DTO
export interface CreateContractDto {
  orderId: ID
  templateId: ID
}

// Contract Status Update DTO
export interface UpdateContractStatusDto {
  status: ContractStatus
  notes?: string
}

// Contract PDF Generation DTO
export interface GenerateContractPDFDto {
  contractId: ID
  outputPath?: string
}

// Contract Template Data (for placeholder replacement)
export interface ContractTemplateData {
  contractNumber: string
  customerName: string
  customerPhone?: string
  orderDate: string
  deliveryDate: string
  totalAmount: number
  dailyRate?: number // For rental contracts
  rentalDays?: number // For rental contracts
}

// Contract List Item (for UI display)
export interface ContractListItem {
  id: ID
  contractNumber: string
  status: ContractStatus
  customerName: string
  orderType: string
  totalAmount: number
  createdAt: Date
  signedAt?: Date
  approvedAt?: Date
}

// Contract Status Badge Colors
export const CONTRACT_STATUS_COLORS = {
  PENDING: 'bg-yellow-100 text-yellow-800',
  SENT: 'bg-blue-100 text-blue-800',
  SIGNED: 'bg-green-100 text-green-800',
  APPROVED: 'bg-emerald-100 text-emerald-800',
  EXPIRED: 'bg-red-100 text-red-800',
  CANCELLED: 'bg-gray-100 text-gray-800'
} as const

// Contract Status Icons
export const CONTRACT_STATUS_ICONS = {
  PENDING: '⏳',
  SENT: '📤',
  SIGNED: '✍️',
  APPROVED: '✅',
  EXPIRED: '⏰',
  CANCELLED: '❌'
} as const

// Contract Status Labels (Turkish)
export const CONTRACT_STATUS_LABELS = {
  PENDING: 'Beklemede',
  SENT: 'Gönderildi',
  SIGNED: 'İmzalandı',
  APPROVED: 'Onaylandı',
  EXPIRED: 'Süresi Doldu',
  CANCELLED: 'İptal Edildi'
} as const
