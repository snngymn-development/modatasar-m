import { z } from 'zod'

export const StockMovementSchema = z.object({
  id: z.string(),
  type: z.enum(['IN', 'OUT', 'ADJUST']),
  productId: z.string().optional(),
  stockCardId: z.string().optional(),
  
  qty: z.number().int(),
  unit: z.string().default('adet'),
  warehouse: z.string().default('MAIN'),
  date: z.string(),
  note: z.string().optional(),
  
  // Audit fields
  referenceType: z.enum(['TAILORING', 'RENTAL', 'ORDER', 'OTHER']).optional(),
  referenceId: z.string().optional(),
  createdBy: z.string().optional(),
})

export type StockMovementInput = z.infer<typeof StockMovementSchema>

// DTO schemas for API operations
export const ConsumeStockSchema = z.object({
  qty: z.number().int().positive('Quantity must be positive'),
  unit: z.string().min(1, 'Unit is required'),
  referenceType: z.enum(['TAILORING', 'RENTAL', 'ORDER', 'OTHER']).optional(),
  referenceId: z.string().optional(),
  note: z.string().optional(),
})

export const AdjustStockSchema = z.object({
  newQty: z.number().int().nonnegative('New quantity must be non-negative'),
  reason: z.string().min(1, 'Reason is required'),
  note: z.string().optional(),
})

export type ConsumeStockInput = z.infer<typeof ConsumeStockSchema>
export type AdjustStockInput = z.infer<typeof AdjustStockSchema>
