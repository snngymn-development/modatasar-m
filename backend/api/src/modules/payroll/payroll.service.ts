import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CreatePayrollRunDto, PayrollPreviewDto, PayrollPayDto } from './dto'

@Injectable()
export class PayrollService {
  constructor(private prisma: PrismaService) {}

  async preview(previewDto: PayrollPreviewDto) {
    const { periodStart, periodEnd, employeeIds } = previewDto

    // Get employees
    const employees = await this.getEmployeesForPayroll(employeeIds)

    // Calculate payroll for each employee
    const items = []
    let grossTotal = 0
    let overtimeTotal = 0
    let allowancesTotal = 0
    let deductionsTotal = 0

    for (const employee of employees) {
      const item = await this.calculateEmployeePayroll(employee, periodStart, periodEnd)
      items.push(item)

      grossTotal += item.grossSalary
      overtimeTotal += item.overtimeAmount
      allowancesTotal += item.allowancesTotal
      deductionsTotal += item.deductionsTotal
    }

    const netTotal = grossTotal + overtimeTotal + allowancesTotal - deductionsTotal

    return {
      periodStart,
      periodEnd,
      employeeCount: employees.length,
      totals: {
        gross: grossTotal,
        overtime: overtimeTotal,
        allowances: allowancesTotal,
        deductions: deductionsTotal,
        net: netTotal
      },
      items
    }
  }

  async createRun(createDto: CreatePayrollRunDto) {
    const { periodStart, periodEnd, scope, employeeIds, createdBy } = createDto

    // Get preview data
    const preview = await this.preview({ periodStart, periodEnd, employeeIds })

    // Create payroll run
    const payrollRun = await this.prisma.payrollRun.create({
      data: {
        periodStart,
        periodEnd,
        scope,
        employeeIds: employeeIds ? JSON.stringify(employeeIds) : null,
        grossTotal: preview.totals.gross,
        overtimeTotal: preview.totals.overtime,
        allowancesTotal: preview.totals.allowances,
        deductionsTotal: preview.totals.deductions,
        netTotal: preview.totals.net,
        status: 'DRAFT',
        createdBy
      }
    })

    // Create payroll items
    const items = await Promise.all(
      preview.items.map(item =>
        this.prisma.payrollItem.create({
          data: {
            payrollRunId: payrollRun.id,
            employeeId: item.employeeId,
            grossSalary: item.grossSalary,
            normalHours: item.normalHours,
            overtimeHours: item.overtimeHours,
            overtimeRate: item.overtimeRate,
            overtimeAmount: item.overtimeAmount,
            allowancesTotal: item.allowancesTotal,
            deductionsTotal: item.deductionsTotal,
            netPay: item.netPay
          }
        })
      )
    )

    return {
      ...payrollRun,
      items
    }
  }

  async findAll() {
    return this.prisma.payrollRun.findMany({
      include: {
        items: {
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
        }
      },
      orderBy: { createdAt: 'desc' }
    })
  }

  async findOne(id: string) {
    const payrollRun = await this.prisma.payrollRun.findUnique({
      where: { id },
      include: {
        items: {
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
        }
      }
    })

    if (!payrollRun) {
      throw new NotFoundException(`PayrollRun #${id} not found`)
    }

    return payrollRun
  }

  async lock(id: string, lockedBy: string) {
    const payrollRun = await this.prisma.payrollRun.findUnique({
      where: { id }
    })

    if (!payrollRun) {
      throw new NotFoundException(`PayrollRun #${id} not found`)
    }

    if (payrollRun.status === 'POSTED') {
      throw new BadRequestException('Payroll run is already locked')
    }

    return this.prisma.payrollRun.update({
      where: { id },
      data: {
        status: 'POSTED',
        postedAt: new Date(),
        postedBy: lockedBy
      }
    })
  }

