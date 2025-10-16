import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { ListInventoryDto, InventoryDetailDto } from './dto'
import { Prisma } from '@prisma/client'

@Injectable()
export class InventoryService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(filters: ListInventoryDto): Promise<{ items: any[]; total: number; page: number; limit: number }> {
    const { q, category, color, size, status, tags, from, to, page = 1, limit = 25 } = filters
    
    // Build where clause
    const where: Prisma.ProductWhereInput = {}
    
    // Search query
    if (q) {
      where.OR = [
        { name: { contains: q } },
        { model: { contains: q } },
        { id: { contains: q } },
      ]
    }
    
    // Filters
    if (category) where.category = category
    if (color) where.color = color
    if (size) where.size = size
    if (status) where.status = status
    
    // Tags filter
    if (tags && tags.length > 0) {
      where.AND = tags.map(tag => ({
        tags: { contains: tag }
      }))
    }
    
    // Get total count
    const total = await this.prisma.product.count({ where })
    
    // Get paginated results
    const items = await this.prisma.product.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    })
    
    return {
      items: items.map(this.mapToInventoryItem),
      total,
      page,
      limit,
    }
  }

  async findOne(id: string): Promise<InventoryDetailDto> {
    const product = await this.prisma.product.findUnique({
      where: { id },
    })
    
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`)
    }
    
    // Get last activity (from rentals and agenda events)
    const lastActivity = await this.getLastActivity(id)
    
    return {
      id: product.id,
      name: product.name,
      model: product.model || undefined,
      color: product.color || undefined,
      size: product.size || undefined,
      category: product.category || undefined,
      tags: product.tags,
      status: product.status,
      createdAt: product.createdAt.toISOString(),
      lastActivity,
    }
  }

  private async getLastActivity(productId: string) {
    // Get last rental
    const lastRental = await this.prisma.rental.findFirst({
      where: { productId },
      orderBy: { order: { createdAt: 'desc' } },
      include: { order: { include: { customer: true } } }
    })
    
    // Get last agenda event
    const lastEvent = await this.prisma.agendaEvent.findFirst({
      where: { productId },
      orderBy: { createdAt: 'desc' }
    })
    
    // Determine most recent activity
    const activities = []
    if (lastRental) {
      activities.push({
        type: 'RENTAL',
        date: lastRental.order.createdAt.toISOString(),
        description: `Kiralama - ${lastRental.order.customer.name}`
      })
    }
    
    if (lastEvent) {
      activities.push({
        type: lastEvent.type,
        date: lastEvent.createdAt.toISOString(),
        description: this.getEventDescription(lastEvent)
      })
    }
    
    if (activities.length === 0) return undefined
    
    // Return most recent
    return activities.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())[0]
  }

  private getEventDescription(event: any): string {
    const typeMap: Record<string, string> = {
      'DRY_CLEANING': 'Kuru Temizleme',
      'ALTERATION': 'Alterasyon',
      'OUT_OF_SERVICE': 'Hizmet Dışı'
    }
    
    return `${typeMap[event.type] || event.type}${event.note ? ` - ${event.note}` : ''}`
  }

  private mapToInventoryItem(product: any) {
    return {
      id: product.id,
      name: product.name,
      model: product.model,
      color: product.color,
      size: product.size,
      category: product.category,
      tags: product.tags,
      status: product.status,
      createdAt: product.createdAt.toISOString(),
    }
  }
}
