import { Controller, Get, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { TransactionsService } from './transactions.service'
import { FindTransactionsDto } from './dto'

@ApiTags('transactions')
@Controller('transactions')
export class TransactionsController {
  constructor(private readonly service: TransactionsService) {}

  @Get()
  @ApiOperation({ summary: 'Get transactions (Orders + Rentals combined view)' })
  @ApiResponse({ status: 200, description: 'Return paginated transactions' })
  async findMany(@Query() query: FindTransactionsDto) {
    return this.service.findMany(query)
  }

  @Get('summary')
  @ApiOperation({ summary: 'Get transaction counts for chip counters' })
  @ApiResponse({
    status: 200,
    description: 'Return tailoring and rental counts',
    schema: {
      example: {
        tailoringCount: 25,
        rentalCount: 12,
        totalCount: 37,
      },
    },
  })
  async getSummary() {
    return this.service.getSummary()
  }
}

