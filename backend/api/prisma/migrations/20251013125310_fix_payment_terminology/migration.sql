/*
  Warnings:

  - You are about to drop the column `collected` on the `Purchase` table. All the data in the column will be lost.
  - You are about to drop the column `paymentStat` on the `Purchase` table. All the data in the column will be lost.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Purchase" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "code" TEXT,
    "date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "supplierId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "paymentStatus" TEXT NOT NULL DEFAULT 'UNPAID',
    "subTotal" INTEGER NOT NULL DEFAULT 0,
    "discountTot" INTEGER NOT NULL DEFAULT 0,
    "chargeTot" INTEGER NOT NULL DEFAULT 0,
    "vatRate" REAL NOT NULL DEFAULT 0.20,
    "vatTot" INTEGER NOT NULL DEFAULT 0,
    "roundingAdj" INTEGER NOT NULL DEFAULT 0,
    "total" INTEGER NOT NULL DEFAULT 0,
    "paid" INTEGER NOT NULL DEFAULT 0,
    "note" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Purchase_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Purchase" ("chargeTot", "code", "createdAt", "date", "discountTot", "id", "note", "roundingAdj", "status", "subTotal", "supplierId", "total", "type", "updatedAt", "vatRate", "vatTot") SELECT "chargeTot", "code", "createdAt", "date", "discountTot", "id", "note", "roundingAdj", "status", "subTotal", "supplierId", "total", "type", "updatedAt", "vatRate", "vatTot" FROM "Purchase";
DROP TABLE "Purchase";
ALTER TABLE "new_Purchase" RENAME TO "Purchase";
CREATE UNIQUE INDEX "Purchase_code_key" ON "Purchase"("code");
CREATE INDEX "Purchase_supplierId_date_status_idx" ON "Purchase"("supplierId", "date", "status");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
