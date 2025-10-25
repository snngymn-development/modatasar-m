import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsEnum, IsOptional, IsDateString, MinLength } from 'class-validator'

// Create Contract DTO
export class CreateContractDto {
  @ApiProperty({
    description: 'Order ID for which the contract is being created',
    example: 'clx123abc456def789'
  })
  @IsString()
  @MinLength(1)
  orderId: string

  @ApiProperty({
    description: 'Template ID to use for the contract',
    example: 'clx789ghi012jkl345'
  })
  @IsString()
  @MinLength(1)
  templateId: string
}

// Update Contract Status DTO
export class UpdateContractStatusDto {
  @ApiProperty({
    description: 'New status for the contract',
    enum: ['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED'],
    example: 'SIGNED'
  })
  @IsEnum(['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED'])
  status: ContractStatus

  @ApiPropertyOptional({
    description: 'Optional notes for the status change',
    example: 'Müşteri e-posta ile onayladı'
  })
  @IsOptional()
  @IsString()
  notes?: string
}

// Generate Contract PDF DTO
export class GenerateContractPdfDto {
  @ApiProperty({
    description: 'Contract ID to generate PDF for',
    example: 'clx456def789ghi012'
  })
  @IsString()
  @MinLength(1)
  contractId: string

  @ApiPropertyOptional({
    description: 'Output path for the PDF file',
    example: '/contracts/contract-241024-D001.pdf'
  })
  @IsOptional()
  @IsString()
  outputPath?: string
}

// Contract Template Data DTO (for placeholder replacement)
export class ContractTemplateDataDto {
  @ApiProperty({
    description: 'Contract number in GGAAYY-D001 format',
    example: '241024-D001'
  })
  @IsString()
  @MinLength(1)
  contractNumber: string

  @ApiProperty({
    description: 'Customer full name',
    example: 'Ahmet Yılmaz'
  })
  @IsString()
  @MinLength(1)
  customerName: string

  @ApiPropertyOptional({
    description: 'Customer phone number',
    example: '+90 555 123 4567'
  })
  @IsOptional()
  @IsString()
  customerPhone?: string

  @ApiProperty({
    description: 'Order date in ISO format',
    example: '2024-10-24T10:00:00.000Z'
  })
  @IsDateString()
  orderDate: string

  @ApiProperty({
    description: 'Delivery date in ISO format',
    example: '2024-10-31T15:00:00.000Z'
  })
  @IsDateString()
  deliveryDate: string

  @ApiProperty({
    description: 'Total amount in cents',
    example: 100000
  })
  totalAmount: number

  @ApiPropertyOptional({
    description: 'Daily rate for rental contracts (in cents)',
    example: 25000
  })
  @IsOptional()
  dailyRate?: number

  @ApiPropertyOptional({
    description: 'Number of rental days',
    example: 7
  })
  @IsOptional()
  rentalDays?: number
}

// Create Customer Consent DTO
export class CreateCustomerConsentDto {
  @ApiProperty({
    description: 'Customer ID',
    example: 'clx123abc456def789'
  })
  @IsString()
  @MinLength(1)
  customerId: string

  @ApiPropertyOptional({
    description: 'Contract ID (for order contracts)',
    example: 'clx456def789ghi012'
  })
  @IsOptional()
  @IsString()
  contractId?: string

  @ApiProperty({
    description: 'Type of consent',
    enum: ['GENERAL', 'MARKETING', 'ORDER_CONTRACT'],
    example: 'ORDER_CONTRACT'
  })
  @IsEnum(['GENERAL', 'MARKETING', 'ORDER_CONTRACT'])
  type: ConsentType

  @ApiPropertyOptional({
    description: 'Initial status of the consent',
    enum: ['PENDING', 'SIGNED', 'REJECTED', 'EXPIRED'],
    example: 'PENDING'
  })
  @IsOptional()
  @IsEnum(['PENDING', 'SIGNED', 'REJECTED', 'EXPIRED'])
  status?: ConsentStatus
}

