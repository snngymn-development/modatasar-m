import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

export interface CalendarMetrics {
  totalEvents: number
  eventsByType: Record<EventType, number>
  eventsByStatus: Record<EventStatus, number>
  eventsThisWeek: number
  eventsThisMonth: number
  completionRate: number
  averageEventDuration: number
  mostActiveDay: string
  mostActiveHour: number
  conflictCount: number
}

export interface EventTrends {
  daily: Array<{ date: string; count: number }>
  weekly: Array<{ week: string; count: number }>
  monthly: Array<{ month: string; count: number }>
}

@Injectable()
export class CalendarAnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getMetrics(dateRange?: { from: Date; to: Date }): Promise<CalendarMetrics> {
    const where = dateRange ? {
      start: {
        gte: dateRange.from,
        lte: dateRange.to
      }
    } : {}

    const events = await this.prisma.calendarEvent.findMany({
      where,
      select: {
        type: true,
        status: true,
        start: true,
        end: true
      }
    })

    const totalEvents = events.length
    const eventsByType = this.groupBy(events, 'type')
    const eventsByStatus = this.groupBy(events, 'status')
    
    const now = new Date()
    const weekStart = new Date(now.setDate(now.getDate() - now.getDay()))
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    
    const eventsThisWeek = events.filter(e => new Date(e.start) >= weekStart).length
    const eventsThisMonth = events.filter(e => new Date(e.start) >= monthStart).length
    
    const completedEvents = events.filter(e => e.status === EventStatus.DONE).length
    const completionRate = totalEvents > 0 ? (completedEvents / totalEvents) * 100 : 0
    
    const eventsWithDuration = events.filter(e => e.end)
    const averageEventDuration = eventsWithDuration.length > 0 
      ? eventsWithDuration.reduce((sum, e) => {
          const duration = new Date(e.end!).getTime() - new Date(e.start).getTime()
          return sum + duration
        }, 0) / eventsWithDuration.length / (1000 * 60) // minutes
      : 0

    const dayCounts = this.getDayCounts(events)
    const mostActiveDay = Object.keys(dayCounts).reduce((a, b) => 
      dayCounts[a] > dayCounts[b] ? a : b
    )

    const hourCounts = this.getHourCounts(events)
    const mostActiveHour = Object.keys(hourCounts).reduce((a, b) => 
      hourCounts[parseInt(a)] > hourCounts[parseInt(b)] ? a : b
    )

    // Conflict detection (simplified)
    const conflictCount = await this.detectConflicts(events)

    return {
      totalEvents,
      eventsByType: eventsByType as Record<EventType, number>,
      eventsByStatus: eventsByStatus as Record<EventStatus, number>,
      eventsThisWeek,
      eventsThisMonth,
      completionRate: Math.round(completionRate * 100) / 100,
      averageEventDuration: Math.round(averageEventDuration * 100) / 100,
      mostActiveDay,
      mostActiveHour: parseInt(mostActiveHour),
      conflictCount
    }
  }

  async getTrends(dateRange?: { from: Date; to: Date }): Promise<EventTrends> {
    const where = dateRange ? {
      start: {
        gte: dateRange.from,
        lte: dateRange.to
      }
    } : {}

    const events = await this.prisma.calendarEvent.findMany({
      where,
      select: {
        start: true,
        type: true
      },
      orderBy: { start: 'asc' }
    })

    const daily = this.groupEventsByPeriod(events, 'day') as Array<{ date: string; count: number }>
    const weekly = this.groupEventsByPeriod(events, 'week') as Array<{ week: string; count: number }>
    const monthly = this.groupEventsByPeriod(events, 'month') as Array<{ month: string; count: number }>

    return { daily, weekly, monthly }
  }

  private groupBy<T>(array: T[], key: keyof T): Record<string, number> {
    return array.reduce((groups, item) => {
      const group = String(item[key])
      groups[group] = (groups[group] || 0) + 1
      return groups
    }, {} as Record<string, number>)
  }

  private getDayCounts(events: any[]): Record<string, number> {
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar']
    const counts = days.reduce((acc, day) => ({ ...acc, [day]: 0 }), {} as Record<string, number>)
    
    events.forEach(event => {
      const dayOfWeek = new Date(event.start).getDay()
      const dayName = days[(dayOfWeek + 6) % 7] // Adjust for Monday start
      counts[dayName]++
    })
    
    return counts
  }

  private getHourCounts(events: any[]): Record<number, number> {
    const counts: Record<number, number> = {}
    
    events.forEach(event => {
      const hour = new Date(event.start).getHours()
      counts[hour] = (counts[hour] || 0) + 1
    })
    
    return counts
  }

  private groupEventsByPeriod(events: any[], period: 'day' | 'week' | 'month') {
    const groups: Record<string, number> = {}
    
    events.forEach(event => {
      const date = new Date(event.start)
      let key: string
      
      switch (period) {
        case 'day':
          key = date.toISOString().split('T')[0]
          break
        case 'week':
          const weekStart = new Date(date)
          weekStart.setDate(date.getDate() - date.getDay())
          key = weekStart.toISOString().split('T')[0]
          break
        case 'month':
          key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
          break
      }
      
      groups[key] = (groups[key] || 0) + 1
    })
    
    return Object.entries(groups).map(([period, count]) => {
      if (period === 'day') {
        return { date: period, count }
      } else if (period === 'week') {
        return { week: period, count }
      } else {
        return { month: period, count }
      }
    })
  }

  private async detectConflicts(events: any[]): Promise<number> {
    // Simplified conflict detection
    let conflicts = 0
    
    for (let i = 0; i < events.length; i++) {
      for (let j = i + 1; j < events.length; j++) {
        const event1 = events[i]
        const event2 = events[j]
        
        if (this.isTimeOverlapping(event1, event2)) {
          conflicts++
        }
      }
    }
    
    return conflicts
  }

  private isTimeOverlapping(event1: any, event2: any): boolean {
    const start1 = new Date(event1.start)
    const end1 = new Date(event1.end || event1.start)
    const start2 = new Date(event2.start)
    const end2 = new Date(event2.end || event2.start)

    return start1 < end2 && start2 < end1
  }
}
