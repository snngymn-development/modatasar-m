import { z } from 'zod'

export const AgendaEventSchema = z.object({
  id: z.string(),
  productId: z.string().min(1, 'Product ID is required'),
  type: z.enum(['DRY_CLEANING', 'ALTERATION', 'OUT_OF_SERVICE']),
  start: z.string(), // ISO 8601
  end: z.string(), // ISO 8601
  note: z.string().optional(),
  createdAt: z.string(),
})

export type AgendaEventInput = z.infer<typeof AgendaEventSchema>

