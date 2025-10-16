import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../common/prisma.service'
import { EventType, EventStatus } from '../dto'

@Injectable()
export class PaymentEventMapper {
  constructor(private readonly prisma: PrismaService) {}

  async createPaymentEvent(transactionId: string): Promise<void> {
    // Transaction model'i yok, şimdilik boş bırakıyoruz
    return
  }

  async updatePaymentEvent(transactionId: string): Promise<void> {
    // Transaction model'i yok, şimdilik boş bırakıyoruz
    return
  }

  async deletePaymentEvent(transactionId: string): Promise<void> {
    // Transaction model'i yok, şimdilik boş bırakıyoruz
    return
  }
}
