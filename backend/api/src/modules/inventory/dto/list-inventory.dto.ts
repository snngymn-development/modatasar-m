import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsArray, IsEnum, IsDateString, IsNumber, Min, Max } from 'class-validator'
import { Transform } from 'class-transformer'

export class ListInventoryDto {
  @ApiPropertyOptional({ description: 'Search query (code, model, product name)' })
  @IsString()
  @IsOptional()
  q?: string

  @ApiPropertyOptional({ description: 'Category filter' })
  @IsString()
  @IsOptional()
  category?: string

  @ApiPropertyOptional({ description: 'Color filter' })
  @IsString()
  @IsOptional()
  color?: string

  @ApiPropertyOptional({ description: 'Size filter' })
  @IsString()
  @IsOptional()
  size?: string

  @ApiPropertyOptional({ 
    description: 'Status filter',
    enum: ['AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE']
  })
  @IsEnum(['AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE'])
  @IsOptional()
  status?: string

  @ApiPropertyOptional({ 
    description: 'Tags filter (comma-separated)',
    type: [String]
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.split(',') : value)
  tags?: string[]

  @ApiPropertyOptional({ description: 'Availability start date (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  from?: string

  @ApiPropertyOptional({ description: 'Availability end date (ISO 8601)' })
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
