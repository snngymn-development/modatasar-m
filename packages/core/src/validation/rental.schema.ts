import { z } from 'zod'

export const RentalSchema = z.object({
  id: z.string(),
  orderId: z.string().min(1, 'Order ID is required'),
  productId: z.string().min(1, 'Product ID is required'),
  period: z.object({
    start: z.string(), // ISO 8601
    end: z.string(), // ISO 8601
  }),
  organization: z.string().optional(),
})

export type RentalInput = z.infer<typeof RentalSchema>

