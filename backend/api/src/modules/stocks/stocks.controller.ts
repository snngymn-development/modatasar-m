import { Controller, Get, Post, Param, Body, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { StocksService } from './stocks.service'
import { ListStocksDto, ConsumeStockDto, AdjustStockDto, ListMovementsDto } from './dto'

@ApiTags('stocks')
@Controller('stocks')
export class StocksController {
  constructor(private readonly service: StocksService) {}

  @Get()
  @ApiOperation({ summary: 'Get stock cards' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return stock cards',
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
  findAll(@Query() filters: ListStocksDto) {
    return this.service.findAll(filters)
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get stock card detail' })
  @ApiResponse({ status: 200, description: 'Return stock card detail' })
  @ApiResponse({ status: 404, description: 'Stock card not found' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }

  @Get(':id/movements')
  @ApiOperation({ summary: 'Get stock movements history' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return stock movements',
    schema: {
      type: 'object',
      properties: {
        movements: { type: 'array', items: { type: 'object' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' }
      }
    }
  })
  getMovements(@Param('id') id: string, @Query() filters: ListMovementsDto) {
    return this.service.getMovements(id, filters)
  }

  @Post(':id/consume')
  @ApiOperation({ summary: 'Consume stock (OUT movement)' })
  @ApiResponse({ status: 201, description: 'Stock consumed successfully' })
  @ApiResponse({ status: 400, description: 'Insufficient stock' })
  @ApiResponse({ status: 404, description: 'Stock card not found' })
  consume(@Param('id') id: string, @Body() dto: ConsumeStockDto) {
    // TODO: Get user ID from auth context
    const userId = 'system'
    return this.service.consume(id, dto, userId)
  }

  @Post(':id/adjust')
  @ApiOperation({ summary: 'Adjust stock quantity' })
  @ApiResponse({ status: 201, description: 'Stock adjusted successfully' })
  @ApiResponse({ status: 404, description: 'Stock card not found' })
  adjust(@Param('id') id: string, @Body() dto: AdjustStockDto) {
    // TODO: Get user ID from auth context
    const userId = 'system'
    return this.service.adjust(id, dto, userId)
  }
}
