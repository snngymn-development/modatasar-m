/// Sale domain entity
///
/// Usage:
/// ```dart
/// final sale = Sale(
///   id: 'S-001',
///   title: 'T-Shirt Sale',
///   total: 29.99,
///   description: 'Cotton t-shirt',
///   status: 'completed',
///   customerId: 'C-001',
///   customerName: 'John Doe',
///   createdAt: DateTime.now(),
/// );
/// ```
class Sale {
  final String id;
  final String title;
  final double total;
  final String? description;
  final String? status;
  final String? customerId;
  final String? customerName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SaleItem>? items;

  const Sale({
    required this.id,
    required this.title,
    required this.total,
    this.description,
    this.status,
    this.customerId,
    this.customerName,
    required this.createdAt,
    this.updatedAt,
    this.items,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale &&
        other.id == id &&
        other.title == title &&
        other.total == total &&
        other.description == description &&
        other.status == status &&
        other.customerId == customerId &&
        other.customerName == customerName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        total.hashCode ^
        description.hashCode ^
        status.hashCode ^
        customerId.hashCode ^
        customerName.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Sale(id: $id, title: $title, total: $total, description: $description, status: $status, customerId: $customerId, customerName: $customerName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Sale item domain entity
class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? sku;
  final String? category;
  final double price; // Unit price alias for compatibility
  final double total; // Total price alias for compatibility
  final String? imageUrl;
  final String? description;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sku,
    this.category,
    this.price = 0.0, // Default value for compatibility
    this.total = 0.0, // Default value for compatibility
    this.imageUrl,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItem &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.totalPrice == totalPrice &&
        other.sku == sku &&
        other.category == category &&
        other.price == price &&
        other.total == total &&
        other.imageUrl == imageUrl &&
        other.description == description;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        productName.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode ^
        totalPrice.hashCode ^
        sku.hashCode ^
        category.hashCode ^
        price.hashCode ^
        total.hashCode ^
        imageUrl.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'SaleItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, sku: $sku, category: $category, price: $price, total: $total, imageUrl: $imageUrl, description: $description)';
  }
}
