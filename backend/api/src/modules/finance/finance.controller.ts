import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Param, 
  Body, 
  Query,
  HttpCode,
  HttpStatus
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger'
import { FinanceService } from './finance.service'
import { CreateAccountDto, CreateTransactionDto, UpdateTransactionDto, TransactionQueryDto, CreatePayrollTransactionDto, CreateBulkPayrollTransactionDto } from './dto'

@ApiTags('finance')
@Controller('finance')
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  // ============================================
  // ACCOUNT ENDPOINTS
  // ============================================

  @Get('accounts')
  @ApiOperation({ summary: 'Get all accounts with balances' })
  @ApiResponse({ status: 200, description: 'Return all accounts with calculated balances' })
  async getAccounts() {
    return this.financeService.getAccountsWithBalance()
  }

  @Get('accounts/:id')
  @ApiOperation({ summary: 'Get account by ID with balance' })
  @ApiParam({ name: 'id', description: 'Account ID' })
  @ApiResponse({ status: 200, description: 'Return account with balance' })
  @ApiResponse({ status: 404, description: 'Account not found' })
  async getAccount(@Param('id') id: string) {
    return this.financeService.getAccount(id)
  }

  @Post('accounts')
  @ApiOperation({ summary: 'Create new account' })
  @ApiResponse({ status: 201, description: 'Account created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid account data' })
  async createAccount(@Body() dto: CreateAccountDto) {
    return this.financeService.createAccount(dto)
  }

  // ============================================
  // TRANSACTION ENDPOINTS
  // ============================================

  @Get('transactions')
  @ApiOperation({ summary: 'Get transactions with filtering and pagination' })
  @ApiQuery({ name: 'from', required: false, description: 'Start date (ISO string)' })
  @ApiQuery({ name: 'to', required: false, description: 'End date (ISO string)' })
  @ApiQuery({ name: 'kinds', required: false, description: 'Transaction kinds (array)' })
  @ApiQuery({ name: 'accounts', required: false, description: 'Account IDs (array)' })
  @ApiQuery({ name: 'q', required: false, description: 'Search query' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page' })
  @ApiQuery({ name: 'sort', required: false, description: 'Sort field' })
  @ApiResponse({ status: 200, description: 'Return paginated transactions' })
  async getTransactions(@Query() query: TransactionQueryDto) {
    return this.financeService.getTransactions(query)
  }

  @Get('transactions/:id')
  @ApiOperation({ summary: 'Get transaction by ID' })
  @ApiParam({ name: 'id', description: 'Transaction ID' })
  @ApiResponse({ status: 200, description: 'Return transaction with postings' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async getTransaction(@Param('id') id: string) {
    return this.financeService.getTransaction(id)
  }

  @Post('transactions')
  @ApiOperation({ summary: 'Create new transaction' })
  @ApiResponse({ status: 201, description: 'Transaction created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid transaction data or double-entry validation failed' })
  async createTransaction(@Body() dto: CreateTransactionDto) {
    return this.financeService.createTransaction(dto)
  }

  @Put('transactions/:id')
  @ApiOperation({ summary: 'Update transaction' })
  @ApiParam({ name: 'id', description: 'Transaction ID' })
  @ApiResponse({ status: 200, description: 'Transaction updated successfully' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async updateTransaction(@Param('id') id: string, @Body() dto: UpdateTransactionDto) {
    return this.financeService.updateTransaction(id, dto)
  }

  @Delete('transactions/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete transaction' })
  @ApiParam({ name: 'id', description: 'Transaction ID' })
  @ApiResponse({ status: 204, description: 'Transaction deleted successfully' })
  @ApiResponse({ status: 404, description: 'Transaction not found' })
  async deleteTransaction(@Param('id') id: string) {
    await this.financeService.deleteTransaction(id)
  }

  // ============================================
  // SUMMARY ENDPOINTS
  // ============================================

  @Get('summary/balance')
  @ApiOperation({ summary: 'Get total balance across all accounts' })
  @ApiResponse({ status: 200, description: 'Return total balance in TRY' })
  async getTotalBalance() {
    const total = await this.financeService.getTotalBalance()
    return { totalBalanceTRY: total }
  }

  @Get('summary/account/:id/balance')
  @ApiOperation({ summary: 'Get account balance' })
  @ApiParam({ name: 'id', description: 'Account ID' })
  @ApiResponse({ status: 200, description: 'Return account balance in TRY' })
  @ApiResponse({ status: 404, description: 'Account not found' })
  async getAccountBalance(@Param('id') id: string) {
    const balance = await this.financeService.getAccountBalance(id)
    return { balanceTRY: balance }
  }

  // ============================================
  // PAYROLL TRANSACTION ENDPOINTS
  // ============================================

  @Post('payroll/transaction')
  @ApiOperation({ summary: 'Create payroll transaction' })
  @ApiResponse({ status: 201, description: 'Payroll transaction created' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 404, description: 'Employee or account not found' })
  async createPayrollTransaction(@Body() dto: CreatePayrollTransactionDto) {
    return this.financeService.createPayrollTransaction(dto)
  }

  @Post('payroll/transactions/bulk')
  @ApiOperation({ summary: 'Create bulk payroll transactions' })
  @ApiResponse({ status: 201, description: 'Bulk payroll transactions created' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async createBulkPayrollTransactions(@Body() dto: CreateBulkPayrollTransactionDto) {
    return this.financeService.createBulkPayrollTransactions(dto)
  }

  @Get('employees/:employeeId/transactions')
  @ApiOperation({ summary: 'Get employee transactions' })
  @ApiResponse({ status: 200, description: 'Return employee transactions' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  async getEmployeeTransactions(
    @Param('employeeId') employeeId: string,
    @Query() query: TransactionQueryDto
  ) {
    return this.financeService.getEmployeeTransactions(employeeId, query)
  }
}
