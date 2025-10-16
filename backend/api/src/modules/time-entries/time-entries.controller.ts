import { Controller, Get, Post, Body, Param, Put, Delete, Query, Patch } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger'
import { TimeEntriesService } from './time-entries.service'
import { CreateTimeEntryDto, UpdateTimeEntryDto, ApproveTimeEntryDto } from './dto'

@ApiTags('time-entries')
@Controller('time-entries')
export class TimeEntriesController {
  constructor(private readonly timeEntriesService: TimeEntriesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all time entries' })
  @ApiResponse({ status: 200, description: 'Return all time entries' })
  @ApiQuery({ name: 'employeeId', required: false, description: 'Filter by employee ID' })
  @ApiQuery({ name: 'type', required: false, description: 'Filter by type (NORMAL/OVERTIME)' })
  @ApiQuery({ name: 'approved', required: false, description: 'Filter by approval status' })
  @ApiQuery({ name: 'dateFrom', required: false, description: 'Filter from date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'dateTo', required: false, description: 'Filter to date (YYYY-MM-DD)' })
  findAll(@Query() params: any) {
    return this.timeEntriesService.findAll(params)
  }

  @Get('pending-approvals')
  @ApiOperation({ summary: 'Get pending time entry approvals' })
  @ApiResponse({ status: 200, description: 'Return pending approvals' })
  getPendingApprovals() {
    return this.timeEntriesService.getPendingApprovals()
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get time entry by id' })
  @ApiResponse({ status: 200, description: 'Return time entry' })
  @ApiResponse({ status: 404, description: 'Time entry not found' })
  findOne(@Param('id') id: string) {
    return this.timeEntriesService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create time entry' })
  @ApiResponse({ status: 201, description: 'Time entry created' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  create(@Body() createTimeEntryDto: CreateTimeEntryDto) {
    return this.timeEntriesService.create(createTimeEntryDto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update time entry' })
  @ApiResponse({ status: 200, description: 'Time entry updated' })
  @ApiResponse({ status: 404, description: 'Time entry not found' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  update(@Param('id') id: string, @Body() updateTimeEntryDto: UpdateTimeEntryDto) {
    return this.timeEntriesService.update(id, updateTimeEntryDto)
  }

  @Patch(':id/approve')
  @ApiOperation({ summary: 'Approve time entry' })
  @ApiResponse({ status: 200, description: 'Time entry approved' })
  @ApiResponse({ status: 404, description: 'Time entry not found' })
  approve(@Param('id') id: string, @Body() approveDto: ApproveTimeEntryDto) {
    return this.timeEntriesService.approve(id, approveDto)
  }

  @Patch(':id/reject')
  @ApiOperation({ summary: 'Reject time entry' })
  @ApiResponse({ status: 200, description: 'Time entry rejected' })
  @ApiResponse({ status: 404, description: 'Time entry not found' })
  reject(@Param('id') id: string, @Body() rejectDto: { rejectedBy: string; reason?: string }) {
    return this.timeEntriesService.reject(id, rejectDto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete time entry' })
  @ApiResponse({ status: 200, description: 'Time entry deleted' })
  @ApiResponse({ status: 404, description: 'Time entry not found' })
  @ApiResponse({ status: 400, description: 'Cannot delete time entry' })
  remove(@Param('id') id: string) {
    return this.timeEntriesService.remove(id)
  }
}
