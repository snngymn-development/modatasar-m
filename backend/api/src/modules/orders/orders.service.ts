import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateOrderDto, UpdateOrderDto } from './dto'

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async create(createOrderDto: CreateOrderDto) {
    return this.prisma.order.create({ data: createOrderDto })
  }

  async findAll() {
    return this.prisma.order.findMany({ include: { customer: true } })
  }

  async findOne(id: string) {
    return this.prisma.order.findUnique({ where: { id }, include: { customer: true } })
  }

  async update(id: string, updateOrderDto: UpdateOrderDto) {
    return this.prisma.order.update({ where: { id }, data: updateOrderDto })
  }

  async remove(id: string) {
    return this.prisma.order.delete({ where: { id } })
  }
}