import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  Query,
  UseGuards,
  Request
} from '@nestjs/common'
import { 
  ApiTags, 
  ApiOperation, 
  ApiResponse, 
  ApiBearerAuth,
  ApiQuery
} from '@nestjs/swagger'
import { CalendarService } from './calendar.service'
import { 
  CreateCalendarEventDto, 
  UpdateCalendarEventDto, 
  CalendarFilterDto,
  ConflictCheckDto,
  EventType,
  EventStatus
} from './dto'
import { CalendarEvent } from './calendar.service'
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard'

@ApiTags('calendar')
@Controller('calendar')
export class CalendarController {
  constructor(private readonly calendarService: CalendarService) {}

  @Get()
  @ApiOperation({ summary: 'Get calendar events with filters' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return paginated calendar events',
    schema: {
      type: 'object',
      properties: {
        events: {
          type: 'array',
          items: { $ref: '#/components/schemas/CalendarEvent' }
        },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' }
      }
    }
  })
  @ApiQuery({ name: 'from', required: false, description: 'Start date filter (ISO 8601)' })
  @ApiQuery({ name: 'to', required: false, description: 'End date filter (ISO 8601)' })
  @ApiQuery({ name: 'types', required: false, description: 'Event types filter (comma-separated)' })
  @ApiQuery({ name: 'assigneeId', required: false, description: 'Assignee ID filter' })
  @ApiQuery({ name: 'customerId', required: false, description: 'Customer ID filter' })
  @ApiQuery({ name: 'resourceId', required: false, description: 'Resource ID filter' })
  @ApiQuery({ name: 'query', required: false, description: 'Search query' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, description: 'Page size' })
  async findAll(@Query() filters: CalendarFilterDto): Promise<{ 
    events: CalendarEvent[]; 
    total: number; 
    page: number; 
    limit: number 
  }> {
    // Parse comma-separated types
    if (filters.types && typeof filters.types === 'string') {
      filters.types = (filters.types as string).split(',') as any
    }
    
    return this.calendarService.findAll(filters)
  }

  @Get('conflicts')
  @ApiOperation({ summary: 'Check for scheduling conflicts' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return conflict check results',
    schema: {
      type: 'object',
      properties: {
        hasConflicts: { type: 'boolean' },
        conflicts: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              type: { type: 'string' },
              title: { type: 'string' },
              start: { type: 'string' },
              end: { type: 'string' },
              assigneeId: { type: 'string' },
              resourceId: { type: 'string' },
              conflictType: { type: 'string' }
            }
          }
        }
      }
    }
  })
  async checkConflicts(@Query() conflictDto: ConflictCheckDto): Promise<{ 
    hasConflicts: boolean; 
    conflicts: any[] 
  }> {
    return this.calendarService.checkConflicts(conflictDto)
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get calendar event by ID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return calendar event',
    schema: { $ref: '#/components/schemas/CalendarEvent' }
  })
  @ApiResponse({ status: 404, description: 'Calendar event not found' })
  async findOne(@Param('id') id: string): Promise<CalendarEvent> {
    return this.calendarService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create new calendar event' })
  @ApiResponse({ 
    status: 201, 
    description: 'Calendar event created successfully',
    schema: { $ref: '#/components/schemas/CalendarEvent' }
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  async create(
    @Body() createCalendarEventDto: CreateCalendarEventDto,
    @Request() req: any
  ): Promise<CalendarEvent> {
    const createdBy = req.user?.id || 'system'
    return this.calendarService.create(createCalendarEventDto, createdBy)
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update calendar event' })
  @ApiResponse({ 
    status: 200, 
    description: 'Calendar event updated successfully',
    schema: { $ref: '#/components/schemas/CalendarEvent' }
  })
  @ApiResponse({ status: 404, description: 'Calendar event not found' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  async update(
    @Param('id') id: string, 
    @Body() updateCalendarEventDto: UpdateCalendarEventDto
  ): Promise<CalendarEvent> {
    return this.calendarService.update(id, updateCalendarEventDto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete calendar event' })
  @ApiResponse({ status: 200, description: 'Calendar event deleted successfully' })
  @ApiResponse({ status: 404, description: 'Calendar event not found' })
  async remove(@Param('id') id: string): Promise<{ message: string }> {
    await this.calendarService.remove(id)
    return { message: 'Calendar event deleted successfully' }
  }

  @Post('test/seed')
  @ApiOperation({ summary: 'Seed test calendar events' })
  @ApiResponse({ status: 201, description: 'Test events created successfully' })
  async seedTestEvents(): Promise<{ message: string; count: number }> {
    const testEvents = [
      {
        type: EventType.APPOINTMENT,
        title: 'Müşteri Görüşmesi - Ayşe Yılmaz',
        start: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Yarın
        emoji: '📅',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-1'
      },
      {
        type: EventType.FITTING,
        title: 'Prova - Mehmet Kaya',
        start: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(), // 2 gün sonra
        emoji: '👗',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-2'
      },
      {
        type: EventType.RENTAL,
        title: 'Kiralama - Fatma Demir',
        start: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(), // 3 gün sonra
        end: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(), // 5 gün sonra
        emoji: '🏷️',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-3',
        resourceId: 'STK-001'
      },
      {
        type: EventType.ORDER_DELIVERY,
        title: 'Sipariş Teslimi - Ali Veli',
        start: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000).toISOString(), // 4 gün sonra
        emoji: '📦',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-4'
      },
      {
        type: EventType.RECEIVABLE,
        title: 'Tahsilat - Zeynep Öz',
        start: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(), // 5 gün sonra
        emoji: '💰',
        status: EventStatus.PLANNED,
        customerId: 'test-customer-5'
      },
      {
        type: EventType.TODO,
        title: 'Stok Kontrolü',
        start: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000).toISOString(), // 6 gün sonra
        emoji: '✅',
        status: EventStatus.PLANNED
      }
    ]

    let count = 0
    for (const eventData of testEvents) {
      await this.calendarService.create(eventData, 'test-user')
      count++
    }

    return { message: 'Test events created successfully', count }
  }

  @Post('seed')
  @ApiOperation({ summary: 'Seed comprehensive test data' })
  @ApiResponse({ status: 201, description: 'Test data seeded successfully' })
  async seedTestData(): Promise<{ message: string; created: number }> {
    const { created } = await this.calendarService.seedTestData()
    return { message: 'Test data seeded successfully', created }
  }

  @Delete('seed')
  @ApiOperation({ summary: 'Clear test data' })
  @ApiResponse({ status: 200, description: 'Test data cleared successfully' })
  async clearTestData(): Promise<{ message: string; deleted: number }> {
    const { deleted } = await this.calendarService.clearTestData()
    return { message: 'Test data cleared successfully', deleted }
  }
}