import { Controller, Get, Post, Body, Param, Put, Delete, Patch } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { OrdersService } from './orders.service'
import { 
  CreateOrderDto, 
  UpdateOrderDto, 
  AddFittingDto, 
  UpdateOrderStatusDto, 
  AddChargeDto, 
  AddDiscountDto,
  CustomerBodyMeasurementsDto 
} from './dto'

@ApiTags('orders')
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all orders' })
  @ApiResponse({ status: 200, description: 'Return all orders with details, fittings, and status history.' })
  findAll() {
    return this.ordersService.findAll()
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get order by id' })
  @ApiResponse({ status: 200, description: 'Return order with all details.' })
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create new tailoring order' })
  @ApiResponse({ status: 201, description: 'Order created successfully.' })
  create(@Body() createOrderDto: CreateOrderDto) {
    return this.ordersService.create(createOrderDto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update order' })
  @ApiResponse({ status: 200, description: 'Order updated successfully.' })
  update(@Param('id') id: string, @Body() updateOrderDto: UpdateOrderDto) {
    return this.ordersService.update(id, updateOrderDto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete order' })
  @ApiResponse({ status: 200, description: 'Order deleted successfully.' })
  remove(@Param('id') id: string) {
    return this.ordersService.remove(id)
  }

  // Fitting management
  @Post('fittings')
  @ApiOperation({ summary: 'Add fitting to order' })
  @ApiResponse({ status: 201, description: 'Fitting added successfully.' })
  addFitting(@Body() addFittingDto: AddFittingDto) {
    return this.ordersService.addFitting(addFittingDto)
  }

  // Status management
  @Patch('status')
  @ApiOperation({ summary: 'Update order status' })
  @ApiResponse({ status: 200, description: 'Order status updated successfully.' })
  updateStatus(@Body() updateOrderStatusDto: UpdateOrderStatusDto) {
    return this.ordersService.updateOrderStatus(updateOrderStatusDto)
  }

  // Charge management
  @Post('charges')
  @ApiOperation({ summary: 'Add charge to order detail' })
  @ApiResponse({ status: 201, description: 'Charge added successfully.' })
  addCharge(@Body() addChargeDto: AddChargeDto) {
    return this.ordersService.addCharge(addChargeDto)
  }

  // Discount management
  @Post('discounts')
  @ApiOperation({ summary: 'Add discount to order detail' })
  @ApiResponse({ status: 201, description: 'Discount added successfully.' })
  addDiscount(@Body() addDiscountDto: AddDiscountDto) {
    return this.ordersService.addDiscount(addDiscountDto)
  }

  // Customer body measurements
  @Get('customers/:customerId/measurements')
  @ApiOperation({ summary: 'Get customer body measurements' })
  @ApiResponse({ status: 200, description: 'Return customer body measurements history.' })
  getCustomerBodyMeasurements(@Param('customerId') customerId: string) {
    return this.ordersService.getCustomerBodyMeasurements(customerId)
  }

  @Get('customers/:customerId/measurements/latest')
  @ApiOperation({ summary: 'Get latest customer body measurements' })
  @ApiResponse({ status: 200, description: 'Return latest customer body measurements.' })
  getLatestCustomerBodyMeasurements(@Param('customerId') customerId: string) {
    return this.ordersService.getLatestCustomerBodyMeasurements(customerId)
  }

  @Post('customers/measurements')
  @ApiOperation({ summary: 'Create customer body measurements' })
  @ApiResponse({ status: 201, description: 'Body measurements created successfully.' })
  createCustomerBodyMeasurements(@Body() measurementsDto: CustomerBodyMeasurementsDto) {
    return this.ordersService.createCustomerBodyMeasurements(measurementsDto)
  }
}