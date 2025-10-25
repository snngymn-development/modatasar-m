import { z } from 'zod'

// Contract Template Schema
export const ContractTemplateSchema = z.object({
  id: z.string(),
  name: z.string().min(1, 'Template adı gerekli'),
  type: z.enum(['DİKİM', 'KİRALAMA', 'GENEL']),
  content: z.string().min(1, 'Template içeriği gerekli'),
  version: z.string().min(1, 'Versiyon gerekli'),
  isActive: z.boolean().default(true),
  createdAt: z.date(),
  updatedAt: z.date()
})

// Contract Schema
export const ContractSchema = z.object({
  id: z.string(),
  orderId: z.string(),
  templateId: z.string(),
  contractNumber: z.string().min(1, 'Sözleşme numarası gerekli'),
  status: z.enum(['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED']),
  content: z.string().min(1, 'Sözleşme içeriği gerekli'),
  pdfUrl: z.string().optional(),
  signedAt: z.date().optional(),
  approvedAt: z.date().optional(),
  createdAt: z.date(),
  updatedAt: z.date()
})

// Customer Consent Schema
export const CustomerConsentSchema = z.object({
  id: z.string(),
  customerId: z.string(),
  contractId: z.string().optional(),
  type: z.enum(['GENERAL', 'MARKETING', 'ORDER_CONTRACT']),
  status: z.enum(['PENDING', 'SIGNED', 'REJECTED', 'EXPIRED']),
  signedAt: z.date().optional(),
  createdAt: z.date()
})

// Create Contract DTO Schema
export const CreateContractSchema = z.object({
  orderId: z.string().min(1, 'Sipariş ID gerekli'),
  templateId: z.string().min(1, 'Template ID gerekli')
})

// Update Contract Status Schema
export const UpdateContractStatusSchema = z.object({
  status: z.enum(['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED']),
  notes: z.string().optional()
})

// Generate Contract PDF Schema
export const GenerateContractPDFSchema = z.object({
  contractId: z.string().min(1, 'Sözleşme ID gerekli'),
  outputPath: z.string().optional()
})

// Contract Template Data Schema (for placeholder replacement)
export const ContractTemplateDataSchema = z.object({
  contractNumber: z.string().min(1, 'Sözleşme numarası gerekli'),
  customerName: z.string().min(1, 'Müşteri adı gerekli'),
  customerPhone: z.string().optional(),
  orderDate: z.string().min(1, 'Sipariş tarihi gerekli'),
  deliveryDate: z.string().min(1, 'Teslim tarihi gerekli'),
  totalAmount: z.number().positive('Toplam tutar pozitif olmalı'),
  dailyRate: z.number().positive().optional(), // For rental contracts
  rentalDays: z.number().int().positive().optional() // For rental contracts
})

// Contract List Item Schema
export const ContractListItemSchema = z.object({
  id: z.string(),
  contractNumber: z.string(),
  status: z.enum(['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED']),
  customerName: z.string(),
  orderType: z.string(),
  totalAmount: z.number(),
  createdAt: z.date(),
  signedAt: z.date().optional(),
  approvedAt: z.date().optional()
})

// Type exports
export type ContractTemplateType = z.infer<typeof ContractTemplateSchema>
export type ContractType = z.infer<typeof ContractSchema>
export type CustomerConsentType = z.infer<typeof CustomerConsentSchema>
export type CreateContractType = z.infer<typeof CreateContractSchema>
export type UpdateContractStatusType = z.infer<typeof UpdateContractStatusSchema>
export type GenerateContractPDFType = z.infer<typeof GenerateContractPDFSchema>
export type ContractTemplateDataType = z.infer<typeof ContractTemplateDataSchema>
export type ContractListItemType = z.infer<typeof ContractListItemSchema>
