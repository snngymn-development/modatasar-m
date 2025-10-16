import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsOptional, IsEnum, IsArray, MinLength } from 'class-validator'

export class CreateProductDto {
  @ApiProperty({ description: 'Product name' })
  @IsString()
  @MinLength(1)
  name!: string

  @ApiProperty({ required: false, description: 'Product model' })
  @IsString()
  @IsOptional()
  model?: string

  @ApiProperty({ required: false, description: 'Product color' })
  @IsString()
  @IsOptional()
  color?: string

  @ApiProperty({ required: false, description: 'Product size' })
  @IsString()
  @IsOptional()
  size?: string

  @ApiProperty({ required: false, description: 'Product category' })
  @IsString()
  @IsOptional()
  category?: string

  @ApiProperty({
    required: false,
    type: [String],
    description: 'Product tags',
    example: ['Düğün', 'Gala', 'Premium'],
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[]

  @ApiProperty({
    enum: ['AVAILABLE', 'IN_USE', 'MAINTENANCE'],
    default: 'AVAILABLE',
  })
  @IsEnum(['AVAILABLE', 'IN_USE', 'MAINTENANCE'])
  @IsOptional()
  status?: string
}

export class UpdateProductDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  name?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  model?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  color?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  size?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  category?: string

  @ApiProperty({
    required: false,
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[]

  @ApiProperty({
    required: false,
    enum: ['AVAILABLE', 'IN_USE', 'MAINTENANCE'],
  })
  @IsEnum(['AVAILABLE', 'IN_USE', 'MAINTENANCE'])
  @IsOptional()
  status?: string
}

