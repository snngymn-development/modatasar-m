import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

export class InventoryDetailDto {
  @ApiProperty({ description: 'Product ID' })
  id: string

  @ApiProperty({ description: 'Product name' })
  name: string

  @ApiPropertyOptional({ description: 'Product model' })
  model?: string

  @ApiPropertyOptional({ description: 'Product color' })
  color?: string

  @ApiPropertyOptional({ description: 'Product size' })
  size?: string

  @ApiPropertyOptional({ description: 'Product category' })
  category?: string

  @ApiProperty({ description: 'Product tags (comma-separated)' })
  tags: string

  @ApiProperty({ 
    description: 'Product status',
    enum: ['AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE']
  })
  status: string

  @ApiProperty({ description: 'Creation date (ISO 8601)' })
  createdAt: string

  @ApiPropertyOptional({ description: 'Last activity summary' })
  lastActivity?: {
    type: string
    date: string
    description: string
  }

  @ApiPropertyOptional({ description: 'Availability status for date range' })
  availability?: {
    isAvailable: boolean
    conflicts?: Array<{
      type: string
      start: string
      end: string
      description: string
    }>
  }
}
