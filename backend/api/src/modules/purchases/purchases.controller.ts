import { Controller, Get, Post, Patch, Delete, Param, Body, Query } from '@nestjs/common'
import { ApiTags } from '@nestjs/swagger'
import { PurchasesService } from './purchases.service'
import { CreatePurchaseDto, UpdatePurchaseDto, ListQueryDto } from './dto'

@ApiTags('purchases')
@Controller('purchases')
export class PurchasesController {
  constructor(private readonly service: PurchasesService) {}

  @Get()
  list(@Query() q: ListQueryDto) { 
    return this.service.list(q) 
  }

  @Post()
  create(@Body() dto: CreatePurchaseDto) { 
    return this.service.create(dto) 
  }

  @Get(':id')
  get(@Param('id') id: string) { 
    return this.service.get(id) 
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdatePurchaseDto) { 
    return this.service.update(id, dto) 
  }

  @Patch(':id/recalc')
  recalc(@Param('id') id: string) { 
    return this.service.recalc(id) 
  }

  // ilerleyen aşama endpointleri (iskele)
  @Post(':id/submit')
  submit(@Param('id') id: string) { 
    return this.service.submit(id) 
  }

  @Post(':id/receipts')
  receipt(@Param('id') id: string, @Body() body: any) { 
    return this.service.createReceipt(id, body) 
  }

  @Post(':id/close')
  close(@Param('id') id: string) { 
    return this.service.close(id) 
  }

  @Post(':id/payments')
  pay(@Param('id') id: string, @Body() body: any) { 
    return this.service.addPayment(id, body) 
  }

  // Purchase Items endpoints
  @Post(':id/items')
  addItem(@Param('id') id: string, @Body() body: any) { return this.service.addItem(id, body) }

  @Patch('items/:itemId')
  updateItem(@Param('itemId') itemId: string, @Body() body: any) { return this.service.updateItem(itemId, body) }

  @Delete('items/:itemId')
  deleteItem(@Param('itemId') itemId: string) { return this.service.deleteItem(itemId) }
}
