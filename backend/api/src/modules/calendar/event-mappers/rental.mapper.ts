import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

@Injectable()
export class RentalEventMapper {
  constructor(private readonly prisma: PrismaService) {}

  async createRentalEvent(rentalId: string): Promise<void> {
    const rental = await this.prisma.rental.findUnique({
      where: { id: rentalId },
      include: { order: true }
    })

    if (!rental) return

    // Rental başlangıç tarihi için event oluştur
    await this.prisma.calendarEvent.create({
      data: {
        type: EventType.RENTAL,
        title: `Kiralama - ${rentalId}`,
        start: rental.start.toISOString(),
        end: rental.end.toISOString(),
        emoji: '🏷️',
        status: EventStatus.PLANNED,
        customerId: rental.order?.customerId,
        resourceId: rental.productId,
        sourceTable: 'rentals',
        sourceId: rental.id,
        payload: JSON.stringify({
          rentalId: rental.id,
          organization: rental.organization,
          orderId: rental.orderId
        }),
        createdBy: 'system'
      }
    })
  }

  async updateRentalEvent(rentalId: string): Promise<void> {
    // Önce mevcut event'i sil
    await this.prisma.calendarEvent.deleteMany({
      where: {
        sourceTable: 'rentals',
        sourceId: rentalId
      }
    })

    // Yeni event oluştur
    await this.createRentalEvent(rentalId)
  }

  async deleteRentalEvent(rentalId: string): Promise<void> {
    await this.prisma.calendarEvent.deleteMany({
      where: {
        sourceTable: 'rentals',
        sourceId: rentalId
      }
    })
  }
}
