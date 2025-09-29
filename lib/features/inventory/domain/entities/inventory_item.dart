/// Inventory item entity
///
/// Usage:
/// ```dart
/// final item = InventoryItem(
///   id: '1',
///   name: 'T-Shirt',
///   category: 'Clothing',
///   price: 29.99,
///   stock: 100,
///   sku: 'TSH-001',
/// );
/// ```
class InventoryItem {
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

  const InventoryItem({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItem &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.price == price &&
        other.stock == stock &&
        other.sku == sku &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        category.hashCode ^
        price.hashCode ^
        stock.hashCode ^
        sku.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, category: $category, price: $price, stock: $stock, sku: $sku)';
  }
}
