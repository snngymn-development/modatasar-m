import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

@Injectable()
export class CalendarSeedService {
  constructor(private readonly prisma: PrismaService) {}

  async seedTestData(): Promise<{ created: number }> {
    const testEvents = [
      // Bugün
      {
        type: EventType.APPOINTMENT,
        title: 'Müşteri Görüşmesi - Ayşe Yılmaz',
        start: new Date().toISOString(),
        emoji: '📅',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-1',
        payload: { notes: 'Yeni kıyafet siparişi' }
      },
      {
        type: EventType.TODO,
        title: 'Stok Kontrolü',
        start: new Date().toISOString(),
        emoji: '✅',
        status: EventStatus.PLANNED,
        payload: { priority: 'high' }
      },
      
      // Yarın
      {
        type: EventType.FITTING,
        title: 'Prova - Mehmet Kaya',
        start: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        emoji: '👗',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-2',
        payload: { product: 'Smokin Takım', size: 'L' }
      },
      {
        type: EventType.RECEIVABLE,
        title: 'Tahsilat - Fatma Demir',
        start: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        emoji: '💰',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-3',
        payload: { amount: 50000, currency: 'TRY' }
      },
      
      // 2 gün sonra
      {
        type: EventType.RENTAL,
        title: 'Kiralama - Ali Veli',
        start: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
        end: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '🏷️',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-4',
        resourceId: 'STK-001',
        payload: { product: 'Classic Smokin Takım', duration: 3 }
      },
      
      // 3 gün sonra
      {
        type: EventType.ORDER_DELIVERY,
        title: 'Sipariş Teslimi - Zeynep Öz',
        start: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '📦',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-5',
        payload: { orderId: 'ORD-001', items: ['Elbise', 'Ayakkabı'] }
      },
      
      // 4 gün sonra
      {
        type: EventType.PAYABLE,
        title: 'Personel Ödemesi - Terzi Maaşı',
        start: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '🧾',
        status: EventStatus.PLANNED,
        assigneeId: 'staff-1',
        payload: { amount: 150000, type: 'salary' }
      },
      
      // 5 gün sonra
      {
        type: EventType.APPOINTMENT,
        title: 'Müşteri Görüşmesi - Can Yılmaz',
        start: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '📅',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-6',
        payload: { notes: 'Düğün kıyafeti' }
      },
      
      // 6 gün sonra
      {
        type: EventType.FITTING,
        title: 'Prova - Elif Kaya',
        start: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '👗',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-7',
        payload: { product: 'Gece Elbisesi', size: 'M' }
      },
      
      // 7 gün sonra
      {
        type: EventType.RENTAL,
        title: 'Kiralama - Ahmet Demir',
        start: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        end: new Date(Date.now() + 9 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '🏷️',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-8',
        resourceId: 'STK-002',
        payload: { product: 'Modern Slim Fit', duration: 3 }
      },
      
      // Geçmiş (tamamlanmış)
      {
        type: EventType.APPOINTMENT,
        title: 'Müşteri Görüşmesi - Sema Yıldız',
        start: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '📅',
        status: EventStatus.DONE,
        customerId: 'test-customer-9',
        payload: { notes: 'Tamamlandı' }
      },
      
      // Geçmiş (iptal)
      {
        type: EventType.FITTING,
        title: 'Prova - Murat Öz',
        start: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
        emoji: '👗',
        status: EventStatus.CANCELLED,
        customerId: 'test-customer-10',
        payload: { reason: 'Müşteri iptal etti' }
      }
    ]

    let created = 0
    for (const eventData of testEvents) {
      try {
        await this.prisma.calendarEvent.create({
          data: {
            ...eventData,
            payload: JSON.stringify(eventData.payload || {}),
            createdBy: 'seed-service'
          }
        })
        created++
      } catch (error) {
        console.error('Error creating test event:', error)
      }
    }

    return { created }
  }

  async clearTestData(): Promise<{ deleted: number }> {
    const result = await this.prisma.calendarEvent.deleteMany({
      where: {
        createdBy: 'seed-service'
      }
    })

    return { deleted: result.count }
  }
}
