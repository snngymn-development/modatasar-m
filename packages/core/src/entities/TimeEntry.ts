import type { ID } from '../types/common'

/**
 * TimeEntry domain entity
 * Represents employee time tracking entries
 */
export interface TimeEntry {
  id: ID
  employeeId: ID
  date: string
  startTime: string
  endTime: string
  breakDuration: number // in minutes
  totalHours: number // calculated
  type: 'NORMAL' | 'OVERTIME'
  status: 'PENDING' | 'APPROVED' | 'REJECTED'
  notes?: string
  createdAt: string
  updatedAt: string
}
