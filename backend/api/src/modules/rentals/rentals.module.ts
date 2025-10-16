import { Module } from '@nestjs/common'
import { RentalsController } from './rentals.controller'
import { RentalsService } from './rentals.service'
import { PrismaService } from '../../common/prisma.service'
import { RentalEventMapper } from '../calendar/event-mappers/rental.mapper'

@Module({ 
  controllers: [RentalsController], 
  providers: [RentalsService, PrismaService, RentalEventMapper] 
})
export class RentalsModule {}