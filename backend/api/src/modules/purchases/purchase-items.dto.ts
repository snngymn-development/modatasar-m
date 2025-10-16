import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsNumber, IsPositive, Min } from 'class-validator'

export class CreatePurchaseItemDto {
  @ApiProperty()
  @IsString()
  purchaseId: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  productId?: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string
  
  @ApiProperty()
  @IsNumber()
  @IsPositive()
  qtyOrdered: number
  
  @ApiProperty()
  @IsNumber()
  @Min(0)
  unitPrice: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  lineDiscountTot?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  lineChargeTot?: number
}

export class UpdatePurchaseItemDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  productId?: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @IsPositive()
  qtyOrdered?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  unitPrice?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  lineDiscountTot?: number
  
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(0)
  lineChargeTot?: number
}
