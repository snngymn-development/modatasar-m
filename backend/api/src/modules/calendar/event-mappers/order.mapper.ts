import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

@Injectable()
export class OrderEventMapper {
  constructor(private readonly prisma: PrismaService) {}

  async createOrderDeliveryEvent(orderId: string): Promise<void> {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: { customer: true }
    })

    if (!order || !order.deliveryDate) return

    await this.prisma.calendarEvent.create({
      data: {
        type: EventType.ORDER_DELIVERY,
        title: `${order.customer?.name || 'Müşteri'} - Sipariş Teslimi`,
        start: order.deliveryDate.toISOString(),
        emoji: '📦',
        status: EventStatus.PLANNED,
        customerId: order.customerId,
        sourceTable: 'orders',
        sourceId: order.id,
        payload: JSON.stringify({
          orderId: order.id,
          orderType: order.type,
          totalAmount: order.total
        }),
        createdBy: 'system'
      }
    })
  }

  async updateOrderDeliveryEvent(orderId: string): Promise<void> {
    // Önce mevcut event'i sil
    await this.prisma.calendarEvent.deleteMany({
      where: {
        sourceTable: 'orders',
        sourceId: orderId
      }
    })

    // Yeni event oluştur (eğer delivery date varsa)
    await this.createOrderDeliveryEvent(orderId)
  }

  async deleteOrderDeliveryEvent(orderId: string): Promise<void> {
    await this.prisma.calendarEvent.deleteMany({
      where: {
        sourceTable: 'orders',
        sourceId: orderId
      }
    })
  }
}
