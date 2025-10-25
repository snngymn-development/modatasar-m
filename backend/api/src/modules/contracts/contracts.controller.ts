import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  HttpStatus,
  HttpCode,
  Res,
  StreamableFile
} from '@nestjs/common'
import { Response } from 'express'
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery
} from '@nestjs/swagger'
import { ContractsService } from './contracts.service'
import {
  CreateContractDto,
  UpdateContractStatusDto,
  GenerateContractPdfDto,
  GenerateContractPdfResponseDto,
  ContractListQueryDto,
  ContractTemplateResponseDto,
  ContractResponseDto,
  ContractListResponseDto
} from './dto'

@ApiTags('contracts')
@Controller('contracts')
export class ContractsController {
  constructor(private readonly contractsService: ContractsService) {}

  @Post(':orderId/create')
  @ApiOperation({
    summary: 'Create a new contract for an order',
    description: 'Creates a contract using the specified template and generates a unique contract number'
  })
  @ApiParam({
    name: 'orderId',
    description: 'ID of the order to create contract for',
    example: 'clx123abc456def789'
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Contract created successfully',
    type: ContractResponseDto
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Order or template not found'
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Contract already exists for this order'
  })
  async createContract(
    @Param('orderId') orderId: string,
    @Body() createDto: CreateContractDto
  ): Promise<ContractResponseDto> {
    // Override orderId from param
    createDto.orderId = orderId

    return this.contractsService.createContract(createDto)
  }

  @Patch(':id/status')
  @ApiOperation({
    summary: 'Update contract status',
    description: 'Updates the status of a contract (PENDING, SENT, SIGNED, APPROVED, etc.)'
  })
  @ApiParam({
    name: 'id',
    description: 'Contract ID',
    example: 'clx456def789ghi012'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Contract status updated successfully',
    type: ContractResponseDto
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Contract not found'
  })
  async updateContractStatus(
    @Param('id') contractId: string,
    @Body() updateDto: UpdateContractStatusDto
  ): Promise<ContractResponseDto> {
    return this.contractsService.updateContractStatus(contractId, updateDto)
  }

  @Get('customer/:customerId')
  @ApiOperation({
    summary: 'Get contracts by customer',
    description: 'Retrieves all contracts for a specific customer with optional filtering'
  })
  @ApiParam({
    name: 'customerId',
    description: 'Customer ID',
    example: 'clx123abc456def789'
  })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['PENDING', 'SENT', 'SIGNED', 'APPROVED', 'EXPIRED', 'CANCELLED'],
    description: 'Filter by contract status'
  })
  @ApiQuery({
    name: 'contractType',
    required: false,
    enum: ['DİKİM', 'KİRALAMA', 'GENEL'],
    description: 'Filter by contract type'
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Page number for pagination',
    example: 1
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Items per page',
    example: 10
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Contracts retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: {
          type: 'array',
          items: { $ref: '#/components/schemas/ContractListResponseDto' }
        },
        total: { type: 'number' }
      }
    }
  })
  async getContractsByCustomer(
    @Param('customerId') customerId: string,
    @Query() query: ContractListQueryDto
  ): Promise<{ data: ContractListResponseDto[]; total: number }> {
    return this.contractsService.getContractsByCustomer(customerId, query)
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get contract by ID',
    description: 'Retrieves a specific contract with full details'
  })
  @ApiParam({
    name: 'id',
    description: 'Contract ID',
    example: 'clx456def789ghi012'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Contract retrieved successfully',
    type: ContractResponseDto
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Contract not found'
  })
  async getContractById(@Param('id') contractId: string): Promise<ContractResponseDto> {
    return this.contractsService.getContractById(contractId)
  }

  @Get('templates')
  @ApiOperation({
    summary: 'Get all active contract templates',
    description: 'Retrieves all available contract templates for creating new contracts'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Templates retrieved successfully',
    type: [ContractTemplateResponseDto]
  })
  async getContractTemplates(): Promise<ContractTemplateResponseDto[]> {
    return this.contractsService.getContractTemplates()
  }

  @Post(':id/generate-pdf')
  @ApiOperation({
    summary: 'Generate PDF for contract',
    description: 'Generates a PDF document from the contract content and returns download URL'
  })
  @ApiParam({
    name: 'id',
    description: 'Contract ID',
    example: 'clx456def789ghi012'
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'PDF generated successfully',
    type: GenerateContractPdfResponseDto
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Contract not found'
  })
  async generateContractPdf(
    @Param('id') contractId: string,
    @Body() generateDto: GenerateContractPdfDto
  ): Promise<GenerateContractPdfResponseDto> {
    // Override contractId from param
    generateDto.contractId = contractId

    return this.contractsService.generateContractPdf(generateDto)
  }

  @Get(':id/download')
  @ApiOperation({
    summary: 'Download contract PDF',
    description: 'Downloads the generated PDF file for a contract'
  })
  @ApiParam({
    name: 'id',
    description: 'Contract ID',
    example: 'clx456def789ghi012'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'PDF file downloaded successfully',
    content: {
      'application/pdf': {
        schema: {
          type: 'string',
          format: 'binary'
        }
      }
    }
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Contract not found'
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'PDF not generated or not found'
  })
  async downloadContractPDF(
    @Param('id') contractId: string,
    @Res() res: Response
  ): Promise<void> {
    const result = await this.contractsService.downloadContractPDF(contractId)

    // Set headers for PDF download
    res.setHeader('Content-Type', 'application/pdf')
    res.setHeader('Content-Disposition', `attachment; filename="${result.fileName}"`)
    res.setHeader('Content-Length', result.buffer.length)

    // Send PDF buffer
    res.send(result.buffer)
  }
}
