import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { EventType, EventStatus } from './dto'

export interface ConflictInfo {
  id: string
  type: EventType
  title: string
  start: string
  end: string
  assigneeId?: string
  resourceId?: string
  conflictType: 'assignee' | 'resource' | 'time'
}

@Injectable()
export class ConflictDetectionService {
  constructor(private readonly prisma: PrismaService) {}

  async detectConflicts(params: {
    start: string
    end: string
    assigneeId?: string
    resourceId?: string
    excludeEventId?: string
  }): Promise<ConflictInfo[]> {
    const { start, end, assigneeId, resourceId, excludeEventId } = params
    const conflicts: ConflictInfo[] = []

    const commonWhere = {
      AND: [
        { start: { lt: new Date(end) } },
        { end: { gt: new Date(start) } },
      ],
      id: excludeEventId ? { not: excludeEventId } : undefined,
    }

    if (assigneeId) {
      const assigneeConflicts = await this.prisma.calendarEvent.findMany({
        where: {
          ...commonWhere,
          assigneeId,
        },
      })
      
      assigneeConflicts.forEach(event => {
        conflicts.push({
          id: event.id,
          type: event.type as EventType,
          title: event.title,
          start: event.start.toISOString(),
          end: event.end?.toISOString() || event.start.toISOString(),
          assigneeId: event.assigneeId || undefined,
          resourceId: event.resourceId || undefined,
          conflictType: 'assignee'
        })
      })
    }

    if (resourceId) {
      const resourceConflicts = await this.prisma.calendarEvent.findMany({
        where: {
          ...commonWhere,
          resourceId,
        },
      })
      
      resourceConflicts.forEach(event => {
        conflicts.push({
          id: event.id,
          type: event.type as EventType,
          title: event.title,
          start: event.start.toISOString(),
          end: event.end?.toISOString() || event.start.toISOString(),
          assigneeId: event.assigneeId || undefined,
          resourceId: event.resourceId || undefined,
          conflictType: 'resource'
        })
      })
    }

    return conflicts
  }

  async checkTimeConflicts(params: {
    start: string
    end: string
    excludeEventId?: string
  }): Promise<ConflictInfo[]> {
    const { start, end, excludeEventId } = params
    
    const timeConflicts = await this.prisma.calendarEvent.findMany({
      where: {
        AND: [
          { start: { lt: new Date(end) } },
          { end: { gt: new Date(start) } },
        ],
        id: excludeEventId ? { not: excludeEventId } : undefined,
      },
    })

    return timeConflicts.map(event => ({
      id: event.id,
      type: event.type as EventType,
      title: event.title,
      start: event.start.toISOString(),
      end: event.end?.toISOString() || event.start.toISOString(),
      assigneeId: event.assigneeId || undefined,
      resourceId: event.resourceId || undefined,
      conflictType: 'time' as const
    }))
  }
}