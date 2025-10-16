-- CreateTable
CREATE TABLE "CalendarEvent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "start" DATETIME NOT NULL,
    "end" DATETIME,
    "emoji" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PLANNED',
    "customerId" TEXT,
    "assigneeId" TEXT,
    "resourceId" TEXT,
    "sourceTable" TEXT,
    "sourceId" TEXT,
    "payload" TEXT,
    "createdBy" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "StockCard" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT,
    "type" TEXT,
    "kind" TEXT,
    "group" TEXT,
    "unit" TEXT NOT NULL DEFAULT 'adet',
    "criticalQty" INTEGER NOT NULL DEFAULT 0,
    "location" TEXT NOT NULL DEFAULT 'MAIN',
    "supplierId" TEXT,
    "tags" TEXT NOT NULL DEFAULT '',
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "StockCard_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_StockMovement" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "type" TEXT NOT NULL,
    "productId" TEXT,
    "stockCardId" TEXT,
    "receiptLineId" TEXT,
    "qty" INTEGER NOT NULL,
    "unit" TEXT NOT NULL DEFAULT 'adet',
    "warehouse" TEXT NOT NULL DEFAULT 'MAIN',
    "date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "note" TEXT,
    "referenceType" TEXT,
    "referenceId" TEXT,
    "createdBy" TEXT,
    CONSTRAINT "StockMovement_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "StockMovement_stockCardId_fkey" FOREIGN KEY ("stockCardId") REFERENCES "StockCard" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "StockMovement_receiptLineId_fkey" FOREIGN KEY ("receiptLineId") REFERENCES "GoodsReceiptLine" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_StockMovement" ("date", "id", "note", "productId", "qty", "receiptLineId", "type", "warehouse") SELECT "date", "id", "note", "productId", "qty", "receiptLineId", "type", "warehouse" FROM "StockMovement";
DROP TABLE "StockMovement";
ALTER TABLE "new_StockMovement" RENAME TO "StockMovement";
CREATE UNIQUE INDEX "StockMovement_receiptLineId_key" ON "StockMovement"("receiptLineId");
CREATE INDEX "StockMovement_productId_date_idx" ON "StockMovement"("productId", "date");
CREATE INDEX "StockMovement_stockCardId_date_idx" ON "StockMovement"("stockCardId", "date");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE INDEX "CalendarEvent_type_start_idx" ON "CalendarEvent"("type", "start");

-- CreateIndex
CREATE INDEX "CalendarEvent_assigneeId_start_idx" ON "CalendarEvent"("assigneeId", "start");

-- CreateIndex
CREATE INDEX "CalendarEvent_customerId_start_idx" ON "CalendarEvent"("customerId", "start");

-- CreateIndex
CREATE INDEX "CalendarEvent_resourceId_start_idx" ON "CalendarEvent"("resourceId", "start");

-- CreateIndex
CREATE INDEX "CalendarEvent_start_end_idx" ON "CalendarEvent"("start", "end");

-- CreateIndex
CREATE UNIQUE INDEX "StockCard_code_key" ON "StockCard"("code");

-- CreateIndex
CREATE INDEX "StockCard_supplierId_category_status_idx" ON "StockCard"("supplierId", "category", "status");
