import { Controller, Get, Post, Body, Param, Patch } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { PayrollService } from './payroll.service'
import { CreatePayrollRunDto, PayrollPreviewDto, PayrollPayDto } from './dto'

@ApiTags('payroll')
@Controller('payroll')
export class PayrollController {
  constructor(private readonly payrollService: PayrollService) {}

  @Post('preview')
  @ApiOperation({ summary: 'Preview payroll calculation' })
  @ApiResponse({ status: 200, description: 'Return payroll preview' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  preview(@Body() previewDto: PayrollPreviewDto) {
    return this.payrollService.preview(previewDto)
  }

  @Post('runs')
  @ApiOperation({ summary: 'Create payroll run' })
  @ApiResponse({ status: 201, description: 'Payroll run created' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  createRun(@Body() createDto: CreatePayrollRunDto) {
    return this.payrollService.createRun(createDto)
  }

  @Get('runs')
  @ApiOperation({ summary: 'Get all payroll runs' })
  @ApiResponse({ status: 200, description: 'Return all payroll runs' })
  findAll() {
    return this.payrollService.findAll()
  }

  @Get('runs/:id')
  @ApiOperation({ summary: 'Get payroll run by id' })
  @ApiResponse({ status: 200, description: 'Return payroll run' })
  @ApiResponse({ status: 404, description: 'Payroll run not found' })
  findOne(@Param('id') id: string) {
    return this.payrollService.findOne(id)
  }

  @Patch('runs/:id/lock')
  @ApiOperation({ summary: 'Lock payroll run' })
  @ApiResponse({ status: 200, description: 'Payroll run locked' })
  @ApiResponse({ status: 404, description: 'Payroll run not found' })
  @ApiResponse({ status: 400, description: 'Payroll run already locked' })
  lock(@Param('id') id: string, @Body() lockDto: { lockedBy: string }) {
    return this.payrollService.lock(id, lockDto.lockedBy)
  }

  @Patch('runs/:id/pay')
  @ApiOperation({ summary: 'Process payroll payment' })
  @ApiResponse({ status: 200, description: 'Payroll payment processed' })
  @ApiResponse({ status: 404, description: 'Payroll run not found' })
  @ApiResponse({ status: 400, description: 'Payroll run not locked' })
  pay(@Param('id') id: string, @Body() payDto: PayrollPayDto) {
    return this.payrollService.pay(id, payDto)
  }
}
