import { ApiProperty } from '@nestjs/swagger'
import { IsOptional, IsString, IsNumber, IsEnum } from 'class-validator'
import { Type } from 'class-transformer'

export class FindTransactionsDto {
  @ApiProperty({
    required: false,
    enum: ['TAILORING', 'RENTAL'],
    description: 'Filter by order type',
    example: 'TAILORING',
  })
  @IsOptional()
  @IsString()
  type?: string

  @ApiProperty({ required: false, description: 'Filter by customer ID' })
  @IsOptional()
  @IsString()
  customerId?: string

  @ApiProperty({ required: false, description: 'Filter by organization name' })
  @IsOptional()
  @IsString()
  organization?: string

  @ApiProperty({
    required: false,
    enum: ['STARTED', 'HALF_DONE', 'NEARLY_DONE', 'READY_FOR_DELIVERY', 'DELIVERED'],
    description: 'Filter by status',
    example: 'ACTIVE',
  })
  @IsOptional()
  @IsString()
  status?: string

  @ApiProperty({ required: false, default: 1, description: 'Page number' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  page?: number

  @ApiProperty({ required: false, default: 20, description: 'Items per page' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number

  @ApiProperty({ required: false, default: 20, description: 'Page size' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  pageSize?: number
}