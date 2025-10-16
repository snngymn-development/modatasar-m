import { z } from 'zod'

export const TimeEntrySchema = z.object({
  id: z.string(),
  employeeId: z.string(),
  date: z.string(),
  startTime: z.string(),
  endTime: z.string(),
  breakDuration: z.number().min(0),
  totalHours: z.number().min(0),
  type: z.enum(['NORMAL', 'OVERTIME']),
  status: z.enum(['PENDING', 'APPROVED', 'REJECTED']),
  notes: z.string().optional(),
  createdAt: z.string(),
  updatedAt: z.string()
})

export type TimeEntryInput = z.infer<typeof TimeEntrySchema>
