import { Module } from '@nestjs/common'
import { PurchasesController } from './purchases.controller'
import { PurchasesService } from './purchases.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [PurchasesController],
  providers: [PurchasesService, PrismaService],
})
export class PurchasesModule {}
