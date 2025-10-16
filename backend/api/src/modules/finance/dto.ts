import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsEnum, IsArray, ValidateNested, Min } from 'class-validator'
import { Type } from 'class-transformer'

export class CreateAccountDto {
  @ApiProperty({ enum: ['CASH', 'BANK', 'POS'] })
  @IsEnum(['CASH', 'BANK', 'POS'])
  type: string

  @ApiProperty()
  @IsString()
  name: string

  @ApiProperty({ enum: ['TRY', 'USD', 'EUR'], default: 'TRY' })
  @IsEnum(['TRY', 'USD', 'EUR'])
  @IsOptional()
  currency?: string = 'TRY'

  @ApiProperty({ default: true })
  @IsOptional()
  isActive?: boolean = true
}

export class CreatePostingDto {
  @ApiProperty()
  @IsString()
  accountId: string

  @ApiProperty({ enum: ['DEBIT', 'CREDIT'] })
  @IsEnum(['DEBIT', 'CREDIT'])
  dc: string

  @ApiProperty({ description: 'Amount in cents' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ enum: ['TRY', 'USD', 'EUR'], default: 'TRY' })
  @IsEnum(['TRY', 'USD', 'EUR'])
  @IsOptional()
  currency?: string = 'TRY'

  @ApiProperty({ default: 1.0 })
  @IsNumber()
  @IsOptional()
  rateToTRY?: number = 1.0
}

export class CreateTransactionDto {
  @ApiProperty({ enum: ['RECEIVABLE', 'PAYABLE', 'INTERNAL_TRANSFER', 'PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND'] })
  @IsEnum(['RECEIVABLE', 'PAYABLE', 'INTERNAL_TRANSFER', 'PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND'])
  kind: string

  @ApiProperty({ description: 'Main transaction amount in cents' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ enum: ['TRY', 'USD', 'EUR'], default: 'TRY' })
  @IsEnum(['TRY', 'USD', 'EUR'])
  @IsOptional()
  currency?: string = 'TRY'

  @ApiProperty({ default: 1.0 })
  @IsNumber()
  @IsOptional()
  rateToTRY?: number = 1.0

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  note?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  customerId?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  supplierId?: string

  @ApiProperty()
  @IsString()
  createdBy: string

  @ApiProperty({ type: [CreatePostingDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreatePostingDto)
  postings: CreatePostingDto[]
}

export class UpdateTransactionDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  note?: string
}

export class TransactionQueryDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  from?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  to?: string

  @ApiProperty({ required: false, isArray: true })
  @IsArray()
  @IsOptional()
  kinds?: string[]

  @ApiProperty({ required: false, isArray: true })
  @IsArray()
  @IsOptional()
  accounts?: string[]

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  q?: string

  @ApiProperty({ required: false, default: 1 })
  @IsNumber()
  @IsOptional()
  page?: number = 1

  @ApiProperty({ required: false, default: 20 })
  @IsNumber()
  @IsOptional()
  limit?: number = 20

  @ApiProperty({ required: false, default: 'date' })
  @IsString()
  @IsOptional()
  sort?: string = 'date'
}

// ============================================
// PAYROLL TRANSACTION DTOs
// ============================================

export class CreatePayrollTransactionDto {
  @ApiProperty({ description: 'Employee ID' })
  @IsString()
  employeeId: string

  @ApiProperty({ description: 'Amount in cents' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ enum: ['PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND'] })
  @IsEnum(['PAYROLL', 'PAYROLL_ADVANCE', 'PAYROLL_REFUND'])
  kind: string

  @ApiProperty({ description: 'Account ID for payment' })
  @IsString()
  accountId: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  note?: string

  @ApiProperty()
  @IsString()
  createdBy: string
}

export class CreateBulkPayrollTransactionDto {
  @ApiProperty({ description: 'Array of employee payments' })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreatePayrollTransactionDto)
  payments: CreatePayrollTransactionDto[]

  @ApiProperty()
  @IsString()
  createdBy: string
}
