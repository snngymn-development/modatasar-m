import type { ID } from '../types/common'
import type { EventType, EventStatus } from '../types/enums'

/**
 * CalendarEvent domain entity
 * Represents all calendar events (appointments, fittings, deliveries, rentals, payments, todos)
 * 
 * Unified model for all calendar activities with type-specific payload
 */
export interface CalendarEvent {
  id: ID
  type: EventType
  title: string
  start: string        // ISO 8601 date-time
  end?: string         // ISO 8601 date-time (for range events like RENTAL)
  emoji: string        // Visual representation emoji
  status?: EventStatus
  customerId?: ID      // Related customer
  assigneeId?: ID      // Assigned staff member
  resourceId?: ID      // Resource (product, room, etc.)
  sourceRef?: SourceReference // Reference to original record
  payload?: Record<string, any> // Type-specific data
  createdBy: ID        // User who created the event
  createdAt: string    // ISO 8601 date-time
}

/**
 * Source reference for automatic events
 */
export interface SourceReference {
  table: string  // Source table name (orders, rentals, payments, etc.)
  id: ID         // Source record ID
}

/**
 * Event taxonomy with emojis and colors
 */
export const EVENT_TAXONOMY: Record<EventType, { emoji: string; color: string; label: string }> = {
  APPOINTMENT: { emoji: '📅', color: 'blue', label: 'Randevu' },
  FITTING: { emoji: '👗', color: 'purple', label: 'Prova' },
  ORDER_DELIVERY: { emoji: '📦', color: 'orange', label: 'Teslim' },
  RENTAL: { emoji: '🏷️', color: 'yellow', label: 'Kiralama' },
  RECEIVABLE: { emoji: '💰', color: 'green', label: 'Tahsilat' },
  PAYABLE: { emoji: '🧾', color: 'brown', label: 'Personel Ödemesi' },
  TODO: { emoji: '✅', color: 'gray', label: 'Görev' }
}

/**
 * Reminder configuration
 */
export interface EventReminder {
  offsetMinutes: number  // Minutes before event
  channel: 'push' | 'email' | 'whatsapp' | 'sms'
}

/**
 * Event conflict information
 */
export interface EventConflict {
  id: ID
  type: EventType
  title: string
  start: string
  end: string
  assigneeId?: ID
  resourceId?: ID
  conflictType: 'assignee' | 'resource' | 'time'
}


/**
 * Calendar filter options
 */
export interface CalendarFilter {
  from?: string        // ISO date
  to?: string          // ISO date
  types?: EventType[]  // Event type filters
  assigneeIds?: ID[]   // Staff filters
  customerIds?: ID[]   // Customer filters
  resourceIds?: ID[]   // Resource filters
  status?: EventStatus[] // Status filters
  keyword?: string     // Search keyword
}

/**
 * Calendar statistics
 */
export interface CalendarStats {
  totalEvents: number
  eventsByType: Record<EventType, number>
  eventsByStatus: Record<EventStatus, number>
  upcomingEvents: number
  overdueEvents: number
}

/**
 * Heatmap data for analytics
 */
export interface CalendarHeatmap {
  date: string
  hour: number
  intensity: number  // 0-100
  eventCount: number
}
