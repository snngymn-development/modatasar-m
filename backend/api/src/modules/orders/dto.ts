import { ApiProperty } from '@nestjs/swagger'

export class CreateOrderDto {
  @ApiProperty()
  type: string

  @ApiProperty()
  customerId: string

  @ApiProperty({ required: false })
  organization?: string

  @ApiProperty({ required: false })
  deliveryDate?: Date

  @ApiProperty()
  total: number

  @ApiProperty()
  collected: number

  @ApiProperty()
  paymentStatus: string

  @ApiProperty()
  status: string
}

export class UpdateOrderDto {
  @ApiProperty({ required: false })
  type?: string

  @ApiProperty({ required: false })
  customerId?: string

  @ApiProperty({ required: false })
  organization?: string

  @ApiProperty({ required: false })
  deliveryDate?: Date

  @ApiProperty({ required: false })
  total?: number

  @ApiProperty({ required: false })
  collected?: number

  @ApiProperty({ required: false })
  paymentStatus?: string

  @ApiProperty({ required: false })
  status?: string
}

