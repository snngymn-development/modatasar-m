import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateCalendarEventDto, UpdateCalendarEventDto, CalendarFilterDto, ConflictCheckDto } from './dto'
import { EventType, EventStatus } from './dto'
import { Prisma } from '@prisma/client'
import { CalendarSeedService } from './seed/calendar-seed.service'

export interface CalendarEvent {
  id: string
  type: EventType
  title: string
  start: string
  end?: string
  emoji: string
  status: EventStatus
  customerId?: string
  assigneeId?: string
  resourceId?: string
  sourceRef?: {
    table: string
    id: string
  }
  payload?: Record<string, any>
  createdBy: string
  createdAt: string
}

@Injectable()
export class CalendarService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly seedService: CalendarSeedService
  ) {}

  async findAll(filters: CalendarFilterDto): Promise<{ events: CalendarEvent[]; total: number; page: number; limit: number }> {
    try {
      const { from, to, types, assigneeId, customerId, resourceId, query, page = 1, limit = 50 } = filters
      
      // Build where clause
      const where: Prisma.CalendarEventWhereInput = {}
      
      // Date range filter
      if (from || to) {
        where.start = {}
        if (from) where.start.gte = new Date(from)
        if (to) where.start.lte = new Date(to)
      }
      
      // Event types filter
      if (types && types.length > 0) {
        where.type = { in: types }
      }
      
      // Assignee filter
      if (assigneeId) {
        where.assigneeId = assigneeId
      }
      
      // Customer filter
      if (customerId) {
        where.customerId = customerId
      }
      
      // Resource filter
      if (resourceId) {
        where.resourceId = resourceId
      }
      
      // Search query
      if (query) {
        where.OR = [
          { title: { contains: query } },
          { emoji: { contains: query } },
        ]
      }
      
      // Get total count
      const total = await this.prisma.calendarEvent.count({ where })
      
      // Get paginated results
      const events = await this.prisma.calendarEvent.findMany({
        where,
        orderBy: { start: 'asc' },
        skip: (page - 1) * limit,
        take: limit,
      })
      
      return {
        events: events.map(this.mapToCalendarEvent),
        total,
        page,
        limit,
      }
    } catch (error) {
      console.error('CalendarService.findAll error:', error)
      throw new BadRequestException(`Failed to fetch calendar events: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  async findOne(id: string): Promise<CalendarEvent> {
    const event = await this.prisma.calendarEvent.findUnique({
      where: { id },
    })
    
    if (!event) {
      throw new NotFoundException(`Calendar event with ID ${id} not found`)
    }
    
    return this.mapToCalendarEvent(event)
  }

  async create(createDto: CreateCalendarEventDto, createdBy: string): Promise<CalendarEvent> {
    // Validate date range
    if (createDto.end && new Date(createDto.end) <= new Date(createDto.start)) {
      throw new BadRequestException('End date must be after start date')
    }
    
    const event = await this.prisma.calendarEvent.create({
      data: {
        ...createDto,
        createdBy,
        payload: createDto.payload ? JSON.stringify(createDto.payload) : null,
      },
    })
    
    return this.mapToCalendarEvent(event)
  }

  async update(id: string, updateDto: UpdateCalendarEventDto): Promise<CalendarEvent> {
    // Check if event exists
    const existingEvent = await this.prisma.calendarEvent.findUnique({
      where: { id },
    })
    
    if (!existingEvent) {
      throw new NotFoundException(`Calendar event with ID ${id} not found`)
    }
    
    // Validate date range
    if (updateDto.end && updateDto.start && new Date(updateDto.end) <= new Date(updateDto.start)) {
      throw new BadRequestException('End date must be after start date')
    }
    
    const event = await this.prisma.calendarEvent.update({
      where: { id },
      data: {
        ...updateDto,
        payload: updateDto.payload ? JSON.stringify(updateDto.payload) : undefined,
      },
    })
    
    return this.mapToCalendarEvent(event)
  }

  async remove(id: string): Promise<void> {
    const event = await this.prisma.calendarEvent.findUnique({
      where: { id },
    })
    
    if (!event) {
      throw new NotFoundException(`Calendar event with ID ${id} not found`)
    }
    
    await this.prisma.calendarEvent.delete({
      where: { id },
    })
  }

  async checkConflicts(conflictDto: ConflictCheckDto): Promise<{ hasConflicts: boolean; conflicts: any[] }> {
    const { start, end, assigneeId, resourceId, excludeEventId } = conflictDto
    
    const where: Prisma.CalendarEventWhereInput = {
      status: { not: EventStatus.CANCELLED },
      OR: [],
    }
    
    // Exclude current event if updating
    if (excludeEventId) {
      where.id = { not: excludeEventId }
    }
    
    // Check assignee conflicts
    if (assigneeId) {
      where.OR!.push({
        assigneeId,
        AND: [
          { start: { lt: new Date(end) } },
          { 
            OR: [
              { end: { gt: new Date(start) } },
              { end: null }
            ]
          }
        ]
      })
    }
    
    // Check resource conflicts
    if (resourceId) {
      where.OR!.push({
        resourceId,
        AND: [
          { start: { lt: new Date(end) } },
          { 
            OR: [
              { end: { gt: new Date(start) } },
              { end: null }
            ]
          }
        ]
      })
    }
    
    const conflicts = await this.prisma.calendarEvent.findMany({
      where,
      select: {
        id: true,
        type: true,
        title: true,
        start: true,
        end: true,
        assigneeId: true,
        resourceId: true,
      },
    })
    
    return {
      hasConflicts: conflicts.length > 0,
      conflicts: conflicts.map(conflict => ({
        ...conflict,
        conflictType: assigneeId && conflict.assigneeId ? 'assignee' : 'resource'
      }))
    }
  }

  private mapToCalendarEvent(event: any): CalendarEvent {
    return {
      id: event.id,
      type: event.type as EventType,
      title: event.title,
      start: event.start.toISOString(),
      end: event.end?.toISOString(),
      emoji: event.emoji,
      status: event.status as EventStatus,
      customerId: event.customerId,
      assigneeId: event.assigneeId,
      resourceId: event.resourceId,
      sourceRef: event.sourceTable && event.sourceId ? {
        table: event.sourceTable,
        id: event.sourceId,
      } : undefined,
      payload: event.payload ? JSON.parse(event.payload) : undefined,
      createdBy: event.createdBy,
      createdAt: event.createdAt.toISOString(),
    }
  }

  async seedTestData(): Promise<{ created: number }> {
    return this.seedService.seedTestData()
  }

  async clearTestData(): Promise<{ deleted: number }> {
    return this.seedService.clearTestData()
  }
}
