import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsNumber, IsString, IsNotEmpty, IsOptional, Min } from 'class-validator'

export class AdjustStockDto {
  @ApiProperty({ description: 'New quantity after adjustment', minimum: 0 })
  @IsNumber()
  @Min(0)
  newQty: number

  @ApiProperty({ description: 'Reason for adjustment' })
  @IsString()
  @IsNotEmpty()
  reason: string

  @ApiPropertyOptional({ description: 'Additional note' })
  @IsString()
  @IsOptional()
  note?: string
}
