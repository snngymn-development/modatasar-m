import { Module } from '@nestjs/common'
import { TimeEntriesController } from './time-entries.controller'
import { TimeEntriesService } from './time-entries.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [TimeEntriesController],
  providers: [TimeEntriesService, PrismaService]
})
export class TimeEntriesModule {}
