import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsEnum, IsArray, Min, Matches } from 'class-validator'

export class PayrollPreviewDto {
  @ApiProperty({ description: 'Period start date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Period start must be YYYY-MM-DD format' })
  periodStart: string

  @ApiProperty({ description: 'Period end date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Period end must be YYYY-MM-DD format' })
  periodEnd: string

  @ApiProperty({ description: 'Employee IDs to include', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  employeeIds?: string[]
}

export class CreatePayrollRunDto {
  @ApiProperty({ description: 'Period start date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Period start must be YYYY-MM-DD format' })
  periodStart: string

  @ApiProperty({ description: 'Period end date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Period end must be YYYY-MM-DD format' })
  periodEnd: string

  @ApiProperty({ description: 'Scope', enum: ['ALL', 'SELECTED'] })
  @IsEnum(['ALL', 'SELECTED'])
  scope: string

  @ApiProperty({ description: 'Employee IDs to include', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  employeeIds?: string[]

  @ApiProperty({ description: 'Created by user ID' })
  @IsString()
  createdBy: string
}

export class PayrollPayDto {
  @ApiProperty({ description: 'Account ID for payment' })
  @IsString()
  accountId: string

  @ApiProperty({ description: 'Created by user ID' })
  @IsString()
  createdBy: string
}
