import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsNumber, IsPositive, IsIn } from 'class-validator'

export class CreateHeaderChargeDto {
  @ApiProperty()
  @IsString()
  purchaseId: string
  
  @ApiProperty()
  @IsString()
  label: string
  
  @ApiProperty()
  @IsNumber()
  @IsPositive()
  amount: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsIn(['PROPORTIONAL', 'BY_QTY', 'BY_VALUE', 'NONE'])
  allocate?: string
}

export class CreateHeaderDiscountDto {
  @ApiProperty()
  @IsString()
  purchaseId: string
  
  @ApiProperty()
  @IsString()
  label: string
  
  @ApiProperty()
  @IsNumber()
  @IsPositive()
  amount: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsIn(['ABS', 'PCT'])
  kind?: string
}

export class UpdateHeaderChargeDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  label?: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @IsPositive()
  amount?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsIn(['PROPORTIONAL', 'BY_QTY', 'BY_VALUE', 'NONE'])
  allocate?: string
}

export class UpdateHeaderDiscountDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  label?: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @IsPositive()
  amount?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @IsIn(['ABS', 'PCT'])
  kind?: string
}
