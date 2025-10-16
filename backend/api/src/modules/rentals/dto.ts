import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsOptional, MinLength } from 'class-validator'

export class CreateRentalDto {
  @ApiProperty({ description: 'Order ID (1-to-1 relationship)' })
  @IsString()
  @MinLength(1)
  orderId!: string

  @ApiProperty({ description: 'Product ID' })
  @IsString()
  @MinLength(1)
  productId!: string

  @ApiProperty({ description: 'Start date (ISO 8601)', example: '2025-10-20T00:00:00Z' })
  @IsString()
  start!: string

  @ApiProperty({ description: 'End date (ISO 8601)', example: '2025-10-22T00:00:00Z' })
  @IsString()
  end!: string

  @ApiProperty({ required: false, description: 'Organization name' })
  @IsString()
  @IsOptional()
  organization?: string
}

export class UpdateRentalDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  productId?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  start?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  end?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  organization?: string
}

export class UpdateRentalPeriodDto {
  @ApiProperty({ description: 'New start date (ISO 8601)' })
  @IsString()
  start!: string

  @ApiProperty({ description: 'New end date (ISO 8601)' })
  @IsString()
  end!: string
}

