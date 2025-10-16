import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsIn } from 'class-validator'

export class CreatePurchaseDto {
  @ApiProperty() 
  @IsString()
  supplierId: string
  
  @ApiProperty() 
  @IsString()
  @IsIn(['EXPENSE', 'STOCK', 'INVENTORY'])
  type: 'EXPENSE'|'STOCK'|'INVENTORY'
  
  @ApiPropertyOptional() 
  @IsOptional()
  @IsString()
  note?: string
}

export class UpdatePurchaseDto {
  @ApiPropertyOptional() 
  date?: string
  
  @ApiPropertyOptional() 
  supplierId?: string
  
  @ApiPropertyOptional() 
  type?: 'EXPENSE'|'STOCK'|'INVENTORY'
  
  @ApiPropertyOptional() 
  note?: string
  
  @ApiPropertyOptional() 
  paid?: number
  
  @ApiPropertyOptional() 
  paymentStatus?: 'UNPAID'|'PARTIAL'|'PAID'
  
  @ApiPropertyOptional() 
  status?: 'DRAFT'|'ORDERED'|'PARTIAL_RECEIVED'|'RECEIVED'|'CLOSED'|'CANCELLED'
}

export class ListQueryDto {
  @ApiPropertyOptional() 
  q?: string
  
  @ApiPropertyOptional() 
  supplierId?: string
  
  @ApiPropertyOptional() 
  type?: 'EXPENSE'|'STOCK'|'INVENTORY'
  
  @ApiPropertyOptional() 
  status?: string
  
  @ApiPropertyOptional() 
  paymentStatus?: string
  
  @ApiPropertyOptional() 
  dateFrom?: string
  
  @ApiPropertyOptional() 
  dateTo?: string
  
  @ApiPropertyOptional() 
  page?: number
  
  @ApiPropertyOptional() 
  limit?: number
}
