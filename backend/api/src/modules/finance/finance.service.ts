import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreateAccountDto, CreateTransactionDto, UpdateTransactionDto, TransactionQueryDto, CreatePayrollTransactionDto, CreateBulkPayrollTransactionDto } from './dto'
import { FinanceUtils } from './finance.utils'

@Injectable()
export class FinanceService {
  constructor(private prisma: PrismaService) {}

  // ============================================
  // ACCOUNT OPERATIONS
  // ============================================

  async getAccountsWithBalance() {
    const accounts = await this.prisma.account.findMany({
      where: { isActive: true },
      include: {
        postings: true
      }
    })

    return accounts.map(account => ({
      ...account,
      balanceTRY: FinanceUtils.calculateAccountBalance(account.postings)
    }))
  }

  async createAccount(dto: CreateAccountDto) {
    return this.prisma.account.create({
      data: dto
    })
  }

  async getAccount(id: string) {
    const account = await this.prisma.account.findUnique({
      where: { id },
      include: {
        postings: {
          include: {
            transaction: true
          }
        }
      }
    })

    if (!account) {
      throw new NotFoundException(`Account #${id} not found`)
    }

    return {
      ...account,
      balanceTRY: FinanceUtils.calculateAccountBalance(account.postings)
    }
  }

  // ============================================
  // TRANSACTION OPERATIONS
  // ============================================

  async getTransactions(query: TransactionQueryDto) {
    const { from, to, kinds, accounts, q, page = 1, limit = 20, sort = 'date' } = query
    const skip = (page - 1) * limit

    const where: any = {}

    // Date range filter
    if (from || to) {
      where.date = {}
      if (from) where.date.gte = new Date(from)
      if (to) where.date.lte = new Date(to)
    }

    // Kind filter
    if (kinds && kinds.length > 0) {
      where.kind = { in: kinds }
    }

    // Account filter (through postings)
    if (accounts && accounts.length > 0) {
      where.postings = {
        some: {
          accountId: { in: accounts }
        }
      }
    }

    // Text search
    if (q) {
      where.OR = [
        { note: { contains: q, mode: 'insensitive' } },
        { customerId: { contains: q, mode: 'insensitive' } },
        { supplierId: { contains: q, mode: 'insensitive' } }
      ]
    }

    const [transactions, total] = await Promise.all([
      this.prisma.transaction.findMany({
        where,
        include: {
          postings: {
            include: {
              account: true
            }
          }
        },
        orderBy: { [sort]: 'desc' },
        skip,
        take: limit
      }),
      this.prisma.transaction.count({ where })
    ])

    return {
      data: transactions,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    }
  }

  async getTransaction(id: string) {
    const transaction = await this.prisma.transaction.findUnique({
      where: { id },
      include: {
        postings: {
          include: {
            account: true
          }
        }
      }
    })

    if (!transaction) {
      throw new NotFoundException(`Transaction #${id} not found`)
    }

    return transaction
  }

  async createTransaction(dto: CreateTransactionDto) {
    // Validate double-entry rule
    if (!FinanceUtils.validateDoubleEntry(dto.postings)) {
      throw new BadRequestException('DEBIT total must equal CREDIT total')
    }

    // Create transaction with postings in a single transaction
    return this.prisma.$transaction(async (tx) => {
      const transaction = await tx.transaction.create({
        data: {
          kind: dto.kind,
          amount: dto.amount,
          currency: dto.currency || 'TRY',
          rateToTRY: dto.rateToTRY || 1.0,
          note: dto.note,
          customerId: dto.customerId,
          supplierId: dto.supplierId,
          createdBy: dto.createdBy,
          date: new Date()
        }
      })

      const postings = await Promise.all(
        dto.postings.map(posting =>
          tx.posting.create({
            data: {
              transactionId: transaction.id,
              accountId: posting.accountId,
              dc: posting.dc,
              amount: posting.amount,
              currency: posting.currency || 'TRY',
              rateToTRY: posting.rateToTRY || 1.0
            }
          })
        )
      )

      return {
        ...transaction,
        postings
      }
    })
  }

