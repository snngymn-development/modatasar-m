import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateAgendaEventDto, UpdateAgendaEventPeriodDto } from './dto'

@Injectable()
export class AgendaEventsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateAgendaEventDto) {
    return this.prisma.agendaEvent.create({
      data: {
        productId: dto.productId,
        type: dto.type,
        start: new Date(dto.start),
        end: new Date(dto.end),
        note: dto.note,
      },
    })
  }

  async findAll(startDate?: string, endDate?: string) {
    const where: any = {}

    if (startDate && endDate) {
      where.start = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      }
    }

    const events = await this.prisma.agendaEvent.findMany({
      where,
      orderBy: { start: 'asc' },
    })

    return events.map((e) => ({
      id: e.id,
      productId: e.productId,
      type: e.type,
      start: e.start.toISOString(),
      end: e.end.toISOString(),
      note: e.note,
      createdAt: e.createdAt.toISOString(),
    }))
  }

  async findOne(id: string) {
    const event = await this.prisma.agendaEvent.findUnique({
      where: { id },
    })

    if (!event) {
      throw new NotFoundException(`Agenda event #${id} not found`)
    }

    return {
      id: event.id,
      productId: event.productId,
      type: event.type,
      start: event.start.toISOString(),
      end: event.end.toISOString(),
      note: event.note,
      createdAt: event.createdAt.toISOString(),
    }
  }

  async updatePeriod(id: string, dto: UpdateAgendaEventPeriodDto) {
    await this.findOne(id) // Validate exists

    return this.prisma.agendaEvent.update({
      where: { id },
      data: {
        start: new Date(dto.start),
        end: new Date(dto.end),
      },
    })
  }

  async remove(id: string) {
    await this.findOne(id) // Validate exists

    return this.prisma.agendaEvent.delete({
      where: { id },
    })
  }
}

