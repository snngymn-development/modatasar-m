import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsArray, IsEnum, IsBoolean, IsNumber, Min, Max } from 'class-validator'
import { Transform } from 'class-transformer'

export class ListStocksDto {
  @ApiPropertyOptional({ description: 'Search query (card code, name)' })
  @IsString()
  @IsOptional()
  q?: string

  @ApiPropertyOptional({ description: 'Supplier ID filter' })
  @IsString()
  @IsOptional()
  supplierId?: string

  @ApiPropertyOptional({ description: 'Category filter' })
  @IsString()
  @IsOptional()
  category?: string

  @ApiPropertyOptional({ description: 'Type filter' })
  @IsString()
  @IsOptional()
  type?: string

  @ApiPropertyOptional({ description: 'Kind filter' })
  @IsString()
  @IsOptional()
  kind?: string

  @ApiPropertyOptional({ description: 'Group filter' })
  @IsString()
  @IsOptional()
  group?: string

  @ApiPropertyOptional({ description: 'Location/warehouse filter' })
  @IsString()
  @IsOptional()
  location?: string

  @ApiPropertyOptional({ description: 'Unit filter' })
  @IsString()
  @IsOptional()
  unit?: string

  @ApiPropertyOptional({ description: 'Show only items below critical level' })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  belowCritical?: boolean

  @ApiPropertyOptional({ 
    description: 'Tags filter (comma-separated)',
    type: [String]
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.split(',') : value)
  tags?: string[]

  @ApiPropertyOptional({ 
    description: 'Status filter',
    enum: ['ACTIVE', 'PASSIVE']
  })
  @IsEnum(['ACTIVE', 'PASSIVE'])
  @IsOptional()
  status?: string

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
