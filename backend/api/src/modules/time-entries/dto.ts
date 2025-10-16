import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, IsBoolean, IsEnum, Min, Matches } from 'class-validator'

export class CreateTimeEntryDto {
  @ApiProperty({ description: 'Employee ID' })
  @IsString()
  employeeId: string

  @ApiProperty({ description: 'Date (YYYY-MM-DD)' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Date must be YYYY-MM-DD format' })
  date: string

  @ApiProperty({ description: 'Start time (HH:MM)' })
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, { message: 'Start time must be HH:MM format' })
  startTime: string

  @ApiProperty({ description: 'End time (HH:MM)' })
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, { message: 'End time must be HH:MM format' })
  endTime: string

  @ApiProperty({ description: 'Time entry type', enum: ['NORMAL', 'OVERTIME'] })
  @IsEnum(['NORMAL', 'OVERTIME'])
  type: string

  @ApiProperty({ description: 'Note', required: false })
  @IsOptional()
  @IsString()
  note?: string

  @ApiProperty({ description: 'Created by user ID' })
  @IsString()
  createdBy: string
}

export class UpdateTimeEntryDto {
  @ApiProperty({ description: 'Date (YYYY-MM-DD)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'Date must be YYYY-MM-DD format' })
  date?: string

  @ApiProperty({ description: 'Start time (HH:MM)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, { message: 'Start time must be HH:MM format' })
  startTime?: string

  @ApiProperty({ description: 'End time (HH:MM)', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/, { message: 'End time must be HH:MM format' })
  endTime?: string

  @ApiProperty({ description: 'Time entry type', enum: ['NORMAL', 'OVERTIME'], required: false })
  @IsOptional()
  @IsEnum(['NORMAL', 'OVERTIME'])
  type?: string

  @ApiProperty({ description: 'Note', required: false })
  @IsOptional()
  @IsString()
  note?: string
}

export class ApproveTimeEntryDto {
  @ApiProperty({ description: 'User ID who approved' })
  @IsString()
  approvedBy: string
}
