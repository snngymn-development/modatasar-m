import { z } from 'zod'

export const StockCardSchema = z.object({
  id: z.string(),
  code: z.string().min(1, 'Stock card code is required'),
  name: z.string().min(1, 'Stock card name is required'),
  description: z.string().optional(),
  
  // Category information
  category: z.string().optional(),
  type: z.string().optional(),
  kind: z.string().optional(),
  group: z.string().optional(),
  
  // Stock information
  unit: z.string().default('adet'),
  criticalQty: z.number().int().nonnegative().default(0),
  location: z.string().default('MAIN'),
  
  // Relations
  supplierId: z.string().optional(),
  
  // Meta
  tags: z.string().default(''), // Comma-separated
  status: z.enum(['ACTIVE', 'PASSIVE']).default('ACTIVE'),
  createdAt: z.string(),
  updatedAt: z.string(),
})

export type StockCardInput = z.infer<typeof StockCardSchema>
