-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Account" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "type" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'TRY',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "parentId" TEXT,
    "creditLimit" INTEGER,
    "usedAmount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Account_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Account" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Account" ("createdAt", "currency", "id", "isActive", "name", "type", "updatedAt") SELECT "createdAt", "currency", "id", "isActive", "name", "type", "updatedAt" FROM "Account";
DROP TABLE "Account";
ALTER TABLE "new_Account" RENAME TO "Account";
CREATE INDEX "Account_type_isActive_idx" ON "Account"("type", "isActive");
CREATE INDEX "Account_parentId_idx" ON "Account"("parentId");
CREATE UNIQUE INDEX "Account_name_type_key" ON "Account"("name", "type");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