  async updateTransaction(id: string, dto: UpdateTransactionDto) {
    const transaction = await this.getTransaction(id)
    
    return this.prisma.transaction.update({
      where: { id },
      data: dto,
      include: {
        postings: {
          include: {
            account: true
          }
        }
      }
    })
  }

  async deleteTransaction(id: string) {
    const transaction = await this.getTransaction(id)
    
    // Delete transaction (postings will be deleted by cascade)
    return this.prisma.transaction.delete({
      where: { id }
    })
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  async getAccountBalance(accountId: string) {
    const postings = await this.prisma.posting.findMany({
      where: { accountId }
    })

    return FinanceUtils.calculateAccountBalance(postings)
  }

  async getTotalBalance() {
    const accounts = await this.getAccountsWithBalance()
    return FinanceUtils.calculateTotalBalance(accounts)
  }

  // ============================================
  // PAYROLL TRANSACTION METHODS
  // ============================================

  async createPayrollTransaction(dto: CreatePayrollTransactionDto) {
    // Validate employee exists
    const employee = await this.prisma.employee.findUnique({
      where: { id: dto.employeeId }
    })

    if (!employee) {
      throw new NotFoundException(`Employee #${dto.employeeId} not found`)
    }

    // Validate account exists
    const account = await this.prisma.account.findUnique({
      where: { id: dto.accountId }
    })

    if (!account) {
      throw new NotFoundException(`Account #${dto.accountId} not found`)
    }

    // Create transaction
    const transaction = await this.prisma.transaction.create({
      data: {
        kind: dto.kind,
        amount: dto.amount,
        currency: 'TRY',
        rateToTRY: 1.0,
        note: dto.note || `Payroll payment for ${employee.firstName} ${employee.lastName}`,
        createdBy: dto.createdBy
      }
    })

    // Create postings (double-entry)
    await this.prisma.posting.createMany({
      data: [
        {
          transactionId: transaction.id,
          accountId: dto.accountId,
          dc: 'CREDIT', // Money going out of account
          amount: dto.amount,
          currency: 'TRY',
          rateToTRY: 1.0
        },
        {
          transactionId: transaction.id,
          accountId: dto.accountId, // Using same account for simplicity
          dc: 'DEBIT', // Employee receivable
          amount: dto.amount,
          currency: 'TRY',
          rateToTRY: 1.0
        }
      ]
    })

    return transaction
  }

  async createBulkPayrollTransactions(dto: CreateBulkPayrollTransactionDto) {
    const results = []

    for (const payment of dto.payments) {
      try {
        const transaction = await this.createPayrollTransaction({
          ...payment,
          createdBy: dto.createdBy
        })
        results.push({ success: true, transaction })
      } catch (error) {
        results.push({ 
          success: false, 
          employeeId: payment.employeeId, 
          error: (error as any).message 
        })
      }
    }

    return {
      total: dto.payments.length,
      successful: results.filter(r => r.success).length,
      failed: results.filter(r => !r.success).length,
      results
    }
  }

  async getEmployeeTransactions(employeeId: string, query?: TransactionQueryDto) {
    const where: any = {
      note: {
        contains: employeeId
      }
    }

    if (query?.from || query?.to) {
      where.date = {}
      if (query.from) {
        where.date.gte = new Date(query.from)
      }
      if (query.to) {
        where.date.lte = new Date(query.to)
      }
    }

    if (query?.kinds && query.kinds.length > 0) {
      where.kind = { in: query.kinds }
    }

    return this.prisma.transaction.findMany({
      where,
      include: {
        postings: {
          include: {
            account: true
          }
        }
      },
      orderBy: { date: 'desc' },
      take: query?.limit || 20,
      skip: query?.page ? (query.page - 1) * (query.limit || 20) : 0
    })
  }
}
