import { ApiProperty } from '@nestjs/swagger'

export class CreateCustomerDto {
  @ApiProperty()
  name!: string

  @ApiProperty({ required: false })
  phone?: string

  @ApiProperty({ required: false })
  email?: string
}

export class UpdateCustomerDto {
  @ApiProperty({ required: false })
  name?: string

  @ApiProperty({ required: false })
  phone?: string

  @ApiProperty({ required: false })
  email?: string
}

