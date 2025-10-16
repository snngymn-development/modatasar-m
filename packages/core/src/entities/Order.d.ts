import type { ID, Currency } from '../types/common';
import { OrderType, PaymentStatus, RecordStatus } from '../types/enums';
export interface Order {
    id: ID;
    type: OrderType;
    customerId: ID;
    organization?: string;
    deliveryDate?: string;
    total: Currency;
    collected: Currency;
    paymentStatus: PaymentStatus;
    status: RecordStatus;
    createdAt: string;
}
