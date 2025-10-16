import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsEnum, IsDateString, IsArray, IsNumber, Min, Max } from 'class-validator'
// Event types and statuses
export const EventType = {
  APPOINTMENT: 'APPOINTMENT',
  FITTING: 'FITTING',
  ORDER_DELIVERY: 'ORDER_DELIVERY',
  RENTAL: 'RENTAL',
  RECEIVABLE: 'RECEIVABLE',
  PAYABLE: 'PAYABLE',
  TODO: 'TODO',
} as const

export const EventStatus = {
  PLANNED: 'PLANNED',
  DONE: 'DONE',
  CANCELLED: 'CANCELLED',
} as const

export type EventType = typeof EventType[keyof typeof EventType]
export type EventStatus = typeof EventStatus[keyof typeof EventStatus]

export class CreateCalendarEventDto {
  @ApiProperty({ enum: EventType, description: 'Event type' })
  @IsEnum(EventType)
  type: EventType

  @ApiProperty({ description: 'Event title' })
  @IsString()
  title: string

  @ApiProperty({ description: 'Start date and time (ISO 8601)' })
  @IsDateString()
  start: string

  @ApiPropertyOptional({ description: 'End date and time (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  end?: string

  @ApiProperty({ description: 'Emoji representation' })
  @IsString()
  emoji: string

  @ApiPropertyOptional({ enum: EventStatus, description: 'Event status' })
  @IsEnum(EventStatus)
  @IsOptional()
  status?: EventStatus

  @ApiPropertyOptional({ description: 'Customer ID' })
  @IsString()
  @IsOptional()
  customerId?: string

  @ApiPropertyOptional({ description: 'Assignee ID (staff member)' })
  @IsString()
  @IsOptional()
  assigneeId?: string

  @ApiPropertyOptional({ description: 'Resource ID (product, room, etc.)' })
  @IsString()
  @IsOptional()
  resourceId?: string

  @ApiPropertyOptional({ description: 'Source table name' })
  @IsString()
  @IsOptional()
  sourceTable?: string

  @ApiPropertyOptional({ description: 'Source record ID' })
  @IsString()
  @IsOptional()
  sourceId?: string

  @ApiPropertyOptional({ description: 'Type-specific data (JSON)' })
  @IsOptional()
  payload?: Record<string, any>
}

export class UpdateCalendarEventDto {
  @ApiPropertyOptional({ enum: EventType, description: 'Event type' })
  @IsEnum(EventType)
  @IsOptional()
  type?: EventType

  @ApiPropertyOptional({ description: 'Event title' })
  @IsString()
  @IsOptional()
  title?: string

  @ApiPropertyOptional({ description: 'Start date and time (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  start?: string

  @ApiPropertyOptional({ description: 'End date and time (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  end?: string

  @ApiPropertyOptional({ description: 'Emoji representation' })
  @IsString()
  @IsOptional()
  emoji?: string

  @ApiPropertyOptional({ enum: EventStatus, description: 'Event status' })
  @IsEnum(EventStatus)
  @IsOptional()
  status?: EventStatus

  @ApiPropertyOptional({ description: 'Customer ID' })
  @IsString()
  @IsOptional()
  customerId?: string

  @ApiPropertyOptional({ description: 'Assignee ID (staff member)' })
  @IsString()
  @IsOptional()
  assigneeId?: string

  @ApiPropertyOptional({ description: 'Resource ID (product, room, etc.)' })
  @IsString()
  @IsOptional()
  resourceId?: string

  @ApiPropertyOptional({ description: 'Type-specific data (JSON)' })
  @IsOptional()
  payload?: Record<string, any>
}

export class CalendarFilterDto {
  @ApiPropertyOptional({ description: 'Start date filter (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  from?: string

  @ApiPropertyOptional({ description: 'End date filter (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  to?: string

  @ApiPropertyOptional({ 
    description: 'Event types filter',
    type: [String],
    enum: EventType
  })
  @IsArray()
  @IsEnum(EventType, { each: true })
  @IsOptional()
  types?: EventType[]

  @ApiPropertyOptional({ description: 'Assignee ID filter' })
  @IsString()
  @IsOptional()
  assigneeId?: string

  @ApiPropertyOptional({ description: 'Customer ID filter' })
  @IsString()
  @IsOptional()
  customerId?: string

  @ApiPropertyOptional({ description: 'Resource ID filter' })
  @IsString()
  @IsOptional()
  resourceId?: string

  @ApiPropertyOptional({ description: 'Search query' })
  @IsString()
  @IsOptional()
  query?: string

  @ApiPropertyOptional({ description: 'Page number', minimum: 1 })
  @IsNumber()
  @Min(1)
  @IsOptional()
  page?: number = 1

  @ApiPropertyOptional({ description: 'Page size', minimum: 1, maximum: 100 })
  @IsNumber()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 50
}

export class ConflictCheckDto {
  @ApiProperty({ description: 'Start date and time (ISO 8601)' })
  @IsDateString()
  start: string

  @ApiProperty({ description: 'End date and time (ISO 8601)' })
  @IsDateString()
  end: string

  @ApiPropertyOptional({ description: 'Assignee ID to check' })
  @IsString()
  @IsOptional()
  assigneeId?: string

  @ApiPropertyOptional({ description: 'Resource ID to check' })
  @IsString()
  @IsOptional()
  resourceId?: string

  @ApiPropertyOptional({ description: 'Event ID to exclude from conflict check' })
  @IsString()
  @IsOptional()
  excludeEventId?: string
}
