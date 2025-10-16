import { z } from 'zod'

export const ProductSchema = z.object({
  id: z.string(),
  name: z.string().min(1, 'Product name is required'),
  model: z.string().optional(),
  color: z.string().optional(),
  size: z.string().optional(),
  category: z.string().optional(),
  tags: z.string().default(''), // Comma-separated
  status: z.enum(['AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE']).default('AVAILABLE'),
  createdAt: z.string(),
})

export type ProductInput = z.infer<typeof ProductSchema>

