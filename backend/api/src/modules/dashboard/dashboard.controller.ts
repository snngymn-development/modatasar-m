import { Controller, Get } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { DashboardService } from './dashboard.service'

@ApiTags('dashboard')
@Controller('api/dashboard')
export class DashboardController {
  constructor(private readonly service: DashboardService) {}

  @Get('cards')
  @ApiOperation({ summary: 'Get dashboard info cards' })
  @ApiResponse({ status: 200, description: 'Return dashboard cards data' })
  getCards() {
    return this.service.getCards()
  }

  @Get()
  @ApiOperation({ summary: 'Get dashboard overview' })
  @ApiResponse({ status: 200, description: 'Return dashboard overview data' })
  getDashboard() {
    return this.service.getDashboard()
  }
}

