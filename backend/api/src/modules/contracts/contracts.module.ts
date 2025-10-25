import { Module } from '@nestjs/common'
import { ContractsController } from './contracts.controller'
import { ContractsService } from './contracts.service'
import { PDFModule } from '../../common/pdf.module'
import { PrismaService } from '../../common/prisma.service'

@Module({
  imports: [PDFModule],
  controllers: [ContractsController],
  providers: [ContractsService, PrismaService],
  exports: [ContractsService]
})
export class ContractsModule {}
