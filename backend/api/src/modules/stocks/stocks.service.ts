import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { ListStocksDto, ConsumeStockDto, AdjustStockDto, ListMovementsDto } from './dto'
import { Prisma } from '@prisma/client'

@Injectable()
export class StocksService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(filters: ListStocksDto): Promise<{ items: any[]; total: number; page: number; limit: number }> {
    const { q, supplierId, category, type, kind, group, location, unit, belowCritical, tags, status, page = 1, limit = 25 } = filters
    
    // Build where clause
    const where: Prisma.StockCardWhereInput = {}
    
    // Search query
    if (q) {
      where.OR = [
        { code: { contains: q } },
        { name: { contains: q } },
      ]
    }
    
    // Filters
    if (supplierId) where.supplierId = supplierId
    if (category) where.category = category
    if (type) where.type = type
    if (kind) where.kind = kind
    if (group) where.group = group
    if (location) where.location = location
    if (unit) where.unit = unit
    if (status) where.status = status
    
    // Tags filter
    if (tags && tags.length > 0) {
      where.AND = tags.map(tag => ({
        tags: { contains: tag }
      }))
    }
    
    // Get total count
    const total = await this.prisma.stockCard.count({ where })
    
    // Get paginated results
    const items = await this.prisma.stockCard.findMany({
      where,
      include: {
        supplier: true,
        movements: {
          orderBy: { date: 'desc' },
          take: 1
        }
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    })
    
    // Calculate current quantities and filter by critical level
    const processedItems = items.map(item => {
      const currentQty = this.calculateCurrentQuantity(item.movements)
      const isBelowCritical = belowCritical ? currentQty <= item.criticalQty : true
      
      return {
        ...item,
        currentQty,
        isBelowCritical,
        lastMovement: item.movements[0] || null
      }
    }).filter(item => !belowCritical || item.isBelowCritical)
    
    return {
      items: processedItems.map(this.mapToStockItem),
      total: belowCritical ? processedItems.length : total,
      page,
      limit,
    }
  }

  async findOne(id: string) {
    const stockCard = await this.prisma.stockCard.findUnique({
      where: { id },
      include: {
        supplier: true,
        movements: {
          orderBy: { date: 'desc' },
          take: 10
        }
      }
    })
    
    if (!stockCard) {
      throw new NotFoundException(`Stock card with ID ${id} not found`)
    }
    
    const currentQty = this.calculateCurrentQuantity(stockCard.movements)
    
    return {
      ...stockCard,
      currentQty,
      isBelowCritical: currentQty <= stockCard.criticalQty
    }
  }

  async getMovements(id: string, filters: ListMovementsDto) {
    const { from, to, page = 1, limit = 25 } = filters
    
    const where: Prisma.StockMovementWhereInput = {
      stockCardId: id
    }
    
    // Date range filter
    if (from || to) {
      where.date = {}
      if (from) where.date.gte = new Date(from)
      if (to) where.date.lte = new Date(to)
    }
    
    const total = await this.prisma.stockMovement.count({ where })
    
    const movements = await this.prisma.stockMovement.findMany({
      where,
      orderBy: { date: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    })
    
    return {
      movements: movements.map(this.mapToMovement),
      total,
      page,
      limit,
    }
  }

  async consume(id: string, dto: ConsumeStockDto, userId: string) {
    return this.prisma.$transaction(async (tx) => {
      // Get current stock card
      const stockCard = await tx.stockCard.findUnique({
        where: { id },
        include: { movements: true }
      })
      
      if (!stockCard) {
        throw new NotFoundException(`Stock card with ID ${id} not found`)
      }
      
      // Calculate current quantity
      const currentQty = this.calculateCurrentQuantity(stockCard.movements)
      
      // Check if we have enough stock
      if (currentQty < dto.qty) {
        throw new BadRequestException(`Insufficient stock. Available: ${currentQty}, Requested: ${dto.qty}`)
      }
      
      // Create OUT movement
      const movement = await tx.stockMovement.create({
        data: {
          type: 'OUT',
          stockCardId: id,
          qty: dto.qty,
          unit: dto.unit,
          referenceType: dto.referenceType,
          referenceId: dto.referenceId,
          note: dto.note,
          createdBy: userId,
        }
      })
      
      return movement
    })
  }

  async adjust(id: string, dto: AdjustStockDto, userId: string) {
    return this.prisma.$transaction(async (tx) => {
      // Get current stock card
      const stockCard = await tx.stockCard.findUnique({
        where: { id },
        include: { movements: true }
      })
      
      if (!stockCard) {
        throw new NotFoundException(`Stock card with ID ${id} not found`)
      }
      
      // Calculate current quantity
      const currentQty = this.calculateCurrentQuantity(stockCard.movements)
      
      // Calculate difference
      const diff = dto.newQty - currentQty
      
      // If no change needed, return
      if (diff === 0) {
        return { message: 'No adjustment needed', currentQty }
      }
      
      // Create ADJUST movement
      const movement = await tx.stockMovement.create({
        data: {
          type: 'ADJUST',
          stockCardId: id,
          qty: Math.abs(diff),
          unit: stockCard.unit,
          note: `Adjustment: ${dto.reason}${dto.note ? ` - ${dto.note}` : ''}`,
          createdBy: userId,
        }
      })
      
      return {
        movement,
        oldQty: currentQty,
        newQty: dto.newQty,
        diff
      }
    })
  }

  private calculateCurrentQuantity(movements: any[]): number {
    return movements.reduce((total, movement) => {
      switch (movement.type) {
        case 'IN':
          return total + movement.qty
        case 'OUT':
          return total - movement.qty
        case 'ADJUST':
          // ADJUST movements represent the final quantity, not a difference
          return movement.qty
        default:
          return total
      }
    }, 0)
  }

  private mapToStockItem = (item: any) => {
    try {
      return {
        id: item.id,
        code: item.code,
        name: item.name,
        description: item.description,
        category: item.category,
        type: item.type,
        kind: item.kind,
        group: item.group,
        unit: item.unit,
        criticalQty: item.criticalQty,
        location: item.location,
        supplier: item.supplier ? {
          id: item.supplier.id,
          name: item.supplier.name
        } : null,
        tags: item.tags,
        status: item.status,
        currentQty: item.currentQty || 0,
        isBelowCritical: item.isBelowCritical || false,
        lastMovement: item.lastMovement ? this.mapToMovement(item.lastMovement) : null,
        createdAt: item.createdAt ? item.createdAt.toISOString() : new Date().toISOString(),
      }
    } catch (error) {
      console.error('Error mapping stock item:', error, item)
      return {
        id: item.id || 'unknown',
        code: item.code || '',
        name: item.name || 'Unknown',
        description: item.description || '',
        category: item.category || '',
        type: item.type || '',
        kind: item.kind || '',
        group: item.group || '',
        unit: item.unit || 'adet',
        criticalQty: item.criticalQty || 0,
        location: item.location || 'MAIN',
        supplier: null,
        tags: item.tags || '',
        status: item.status || 'ACTIVE',
        currentQty: 0,
        isBelowCritical: false,
        lastMovement: null,
        createdAt: new Date().toISOString(),
      }
    }
  }

  private mapToMovement = (movement: any) => {
    return {
      id: movement.id,
      type: movement.type,
      qty: movement.qty,
      unit: movement.unit,
      warehouse: movement.warehouse,
      date: movement.date.toISOString(),
      note: movement.note,
      referenceType: movement.referenceType,
      referenceId: movement.referenceId,
      createdBy: movement.createdBy,
    }
  }
}
