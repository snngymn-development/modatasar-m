import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { PDFService } from '../../common/pdf.service'
import type {
  ContractTemplate,
  Contract,
  CustomerConsent
} from '@prisma/client'
import { ContractStatus, ConsentType, ConsentStatus } from './dto'
import type {
  CreateContractDto,
  UpdateContractStatusDto,
  GenerateContractPdfDto,
  ContractTemplateDataDto,
  CreateCustomerConsentDto,
  UpdateCustomerConsentDto,
  ContractListQueryDto,
  ContractTemplateResponseDto,
  ContractResponseDto,
  CustomerConsentResponseDto,
  ContractListResponseDto
} from './dto'

@Injectable()
export class ContractsService {
  constructor(
    private prisma: PrismaService,
    private pdfService: PDFService
  ) {}

  /**
   * Create a new contract for an order
   */
  async createContract(createDto: CreateContractDto): Promise<ContractResponseDto> {
    // Check if order exists and doesn't already have a contract
    const order = await this.prisma.order.findUnique({
      where: { id: createDto.orderId },
      include: {
        customer: true,
        rental: true,
        details: true
      }
    })

    if (!order) {
      throw new NotFoundException(`Order with ID ${createDto.orderId} not found`)
    }

    // Check if contract already exists for this order
    const existingContract = await this.prisma.contract.findUnique({
      where: { orderId: createDto.orderId }
    })

    if (existingContract) {
      throw new BadRequestException(`Contract already exists for order ${createDto.orderId}`)
    }

    // Get template
    const template = await this.prisma.contractTemplate.findUnique({
      where: { id: createDto.templateId }
    })

    if (!template) {
      throw new NotFoundException(`Contract template with ID ${createDto.templateId} not found`)
    }

    // Generate contract number
    const contractNumber = await this.generateContractNumber(order.type)

    // Prepare template data
    const templateData = await this.prepareTemplateData(order, contractNumber)

    // Replace placeholders in template
    const contractContent = this.replaceTemplatePlaceholders(template.content, templateData)

    // Create contract
    const contract = await this.prisma.contract.create({
      data: {
        orderId: createDto.orderId,
        templateId: createDto.templateId,
        contractNumber,
        status: 'PENDING',
        content: contractContent
      }
    })

    // Update order with contract info
    await this.prisma.order.update({
      where: { id: createDto.orderId },
      data: {
        contractId: contract.id,
        contractStatus: 'PENDING',
        contractCreatedAt: new Date()
      }
    })

    // Create customer consent record
    await this.prisma.customerConsent.create({
      data: {
        customerId: order.customerId,
        contractId: contract.id,
        type: 'ORDER_CONTRACT',
        status: 'PENDING'
      }
    })

    return this.mapToContractResponse(contract)
  }

