import type { ID, Currency } from '../types/common';
export interface Payment {
    id: ID;
    orderId?: ID;
    rentalId?: ID;
    amount: Currency;
    date: string;
}
