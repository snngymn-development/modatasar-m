import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateEmployeeDto, UpdateEmployeeDto } from './dto'

@Injectable()
export class EmployeesService {
  constructor(private prisma: PrismaService) {}

  async create(createEmployeeDto: CreateEmployeeDto) {
    try {
      return await this.prisma.employee.create({
        data: createEmployeeDto
      })
    } catch (error: any) {
      if (error.code === 'P2002') {
        throw new BadRequestException('Employee with this TC No already exists')
      }
      throw error
    }
  }

  async findAll(params?: {
    status?: string
    department?: string
    search?: string
  }) {
    const where: any = {}

    if (params?.status) {
      where.status = params.status
    }

    if (params?.department) {
      where.department = params.department
    }

    if (params?.search) {
      where.OR = [
        { firstName: { contains: params.search, mode: 'insensitive' } },
        { lastName: { contains: params.search, mode: 'insensitive' } },
        { tcNo: { contains: params.search } },
        { position: { contains: params.search, mode: 'insensitive' } }
      ]
    }

    return this.prisma.employee.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    })
  }

  async findOne(id: string) {
    const employee = await this.prisma.employee.findUnique({
      where: { id },
      include: {
        timeEntries: {
          orderBy: { date: 'desc' },
          take: 10
        },
        allowances: {
          orderBy: { date: 'desc' },
          take: 10
        },
        sgkRecords: {
          orderBy: { period: 'desc' },
          take: 5
        }
      }
    })

    if (!employee) {
      throw new NotFoundException(`Employee #${id} not found`)
    }

    return employee
  }

  async update(id: string, updateEmployeeDto: UpdateEmployeeDto) {
    try {
      return await this.prisma.employee.update({
        where: { id },
        data: updateEmployeeDto
      })
    } catch (error: any) {
      if (error.code === 'P2002') {
        throw new BadRequestException('Employee with this TC No already exists')
      }
      throw error
    }
  }

  async remove(id: string) {
    try {
      return await this.prisma.employee.delete({
        where: { id }
      })
    } catch (error: any) {
      if (error.code === 'P2003') {
        throw new BadRequestException('Cannot delete employee with related records')
      }
      throw error
    }
  }

  async getDepartments() {
    const departments = await this.prisma.employee.findMany({
      select: { department: true },
      where: { department: { not: null } },
      distinct: ['department']
    })

    return departments.map(d => d.department).filter(Boolean)
  }

  async getPositions() {
    const positions = await this.prisma.employee.findMany({
      select: { position: true },
      where: { position: { not: null } },
      distinct: ['position']
    })

    return positions.map(p => p.position).filter(Boolean)
  }
}
