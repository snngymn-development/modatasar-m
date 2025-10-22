import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsArray, ValidateNested, IsEnum, Min, Max } from 'class-validator'
import { Type } from 'class-transformer'

// Order Detail DTOs
export class OrderChargeDto {
  @ApiProperty({ description: 'Masraf etiketi' })
  @IsString()
  label: string

  @ApiProperty({ description: 'Masraf tutarı (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'Masraf açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string
}

export class OrderDiscountDto {
  @ApiProperty({ description: 'İndirim etiketi' })
  @IsString()
  label: string

  @ApiProperty({ description: 'İndirim tutarı (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'İndirim açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string
}

export class OrderDetailDto {
  @ApiProperty({ description: 'Sipariş açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string

  @ApiProperty({ description: 'Tutar (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'Masraflar', type: [OrderChargeDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderChargeDto)
  charges?: OrderChargeDto[]

  @ApiProperty({ description: 'İndirimler', type: [OrderDiscountDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderDiscountDto)
  discounts?: OrderDiscountDto[]

  @ApiProperty({ description: 'Önemli not', required: false })
  @IsOptional()
  @IsString()
  importantNote?: string
}

export class OrderFittingDto {
  @ApiProperty({ description: 'Prova numarası' })
  @IsNumber()
  @Min(1)
  fittingNumber: number

  @ApiProperty({ description: 'Prova tarihi' })
  @IsString()
  fittingDate: string

  @ApiProperty({ description: 'Prova notları', required: false })
  @IsOptional()
  @IsString()
  notes?: string

  @ApiProperty({ description: 'Prova durumu', enum: ['SCHEDULED', 'COMPLETED', 'CANCELLED'], required: false })
  @IsOptional()
  @IsEnum(['SCHEDULED', 'COMPLETED', 'CANCELLED'])
  status?: string
}

export class CreateOrderDto {
  @ApiProperty({ description: 'Sipariş türü', enum: ['TAILORING'] })
  @IsEnum(['TAILORING'])
  type: string

  @ApiProperty({ description: 'Müşteri ID' })
  @IsString()
  customerId: string

  @ApiProperty({ description: 'Organizasyon', required: false })
  @IsOptional()
  @IsString()
  organization?: string

  @ApiProperty({ description: 'Teslim tarihi' })
  @IsString()
  deliveryDate: string

  @ApiProperty({ description: 'Sipariş açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string

  @ApiProperty({ description: 'Tutar (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'Önemli not', required: false })
  @IsOptional()
  @IsString()
  importantNote?: string

  @ApiProperty({ description: 'Masraflar', type: [OrderChargeDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderChargeDto)
  charges?: OrderChargeDto[]

  @ApiProperty({ description: 'İndirimler', type: [OrderDiscountDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderDiscountDto)
  discounts?: OrderDiscountDto[]

  @ApiProperty({ description: 'Provalar', type: [OrderFittingDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderFittingDto)
  fittings?: OrderFittingDto[]
}

export class UpdateOrderDto {
  @ApiProperty({ description: 'Sipariş türü', enum: ['TAILORING'], required: false })
  @IsOptional()
  @IsEnum(['TAILORING'])
  type?: string

  @ApiProperty({ description: 'Müşteri ID', required: false })
  @IsOptional()
  @IsString()
  customerId?: string

  @ApiProperty({ description: 'Organizasyon', required: false })
  @IsOptional()
  @IsString()
  organization?: string

  @ApiProperty({ description: 'Teslim tarihi', required: false })
  @IsOptional()
  @IsString()
  deliveryDate?: string

  @ApiProperty({ description: 'Sipariş açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string

  @ApiProperty({ description: 'Tutar (kuruş)', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number

  @ApiProperty({ description: 'Önemli not', required: false })
  @IsOptional()
  @IsString()
  importantNote?: string

  @ApiProperty({ description: 'Masraflar', type: [OrderChargeDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderChargeDto)
  charges?: OrderChargeDto[]

  @ApiProperty({ description: 'İndirimler', type: [OrderDiscountDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderDiscountDto)
  discounts?: OrderDiscountDto[]

  @ApiProperty({ description: 'Provalar', type: [OrderFittingDto], required: false })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderFittingDto)
  fittings?: OrderFittingDto[]
}

// Additional DTOs for specific operations
export class AddFittingDto {
  @ApiProperty({ description: 'Sipariş ID' })
  @IsString()
  orderId: string

  @ApiProperty({ description: 'Prova numarası' })
  @IsNumber()
  @Min(1)
  fittingNumber: number

  @ApiProperty({ description: 'Prova tarihi' })
  @IsString()
  fittingDate: string

  @ApiProperty({ description: 'Prova notları', required: false })
  @IsOptional()
  @IsString()
  notes?: string
}

export class UpdateOrderStatusDto {
  @ApiProperty({ description: 'Sipariş ID' })
  @IsString()
  orderId: string

  @ApiProperty({ description: 'Durum', enum: ['STARTED', 'PROGRESS_50', 'PROGRESS_80', 'READY', 'DELIVERED'] })
  @IsEnum(['STARTED', 'PROGRESS_50', 'PROGRESS_80', 'READY', 'DELIVERED'])
  status: string

  @ApiProperty({ description: 'Durum notları', required: false })
  @IsOptional()
  @IsString()
  notes?: string
}

export class AddChargeDto {
  @ApiProperty({ description: 'Sipariş detay ID' })
  @IsString()
  orderDetailId: string

  @ApiProperty({ description: 'Masraf etiketi' })
  @IsString()
  label: string

  @ApiProperty({ description: 'Masraf tutarı (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'Masraf açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string
}

export class AddDiscountDto {
  @ApiProperty({ description: 'Sipariş detay ID' })
  @IsString()
  orderDetailId: string

  @ApiProperty({ description: 'İndirim etiketi' })
  @IsString()
  label: string

  @ApiProperty({ description: 'İndirim tutarı (kuruş)' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'İndirim açıklaması', required: false })
  @IsOptional()
  @IsString()
  description?: string
}

// Customer Body Measurements DTOs
export class CustomerBodyMeasurementsDto {
  @ApiProperty({ description: 'Müşteri ID' })
  @IsString()
  customerId: string

  @ApiProperty({ description: 'Göğüs ölçüsü (cm)' })
  @IsNumber()
  @Min(0)
  chest: number

  @ApiProperty({ description: 'Bel ölçüsü (cm)' })
  @IsNumber()
  @Min(0)
  waist: number

  @ApiProperty({ description: 'Kalça ölçüsü (cm)' })
  @IsNumber()
  @Min(0)
  hip: number

  @ApiProperty({ description: 'Omuz ölçüsü (cm)' })
  @IsNumber()
  @Min(0)
  shoulder: number

  @ApiProperty({ description: 'Kol uzunluğu (cm)' })
  @IsNumber()
  @Min(0)
  armLength: number

  @ApiProperty({ description: 'Bacak uzunluğu (cm)' })
  @IsNumber()
  @Min(0)
  legLength: number

  @ApiProperty({ description: 'Boyun ölçüsü (cm)' })
  @IsNumber()
  @Min(0)
  neck: number

  @ApiProperty({ description: 'Ölçüm notları', required: false })
  @IsOptional()
  @IsString()
  notes?: string

  @ApiProperty({ description: 'Ölçüm tarihi' })
  @IsString()
  measuredAt: string
}

