import { Controller, Get, Post, Body, Param, Put, Delete, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger'
import { SuppliersService } from './suppliers.service'
import { CreateSupplierDto, UpdateSupplierDto } from './dto'

@ApiTags('suppliers')
@Controller('suppliers')
export class SuppliersController {
  constructor(private readonly suppliersService: SuppliersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all suppliers with filters' })
  @ApiResponse({ status: 200, description: 'Return paginated suppliers list' })
  @ApiQuery({ name: 'name', required: false, description: 'Filter by supplier name' })
  @ApiQuery({ name: 'phone', required: false, description: 'Filter by phone' })
  @ApiQuery({ name: 'city', required: false, description: 'Filter by city' })
  @ApiQuery({ name: 'category', required: false, description: 'Filter by category' })
  @ApiQuery({ name: 'status', required: false, description: 'Filter by status' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page' })
  @ApiQuery({ name: 'sort', required: false, description: 'Sort field:direction' })
  findAll(
    @Query('name') name?: string,
    @Query('phone') phone?: string,
    @Query('city') city?: string,
    @Query('category') category?: string,
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('sort') sort?: string
  ) {
    return this.suppliersService.findAll({
      name,
      phone,
      city,
      category,
      status,
      page,
      limit,
      sort
    })
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get supplier by id' })
  @ApiResponse({ status: 200, description: 'Return supplier' })
  @ApiResponse({ status: 404, description: 'Supplier not found' })
  findOne(@Param('id') id: string) {
    return this.suppliersService.findOne(id)
  }

  @Get(':id/detail')
  @ApiOperation({ summary: 'Get supplier detail with related data' })
  @ApiResponse({ status: 200, description: 'Return supplier detail' })
  @ApiResponse({ status: 404, description: 'Supplier not found' })
  findDetail(@Param('id') id: string) {
    return this.suppliersService.findDetail(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create supplier' })
  @ApiResponse({ status: 201, description: 'Supplier created' })
  create(@Body() createSupplierDto: CreateSupplierDto) {
    return this.suppliersService.create(createSupplierDto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update supplier' })
  @ApiResponse({ status: 200, description: 'Supplier updated' })
  @ApiResponse({ status: 404, description: 'Supplier not found' })
  update(@Param('id') id: string, @Body() updateSupplierDto: UpdateSupplierDto) {
    return this.suppliersService.update(id, updateSupplierDto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete supplier' })
  @ApiResponse({ status: 200, description: 'Supplier deleted' })
  @ApiResponse({ status: 404, description: 'Supplier not found' })
  remove(@Param('id') id: string) {
    return this.suppliersService.remove(id)
  }
}
