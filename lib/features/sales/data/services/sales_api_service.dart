import 'package:deneme1/core/network/enhanced_network_client.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';
import 'package:deneme1/core/config/api_config.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/features/sales/data/models/sale_model.dart';

/// Real API service for sales data operations
///
/// Usage:
/// ```dart
/// final service = SalesApiService(networkClient);
/// final result = await service.getSales();
/// ```
class SalesApiService {
  final EnhancedNetworkClient _client;

  SalesApiService(this._client);

  /// Get all sales with pagination and filtering
  Future<Result<SalesResponse>> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final result = await _client.get<Map<String, dynamic>>(
      ApiConfig.salesEndpoint,
      queryParameters: queryParams,
    );

    return result.when(
      success: (data) {
        try {
          final salesResponse = SalesResponse.fromJson(data);
          return Success(salesResponse);
        } catch (e) {
          return Error(Failure('Failed to parse sales response: $e'));
        }
      },
      error: (failure) => Error(failure),
    );
  }

  /// Get single sale by ID
  Future<Result<Sale>> getSaleById(String id) async {
    final result = await _client.get<Map<String, dynamic>>(
      '${ApiConfig.salesEndpoint}/$id',
    );

    return result.when(
      success: (data) {
        try {
          final sale = SaleModel.fromJson(data).toEntity();
          return Success(sale);
        } catch (e) {
          return Error(Failure('Failed to parse sale: $e'));
        }
      },
      error: (failure) => Error(failure),
    );
  }

  /// Create new sale
  Future<Result<Sale>> createSale(CreateSaleRequest request) async {
    final result = await _client.post<Map<String, dynamic>>(
      ApiConfig.salesEndpoint,
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        try {
          final sale = SaleModel.fromJson(data).toEntity();
          return Success(sale);
        } catch (e) {
          return Error(Failure('Failed to parse created sale: $e'));
        }
      },
      error: (failure) => Error(failure),
    );
  }

  /// Update existing sale
  Future<Result<Sale>> updateSale(String id, UpdateSaleRequest request) async {
    final result = await _client.put<Map<String, dynamic>>(
      '${ApiConfig.salesEndpoint}/$id',
      data: request.toJson(),
    );

    return result.when(
      success: (data) {
        try {
          final sale = SaleModel.fromJson(data).toEntity();
          return Success(sale);
        } catch (e) {
          return Error(Failure('Failed to parse updated sale: $e'));
        }
      },
      error: (failure) => Error(failure),
    );
  }

  /// Delete sale
  Future<Result<void>> deleteSale(String id) async {
    final result = await _client.delete<void>('${ApiConfig.salesEndpoint}/$id');

    return result.when(
      success: (_) => const Success(null),
      error: (failure) => Error(failure),
    );
  }

  /// Get sales statistics
  Future<Result<SalesStatistics>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    final result = await _client.get<Map<String, dynamic>>(
      '${ApiConfig.salesEndpoint}/statistics',
      queryParameters: queryParams,
    );

    return result.when(
      success: (data) {
        try {
          final statistics = SalesStatistics.fromJson(data);
          return Success(statistics);
        } catch (e) {
          return Error(Failure('Failed to parse sales statistics: $e'));
        }
      },
      error: (failure) => Error(failure),
    );
  }
}

/// Sales API response model
class SalesResponse {
  final List<Sale> sales;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  SalesResponse({
    required this.sales,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    return SalesResponse(
      sales: (json['data'] as List<dynamic>)
          .map((item) => SaleModel.fromJson(item).toEntity())
          .toList(),
      totalCount: json['total_count'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );
  }
}

/// Create sale request model
class CreateSaleRequest {
  final String title;
  final double total;
  final String? description;
  final String? customerId;
  final List<SaleItem> items;

  CreateSaleRequest({
    required this.title,
    required this.total,
    this.description,
    this.customerId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'total': total,
      'description': description,
      'customer_id': customerId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Update sale request model
class UpdateSaleRequest {
  final String? title;
  final double? total;
  final String? description;
  final String? status;
  final List<SaleItem>? items;

  UpdateSaleRequest({
    this.title,
    this.total,
    this.description,
    this.status,
    this.items,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (total != null) json['total'] = total;
    if (description != null) json['description'] = description;
    if (status != null) json['status'] = status;
    if (items != null) {
      json['items'] = items!.map((item) => item.toJson()).toList();
    }
    return json;
  }
}

/// Sale item model
class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}

/// Sales statistics model
class SalesStatistics {
  final double totalRevenue;
  final int totalSales;
  final double averageOrderValue;
  final int todaySales;
  final double todayRevenue;
  final List<DailySales> dailySales;

  SalesStatistics({
    required this.totalRevenue,
    required this.totalSales,
    required this.averageOrderValue,
    required this.todaySales,
    required this.todayRevenue,
    required this.dailySales,
  });

  factory SalesStatistics.fromJson(Map<String, dynamic> json) {
    return SalesStatistics(
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      totalSales: json['total_sales'] as int,
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      todaySales: json['today_sales'] as int,
      todayRevenue: (json['today_revenue'] as num).toDouble(),
      dailySales: (json['daily_sales'] as List<dynamic>)
          .map((item) => DailySales.fromJson(item))
          .toList(),
    );
  }
}

/// Daily sales model
class DailySales {
  final DateTime date;
  final int salesCount;
  final double revenue;

  DailySales({
    required this.date,
    required this.salesCount,
    required this.revenue,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date'] as String),
      salesCount: json['sales_count'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}
