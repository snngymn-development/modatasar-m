import { Controller, Get, Post, Body, Param, Put, Delete, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger'
import { AllowancesService } from './allowances.service'
import { CreateAllowanceDto, UpdateAllowanceDto } from './dto'

@ApiTags('allowances')
@Controller('allowances')
export class AllowancesController {
  constructor(private readonly allowancesService: AllowancesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all allowances' })
  @ApiResponse({ status: 200, description: 'Return all allowances' })
  @ApiQuery({ name: 'employeeId', required: false, description: 'Filter by employee ID' })
  @ApiQuery({ name: 'kind', required: false, description: 'Filter by kind (MEAL/TRANSPORT/OTHER)' })
  @ApiQuery({ name: 'dateFrom', required: false, description: 'Filter from date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'dateTo', required: false, description: 'Filter to date (YYYY-MM-DD)' })
  findAll(@Query() params: any) {
    return this.allowancesService.findAll(params)
  }

  @Get('summary')
  @ApiOperation({ summary: 'Get allowance summary by kind' })
  @ApiResponse({ status: 200, description: 'Return allowance summary' })
  @ApiQuery({ name: 'dateFrom', required: false, description: 'Filter from date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'dateTo', required: false, description: 'Filter to date (YYYY-MM-DD)' })
  getSummary(@Query() params: any) {
    return this.allowancesService.getSummaryByKind(params.dateFrom, params.dateTo)
  }

  @Get('employee/:employeeId/total')
  @ApiOperation({ summary: 'Get total allowances for employee' })
  @ApiResponse({ status: 200, description: 'Return employee allowance total' })
  @ApiQuery({ name: 'dateFrom', required: false, description: 'Filter from date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'dateTo', required: false, description: 'Filter to date (YYYY-MM-DD)' })
  getEmployeeTotal(@Param('employeeId') employeeId: string, @Query() params: any) {
    return this.allowancesService.getTotalByEmployee(employeeId, params.dateFrom, params.dateTo)
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get allowance by id' })
  @ApiResponse({ status: 200, description: 'Return allowance' })
  @ApiResponse({ status: 404, description: 'Allowance not found' })
  findOne(@Param('id') id: string) {
    return this.allowancesService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create allowance' })
  @ApiResponse({ status: 201, description: 'Allowance created' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  create(@Body() createAllowanceDto: CreateAllowanceDto) {
    return this.allowancesService.create(createAllowanceDto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update allowance' })
  @ApiResponse({ status: 200, description: 'Allowance updated' })
  @ApiResponse({ status: 404, description: 'Allowance not found' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  update(@Param('id') id: string, @Body() updateAllowanceDto: UpdateAllowanceDto) {
    return this.allowancesService.update(id, updateAllowanceDto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete allowance' })
  @ApiResponse({ status: 200, description: 'Allowance deleted' })
  @ApiResponse({ status: 404, description: 'Allowance not found' })
  @ApiResponse({ status: 400, description: 'Cannot delete allowance' })
  remove(@Param('id') id: string) {
    return this.allowancesService.remove(id)
  }
}
