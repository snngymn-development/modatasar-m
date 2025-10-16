import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateTimeEntryDto, UpdateTimeEntryDto, ApproveTimeEntryDto } from './dto'

@Injectable()
export class TimeEntriesService {
  constructor(private prisma: PrismaService) {}

  async create(createTimeEntryDto: CreateTimeEntryDto) {
    // Validate employee exists
    const employee = await this.prisma.employee.findUnique({
      where: { id: createTimeEntryDto.employeeId }
    })

    if (!employee) {
      throw new NotFoundException(`Employee #${createTimeEntryDto.employeeId} not found`)
    }

    // Calculate duration
    const duration = this.calculateDuration(
      createTimeEntryDto.startTime,
      createTimeEntryDto.endTime
    )

    return this.prisma.timeEntry.create({
      data: {
        ...createTimeEntryDto,
        durationHours: duration
      }
    })
  }

  async findAll(params?: {
    employeeId?: string
    type?: string
    approved?: boolean
    dateFrom?: string
    dateTo?: string
  }) {
    const where: any = {}

    if (params?.employeeId) {
      where.employeeId = params.employeeId
    }

    if (params?.type) {
      where.type = params.type
    }

    if (params?.approved !== undefined) {
      where.approved = params.approved
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

    return this.prisma.timeEntry.findMany({
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
    const timeEntry = await this.prisma.timeEntry.findUnique({
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

    if (!timeEntry) {
      throw new NotFoundException(`TimeEntry #${id} not found`)
    }

    return timeEntry
  }

  async update(id: string, updateTimeEntryDto: UpdateTimeEntryDto) {
    // Validate time entry exists
    const existing = await this.prisma.timeEntry.findUnique({
      where: { id }
    })

    if (!existing) {
      throw new NotFoundException(`TimeEntry #${id} not found`)
    }

    // Calculate duration if times are provided
    let duration = existing.durationHours
    if (updateTimeEntryDto.startTime && updateTimeEntryDto.endTime) {
      duration = this.calculateDuration(
        updateTimeEntryDto.startTime,
        updateTimeEntryDto.endTime
      )
    }

    return this.prisma.timeEntry.update({
      where: { id },
      data: {
        ...updateTimeEntryDto,
        durationHours: duration
      }
    })
  }

  async remove(id: string) {
    try {
      return await this.prisma.timeEntry.delete({
        where: { id }
      })
    } catch (error: any) {
      throw new BadRequestException('Cannot delete time entry')
    }
  }

  async approve(id: string, approveDto: ApproveTimeEntryDto) {
    const timeEntry = await this.prisma.timeEntry.findUnique({
      where: { id }
    })

    if (!timeEntry) {
      throw new NotFoundException(`TimeEntry #${id} not found`)
    }

    return this.prisma.timeEntry.update({
      where: { id },
      data: {
        approved: true,
        approvedBy: approveDto.approvedBy,
        approvedAt: new Date()
      }
    })
  }

  async reject(id: string, rejectDto: { rejectedBy: string; reason?: string }) {
    const timeEntry = await this.prisma.timeEntry.findUnique({
      where: { id }
    })

    if (!timeEntry) {
      throw new NotFoundException(`TimeEntry #${id} not found`)
    }

    return this.prisma.timeEntry.update({
      where: { id },
      data: {
        approved: false,
        approvedBy: null,
        approvedAt: null,
        note: rejectDto.reason ? `${timeEntry.note || ''}\nRejected: ${rejectDto.reason}`.trim() : timeEntry.note
      }
    })
  }

  async getPendingApprovals() {
    return this.prisma.timeEntry.findMany({
      where: { approved: false },
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
      orderBy: { createdAt: 'asc' }
    })
  }

  private calculateDuration(startTime: string, endTime: string): number {
    const [startHour, startMin] = startTime.split(':').map(Number)
    const [endHour, endMin] = endTime.split(':').map(Number)

    const startMinutes = startHour * 60 + startMin
    const endMinutes = endHour * 60 + endMin

    if (endMinutes <= startMinutes) {
      throw new BadRequestException('End time must be after start time')
    }

    return (endMinutes - startMinutes) / 60
  }
}
