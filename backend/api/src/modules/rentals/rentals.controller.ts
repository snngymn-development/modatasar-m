import { Controller, Get, Post, Body, Param, Put, Delete, Patch, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { RentalsService } from './rentals.service'
import { CreateRentalDto, UpdateRentalDto, UpdateRentalPeriodDto } from './dto'

@ApiTags('rentals')
@Controller('rentals')
export class RentalsController {
  constructor(private readonly rentalsService: RentalsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all rentals' })
  @ApiResponse({ status: 200, description: 'Return all rentals.' })
  findAll(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    return this.rentalsService.findAll(startDate, endDate)
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get rental by id' })
  @ApiResponse({ status: 200, description: 'Return rental.' })
  @ApiResponse({ status: 404, description: 'Rental not found.' })
  findOne(@Param('id') id: string) {
    return this.rentalsService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create rental (creates Order + Rental)' })
  @ApiResponse({ status: 201, description: 'Rental created.' })
  create(@Body() createRentalDto: CreateRentalDto) {
    return this.rentalsService.create(createRentalDto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update rental' })
  @ApiResponse({ status: 200, description: 'Rental updated.' })
  @ApiResponse({ status: 404, description: 'Rental not found.' })
  update(@Param('id') id: string, @Body() updateRentalDto: UpdateRentalDto) {
    return this.rentalsService.update(id, updateRentalDto)
  }

  @Patch(':id/period')
  @ApiOperation({
    summary: 'Update rental period (drag & drop)',
    description: 'Updates rental dates and recalculates Order total',
  })
  @ApiResponse({ status: 200, description: 'Rental period updated, Order total recalculated.' })
  @ApiResponse({ status: 404, description: 'Rental not found.' })
  updatePeriod(@Param('id') id: string, @Body() dto: UpdateRentalPeriodDto) {
    return this.rentalsService.updatePeriod(id, dto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete rental' })
  @ApiResponse({ status: 200, description: 'Rental deleted.' })
  @ApiResponse({ status: 404, description: 'Rental not found.' })
  remove(@Param('id') id: string) {
    return this.rentalsService.remove(id)
  }
}