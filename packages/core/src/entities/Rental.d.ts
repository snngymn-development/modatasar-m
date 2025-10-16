import type { ID, Currency, DateRange } from '../types/common';
import { PaymentStatus, RecordStatus } from '../types/enums';
export interface Rental {
    id: ID;
    customerId: ID;
    organization?: string;
    period: DateRange;
    total: Currency;
    collected: Currency;
    paymentStatus: PaymentStatus;
    status: RecordStatus;
    createdAt: string;
}
