import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreatePurchaseDto, ListQueryDto, UpdatePurchaseDto } from './dto'

@Injectable()
export class PurchasesService {
  constructor(private prisma: PrismaService) {}

  async list(q: ListQueryDto) {
    const page = Math.max(1, Number(q.page || 1))
    const limit = Math.min(100, Number(q.limit || 25))
    const where: any = {}

    if (q.q) {
      where.OR = [
        { code: { contains: q.q, mode: 'insensitive' } },
        { note: { contains: q.q, mode: 'insensitive' } },
        { supplier: { name: { contains: q.q, mode: 'insensitive' } } },
      ]
    }
    if (q.supplierId) where.supplierId = q.supplierId
    if (q.type) where.type = q.type
    if (q.status) where.status = q.status
    if (q.paymentStatus) where.paymentStatus = q.paymentStatus
    if (q.dateFrom || q.dateTo) {
      where.date = {}
      if (q.dateFrom) where.date.gte = new Date(q.dateFrom)
      if (q.dateTo) where.date.lte = new Date(q.dateTo)
    }

    const [rows, total] = await this.prisma.$transaction([
      this.prisma.purchase.findMany({
        where, 
        orderBy: { date: 'desc' }, 
        skip: (page-1)*limit, 
        take: limit,
        include: { supplier: true },
      }),
      this.prisma.purchase.count({ where }),
    ])
    return { rows, total, page, limit }
  }

  async create(dto: CreatePurchaseDto) {
    return this.prisma.purchase.create({
      data: { 
        supplierId: dto.supplierId, 
        type: dto.type, 
        note: dto.note ?? null 
      }
    })
  }

  async get(id: string) {
    const it = await this.prisma.purchase.findUnique({
      where: { id },
      include: {
        items: true, 
        headerCharges: true, 
        headerDiscounts: true, 
        receipts: { include: { lines: true } }
      },
    })
    if (!it) throw new NotFoundException('Purchase not found')
    return it
  }

  async update(id: string, dto: UpdatePurchaseDto) {
    return this.prisma.purchase.update({ 
      where: { id }, 
      data: dto as any 
    })
  }

  // hesaplama sistemi - core utility kullanarak
  async recalc(id: string) {
    const p = await this.get(id)
    
    // Geçici olarak basit hesaplama (core import sorunu için)
    // const { calculatePurchaseTotals } = await import('@deneme1/core/utils/purchase-calculator')
    
    const calculationInput = {
      items: p.items.map(item => ({
        id: item.id,
        qtyOrdered: item.qtyOrdered,
        qtyReceived: item.qtyReceived,
        unitPrice: item.unitPrice,
        lineDiscountTot: item.lineDiscountTot,
        lineChargeTot: item.lineChargeTot,
        lineSubTotal: item.lineSubTotal,
        lineVat: item.lineVat,
        lineTotal: item.lineTotal
      })),
      headerCharges: p.headerCharges.map(charge => ({
        id: charge.id,
        title: charge.label,
        amount: charge.amount,
        allocate: 'PROPORTIONAL' as const
      })),
      headerDiscounts: p.headerDiscounts.map(discount => ({
        id: discount.id,
        title: discount.label,
        amount: discount.amount,
        kind: 'ABS' as const
      })),
      vatRate: p.vatRate
    }
    
    // Basit hesaplama (geçici)
    const result = {
      lineCalculations: p.items.map(item => ({
        itemId: item.id,
        lineSubTotal: item.qtyOrdered * item.unitPrice,
        lineVat: Math.round(item.qtyOrdered * item.unitPrice * p.vatRate),
        lineTotal: item.qtyOrdered * item.unitPrice + Math.round(item.qtyOrdered * item.unitPrice * p.vatRate)
      })),
      subTotal: p.items.reduce((sum, item) => sum + item.qtyOrdered * item.unitPrice, 0),
      discountTot: p.headerDiscounts.reduce((sum, d) => sum + d.amount, 0),
      chargeTot: p.headerCharges.reduce((sum, c) => sum + c.amount, 0),
      vatTot: Math.round(p.items.reduce((sum, item) => sum + item.qtyOrdered * item.unitPrice, 0) * p.vatRate),
      roundingAdj: 0,
      total: p.items.reduce((sum, item) => sum + item.qtyOrdered * item.unitPrice, 0) + Math.round(p.items.reduce((sum, item) => sum + item.qtyOrdered * item.unitPrice, 0) * p.vatRate)
    }
    
    // Update purchase totals
    const updatedPurchase = await this.prisma.purchase.update({
      where: { id },
      data: {
        subTotal: result.subTotal,
        discountTot: result.discountTot,
        chargeTot: result.chargeTot,
        vatTot: result.vatTot,
        roundingAdj: result.roundingAdj,
        total: result.total
      }
    })
    
    // Update line items
    for (const lineCalc of result.lineCalculations) {
      await this.prisma.purchaseItem.update({
        where: { id: lineCalc.itemId },
        data: {
          lineSubTotal: lineCalc.lineSubTotal,
          lineVat: lineCalc.lineVat,
          lineTotal: lineCalc.lineTotal
        }
      })
    }
    
    return updatedPurchase
  }