  /**
   * Update contract status
   */
  async updateContractStatus(
    contractId: string,
    updateDto: UpdateContractStatusDto
  ): Promise<ContractResponseDto> {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId }
    })

    if (!contract) {
      throw new NotFoundException(`Contract with ID ${contractId} not found`)
    }

    // Update contract
    const updatedContract = await this.prisma.contract.update({
      where: { id: contractId },
      data: {
        status: updateDto.status,
        ...(updateDto.status === 'SIGNED' && { signedAt: new Date() }),
        ...(updateDto.status === 'APPROVED' && { approvedAt: new Date() })
      }
    })

    // Update order status if contract is signed or approved
    if (updateDto.status === 'SIGNED' || updateDto.status === 'APPROVED') {
      await this.prisma.order.update({
        where: { id: contract.orderId },
        data: {
          contractStatus: updateDto.status,
          contractSignedAt: updateDto.status === 'SIGNED' ? new Date() : undefined,
          contractApprovedAt: updateDto.status === 'APPROVED' ? new Date() : undefined
        }
      })

      // Update customer consent
      await this.prisma.customerConsent.updateMany({
        where: { contractId },
        data: {
          status: updateDto.status === 'SIGNED' ? 'SIGNED' : 'PENDING',
          ...(updateDto.status === 'SIGNED' && { signedAt: new Date() })
        }
      })
    }

    return this.mapToContractResponse(updatedContract)
  }

  /**
   * Get contracts by customer
   */
  async getContractsByCustomer(
    customerId: string,
    query: ContractListQueryDto
  ): Promise<{ data: ContractListResponseDto[]; total: number }> {
    const { status, contractType, page = 1, limit = 10 } = query
    const skip = (page - 1) * limit

    const where: any = {
      order: {
        customerId
      }
    }

    if (status) {
      where.status = status
    }

    if (contractType) {
      where.template = {
        type: contractType
      }
    }

    const [contracts, total] = await Promise.all([
      this.prisma.contract.findMany({
        where,
        include: {
          order: {
            include: {
              customer: true
            }
          },
          template: true
        },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' }
      }),
      this.prisma.contract.count({ where })
    ])

    return {
      data: contracts.map(this.mapToContractListResponse),
      total
    }
  }

  /**
   * Get contract by ID
   */
  async getContractById(contractId: string): Promise<ContractResponseDto> {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: {
        order: {
          include: {
            customer: true
          }
        },
        template: true
      }
    })

    if (!contract) {
      throw new NotFoundException(`Contract with ID ${contractId} not found`)
    }

    return this.mapToContractResponse(contract)
  }

  /**
   * Get all contract templates
   */
  async getContractTemplates(): Promise<ContractTemplateResponseDto[]> {
    const templates = await this.prisma.contractTemplate.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' }
    })

    return templates.map(this.mapToTemplateResponse)
  }

  /**
   * Generate contract PDF
   */
  async generateContractPdf(generateDto: GenerateContractPdfDto): Promise<{ pdfUrl: string; filePath: string }> {
    const contract = await this.prisma.contract.findUnique({
      where: { id: generateDto.contractId },
      include: {
        order: {
          include: {
            customer: true,
            rental: true
          }
        }
      }
    })

    if (!contract) {
      throw new NotFoundException(`Contract with ID ${generateDto.contractId} not found`)
    }

    // Check if PDF already exists
    if (contract.pdfUrl) {
      const filePath = this.getContractPDFPath(contract.contractNumber)
      const exists = await this.pdfService.pdfExists(filePath)

      if (exists) {
        return { pdfUrl: contract.pdfUrl, filePath }
      }
    }

    // Generate PDF path
    const filePath = this.getContractPDFPath(contract.contractNumber)

    try {
      // Generate PDF using PDF service
      await this.pdfService.generateContractPDF(contract.content, contract.contractNumber, filePath)

      // Update contract with PDF URL
      const pdfUrl = `/contracts/${contract.contractNumber}.pdf`
      await this.prisma.contract.update({
        where: { id: generateDto.contractId },
        data: { pdfUrl }
      })

      return { pdfUrl, filePath }
    } catch (error) {
      const err = error as Error
      throw new BadRequestException(`Failed to generate PDF: ${err.message}`)
    }
  }

  /**
   * Download contract PDF
   */
  async downloadContractPDF(contractId: string): Promise<{ buffer: Buffer; fileName: string }> {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId }
    })

    if (!contract) {
      throw new NotFoundException(`Contract with ID ${contractId} not found`)
    }

    if (!contract.pdfUrl) {
      throw new BadRequestException('PDF not generated yet. Please generate PDF first.')
    }

    const filePath = this.getContractPDFPath(contract.contractNumber)
    const exists = await this.pdfService.pdfExists(filePath)

    if (!exists) {
      throw new BadRequestException('PDF file not found. Please regenerate PDF.')
    }

    // Read PDF file and return buffer
    const fs = require('fs').promises
    const buffer = await fs.readFile(filePath)

    return {
      buffer,
      fileName: `${contract.contractNumber}.pdf`
    }
  }

  /**
   * Get contract PDF path
   */
  private getContractPDFPath(contractNumber: string): string {
    const sanitizedNumber = contractNumber.replace(/[^a-zA-Z0-9-_]/g, '_')
    return `public/contracts/${sanitizedNumber}.pdf`
  }

  /**
   * Generate unique contract number in GGAAYY-D001 format
   */
  private async generateContractNumber(orderType: string): Promise<string> {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')

    // Get current year and month
    const yearMonth = `${year}${month}`

    // Get last contract number for this month
    const lastContract = await this.prisma.contract.findFirst({
      where: {
        contractNumber: {
          startsWith: `${yearMonth}-`
        }
      },
      orderBy: { contractNumber: 'desc' }
    })

    let sequenceNumber = 1

    if (lastContract) {
      const lastSequence = parseInt(lastContract.contractNumber.split('-')[2])
      sequenceNumber = lastSequence + 1
    }

    const sequenceStr = String(sequenceNumber).padStart(3, '0')
    const typePrefix = orderType === 'KİRALAMA' ? 'K' : 'D'

    return `${yearMonth}-${typePrefix}${sequenceStr}`
  }

  /**
   * Prepare template data from order
   */
  private async prepareTemplateData(order: any, contractNumber: string): Promise<ContractTemplateDataDto> {
    const totalAmount = order.total
    let dailyRate: number | undefined
    let rentalDays: number | undefined

    if (order.type === 'KİRALAMA' && order.rental) {
      const startDate = new Date(order.rental.startDate)
      const endDate = new Date(order.rental.endDate)
      const daysDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24))
      rentalDays = daysDiff
      dailyRate = Math.floor(totalAmount / daysDiff)
    }

    return {
      contractNumber,
      customerName: order.customer.name,
      customerPhone: order.customer.phone,
      orderDate: order.createdAt.toISOString(),
      deliveryDate: order.deliveryDate?.toISOString() || order.createdAt.toISOString(),
      totalAmount,
      dailyRate,
      rentalDays
    }
  }

  /**
   * Replace placeholders in template content
   */
  private replaceTemplatePlaceholders(template: string, data: ContractTemplateDataDto): string {
    let result = template

    // Basic replacements
    result = result.replace(/\{\{contractNumber\}\}/g, data.contractNumber)
    result = result.replace(/\{\{customerName\}\}/g, data.customerName)
    result = result.replace(/\{\{customerPhone\}\}/g, data.customerPhone || '')
    result = result.replace(/\{\{orderDate\}\}/g, new Date(data.orderDate).toLocaleDateString('tr-TR'))
    result = result.replace(/\{\{deliveryDate\}\}/g, new Date(data.deliveryDate).toLocaleDateString('tr-TR'))
    result = result.replace(/\{\{totalAmount\}\}/g, `₺${(data.totalAmount / 100).toFixed(2)}`)

    // Rental specific replacements
    if (data.dailyRate && data.rentalDays) {
      result = result.replace(/\{\{dailyRate\}\}/g, `₺${(data.dailyRate / 100).toFixed(2)}`)
      result = result.replace(/\{\{rentalDays\}\}/g, data.rentalDays.toString())
    }

    return result
  }

  /**
   * Map contract to response DTO
   */
  private mapToContractResponse(contract: any): ContractResponseDto {
    return {
      id: contract.id,
      orderId: contract.orderId,
      templateId: contract.templateId,
      contractNumber: contract.contractNumber,
      status: contract.status as ContractStatus,
      content: contract.content,
      pdfUrl: contract.pdfUrl,
      signedAt: contract.signedAt,
      approvedAt: contract.approvedAt,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt
    }
  }

  /**
   * Map template to response DTO
   */
  private mapToTemplateResponse(template: ContractTemplate): ContractTemplateResponseDto {
    return {
      id: template.id,
      name: template.name,
      type: template.type,
      content: template.content,
      version: template.version,
      isActive: template.isActive,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt
    }
  }

  /**
   * Map contract list response
   */
  private mapToContractListResponse(contract: any): ContractListResponseDto {
    return {
      id: contract.id,
      contractNumber: contract.contractNumber,
      status: contract.status as ContractStatus,
      customerName: contract.order.customer.name,
      orderType: contract.order.type,
      totalAmount: contract.order.total,
      createdAt: contract.createdAt,
      signedAt: contract.signedAt,
      approvedAt: contract.approvedAt
    }
  }
}
