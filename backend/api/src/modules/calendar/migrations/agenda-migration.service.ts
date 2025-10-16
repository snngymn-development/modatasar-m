import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

@Injectable()
export class AgendaMigrationService {
  constructor(private readonly prisma: PrismaService) {}

  async migrateAgendaEvents(): Promise<{ migrated: number; errors: number }> {
    let migrated = 0
    let errors = 0

    try {
      // Tüm AgendaEvent'leri al
      const agendaEvents = await this.prisma.agendaEvent.findMany()

      for (const agendaEvent of agendaEvents) {
        try {
          // AgendaEvent türünü CalendarEvent türüne çevir
          const calendarEventType = this.mapAgendaTypeToCalendarType(agendaEvent.type)
          
          // CalendarEvent oluştur
          await this.prisma.calendarEvent.create({
            data: {
              type: calendarEventType,
              title: this.generateEventTitle(agendaEvent.type, agendaEvent.productId),
              start: agendaEvent.start.toISOString(),
              end: agendaEvent.end.toISOString(),
              emoji: this.getEventEmoji(agendaEvent.type),
              status: EventStatus.PLANNED,
              resourceId: agendaEvent.productId,
              sourceTable: 'agenda_events',
              sourceId: agendaEvent.id,
              payload: JSON.stringify({
                originalType: agendaEvent.type,
                note: agendaEvent.note
              }),
              createdBy: 'migration'
            }
          })

          migrated++
        } catch (error) {
          console.error(`Error migrating agenda event ${agendaEvent.id}:`, error)
          errors++
        }
      }

      return { migrated, errors }
    } catch (error) {
      console.error('Migration failed:', error)
      throw error
    }
  }

  private mapAgendaTypeToCalendarType(agendaType: string): EventType {
    switch (agendaType) {
      case 'DRY_CLEANING':
        return EventType.TODO // Temizlik görevi olarak
      case 'ALTERATION':
        return EventType.TODO // Tadilat görevi olarak
      case 'OUT_OF_SERVICE':
        return EventType.TODO // Bakım görevi olarak
      default:
        return EventType.TODO
    }
  }

  private generateEventTitle(agendaType: string, productId: string): string {
    const typeLabels = {
      'DRY_CLEANING': 'Kuru Temizleme',
      'ALTERATION': 'Tadilat',
      'OUT_OF_SERVICE': 'Bakım'
    }
    
    return `${typeLabels[agendaType as keyof typeof typeLabels] || 'Görev'} - ${productId}`
  }

  private getEventEmoji(agendaType: string): string {
    switch (agendaType) {
      case 'DRY_CLEANING':
        return '🧼'
      case 'ALTERATION':
        return '✂️'
      case 'OUT_OF_SERVICE':
        return '🔧'
      default:
        return '✅'
    }
  }

  async cleanupAgendaEvents(): Promise<void> {
    // Migration tamamlandıktan sonra AgendaEvent'leri sil
    await this.prisma.agendaEvent.deleteMany()
  }
}
