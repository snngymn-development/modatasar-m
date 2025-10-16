import { Module } from '@nestjs/common'
import { StocksController } from './stocks.controller'
import { StocksService } from './stocks.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [StocksController],
  providers: [StocksService, PrismaService],
  exports: [StocksService],
})
export class StocksModule {}
