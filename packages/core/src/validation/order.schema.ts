import { z } from 'zod'

export const OrderSchema = z.object({
  id: z.string(),
  type: z.enum(['SALE', 'RENTAL']),
  customerId: z.string(),
  organization: z.string().optional(),
  deliveryDate: z.string().optional(),
  total: z.number().nonnegative('Total must be non-negative'),
  collected: z.number().nonnegative('Collected must be non-negative'),
  status: z.enum(['ACTIVE', 'CANCELLED', 'COMPLETED']),
  stage: z.string().optional(),
  createdAt: z.string(),
})

export type OrderInput = z.infer<typeof OrderSchema>

