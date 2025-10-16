import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateCustomerDto, UpdateCustomerDto } from './dto'

@Injectable()
export class CustomersService {
  constructor(private prisma: PrismaService) {}

  async create(createCustomerDto: CreateCustomerDto) {
    return this.prisma.customer.create({ data: createCustomerDto })
  }

  async findAll() {
    return this.prisma.customer.findMany()
  }

  async findOne(id: string) {
    return this.prisma.customer.findUnique({ where: { id } })
  }

  async update(id: string, updateCustomerDto: UpdateCustomerDto) {
    return this.prisma.customer.update({ where: { id }, data: updateCustomerDto })
  }

  async remove(id: string) {
    return this.prisma.customer.delete({ where: { id } })
  }
}