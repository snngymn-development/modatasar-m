import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsEnum, Min, Matches } from 'class-validator'

export class CreateAllowanceDto {
  @ApiProperty({ description: 'Employee ID' })
  @IsString()
  employeeId: string

  @ApiProperty({ description: 'Date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Date must be YYYY-MM-DD format' })
  date: string

  @ApiProperty({ description: 'Allowance kind', enum: ['MEAL', 'TRANSPORT', 'OTHER'] })
  @IsEnum(['MEAL', 'TRANSPORT', 'OTHER'])
  kind: string

  @ApiProperty({ description: 'Amount in cents' })
  @IsNumber()
  @Min(0)
  amount: number

  @ApiProperty({ description: 'Currency', default: 'TRY' })
  @IsOptional()
  @IsString()
  currency?: string

  @ApiProperty({ description: 'Note', required: false })
  @IsOptional()
  @IsString()
  note?: string

  @ApiProperty({ description: 'Created by user ID' })
  @IsString()
  createdBy: string
}

export class UpdateAllowanceDto {
  @ApiProperty({ description: 'Date (YYYY-MM-DD)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Date must be YYYY-MM-DD format' })
  date?: string

  @ApiProperty({ description: 'Allowance kind', enum: ['MEAL', 'TRANSPORT', 'OTHER'], required: false })
  @IsOptional()
  @IsEnum(['MEAL', 'TRANSPORT', 'OTHER'])
  kind?: string

  @ApiProperty({ description: 'Amount in cents', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number

  @ApiProperty({ description: 'Currency', required: false })
  @IsOptional()
  @IsString()
  currency?: string

  @ApiProperty({ description: 'Note', required: false })
  @IsOptional()
  @IsString()
  note?: string
}
