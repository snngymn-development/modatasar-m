/// Cart item domain entity
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final String? imageUrl;
  final String? description;
  final DateTime addedAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.imageUrl,
    this.description,
    required this.addedAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
      'imageUrl': imageUrl,
      'description': description,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
