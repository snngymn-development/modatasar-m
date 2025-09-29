import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    test('should create inventory item with required fields', () {
      const item = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      expect(item.id, '1');
      expect(item.name, 'T-Shirt');
      expect(item.category, 'Clothing');
      expect(item.price, 29.99);
      expect(item.stock, 100);
      expect(item.sku, 'TSH-001');
      expect(item.isActive, false);
    });

    test('should create inventory item with optional fields', () {
      final now = DateTime.now();
      final item = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
        description: 'Comfortable cotton t-shirt',
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.description, 'Comfortable cotton t-shirt');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.isActive, true);
      expect(item.createdAt, now);
      expect(item.updatedAt, now);
    });

    test('should support equality', () {
      const item1 = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      const item2 = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      const item3 = InventoryItem(
        id: '2',
        name: 'Jeans',
        category: 'Clothing',
        price: 79.99,
        stock: 50,
        sku: 'JNS-001',
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('should support hashCode', () {
      const item1 = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      const item2 = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should support toString', () {
      const item = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
      );

      expect(item.toString(), contains('InventoryItem'));
      expect(item.toString(), contains('id: 1'));
      expect(item.toString(), contains('name: T-Shirt'));
    });
  });
}
