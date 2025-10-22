import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { 
  CreateOrderDto, 
  UpdateOrderDto, 
  AddFittingDto, 
  UpdateOrderStatusDto, 
  AddChargeDto, 
  AddDiscountDto,
  CustomerBodyMeasurementsDto 
} from './dto'

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async create(createOrderDto: CreateOrderDto) {
    const { charges = [], discounts = [], fittings = [], ...orderData } = createOrderDto
    
    // Calculate total amount
    const chargesTotal = charges.reduce((sum, charge) => sum + charge.amount, 0)
    const discountsTotal = discounts.reduce((sum, discount) => sum + discount.amount, 0)
    const totalAmount = orderData.amount + chargesTotal - discountsTotal

    return this.prisma.$transaction(async (tx) => {
      // Create order
      const order = await tx.order.create({
        data: {
          ...orderData,
          total: totalAmount,
          collected: 0,
          status: 'ACTIVE',
          stage: 'STARTED',
          deliveryDate: new Date(orderData.deliveryDate),
        }
      })

      // Create order detail
      const orderDetail = await tx.orderDetail.create({
        data: {
          orderId: order.id,
          description: orderData.description,
          amount: orderData.amount,
          importantNote: orderData.importantNote,
          totalAmount: totalAmount,
        }
      })

      // Create charges
      if (charges.length > 0) {
        await tx.orderCharge.createMany({
          data: charges.map(charge => ({
            orderDetailId: orderDetail.id,
            label: charge.label,
            amount: charge.amount,
            description: charge.description,
          }))
        })
      }

      // Create discounts
      if (discounts.length > 0) {
        await tx.orderDiscount.createMany({
          data: discounts.map(discount => ({
            orderDetailId: orderDetail.id,
            label: discount.label,
            amount: discount.amount,
            description: discount.description,
          }))
        })
      }

      // Create fittings
      if (fittings.length > 0) {
        await tx.orderFitting.createMany({
          data: fittings.map(fitting => ({
            orderId: order.id,
            fittingNumber: fitting.fittingNumber,
            fittingDate: new Date(fitting.fittingDate),
            notes: fitting.notes,
            status: fitting.status || 'SCHEDULED',
          }))
        })
      }

      // Create initial status
      await tx.orderStatus.create({
        data: {
          orderId: order.id,
          status: 'STARTED',
          percentage: 0,
          notes: 'Sipariş oluşturuldu',
        }
      })

      return this.findOne(order.id)
    })
  }

  async findAll() {
    return this.prisma.order.findMany({ 
      include: { 
        customer: true,
        details: {
          include: {
            charges: true,
            discounts: true,
          }
        },
        fittings: true,
        statusHistory: {
          orderBy: { createdAt: 'desc' }
        }
      } 
    })
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({ 
      where: { id }, 
      include: { 
        customer: true,
        details: {
          include: {
            charges: true,
            discounts: true,
          }
        },
        fittings: {
          orderBy: { fittingNumber: 'asc' }
        },
        statusHistory: {
          orderBy: { createdAt: 'desc' }
        }
      } 
    })

    if (!order) {
      throw new NotFoundException(`Sipariş bulunamadı: ${id}`)
    }

    return order
  }

  async update(id: string, updateOrderDto: UpdateOrderDto) {
    const existingOrder = await this.findOne(id)
    
    const { charges = [], discounts = [], fittings = [], ...orderData } = updateOrderDto
    
    return this.prisma.$transaction(async (tx) => {
      // Update order
      const updatedOrder = await tx.order.update({
        where: { id },
        data: {
          ...orderData,
          deliveryDate: orderData.deliveryDate ? new Date(orderData.deliveryDate) : undefined,
        }
      })

      // Update order detail if amount changed
      if (orderData.amount !== undefined) {
        const orderDetail = await tx.orderDetail.findFirst({
          where: { orderId: id }
        })

        if (orderDetail) {
          const chargesTotal = charges.reduce((sum, charge) => sum + charge.amount, 0)
          const discountsTotal = discounts.reduce((sum, discount) => sum + discount.amount, 0)
          const totalAmount = orderData.amount + chargesTotal - discountsTotal

          await tx.orderDetail.update({
            where: { id: orderDetail.id },
            data: {
              amount: orderData.amount,
              totalAmount: totalAmount,
              description: orderData.description,
              importantNote: orderData.importantNote,
            }
          })

          // Update order total
          await tx.order.update({
            where: { id },
            data: { total: totalAmount }
          })
        }
      }

      return this.findOne(id)
    })
  }

  async remove(id: string) {
    await this.findOne(id) // Check if exists
    return this.prisma.order.delete({ where: { id } })
  }

  // Additional methods for order management
  async addFitting(addFittingDto: AddFittingDto) {
    const { orderId, ...fittingData } = addFittingDto
    
    await this.findOne(orderId) // Check if order exists

    return this.prisma.orderFitting.create({
      data: {
        orderId,
        fittingNumber: fittingData.fittingNumber,
        fittingDate: new Date(fittingData.fittingDate),
        notes: fittingData.notes,
        status: 'SCHEDULED',
      }
    })
  }

  async updateOrderStatus(updateOrderStatusDto: UpdateOrderStatusDto) {
    const { orderId, status, notes } = updateOrderStatusDto
    
    await this.findOne(orderId) // Check if order exists

    const statusMap: Record<string, number> = {
      'STARTED': 0,
      'PROGRESS_50': 50,
      'PROGRESS_80': 80,
      'READY': 95,
      'DELIVERED': 100,
    }

    return this.prisma.$transaction(async (tx) => {
      // Create new status record
      await tx.orderStatus.create({
        data: {
          orderId,
          status,
          percentage: statusMap[status],
          notes,
        }
      })

      // Update order stage
      await tx.order.update({
        where: { id: orderId },
        data: { stage: status }
      })

      return this.findOne(orderId)
    })
  }

  async addCharge(addChargeDto: AddChargeDto) {
    const { orderDetailId, ...chargeData } = addChargeDto

    return this.prisma.$transaction(async (tx) => {
      // Create charge
      const charge = await tx.orderCharge.create({
        data: {
          orderDetailId,
          ...chargeData,
        }
      })

      // Update order detail total
      const orderDetail = await tx.orderDetail.findUnique({
        where: { id: orderDetailId },
        include: { charges: true, discounts: true }
      })

      if (orderDetail) {
        const chargesTotal = orderDetail.charges.reduce((sum, c) => sum + c.amount, 0) + charge.amount
        const discountsTotal = orderDetail.discounts.reduce((sum, d) => sum + d.amount, 0)
        const totalAmount = orderDetail.amount + chargesTotal - discountsTotal

        await tx.orderDetail.update({
          where: { id: orderDetailId },
          data: { totalAmount }
        })

        // Update order total
        const order = await tx.order.findFirst({
          where: { details: { some: { id: orderDetailId } } }
        })

        if (order) {
          const allDetails = await tx.orderDetail.findMany({
            where: { orderId: order.id }
          })
          const orderTotal = allDetails.reduce((sum, detail) => sum + detail.totalAmount, 0)

          await tx.order.update({
            where: { id: order.id },
            data: { total: orderTotal }
          })
        }
      }

      return charge
    })
  }

  async addDiscount(addDiscountDto: AddDiscountDto) {
    const { orderDetailId, ...discountData } = addDiscountDto

    return this.prisma.$transaction(async (tx) => {
      // Create discount
      const discount = await tx.orderDiscount.create({
        data: {
          orderDetailId,
          ...discountData,
        }
      })

      // Update order detail total
      const orderDetail = await tx.orderDetail.findUnique({
        where: { id: orderDetailId },
        include: { charges: true, discounts: true }
      })

      if (orderDetail) {
        const chargesTotal = orderDetail.charges.reduce((sum, c) => sum + c.amount, 0)
        const discountsTotal = orderDetail.discounts.reduce((sum, d) => sum + d.amount, 0) + discount.amount
        const totalAmount = orderDetail.amount + chargesTotal - discountsTotal

        await tx.orderDetail.update({
          where: { id: orderDetailId },
          data: { totalAmount }
        })

        // Update order total
        const order = await tx.order.findFirst({
          where: { details: { some: { id: orderDetailId } } }
        })

        if (order) {
          const allDetails = await tx.orderDetail.findMany({
            where: { orderId: order.id }
          })
          const orderTotal = allDetails.reduce((sum, detail) => sum + detail.totalAmount, 0)

          await tx.order.update({
            where: { id: order.id },
            data: { total: orderTotal }
          })
        }
      }

      return discount
    })
  }

  // Customer Body Measurements methods
  async getCustomerBodyMeasurements(customerId: string) {
    return this.prisma.customerBodyMeasurements.findMany({
      where: { customerId },
      orderBy: { measuredAt: 'desc' }
    })
  }

  async createCustomerBodyMeasurements(measurementsDto: CustomerBodyMeasurementsDto) {
    const { customerId, measuredAt, ...measurements } = measurementsDto

    return this.prisma.customerBodyMeasurements.create({
      data: {
        customerId,
        measuredAt: new Date(measuredAt),
        ...measurements,
      }
    })
  }

  async getLatestCustomerBodyMeasurements(customerId: string) {
    return this.prisma.customerBodyMeasurements.findFirst({
      where: { customerId },
      orderBy: { measuredAt: 'desc' }
    })
  }
}