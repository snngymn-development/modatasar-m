import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { FindTransactionsDto } from './dto'

@Injectable()
export class TransactionsService {
  constructor(private prisma: PrismaService) {}

  async findMany(query: FindTransactionsDto) {
    // Build where clause
    const where: any = {
      type: query.type ? { in: [].concat(query.type as any) } : undefined,
      customerId: query.customerId,
      organization: query.organization,
      status: query.status ? { in: [].concat(query.status as any) } : undefined,
    }

    // Fetch orders with rental JOIN
    const orders = await this.prisma.order.findMany({
      where,
      include: {
        rental: true,
        customer: true,
      },
      orderBy: { createdAt: 'desc' },
      take: query.limit ?? 20,
      skip: query.page ? (query.page - 1) * (query.limit ?? 20) : 0,
    })

    // Map to response DTO
    const items = orders.map((o) => ({
      id: o.id,
      type: o.type,
      createdAt: o.createdAt.toISOString(),
      deliveryDate: o.deliveryDate?.toISOString() || null,
      rental: o.rental
        ? {
            start: o.rental.start.toISOString(),
            end: o.rental.end.toISOString(),
            productId: o.rental.productId,
          }
        : null,
      customer: {
        id: o.customer.id,
        name: o.customer.name,
      },
      organization: o.organization,
      total: o.total,
      collected: o.collected,
      balance: o.total - o.collected,
      status: o.status,
      stage: o.stage,
    }))

    // Count total for pagination
    const total = await this.prisma.order.count({ where })

    return {
      items,
      total,
      page: query.page ?? 1,
      pageSize: query.limit ?? 20,
      totalPages: Math.ceil(total / (query.limit ?? 20)),
    }
  }

  async getSummary() {
    const [tailoringCount, rentalCount] = await Promise.all([
      this.prisma.order.count({
        where: { type: 'TAILORING', status: 'ACTIVE' },
      }),
      this.prisma.order.count({
        where: { type: 'RENTAL', status: 'ACTIVE' },
      }),
    ])

    return {
      tailoringCount,
      rentalCount,
      totalCount: tailoringCount + rentalCount,
    }
  }
}

