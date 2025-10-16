import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateRentalDto, UpdateRentalDto, UpdateRentalPeriodDto } from './dto'
import { RentalEventMapper } from '../calendar/event-mappers/rental.mapper'

@Injectable()
export class RentalsService {
  constructor(
    private prisma: PrismaService,
    private rentalEventMapper: RentalEventMapper
  ) {}

  async create(createRentalDto: CreateRentalDto) {
    // TODO: Create Order + Rental together in a transaction
    const rental = await this.prisma.rental.create({ data: createRentalDto })
    
    // Create calendar event
    await this.rentalEventMapper.createRentalEvent(rental.id)
    
    return rental
  }

  async findAll(startDate?: string, endDate?: string) {
    const where: any = {}

    if (startDate && endDate) {
      where.start = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      }
    }

    return this.prisma.rental.findMany({
      where,
      include: { order: true },
      orderBy: { start: 'asc' },
    })
  }

  async findOne(id: string) {
    const rental = await this.prisma.rental.findUnique({
      where: { id },
      include: { order: true },
    })

    if (!rental) {
      throw new NotFoundException(`Rental #${id} not found`)
    }

    return rental
  }

  async update(id: string, updateRentalDto: UpdateRentalDto) {
    await this.findOne(id) // Validate exists

    const rental = await this.prisma.rental.update({
      where: { id },
      data: updateRentalDto,
    })

    // Update calendar event
    await this.rentalEventMapper.updateRentalEvent(id)

    return rental
  }

  /**
   * Update rental period (drag & drop)
   * Also recalculates Order total based on new duration
   */
  async updatePeriod(id: string, dto: UpdateRentalPeriodDto) {
    const rental = await this.findOne(id)

    // Calculate duration in days
    const startDate = new Date(dto.start)
    const endDate = new Date(dto.end)
    const durationDays = Math.ceil(
      (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24),
    )

    // Calculate new total (simple example: 10000 cents per day)
    // TODO: Get actual product price from Product table
    const dailyRate = 10000 // 100 TL per day
    const newTotal = durationDays * dailyRate

    // Update Rental period AND Order total in a transaction
    await this.prisma.$transaction([
      this.prisma.rental.update({
        where: { id },
        data: {
          start: startDate,
          end: endDate,
        },
      }),
      this.prisma.order.update({
        where: { id: rental.orderId },
        data: {
          total: newTotal,
        },
      }),
    ])

    // Update calendar event
    await this.rentalEventMapper.updateRentalEvent(id)

    return this.findOne(id)
  }

  async remove(id: string) {
    await this.findOne(id) // Validate exists

    // Delete calendar event first
    await this.rentalEventMapper.deleteRentalEvent(id)

    return this.prisma.rental.delete({ where: { id } })
  }
}