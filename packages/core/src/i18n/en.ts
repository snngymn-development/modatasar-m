export default {
  // Navigation & Tabs
  tabs: {
    orders: 'Orders',
    calendar: 'Rental Calendar',
  },

  // Chips
  chips: {
    tailoring: 'Tailoring',
    rental: 'Rental',
  },

  // Order Types
  orderType: {
    TAILORING: 'Tailoring',
    RENTAL: 'Rental',
  },

  // Statuses
  status: {
    ACTIVE: 'Active',
    CANCELLED: 'Cancelled',
    COMPLETED: 'Completed',
  },

  // Employee Management
  employees: {
    title: 'Employee Management',
    list: 'Employee List',
    card: 'Employee Card',
    add: 'Add New Employee',
    edit: 'Edit Employee',
    delete: 'Delete Employee',
    
    // Employee Status
    status: {
      ACTIVE: 'Active',
      PASSIVE: 'Passive',
      PROBATION: 'Probation'
    },
    
    // Wage Types
    wageType: {
      FIXED: 'Fixed Salary',
      HOURLY: 'Hourly Wage'
    },
    
    // Time Entry
    timeEntry: {
      title: 'Time Entries',
      add: 'Add Time Entry',
      addOvertime: 'Add Overtime',
      normal: 'Normal Time',
      overtime: 'Overtime',
      approved: 'Approved',
      pending: 'Pending',
      rejected: 'Rejected',
      approval: 'Time Entry Approvals'
    },
    
    // Allowances
    allowance: {
      title: 'Allowance Records',
      add: 'Add Allowance',
      meal: 'Meal',
      transport: 'Transport',
      other: 'Other'
    },
    
    // Payroll
    payroll: {
      title: 'Payroll Management',
      calculate: 'Calculate Weekly',
      preview: 'Payroll Preview',
      run: 'Payroll Run',
      lock: 'Lock',
      pay: 'Pay',
      bulkPay: 'Bulk Pay',
      draft: 'Draft',
      posted: 'Posted',
      gross: 'Gross Salary',
      overtime: 'Overtime',
      allowances: 'Allowances',
      deductions: 'Deductions',
      net: 'Net Payable'
    },
    
    // SGK
    sgk: {
      title: 'SGK Records',
      paid: 'Paid',
      unpaid: 'Unpaid'
    },
    
    // Filters
    filters: {
      search: 'Search',
      status: 'Status',
      department: 'Department',
      position: 'Position',
      sgkStatus: 'SGK Status',
      period: 'Period',
      week: 'Week',
      month: 'Month',
      thisWeek: 'This Week',
      lastWeek: 'Last Week',
      thisMonth: 'This Month'
    },
    
    // General Info
    general: {
      firstName: 'First Name',
      lastName: 'Last Name',
      tcNo: 'TC No',
      sgkNo: 'SGK No',
      position: 'Position',
      department: 'Department',
      hireDate: 'Hire Date',
      terminationDate: 'Termination Date',
      phone: 'Phone',
      email: 'Email',
      address: 'Address',
      iban: 'IBAN',
      normalWeeklyHours: 'Normal Weekly Hours',
      baseWage: 'Base Wage'
    }
  },

  // Stages - Tailoring
  stageTailoring: {
    CREATED: 'Order Received',
    IN_PROGRESS_50: 'In Progress 50%',
    IN_PROGRESS_80: 'In Progress 80%',
    READY: 'Ready',
    DELIVERED: 'Delivered',
  },

  // Stages - Rental
  stageRental: {
    BOOKED: 'Booked',
    PICKED_UP: 'Picked Up',
    RETURNED: 'Returned',
  },

  // Product Status
  productStatus: {
    AVAILABLE: 'Available',
    IN_USE: 'In Use',
    MAINTENANCE: 'Maintenance',
  },

  // Agenda Event Types
  agendaType: {
    DRY_CLEANING: 'Dry Cleaning',
    ALTERATION: 'Alteration',
    OUT_OF_SERVICE: 'Out of Service',
  },

  // Filters
  filters: {
    customer: 'Customer',
    type: 'Type',
    organization: 'Organization',
    product: 'Product',
    status: 'Status',
    delivery: 'Delivery Date',
    rentPeriod: 'Rental Period',
    dateRange: 'Date Range',
    all: 'All',
  },

  // Table Columns
  table: {
    orderDate: 'Order Date',
    deliveryRent: 'Delivery / Rent',
    customer: 'Customer',
    type: 'Type',
    organization: 'Organization',
    product: 'Product',
    total: 'Total',
    collected: 'Collected',
    balance: 'Balance',
    currentBalance: 'Current Balance',
    status: 'Status',
    stage: 'Stage',
  },

  // Tool Palette
  tools: {
    newRental: 'New Rental',
    dryCleaning: 'Dry Cleaning',
    alteration: 'Alteration',
    outOfService: 'Out of Service',
  },

  // Common
  common: {
    search: 'Search',
    filter: 'Filter',
    reset: 'Reset',
    save: 'Save',
    cancel: 'Cancel',
    delete: 'Delete',
    edit: 'Edit',
    add: 'Add',
    loading: 'Loading...',
    noData: 'No data found',
  },
}

