import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

/// Sale data model for API communication
@JsonSerializable()
class SaleModel {
  final String id;
  final String title;
  final double total;
  final String? description;
  final String? status;
  final String? customerId;
  final String? customerName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final List<SaleItemModel>? items;

  const SaleModel({
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

  /// Create from JSON
  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  /// Convert to domain entity
  Sale toEntity() {
    return Sale(
      id: id,
      title: title,
      total: total,
      description: description,
      status: status,
      customerId: customerId,
      customerName: customerName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items?.map((item) => item.toEntity()).toList(),
    );
  }

  /// Create from domain entity
  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      title: sale.title,
      total: sale.total,
      description: sale.description,
      status: sale.status,
      customerId: sale.customerId,
      customerName: sale.customerName,
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
      items: sale.items?.map((item) => SaleItemModel.fromEntity(item)).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleModel &&
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
    return 'SaleModel(id: $id, title: $title, total: $total, status: $status)';
  }
}

/// Sale item data model
@JsonSerializable()
class SaleItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final String? imageUrl;
  final String? description;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.imageUrl,
    this.description,
  });

  /// Create from JSON
  factory SaleItemModel.fromJson(Map<String, dynamic> json) =>
      _$SaleItemModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SaleItemModelToJson(this);

  /// Convert to domain entity
  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: price, // Use price as unitPrice
      totalPrice: total, // Use total as totalPrice
      price: price,
      total: total,
      imageUrl: imageUrl,
      description: description,
    );
  }

  /// Create from domain entity
  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      productId: item.productId,
      productName: item.productName,
      price: item.unitPrice, // Use unitPrice as price
      quantity: item.quantity,
      total: item.totalPrice, // Use totalPrice as total
      imageUrl: item.imageUrl,
      description: item.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItemModel &&
        other.productId == productId &&
        other.productName == productName &&
        other.price == price &&
        other.quantity == quantity &&
        other.total == total &&
        other.imageUrl == imageUrl &&
        other.description == description;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        productName.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        total.hashCode ^
        imageUrl.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'SaleItemModel(productId: $productId, productName: $productName, quantity: $quantity, total: $total)';
  }
}
