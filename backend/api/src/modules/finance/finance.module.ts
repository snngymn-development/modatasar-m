import { Module } from '@nestjs/common'
import { FinanceController } from './finance.controller'
import { FinanceService } from './finance.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [FinanceController],
  providers: [FinanceService, PrismaService],
  exports: [FinanceService]
})
export class FinanceModule {}
