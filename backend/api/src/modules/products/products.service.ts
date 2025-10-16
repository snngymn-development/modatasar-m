import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateProductDto, UpdateProductDto } from './dto'

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateProductDto) {
    return this.prisma.product.create({
      data: {
        ...dto,
        tags: dto.tags?.join(',') || '',
      },
    })
  }

  async findAll() {
    const products = await this.prisma.product.findMany({
      orderBy: { createdAt: 'desc' },
    })

    return products.map((p) => ({
      ...p,
      tags: p.tags ? p.tags.split(',').filter(Boolean) : [],
    }))
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
    })

    if (!product) {
      throw new NotFoundException(`Product #${id} not found`)
    }

    return {
      ...product,
      tags: product.tags ? product.tags.split(',').filter(Boolean) : [],
    }
  }

  async update(id: string, dto: UpdateProductDto) {
    await this.findOne(id) // Validate exists

    return this.prisma.product.update({
      where: { id },
      data: {
        ...dto,
        tags: dto.tags ? dto.tags.join(',') : undefined,
      },
    })
  }

  async remove(id: string) {
    await this.findOne(id) // Validate exists

    return this.prisma.product.delete({
      where: { id },
    })
  }
}

