import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsNumber, IsString, IsOptional, IsPositive, IsEnum } from 'class-validator'

export class ConsumeStockDto {
  @ApiProperty({ description: 'Quantity to consume', minimum: 1 })
  @IsNumber()
  @IsPositive()
  qty: number

  @ApiProperty({ description: 'Unit of measurement' })
  @IsString()
  unit: string

  @ApiPropertyOptional({ 
    description: 'Reference type',
    enum: ['TAILORING', 'RENTAL', 'ORDER', 'OTHER']
  })
  @IsEnum(['TAILORING', 'RENTAL', 'ORDER', 'OTHER'])
  @IsOptional()
  referenceType?: string

  @ApiPropertyOptional({ description: 'Reference ID' })
  @IsString()
  @IsOptional()
  referenceId?: string

  @ApiPropertyOptional({ description: 'Note about consumption' })
  @IsString()
  @IsOptional()
  note?: string
}
