import { Module } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { CalendarController } from './calendar.controller'
import { CalendarService } from './calendar.service'
import { CalendarGateway } from './calendar.gateway'
import { RentalEventMapper } from './event-mappers/rental.mapper'
import { OrderEventMapper } from './event-mappers/order.mapper'
import { PaymentEventMapper } from './event-mappers/payment.mapper'
import { AgendaMigrationService } from './migrations/agenda-migration.service'
import { CalendarSeedService } from './seed/calendar-seed.service'
import { CalendarAnalyticsService } from './analytics/calendar-analytics.service'
import { ConflictDetectionService } from './conflict-detection.service'

@Module({
  controllers: [CalendarController],
  providers: [
    PrismaService,
    CalendarService, 
    CalendarGateway, 
    RentalEventMapper, 
    OrderEventMapper, 
    PaymentEventMapper, 
    AgendaMigrationService, 
    CalendarSeedService,
    CalendarAnalyticsService,
    ConflictDetectionService
  ],
  exports: [
    CalendarService, 
    CalendarGateway, 
    RentalEventMapper, 
    OrderEventMapper, 
    PaymentEventMapper, 
    AgendaMigrationService, 
    CalendarSeedService,
    CalendarAnalyticsService,
    ConflictDetectionService
  ],
})
export class CalendarModule {}
