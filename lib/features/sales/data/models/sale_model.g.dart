// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleModel _$SaleModelFromJson(Map<String, dynamic> json) => SaleModel(
  id: json['id'] as String,
  title: json['title'] as String,
  total: (json['total'] as num).toDouble(),
  description: json['description'] as String?,
  status: json['status'] as String?,
  customerId: json['customerId'] as String?,
  customerName: json['customerName'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SaleModelToJson(SaleModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'total': instance.total,
  'description': instance.description,
  'status': instance.status,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'items': instance.items,
};

SaleItemModel _$SaleItemModelFromJson(Map<String, dynamic> json) =>
    SaleItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SaleItemModelToJson(SaleItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'price': instance.price,
      'quantity': instance.quantity,
      'total': instance.total,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
    };
