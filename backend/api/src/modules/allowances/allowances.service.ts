import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateAllowanceDto, UpdateAllowanceDto } from './dto'

@Injectable()
export class AllowancesService {
  constructor(private prisma: PrismaService) {}

  async create(createAllowanceDto: CreateAllowanceDto) {
    // Validate employee exists
    const employee = await this.prisma.employee.findUnique({
      where: { id: createAllowanceDto.employeeId }
    })

    if (!employee) {
      throw new NotFoundException(`Employee #${createAllowanceDto.employeeId} not found`)
    }

    return this.prisma.allowance.create({
      data: createAllowanceDto
    })
  }

  async findAll(params?: {
    employeeId?: string
    kind?: string
    dateFrom?: string
    dateTo?: string
  }) {
    const where: any = {}

    if (params?.employeeId) {
      where.employeeId = params.employeeId
    }

    if (params?.kind) {
      where.kind = params.kind
    }

    if (params?.dateFrom || params?.dateTo) {
      where.date = {}
      if (params.dateFrom) {
        where.date.gte = params.dateFrom
      }
      if (params.dateTo) {
        where.date.lte = params.dateTo
      }
    }

    return this.prisma.allowance.findMany({
      where,
      include: {
        employee: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            position: true
          }
        }
      },
      orderBy: { date: 'desc' }
    })
  }

  async findOne(id: string) {
    const allowance = await this.prisma.allowance.findUnique({
      where: { id },
      include: {
        employee: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            position: true
          }
        }
      }
    })

    if (!allowance) {
      throw new NotFoundException(`Allowance #${id} not found`)
    }

    return allowance
  }

  async update(id: string, updateAllowanceDto: UpdateAllowanceDto) {
    // Validate allowance exists
    const existing = await this.prisma.allowance.findUnique({
      where: { id }
    })

    if (!existing) {
      throw new NotFoundException(`Allowance #${id} not found`)
    }

    return this.prisma.allowance.update({
      where: { id },
      data: updateAllowanceDto
    })
  }

  async remove(id: string) {
    try {
      return await this.prisma.allowance.delete({
        where: { id }
      })
    } catch (error: any) {
      throw new BadRequestException('Cannot delete allowance')
    }
  }

  async getTotalByEmployee(employeeId: string, dateFrom?: string, dateTo?: string) {
    const where: any = { employeeId }

    if (dateFrom || dateTo) {
      where.date = {}
      if (dateFrom) {
        where.date.gte = dateFrom
      }
      if (dateTo) {
        where.date.lte = dateTo
      }
    }

    const allowances = await this.prisma.allowance.findMany({
      where,
      select: { amount: true, kind: true }
    })

    const total = allowances.reduce((sum, allowance) => sum + allowance.amount, 0)
    const byKind = allowances.reduce((acc, allowance) => {
      acc[allowance.kind] = (acc[allowance.kind] || 0) + allowance.amount
      return acc
    }, {} as Record<string, number>)

    return {
      total,
      byKind,
      count: allowances.length
    }
  }

  async getSummaryByKind(dateFrom?: string, dateTo?: string) {
    const where: any = {}

    if (dateFrom || dateTo) {
      where.date = {}
      if (dateFrom) {
        where.date.gte = dateFrom
      }
      if (dateTo) {
        where.date.lte = dateTo
      }
    }

    const allowances = await this.prisma.allowance.findMany({
      where,
      select: { amount: true, kind: true }
    })

    const summary = allowances.reduce((acc, allowance) => {
      if (!acc[allowance.kind]) {
        acc[allowance.kind] = { total: 0, count: 0 }
      }
      acc[allowance.kind].total += allowance.amount
      acc[allowance.kind].count += 1
      return acc
    }, {} as Record<string, { total: number; count: number }>)

    return summary
  }
}
