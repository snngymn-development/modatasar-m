import { Controller, Get, Post, Patch, Delete, Param, Body, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { AgendaEventsService } from './agenda-events.service'
import { CreateAgendaEventDto, UpdateAgendaEventPeriodDto } from './dto'

@ApiTags('agenda-events')
@Controller('agenda-events')
export class AgendaEventsController {
  constructor(private readonly service: AgendaEventsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all agenda events (maintenance, cleaning, out of service)' })
  @ApiResponse({ status: 200, description: 'Return all agenda events' })
  findAll(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    return this.service.findAll(startDate, endDate)
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get agenda event by id' })
  @ApiResponse({ status: 200, description: 'Return agenda event' })
  @ApiResponse({ status: 404, description: 'Agenda event not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create agenda event (Alteration, Dry Cleaning, Out of Service)' })
  @ApiResponse({ status: 201, description: 'Agenda event created' })
  create(@Body() dto: CreateAgendaEventDto) {
    return this.service.create(dto)
  }

  @Patch(':id/period')
  @ApiOperation({ summary: 'Update agenda event period (drag & drop)' })
  @ApiResponse({ status: 200, description: 'Agenda event period updated' })
  @ApiResponse({ status: 404, description: 'Agenda event not found' })
  updatePeriod(@Param('id') id: string, @Body() dto: UpdateAgendaEventPeriodDto) {
    return this.service.updatePeriod(id, dto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete agenda event' })
  @ApiResponse({ status: 200, description: 'Agenda event deleted' })
  @ApiResponse({ status: 404, description: 'Agenda event not found' })
  remove(@Param('id') id: string) {
    return this.service.remove(id)
  }
}

