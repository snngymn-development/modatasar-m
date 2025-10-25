-- Test purchase data
INSERT INTO Purchase (id, code, supplierId, type, status, paymentStatus, date, dueDate, note, subTotal, discountTot, chargeTot, vatTot, roundingAdj, total, paid, createdAt, updatedAt) VALUES
('purchase_1', 'PUR-001', 'supplier_1', 'STOCK', 'ORDERED', 'UNPAID', '2024-01-15', '2024-02-15', 'Test purchase 1', 100000, 0, 5000, 21000, 0, 126000, 0, datetime('now'), datetime('now')),
('purchase_2', 'PUR-002', 'supplier_2', 'EXPENSE', 'RECEIVED', 'PAID', '2024-01-20', '2024-02-20', 'Test purchase 2', 50000, 5000, 0, 9000, 0, 54000, 54000, datetime('now'), datetime('now')),
('purchase_3', 'PUR-003', 'supplier_1', 'INVENTORY', 'PARTIAL_RECEIVED', 'PARTIAL', '2024-01-25', '2024-02-25', 'Test purchase 3', 200000, 10000, 15000, 41000, 0, 246000, 100000, datetime('now'), datetime('now'));
