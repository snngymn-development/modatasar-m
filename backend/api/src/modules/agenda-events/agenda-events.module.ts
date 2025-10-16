import { Module } from '@nestjs/common'
import { AgendaEventsController } from './agenda-events.controller'
import { AgendaEventsService } from './agenda-events.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [AgendaEventsController],
  providers: [AgendaEventsService, PrismaService],
})
export class AgendaEventsModule {}

