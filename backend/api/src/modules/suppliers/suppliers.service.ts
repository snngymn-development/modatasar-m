import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateSupplierDto, UpdateSupplierDto } from './dto'

@Injectable()
export class SuppliersService {
  constructor(private prisma: PrismaService) {}

  async create(createSupplierDto: CreateSupplierDto) {
    return this.prisma.supplier.create({ data: createSupplierDto })
  }

  async findAll(filters?: {
    name?: string
    phone?: string
    city?: string
    category?: string
    status?: string
    page?: number
    limit?: number
    sort?: string
  }) {
    const where: any = {}
    
    if (filters?.name) {
      where.name = { contains: filters.name, mode: 'insensitive' }
    }
    if (filters?.phone) {
      where.phone = { contains: filters.phone, mode: 'insensitive' }
    }
    if (filters?.city) {
      where.city = { contains: filters.city, mode: 'insensitive' }
    }
    if (filters?.category) {
      where.category = filters.category
    }
    if (filters?.status) {
      where.status = filters.status
    }

    const page = filters?.page || 1
    const limit = filters?.limit || 25
    const skip = (page - 1) * limit

    const [suppliers, total] = await Promise.all([
      this.prisma.supplier.findMany({
        where,
        skip,
        take: limit,
        orderBy: this.getOrderBy(filters?.sort)
      }),
      this.prisma.supplier.count({ where })
    ])

    return {
      data: suppliers,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit)
    }
  }

  async findOne(id: string) {
    const supplier = await this.prisma.supplier.findUnique({ where: { id } })
    if (!supplier) {
      throw new NotFoundException(`Supplier #${id} not found`)
    }
    return supplier
  }

  async findDetail(id: string) {
    const supplier = await this.prisma.supplier.findUnique({ 
      where: { id },
      include: {
        // İleride priceLists, payments gibi ilişkiler eklenebilir
      }
    })
    if (!supplier) {
      throw new NotFoundException(`Supplier #${id} not found`)
    }
    return supplier
  }

  async update(id: string, updateSupplierDto: UpdateSupplierDto) {
    return this.prisma.supplier.update({ 
      where: { id }, 
      data: updateSupplierDto 
    })
  }

  async remove(id: string) {
    return this.prisma.supplier.delete({ where: { id } })
  }

  private getOrderBy(sort?: string) {
    if (!sort) return { createdAt: 'desc' as const }
    
    const [field, direction] = sort.split(':')
    return { [field]: (direction || 'desc') as 'asc' | 'desc' }
  }
}
