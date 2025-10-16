import { z } from 'zod'

// Event types and statuses (local definitions to avoid circular imports)
const EventType = {
  APPOINTMENT: 'APPOINTMENT',
  FITTING: 'FITTING',
  ORDER_DELIVERY: 'ORDER_DELIVERY',
  RENTAL: 'RENTAL',
  RECEIVABLE: 'RECEIVABLE',
  PAYABLE: 'PAYABLE',
  TODO: 'TODO',
} as const

const EventStatus = {
  PLANNED: 'PLANNED',
  DONE: 'DONE',
  CANCELLED: 'CANCELLED',
} as const

/**
 * CalendarEvent validation schema
 * Validates all calendar events with type-specific rules
 */

// Source reference validation
const SourceReferenceSchema = z.object({
  table: z.string().min(1, 'Table name is required'),
  id: z.string().min(1, 'Source ID is required')
})

// Event reminder validation
const EventReminderSchema = z.object({
  offsetMinutes: z.number().int().min(0, 'Offset must be non-negative'),
  channel: z.enum(['push', 'email', 'whatsapp', 'sms'])
})

// Main CalendarEvent schema
export const CalendarEventSchema = z.object({
  id: z.string().min(1, 'ID is required'),
  type: z.enum(Object.values(EventType) as [string, ...string[]], { 
    errorMap: () => ({ message: 'Invalid event type' }) 
  }),
  title: z.string().min(1, 'Title is required').max(200, 'Title too long'),
  start: z.string().datetime('Invalid start date format'),
  end: z.string().datetime('Invalid end date format').optional(),
  emoji: z.string().min(1, 'Emoji is required').max(10, 'Emoji too long'),
  status: z.enum(Object.values(EventStatus) as [string, ...string[]]).optional().default(EventStatus.PLANNED),
  customerId: z.string().min(1, 'Customer ID is required').optional(),
  assigneeId: z.string().min(1, 'Assignee ID is required').optional(),
  resourceId: z.string().min(1, 'Resource ID is required').optional(),
  sourceRef: SourceReferenceSchema.optional(),
  payload: z.record(z.any()).optional(),
  createdBy: z.string().min(1, 'Created by is required'),
  createdAt: z.string().datetime('Invalid created date format')
})

// Create CalendarEvent schema (without id, createdAt)
export const CreateCalendarEventSchema = CalendarEventSchema.omit({
  id: true,
  createdAt: true
}).extend({
  reminders: z.array(EventReminderSchema).optional()
})

// Update CalendarEvent schema (partial)
export const UpdateCalendarEventSchema = CalendarEventSchema.partial().omit({
  id: true,
  createdBy: true,
  createdAt: true
})

// Calendar filter schema
export const CalendarFilterSchema = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  types: z.array(z.enum(Object.values(EventType) as [string, ...string[]])).optional(),
  assigneeIds: z.array(z.string()).optional(),
  customerIds: z.array(z.string()).optional(),
  resourceIds: z.array(z.string()).optional(),
  status: z.array(z.enum(Object.values(EventStatus) as [string, ...string[]])).optional(),
  keyword: z.string().optional()
})

// Conflict check schema
export const ConflictCheckSchema = z.object({
  assigneeId: z.string().optional(),
  resourceId: z.string().optional(),
  start: z.string().datetime(),
  end: z.string().datetime(),
  excludeEventId: z.string().optional()
})

// Type-specific validation schemas
export const AppointmentEventSchema = CreateCalendarEventSchema.extend({
  type: z.literal(EventType.APPOINTMENT),
  customerId: z.string().min(1, 'Customer is required for appointments'),
  assigneeId: z.string().min(1, 'Assignee is required for appointments'),
  end: z.string().datetime().optional() // Default to 30 minutes if not provided
})

