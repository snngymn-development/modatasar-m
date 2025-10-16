export enum OrderType {
  SALE = 'SALE',
  RENTAL = 'RENTAL'
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  PAID = 'PAID',
  PARTIAL = 'PARTIAL'
}

export enum EventType {
  APPOINTMENT = 'APPOINTMENT',
  FITTING = 'FITTING',
  ORDER_DELIVERY = 'ORDER_DELIVERY',
  RENTAL = 'RENTAL',
  RECEIVABLE = 'RECEIVABLE',
  PAYABLE = 'PAYABLE',
  TODO = 'TODO'
}

export enum EventStatus {
  PLANNED = 'PLANNED',
  DONE = 'DONE',
  CANCELLED = 'CANCELLED'
}

export enum RecordStatus {
  ACTIVE = 'ACTIVE',
  CANCELLED = 'CANCELLED',
  COMPLETED = 'COMPLETED'
}

// Finance enums
export enum AccountType {
  CASH = 'CASH',
  BANK = 'BANK',
  POS = 'POS'
}


export enum PostingDC {
  DEBIT = 'DEBIT',
  CREDIT = 'CREDIT'
}

export enum Currency {
  TRY = 'TRY',
  USD = 'USD',
  EUR = 'EUR'
}


// Calendar Event Types
export enum CalendarView {
  WEEK = 'WEEK',
  MONTH = 'MONTH',
  RESOURCE = 'RESOURCE',
  GANTT = 'GANTT'
}

export enum ReminderChannel {
  PUSH = 'PUSH',
  EMAIL = 'EMAIL',
  WHATSAPP = 'WHATSAPP',
  SMS = 'SMS'
}

export enum ConflictType {
  ASSIGNEE = 'ASSIGNEE',
  RESOURCE = 'RESOURCE',
  TIME = 'TIME'
}

// User Roles for Calendar Access
export enum CalendarRole {
  PATRON = 'PATRON',           // See everything
  ACCOUNTING = 'ACCOUNTING',   // See payments + summary
  TAILOR = 'TAILOR',           // See own appointments/fittings
  SALES = 'SALES'              // See own customer events
}

// Business Hours Configuration
export enum DayOfWeek {
  MONDAY = 'MONDAY',
  TUESDAY = 'TUESDAY',
  WEDNESDAY = 'WEDNESDAY',
  THURSDAY = 'THURSDAY',
  FRIDAY = 'FRIDAY',
  SATURDAY = 'SATURDAY',
  SUNDAY = 'SUNDAY'
}

// Employee Enums
export const EmployeeStatus = {
  EMPLOYEE_ACTIVE: 'ACTIVE',
  EMPLOYEE_PASSIVE: 'PASSIVE',
  EMPLOYEE_PROBATION: 'PROBATION'
} as const

export type EmployeeStatus = typeof EmployeeStatus[keyof typeof EmployeeStatus]

export const WageType = {
  FIXED: 'FIXED',      // Sabit maaş
  HOURLY: 'HOURLY'     // Saatlik ücret
} as const

export type WageType = typeof WageType[keyof typeof WageType]

export const TimeEntryType = {
  NORMAL: 'NORMAL',        // Normal mesai
  OVERTIME: 'OVERTIME'     // Fazla mesai
} as const

export type TimeEntryType = typeof TimeEntryType[keyof typeof TimeEntryType]

export const AllowanceKind = {
  MEAL: 'MEAL',           // Yemek
  TRANSPORT: 'TRANSPORT', // Yol
  OTHER: 'OTHER'          // Diğer
} as const

export type AllowanceKind = typeof AllowanceKind[keyof typeof AllowanceKind]

export const PayrollStatus = {
  DRAFT: 'DRAFT',         // Taslak
  POSTED: 'POSTED'        // Kilitleme
} as const

export type PayrollStatus = typeof PayrollStatus[keyof typeof PayrollStatus]

export const SgkStatus = {
  PAID: 'PAID',           // Yatırıldı
  UNPAID: 'UNPAID'        // Yatırılmadı
} as const

export type SgkStatus = typeof SgkStatus[keyof typeof SgkStatus]

export const TransactionKind = {
  RECEIVABLE: 'RECEIVABLE',           // Alacak
  PAYABLE: 'PAYABLE',                 // Borç
  INTERNAL_TRANSFER: 'INTERNAL_TRANSFER', // İç transfer
  PAYROLL: 'PAYROLL',                 // Personel ödemesi
  PAYROLL_ADVANCE: 'PAYROLL_ADVANCE', // Personel avansı
  PAYROLL_REFUND: 'PAYROLL_REFUND'    // Personel iadesi
} as const

export type TransactionKind = typeof TransactionKind[keyof typeof TransactionKind]