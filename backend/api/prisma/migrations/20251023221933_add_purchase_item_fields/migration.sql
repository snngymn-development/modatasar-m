-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_PurchaseItem" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "purchaseId" TEXT NOT NULL,
    "productId" TEXT,
    "productType" TEXT NOT NULL DEFAULT 'PRODUCT',
    "category" TEXT,
    "color" TEXT,
    "property" TEXT,
    "description" TEXT,
    "qtyOrdered" INTEGER NOT NULL,
    "qtyReceived" INTEGER NOT NULL DEFAULT 0,
    "unitPrice" INTEGER NOT NULL,
    "vatRate" REAL NOT NULL DEFAULT 20.0,
    "lineDiscountTot" INTEGER NOT NULL DEFAULT 0,
    "lineChargeTot" INTEGER NOT NULL DEFAULT 0,
    "lineSubTotal" INTEGER NOT NULL DEFAULT 0,
    "lineVat" INTEGER NOT NULL DEFAULT 0,
    "lineTotal" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "PurchaseItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "PurchaseItem_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES "Purchase" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_PurchaseItem" ("description", "id", "lineChargeTot", "lineDiscountTot", "lineSubTotal", "lineTotal", "lineVat", "productId", "purchaseId", "qtyOrdered", "qtyReceived", "unitPrice") SELECT "description", "id", "lineChargeTot", "lineDiscountTot", "lineSubTotal", "lineTotal", "lineVat", "productId", "purchaseId", "qtyOrdered", "qtyReceived", "unitPrice" FROM "PurchaseItem";
DROP TABLE "PurchaseItem";
ALTER TABLE "new_PurchaseItem" RENAME TO "PurchaseItem";
CREATE INDEX "PurchaseItem_purchaseId_idx" ON "PurchaseItem"("purchaseId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