export const FittingEventSchema = CreateCalendarEventSchema.extend({
  type: z.literal(EventType.FITTING),
  customerId: z.string().min(1, 'Customer is required for fittings'),
  assigneeId: z.string().min(1, 'Assignee is required for fittings'),
  resourceId: z.string().min(1, 'Product is required for fittings'),
  end: z.string().datetime().optional() // Default to 45 minutes if not provided
})

export const TodoEventSchema = CreateCalendarEventSchema.extend({
  type: z.literal(EventType.TODO),
  assigneeId: z.string().min(1, 'Assignee is required for todos'),
  end: z.string().datetime().optional() // Can be single-day event
})

export const RentalEventSchema = CreateCalendarEventSchema.extend({
  type: z.literal(EventType.RENTAL),
  customerId: z.string().min(1, 'Customer is required for rentals'),
  resourceId: z.string().min(1, 'Product is required for rentals'),
  end: z.string().datetime('End date is required for rentals')
})

export const PaymentEventSchema = CreateCalendarEventSchema.extend({
  type: z.union([z.literal(EventType.RECEIVABLE), z.literal(EventType.PAYABLE)]),
  customerId: z.string().min(1, 'Customer is required for payments').optional(),
  assigneeId: z.string().min(1, 'Assignee is required for payments').optional(),
  payload: z.object({
    amount: z.number().int().min(0, 'Amount must be positive'),
    currency: z.string().default('TRY'),
    paymentMethod: z.string().optional(),
    reference: z.string().optional()
  })
})

export const DeliveryEventSchema = CreateCalendarEventSchema.extend({
  type: z.literal(EventType.ORDER_DELIVERY),
  customerId: z.string().min(1, 'Customer is required for deliveries'),
  sourceRef: SourceReferenceSchema,
  end: z.string().datetime().optional() // Default to same day
})

// Type inference
export type CalendarEventInput = z.infer<typeof CalendarEventSchema>
export type CreateCalendarEventInput = z.infer<typeof CreateCalendarEventSchema>
export type UpdateCalendarEventInput = z.infer<typeof UpdateCalendarEventSchema>
export type CalendarFilterInput = z.infer<typeof CalendarFilterSchema>
export type ConflictCheckInput = z.infer<typeof ConflictCheckSchema>

// Type-specific inputs
export type AppointmentEventInput = z.infer<typeof AppointmentEventSchema>
export type FittingEventInput = z.infer<typeof FittingEventSchema>
export type TodoEventInput = z.infer<typeof TodoEventSchema>
export type RentalEventInput = z.infer<typeof RentalEventSchema>
export type PaymentEventInput = z.infer<typeof PaymentEventSchema>
export type DeliveryEventInput = z.infer<typeof DeliveryEventSchema>

// Validation helper functions
export const validateCalendarEvent = (data: unknown) => {
  return CalendarEventSchema.safeParse(data)
}

export const validateCreateCalendarEvent = (data: unknown) => {
  return CreateCalendarEventSchema.safeParse(data)
}

export const validateUpdateCalendarEvent = (data: unknown) => {
  return UpdateCalendarEventSchema.safeParse(data)
}

export const validateCalendarFilter = (data: unknown) => {
  return CalendarFilterSchema.safeParse(data)
}

export const validateConflictCheck = (data: unknown) => {
  return ConflictCheckSchema.safeParse(data)
}

// Type-specific validation helpers
export const validateAppointmentEvent = (data: unknown) => {
  return AppointmentEventSchema.safeParse(data)
}

export const validateFittingEvent = (data: unknown) => {
  return FittingEventSchema.safeParse(data)
}

export const validateTodoEvent = (data: unknown) => {
  return TodoEventSchema.safeParse(data)
}

export const validateRentalEvent = (data: unknown) => {
  return RentalEventSchema.safeParse(data)
}

export const validatePaymentEvent = (data: unknown) => {
  return PaymentEventSchema.safeParse(data)
}

export const validateDeliveryEvent = (data: unknown) => {
  return DeliveryEventSchema.safeParse(data)
}
