import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsOptional, IsEnum, MinLength } from 'class-validator'

export class CreateAgendaEventDto {
  @ApiProperty({ description: 'Product ID' })
  @IsString()
  @MinLength(1)
  productId!: string

  @ApiProperty({
    enum: ['DRY_CLEANING', 'ALTERATION', 'OUT_OF_SERVICE'],
    description: 'Agenda event type',
  })
  @IsEnum(['DRY_CLEANING', 'ALTERATION', 'OUT_OF_SERVICE'])
  type!: string

  @ApiProperty({ description: 'Start date (ISO 8601)', example: '2025-10-20T00:00:00Z' })
  @IsString()
  start!: string

  @ApiProperty({ description: 'End date (ISO 8601)', example: '2025-10-22T00:00:00Z' })
  @IsString()
  end!: string

  @ApiProperty({ required: false, description: 'Optional note' })
  @IsString()
  @IsOptional()
  note?: string
}

export class UpdateAgendaEventPeriodDto {
  @ApiProperty({ description: 'New start date (ISO 8601)' })
  @IsString()
  start!: string

  @ApiProperty({ description: 'New end date (ISO 8601)' })
  @IsString()
  end!: string
}