  async submit(id: string) {
    return this.prisma.purchase.update({
      where: { id },
      data: { status: 'ORDERED' }
    })
  }

  async createReceipt(id: string, body: { lines: { itemId: string, qty: number, lotCode?: string }[], date?: string, warehouse?: string }) {
    const purchase = await this.get(id)
    if (['RECEIVED','CLOSED','CANCELLED'].includes(purchase.status)) {
      throw new BadRequestException('Receipt not allowed for finalised purchase')
    }
    // qty guard
    for (const l of body.lines) {
      const item = purchase.items.find(i => i.id === l.itemId)
      if (!item) throw new BadRequestException('Item not found in purchase')
      if (item.qtyReceived + l.qty > item.qtyOrdered) {
        throw new BadRequestException('Over-receive not allowed')
      }
    }
    // create receipt + update items atomik
    const res = await this.prisma.$transaction(async (tx) => {
      const receipt = await tx.goodsReceipt.create({
        data: {
          purchaseId: id,
          date: body.date ? new Date(body.date) : new Date(),
          warehouse: body.warehouse || process.env.DEFAULT_WAREHOUSE || 'MAIN',
          lines: {
            create: body.lines.map(l => ({
              itemId: l.itemId, qty: l.qty, lotCode: l.lotCode ?? null
            }))
          }
        },
        include: { lines: true }
      })
      // update received
      for (const l of body.lines) {
        await tx.purchaseItem.update({
          where: { id: l.itemId },
          data: { qtyReceived: { increment: l.qty } }
        })
      }
      // status advance
      const all = await tx.purchaseItem.findMany({ where: { purchaseId: id } })
      const allReceived = all.every(i => i.qtyReceived >= i.qtyOrdered)
      await tx.purchase.update({
        where: { id },
        data: { status: allReceived ? 'RECEIVED' : 'PARTIAL_RECEIVED' }
      })
      return receipt
    })
    return res
  }

  async close(id: string) {
    // kalan iptal: CLOSED
    return this.prisma.purchase.update({ 
      where: { id }, 
      data: { status: 'CLOSED' } 
    })
  }

  async addPayment(id: string, body: { amount: number, method: string }) {
    // Payment tablonuz varsa burada create edin; ardından paymentStat güncelleyin
    const purchase = await this.get(id)
    const paid = purchase.paid + body.amount
    const paymentStatus = paid >= purchase.total ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'UNPAID')
    return this.prisma.purchase.update({ 
      where: { id }, 
      data: { paid, paymentStatus } 
    })
  }

  // Purchase Items methods
  async addItem(purchaseId: string, body: any) {
    const item = await this.prisma.purchaseItem.create({
      data: {
        purchaseId,
        productId: body.productId || null,
        description: body.description || null,
        qtyOrdered: body.qtyOrdered,
        unitPrice: body.unitPrice,
        lineDiscountTot: body.lineDiscountTot || 0,
        lineChargeTot: body.lineChargeTot || 0
      }
    })
    
    // Recalculate totals
    await this.recalc(purchaseId)
    return item
  }

  async updateItem(itemId: string, body: any) {
    const item = await this.prisma.purchaseItem.findUnique({ where: { id: itemId } })
    if (!item) throw new NotFoundException('Item not found')
    
    const updatedItem = await this.prisma.purchaseItem.update({
      where: { id: itemId },
      data: body
    })
    
    // Recalculate totals
    await this.recalc(item.purchaseId)
    return updatedItem
  }

  async deleteItem(itemId: string) {
    const item = await this.prisma.purchaseItem.findUnique({ where: { id: itemId } })
    if (!item) throw new NotFoundException('Item not found')
    
    await this.prisma.purchaseItem.delete({ where: { id: itemId } })
    
    // Recalculate totals
    await this.recalc(item.purchaseId)
    return { success: true }
  }
}
