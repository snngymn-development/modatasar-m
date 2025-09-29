import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';

/// Inventory item data model
///
/// Usage:
/// ```dart
/// final model = InventoryItemModel.fromJson(json);
/// final entity = model.toEntity();
/// ```
class InventoryItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String sku;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.sku,
    this.description,
    this.imageUrl,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      sku: json['sku'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'sku': sku,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  InventoryItem toEntity() {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      price: price,
      stock: stock,
      sku: sku,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory InventoryItemModel.fromEntity(InventoryItem entity) {
    return InventoryItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      price: entity.price,
      stock: entity.stock,
      sku: entity.sku,
      description: entity.description,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
