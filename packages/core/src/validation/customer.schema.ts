import { z } from 'zod'
export const CustomerSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(2),
  phone: z.string().optional(),
  email: z.string().email().optional()
})

