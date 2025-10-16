import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsBoolean, IsEnum, Min, IsEmail, Matches } from 'class-validator'

export class CreateEmployeeDto {
  @ApiProperty({ description: 'First name' })
  @IsString()
  firstName: string

  @ApiProperty({ description: 'Last name' })
  @IsString()
  lastName: string

  @ApiProperty({ description: 'TC Identity Number', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{11}$/, { message: 'TC No must be 11 digits' })
  tcNo?: string

  @ApiProperty({ description: 'Employee status', enum: ['ACTIVE', 'PASSIVE', 'PROBATION'] })
  @IsEnum(['ACTIVE', 'PASSIVE', 'PROBATION'])
  status: string

  @ApiProperty({ description: 'Department ID', required: false })
  @IsOptional()
  @IsString()
  departmentId?: string

  @ApiProperty({ description: 'Department name', required: false })
  @IsOptional()
  @IsString()
  department?: string

  @ApiProperty({ description: 'Position/Title', required: false })
  @IsOptional()
  @IsString()
  position?: string

  @ApiProperty({ description: 'Hire date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Hire date must be YYYY-MM-DD format' })
  hireDate: string

  @ApiProperty({ description: 'Termination date (YYYY-MM-DD)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Termination date must be YYYY-MM-DD format' })
  terminationDate?: string

  @ApiProperty({ description: 'Wage type', enum: ['FIXED', 'HOURLY'] })
  @IsEnum(['FIXED', 'HOURLY'])
  wageType: string

  @ApiProperty({ description: 'Base wage amount in cents' })
  @IsNumber()
  @Min(0)
  baseWageAmount: number

  @ApiProperty({ description: 'Base wage currency', default: 'TRY' })
  @IsOptional()
  @IsString()
  baseWageCurrency?: string

  @ApiProperty({ description: 'Normal weekly hours', default: 45 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  normalWeeklyHours?: number

  @ApiProperty({ description: 'Phone number', required: false })
  @IsOptional()
  @IsString()
  phone?: string

  @ApiProperty({ description: 'Email address', required: false })
  @IsOptional()
  @IsEmail()
  email?: string

  @ApiProperty({ description: 'Address', required: false })
  @IsOptional()
  @IsString()
  address?: string

  @ApiProperty({ description: 'IBAN', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^TR\d{2}\d{4}\d{16}$/, { message: 'Invalid IBAN format' })
  iban?: string

  @ApiProperty({ description: 'SGK number', required: false })
  @IsOptional()
  @IsString()
  sgkNo?: string

  @ApiProperty({ description: 'Shift ID', required: false })
  @IsOptional()
  @IsString()
  shiftId?: string

  @ApiProperty({ description: 'Shift name', required: false })
  @IsOptional()
  @IsString()
  shiftName?: string

  @ApiProperty({ description: 'Advance policy', required: false })
  @IsOptional()
  @IsString()
  advancePolicy?: string
}

export class UpdateEmployeeDto {
  @ApiProperty({ description: 'First name', required: false })
  @IsOptional()
  @IsString()
  firstName?: string

  @ApiProperty({ description: 'Last name', required: false })
  @IsOptional()
  @IsString()
  lastName?: string

  @ApiProperty({ description: 'TC Identity Number', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{11}$/, { message: 'TC No must be 11 digits' })
  tcNo?: string

  @ApiProperty({ description: 'Employee status', enum: ['ACTIVE', 'PASSIVE', 'PROBATION'], required: false })
  @IsOptional()
  @IsEnum(['ACTIVE', 'PASSIVE', 'PROBATION'])
  status?: string

  @ApiProperty({ description: 'Department ID', required: false })
  @IsOptional()
  @IsString()
  departmentId?: string

  @ApiProperty({ description: 'Department name', required: false })
  @IsOptional()
  @IsString()
  department?: string

  @ApiProperty({ description: 'Position/Title', required: false })
  @IsOptional()
  @IsString()
  position?: string

  @ApiProperty({ description: 'Hire date (YYYY-MM-DD)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Hire date must be YYYY-MM-DD format' })
  hireDate?: string

  @ApiProperty({ description: 'Termination date (YYYY-MM-DD)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Termination date must be YYYY-MM-DD format' })
  terminationDate?: string

  @ApiProperty({ description: 'Wage type', enum: ['FIXED', 'HOURLY'], required: false })
  @IsOptional()
  @IsEnum(['FIXED', 'HOURLY'])
  wageType?: string

  @ApiProperty({ description: 'Base wage amount in cents', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  baseWageAmount?: number

  @ApiProperty({ description: 'Base wage currency', required: false })
  @IsOptional()
  @IsString()
  baseWageCurrency?: string

  @ApiProperty({ description: 'Normal weekly hours', required: false })
  @IsOptional()
  @IsNumber()
  @Min(1)
  normalWeeklyHours?: number

  @ApiProperty({ description: 'Phone number', required: false })
  @IsOptional()
  @IsString()
  phone?: string

  @ApiProperty({ description: 'Email address', required: false })
  @IsOptional()
  @IsEmail()
  email?: string

  @ApiProperty({ description: 'Address', required: false })
  @IsOptional()
  @IsString()
  address?: string

  @ApiProperty({ description: 'IBAN', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^TR\d{2}\d{4}\d{16}$/, { message: 'Invalid IBAN format' })
  iban?: string

  @ApiProperty({ description: 'SGK number', required: false })
  @IsOptional()
  @IsString()
  sgkNo?: string

  @ApiProperty({ description: 'Shift ID', required: false })
  @IsOptional()
  @IsString()
  shiftId?: string

  @ApiProperty({ description: 'Shift name', required: false })
  @IsOptional()
  @IsString()
  shiftName?: string

  @ApiProperty({ description: 'Advance policy', required: false })
  @IsOptional()
  @IsString()
  advancePolicy?: string
}
