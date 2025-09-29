import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';
import 'package:deneme1/features/inventory/data/models/inventory_item_model.dart';

void main() {
  group('InventoryItemModel', () {
    test('should create model from JSON', () {
      final json = {
        'id': '1',
        'name': 'T-Shirt',
        'category': 'Clothing',
        'price': 29.99,
        'stock': 100,
        'sku': 'TSH-001',
        'description': 'Comfortable cotton t-shirt',
        'imageUrl': 'https://example.com/image.jpg',
        'isActive': true,
        'createdAt': '2023-01-01T00:00:00Z',
        'updatedAt': '2023-01-02T00:00:00Z',
      };

      final model = InventoryItemModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'T-Shirt');
      expect(model.category, 'Clothing');
      expect(model.price, 29.99);
      expect(model.stock, 100);
      expect(model.sku, 'TSH-001');
      expect(model.description, 'Comfortable cotton t-shirt');
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.isActive, true);
      expect(model.createdAt, DateTime.parse('2023-01-01T00:00:00Z'));
      expect(model.updatedAt, DateTime.parse('2023-01-02T00:00:00Z'));
    });

    test('should convert to JSON', () {
      final now = DateTime.now();
      final model = InventoryItemModel(
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

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'T-Shirt');
      expect(json['category'], 'Clothing');
      expect(json['price'], 29.99);
      expect(json['stock'], 100);
      expect(json['sku'], 'TSH-001');
      expect(json['description'], 'Comfortable cotton t-shirt');
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['isActive'], true);
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('should convert to entity', () {
      const model = InventoryItemModel(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
        description: 'Comfortable cotton t-shirt',
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
      );

      final entity = model.toEntity();

      expect(entity.id, '1');
      expect(entity.name, 'T-Shirt');
      expect(entity.category, 'Clothing');
      expect(entity.price, 29.99);
      expect(entity.stock, 100);
      expect(entity.sku, 'TSH-001');
      expect(entity.description, 'Comfortable cotton t-shirt');
      expect(entity.imageUrl, 'https://example.com/image.jpg');
      expect(entity.isActive, true);
    });

    test('should create from entity', () {
      const entity = InventoryItem(
        id: '1',
        name: 'T-Shirt',
        category: 'Clothing',
        price: 29.99,
        stock: 100,
        sku: 'TSH-001',
        description: 'Comfortable cotton t-shirt',
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
      );

      final model = InventoryItemModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'T-Shirt');
      expect(model.category, 'Clothing');
      expect(model.price, 29.99);
      expect(model.stock, 100);
      expect(model.sku, 'TSH-001');
      expect(model.description, 'Comfortable cotton t-shirt');
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.isActive, true);
    });
  });
}
