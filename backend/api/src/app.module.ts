import { Module } from '@nestjs/common'
import { PrismaService } from './common/prisma.service'
import { EventsGateway } from './common/events.gateway'
import { HealthModule } from './health/health.module'
import { CustomersModule } from './modules/customers/customers.module'
import { SuppliersModule } from './modules/suppliers/suppliers.module'
import { RentalsModule } from './modules/rentals/rentals.module'
import { DashboardModule } from './modules/dashboard/dashboard.module'
import { ProductsModule } from './modules/products/products.module'
import { TransactionsModule } from './modules/transactions/transactions.module'
import { AgendaEventsModule } from './modules/agenda-events/agenda-events.module'
import { PurchasesModule } from './modules/purchases/purchases.module'
import { CalendarModule } from './modules/calendar/calendar.module'
import { InventoryModule } from './modules/inventory/inventory.module'
import { StocksModule } from './modules/stocks/stocks.module'
import { FinanceModule } from './modules/finance/finance.module'
import { EmployeesModule } from './modules/employees/employees.module'
import { TimeEntriesModule } from './modules/time-entries/time-entries.module'
import { AllowancesModule } from './modules/allowances/allowances.module'
import { PayrollModule } from './modules/payroll/payroll.module'

@Module({
  imports: [
    HealthModule,
    CustomersModule,
    SuppliersModule,
    RentalsModule,
    DashboardModule,
    ProductsModule,
    TransactionsModule,
    AgendaEventsModule,
    PurchasesModule,
    CalendarModule,
    InventoryModule,
    StocksModule,
    FinanceModule,
    EmployeesModule,
    TimeEntriesModule,
    AllowancesModule,
    PayrollModule,
  ],
  providers: [PrismaService, EventsGateway],
  exports: [PrismaService],
})
export class AppModule {}