// Update Customer Consent DTO
export class UpdateCustomerConsentDto {
  @ApiProperty({
    description: 'New status for the consent',
    enum: ['PENDING', 'SIGNED', 'REJECTED', 'EXPIRED'],
    example: 'SIGNED'
  })
  @IsEnum(['PENDING', 'SIGNED', 'REJECTED', 'EXPIRED'])
  status: ConsentStatus

  @ApiPropertyOptional({
    description: 'Signature timestamp',
    example: '2024-10-24T14:30:00.000Z'
  })
  @IsOptional()
  @IsDateString()
  signedAt?: string
}

// Contract List Query DTO
export class ContractListQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by contract status',
    enum: ['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED']
  })
  @IsOptional()
  @IsEnum(['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED'])
  status?: ContractStatus

  @ApiPropertyOptional({
    description: 'Filter by customer ID',
    example: 'clx123abc456def789'
  })
  @IsOptional()
  @IsString()
  customerId?: string

  @ApiPropertyOptional({
    description: 'Filter by contract type',
    enum: ['DİKİM', 'KİRALAMA', 'GENEL']
  })
  @IsOptional()
  @IsEnum(['DİKİM', 'KİRALAMA', 'GENEL'])
  contractType?: string

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    example: 1,
    default: 1
  })
  @IsOptional()
  page?: number = 1

  @ApiPropertyOptional({
    description: 'Items per page',
    example: 10,
    default: 10
  })
  @IsOptional()
  limit?: number = 10
}

// Contract Response DTOs
export class ContractTemplateResponseDto {
  @ApiProperty()
  id: string

  @ApiProperty()
  name: string

  @ApiProperty()
  type: string

  @ApiProperty()
  content: string

  @ApiProperty()
  version: string

  @ApiProperty()
  isActive: boolean

  @ApiProperty()
  createdAt: Date

  @ApiProperty()
  updatedAt: Date
}

export class ContractResponseDto {
  @ApiProperty()
  id: string

  @ApiProperty()
  orderId: string

  @ApiProperty()
  templateId: string

  @ApiProperty()
  contractNumber: string

  @ApiProperty()
  status: ContractStatus

  @ApiProperty()
  content: string

  @ApiPropertyOptional()
  pdfUrl?: string

  @ApiPropertyOptional()
  signedAt?: Date

  @ApiPropertyOptional()
  approvedAt?: Date

  @ApiProperty()
  createdAt: Date

  @ApiProperty()
  updatedAt: Date
}

export class CustomerConsentResponseDto {
  @ApiProperty()
  id: string

  @ApiProperty()
  customerId: string

  @ApiPropertyOptional()
  contractId?: string

  @ApiProperty()
  type: ConsentType

  @ApiProperty()
  status: ConsentStatus

  @ApiPropertyOptional()
  signedAt?: Date

  @ApiProperty()
  createdAt: Date
}

export class ContractListResponseDto {
  @ApiProperty()
  id: string

  @ApiProperty()
  contractNumber: string

  @ApiProperty()
  status: ContractStatus

  @ApiProperty()
  customerName: string

  @ApiProperty()
  orderType: string

  @ApiProperty()
  totalAmount: number

  @ApiProperty()
  createdAt: Date

  @ApiPropertyOptional()
  signedAt?: Date

  @ApiPropertyOptional()
  approvedAt?: Date
}

export class GenerateContractPdfResponseDto {
  @ApiProperty({
    description: 'URL path to the generated PDF',
    example: '/contracts/241024-D001.pdf'
  })
  pdfUrl: string

  @ApiProperty({
    description: 'Local file path of the generated PDF',
    example: 'public/contracts/241024-D001.pdf'
  })
  filePath: string
}

// Type definitions (matching @deneme1/core)
export type ContractStatus =
  | 'PENDING'
  | 'SENT'
  | 'SIGNED'
  | 'APPROVED'
  | 'EXPIRED'
  | 'CANCELLED'

export type ConsentType =
  | 'GENERAL'
  | 'MARKETING'
  | 'ORDER_CONTRACT'

export type ConsentStatus =
  | 'PENDING'
  | 'SIGNED'
  | 'REJECTED'
  | 'EXPIRED'
