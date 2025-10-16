import { Controller, Get, Param, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { InventoryService } from './inventory.service'
import { ListInventoryDto, InventoryDetailDto } from './dto'

@ApiTags('inventory')
@Controller('inventory')
export class InventoryController {
  constructor(private readonly service: InventoryService) {}

  @Get()
  @ApiOperation({ summary: 'Get inventory items (read-only)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return inventory items',
    schema: {
      type: 'object',
      properties: {
        items: { type: 'array', items: { type: 'object' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' }
      }
    }
  })
  findAll(@Query() filters: ListInventoryDto) {
    return this.service.findAll(filters)
  }

  @Get(':id/detail')
  @ApiOperation({ summary: 'Get inventory item detail (read-only)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return inventory item detail',
    type: InventoryDetailDto
  })
  @ApiResponse({ status: 404, description: 'Product not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }
}
