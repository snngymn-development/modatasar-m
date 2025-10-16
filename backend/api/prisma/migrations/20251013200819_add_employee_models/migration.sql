-- CreateTable
CREATE TABLE "Employee" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "tcNo" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "departmentId" TEXT,
    "department" TEXT,
    "position" TEXT,
    "hireDate" TEXT NOT NULL,
    "terminationDate" TEXT,
    "wageType" TEXT NOT NULL,
    "baseWageAmount" INTEGER NOT NULL,
    "baseWageCurrency" TEXT NOT NULL DEFAULT 'TRY',
    "normalWeeklyHours" INTEGER NOT NULL DEFAULT 45,
    "phone" TEXT,
    "email" TEXT,
    "address" TEXT,
    "iban" TEXT,
    "sgkNo" TEXT,
    "shiftId" TEXT,
    "shiftName" TEXT,
    "advancePolicy" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "TimeEntry" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "employeeId" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "durationHours" REAL NOT NULL,
    "type" TEXT NOT NULL,
    "approved" BOOLEAN NOT NULL DEFAULT false,
    "note" TEXT,
    "approvedBy" TEXT,
    "approvedAt" DATETIME,
    "createdBy" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "TimeEntry_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Allowance" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "employeeId" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'TRY',
    "note" TEXT,
    "createdBy" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Allowance_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "SgkRecord" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "employeeId" TEXT NOT NULL,
    "period" TEXT NOT NULL,
    "baseAmount" INTEGER NOT NULL,
    "employerShare" INTEGER NOT NULL,
    "employeeShare" INTEGER NOT NULL,
    "total" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'UNPAID',
    "paymentDate" TEXT,
    "financeTransactionId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "SgkRecord_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "PayrollRun" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "periodStart" TEXT NOT NULL,
    "periodEnd" TEXT NOT NULL,
    "scope" TEXT NOT NULL,
    "employeeIds" TEXT,
    "grossTotal" INTEGER NOT NULL DEFAULT 0,
    "overtimeTotal" INTEGER NOT NULL DEFAULT 0,
    "allowancesTotal" INTEGER NOT NULL DEFAULT 0,
    "deductionsTotal" INTEGER NOT NULL DEFAULT 0,
    "netTotal" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "createdBy" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "postedAt" DATETIME,
    "postedBy" TEXT
);

-- CreateTable
CREATE TABLE "PayrollItem" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "payrollRunId" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "grossSalary" INTEGER NOT NULL,
    "normalHours" REAL NOT NULL,
    "overtimeHours" REAL NOT NULL,
    "overtimeRate" REAL NOT NULL,
    "overtimeAmount" INTEGER NOT NULL,
    "allowancesTotal" INTEGER NOT NULL,
    "deductionsTotal" INTEGER NOT NULL,
    "netPay" INTEGER NOT NULL,
    "postedFinanceTransactionId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "PayrollItem_payrollRunId_fkey" FOREIGN KEY ("payrollRunId") REFERENCES "PayrollRun" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "PayrollItem_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "Employee_tcNo_key" ON "Employee"("tcNo");

-- CreateIndex
CREATE INDEX "Employee_status_department_idx" ON "Employee"("status", "department");

-- CreateIndex
CREATE INDEX "Employee_hireDate_idx" ON "Employee"("hireDate");

-- CreateIndex
CREATE INDEX "Employee_tcNo_idx" ON "Employee"("tcNo");

-- CreateIndex
CREATE INDEX "TimeEntry_employeeId_date_idx" ON "TimeEntry"("employeeId", "date");

-- CreateIndex
CREATE INDEX "TimeEntry_type_approved_idx" ON "TimeEntry"("type", "approved");

-- CreateIndex
CREATE INDEX "TimeEntry_date_idx" ON "TimeEntry"("date");

-- CreateIndex
CREATE INDEX "Allowance_employeeId_date_idx" ON "Allowance"("employeeId", "date");

-- CreateIndex
CREATE INDEX "Allowance_kind_date_idx" ON "Allowance"("kind", "date");

-- CreateIndex
CREATE INDEX "SgkRecord_period_status_idx" ON "SgkRecord"("period", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SgkRecord_employeeId_period_key" ON "SgkRecord"("employeeId", "period");

-- CreateIndex
CREATE INDEX "PayrollRun_periodStart_periodEnd_idx" ON "PayrollRun"("periodStart", "periodEnd");

-- CreateIndex
CREATE INDEX "PayrollRun_status_idx" ON "PayrollRun"("status");

-- CreateIndex
CREATE INDEX "PayrollItem_payrollRunId_idx" ON "PayrollItem"("payrollRunId");

-- CreateIndex
CREATE INDEX "PayrollItem_employeeId_idx" ON "PayrollItem"("employeeId");

-- CreateIndex
CREATE UNIQUE INDEX "PayrollItem_payrollRunId_employeeId_key" ON "PayrollItem"("payrollRunId", "employeeId");
