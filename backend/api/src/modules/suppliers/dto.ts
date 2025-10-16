import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsOptional, IsEmail, IsIn } from 'class-validator'

export class CreateSupplierDto {
  @ApiProperty({ description: 'Supplier name' })
  @IsString()
  name: string

  @ApiProperty({ required: false, description: 'Phone number' })
  @IsString()
  @IsOptional()
  phone?: string

  @ApiProperty({ required: false, description: 'Email address' })
  @IsEmail()
  @IsOptional()
  email?: string

  @ApiProperty({ required: false, description: 'City' })
  @IsString()
  @IsOptional()
  city?: string

  @ApiProperty({ 
    required: false, 
    description: 'Supplier category',
    enum: ['FABRIC', 'ACCESSORY', 'CLEANING', 'ALTERATION']
  })
  @IsString()
  @IsOptional()
  @IsIn(['FABRIC', 'ACCESSORY', 'CLEANING', 'ALTERATION'])
  category?: string

  @ApiProperty({ 
    required: false, 
    description: 'Supplier status',
    enum: ['ACTIVE', 'PASSIVE'],
    default: 'ACTIVE'
  })
  @IsString()
  @IsOptional()
  @IsIn(['ACTIVE', 'PASSIVE'])
  status?: string
}

export class UpdateSupplierDto {
  @ApiProperty({ required: false, description: 'Supplier name' })
  @IsString()
  @IsOptional()
  name?: string

  @ApiProperty({ required: false, description: 'Phone number' })
  @IsString()
  @IsOptional()
  phone?: string

  @ApiProperty({ required: false, description: 'Email address' })
  @IsEmail()
  @IsOptional()
  email?: string

  @ApiProperty({ required: false, description: 'City' })
  @IsString()
  @IsOptional()
  city?: string

  @ApiProperty({ 
    required: false, 
    description: 'Supplier category',
    enum: ['FABRIC', 'ACCESSORY', 'CLEANING', 'ALTERATION']
  })
  @IsString()
  @IsOptional()
  @IsIn(['FABRIC', 'ACCESSORY', 'CLEANING', 'ALTERATION'])
  category?: string

  @ApiProperty({ 
    required: false, 
    description: 'Supplier status',
    enum: ['ACTIVE', 'PASSIVE']
  })
  @IsString()
  @IsOptional()
  @IsIn(['ACTIVE', 'PASSIVE'])
  status?: string
}
