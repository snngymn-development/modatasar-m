-- Test tedarikçi verileri oluştur
INSERT INTO Supplier (id, name, email, phone, city, category, status, createdAt, updatedAt) VALUES
('supplier_1', 'ABC Tedarik AS', 'info@abc.com', '+90 212 123 4567', 'Istanbul', 'Malzeme', 'ACTIVE', datetime('now'), datetime('now')),
('supplier_2', 'XYZ Malzeme Ltd', 'info@xyz.com', '+90 216 987 6543', 'Ankara', 'Hizmet', 'ACTIVE', datetime('now'), datetime('now')),
('supplier_3', 'DEF Hizmetler', 'info@def.com', '+90 232 555 1234', 'Izmir', 'Malzeme', 'ACTIVE', datetime('now'), datetime('now'));