  async pay(id: string, payDto: PayrollPayDto) {
    const payrollRun = await this.prisma.payrollRun.findUnique({
      where: { id },
      include: { items: true }
    })

    if (!payrollRun) {
      throw new NotFoundException(`PayrollRun #${id} not found`)
    }

    if (payrollRun.status !== 'POSTED') {
      throw new BadRequestException('Payroll run must be locked before payment')
    }

    // Create finance transactions for each employee
    const transactions = []
    for (const item of payrollRun.items) {
      if (item.netPay > 0) {
        // Create transaction in finance module
        const transaction = await this.createFinanceTransaction({
          employeeId: item.employeeId,
          amount: item.netPay,
          accountId: payDto.accountId,
          note: `Payroll payment for ${payrollRun.periodStart} - ${payrollRun.periodEnd}`,
          createdBy: payDto.createdBy
        })

        // Update payroll item with transaction ID
        await this.prisma.payrollItem.update({
          where: { id: item.id },
          data: { postedFinanceTransactionId: transaction.id }
        })

        transactions.push(transaction)
      }
    }

    return {
      payrollRun,
      transactions,
      totalPaid: transactions.reduce((sum, t) => sum + t.amount, 0)
    }
  }

  private async getEmployeesForPayroll(employeeIds?: string[]) {
    const where: any = { status: 'ACTIVE' }
    
    if (employeeIds && employeeIds.length > 0) {
      where.id = { in: employeeIds }
    }

    return this.prisma.employee.findMany({
      where,
      select: {
        id: true,
        firstName: true,
        lastName: true,
        wageType: true,
        baseWageAmount: true,
        normalWeeklyHours: true
      }
    })
  }

  private async calculateEmployeePayroll(employee: any, periodStart: string, periodEnd: string) {
    // Get time entries for period
    const timeEntries = await this.prisma.timeEntry.findMany({
      where: {
        employeeId: employee.id,
        date: { gte: periodStart, lte: periodEnd },
        approved: true
      }
    })

    // Get allowances for period
    const allowances = await this.prisma.allowance.findMany({
      where: {
        employeeId: employee.id,
        date: { gte: periodStart, lte: periodEnd }
      }
    })

    // Calculate normal and overtime hours
    const normalHours = timeEntries
      .filter(te => te.type === 'NORMAL')
      .reduce((sum, te) => sum + te.durationHours, 0)

    const overtimeHours = timeEntries
      .filter(te => te.type === 'OVERTIME')
      .reduce((sum, te) => sum + te.durationHours, 0)

    // Calculate gross salary
    let grossSalary = 0
    if (employee.wageType === 'FIXED') {
      // Fixed salary - prorated for period
      const daysInPeriod = this.getDaysInPeriod(periodStart, periodEnd)
      const workingDays = this.getWorkingDaysInPeriod(periodStart, periodEnd)
      const prorationFactor = workingDays / daysInPeriod
      grossSalary = Math.round(employee.baseWageAmount * prorationFactor)
    } else {
      // Hourly wage
      const hourlyRate = employee.baseWageAmount / (employee.normalWeeklyHours * 4.33) // Approximate monthly hours
      grossSalary = Math.round(normalHours * hourlyRate)
    }

    // Calculate overtime amount
    const hourlyRate = employee.wageType === 'FIXED' 
      ? employee.baseWageAmount / (employee.normalWeeklyHours * 4.33)
      : employee.baseWageAmount / (employee.normalWeeklyHours * 4.33)
    
    const overtimeAmount = Math.round(overtimeHours * hourlyRate * 1.5) // 1.5x multiplier

    // Calculate allowances total
    const allowancesTotal = allowances.reduce((sum, allowance) => sum + allowance.amount, 0)

    // Calculate net pay
    const netPay = grossSalary + overtimeAmount + allowancesTotal

    return {
      employeeId: employee.id,
      employeeName: `${employee.firstName} ${employee.lastName}`,
      grossSalary,
      normalHours,
      overtimeHours,
      overtimeRate: 1.5,
      overtimeAmount,
      allowancesTotal,
      deductionsTotal: 0, // TODO: Implement deductions
      netPay
    }
  }

  private async createFinanceTransaction(data: {
    employeeId: string
    amount: number
    accountId: string
    note: string
    createdBy: string
  }) {
    // This would integrate with the existing finance module
    // For now, return a mock transaction
    return {
      id: `txn_${Date.now()}`,
      ...data,
      kind: 'PAYROLL',
      date: new Date().toISOString(),
      currency: 'TRY'
    }
  }

  private getDaysInPeriod(start: string, end: string): number {
    const startDate = new Date(start)
    const endDate = new Date(end)
    return Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1
  }

  private getWorkingDaysInPeriod(start: string, end: string): number {
    // Simplified: assume 5 working days per week
    const daysInPeriod = this.getDaysInPeriod(start, end)
    const weeks = daysInPeriod / 7
    return Math.round(weeks * 5)
  }
}
