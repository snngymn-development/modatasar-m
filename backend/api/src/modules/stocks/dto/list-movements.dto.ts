import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsDateString, IsNumber, IsOptional, Min, Max } from 'class-validator'
import { Transform } from 'class-transformer'

export class ListMovementsDto {
  @ApiPropertyOptional({ description: 'Start date filter (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  from?: string

  @ApiPropertyOptional({ description: 'End date filter (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  to?: string

  @ApiPropertyOptional({ description: 'Page number', minimum: 1 })
  @IsNumber()
  @Min(1)
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  page?: number = 1

  @ApiPropertyOptional({ description: 'Page size', minimum: 1, maximum: 100 })
  @IsNumber()
  @Min(1)
  @Max(100)
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  limit?: number = 25
}
