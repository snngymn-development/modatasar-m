import 'cart_item.dart';

/// Cart domain entity
class Cart {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String? customerId;
  final String? customerName;
  final String? discountCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    this.id = '',
    this.items = const [],
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.customerId,
    this.customerName,
    this.discountCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      discountCode: json['discountCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'customerId': customerId,
      'customerName': customerName,
      'discountCode': discountCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}
