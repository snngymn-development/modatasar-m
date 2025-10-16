import { Module } from '@nestjs/common'
import { AllowancesController } from './allowances.controller'
import { AllowancesService } from './allowances.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [AllowancesController],
  providers: [AllowancesService, PrismaService]
})
export class AllowancesModule {}
