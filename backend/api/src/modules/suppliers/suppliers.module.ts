import { Module } from '@nestjs/common'
import { SuppliersController } from './suppliers.controller'
import { SuppliersService } from './suppliers.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [SuppliersController],
  providers: [SuppliersService, PrismaService]
})
export class SuppliersModule {}
