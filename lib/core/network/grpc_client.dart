import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../logging/talker_config.dart';
import '../error/failure.dart';
import 'result.dart';

/// Simplified gRPC client for microservices communication
///
/// Usage:
/// ```dart
/// final grpcClient = GrpcClient();
/// final result = await grpcClient.call('GetSales', request);
/// ```
class GrpcClient {
  static final GrpcClient _instance = GrpcClient._internal();
  factory GrpcClient() => _instance;
  GrpcClient._internal();

  late String _baseUrl;
  late String _authToken;
  bool _isInitialized = false;

  /// Initialize gRPC client
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _baseUrl = const String.fromEnvironment(
        'GRPC_ENDPOINT',
        defaultValue: 'https://api.example.com/grpc',
      );

      _authToken = await _getAuthToken() ?? '';

      _isInitialized = true;
      TalkerConfig.logInfo('gRPC client initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to initialize gRPC client', e, stackTrace);
      rethrow;
    }
  }

  /// Call gRPC service method
  Future<Result<T>> call<T>(
    String serviceName,
    String methodName,
    Map<String, dynamic> request, {
    Duration? timeout,
    Map<String, String>? metadata,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Simulate gRPC call via HTTP
      final response = await http.post(
        Uri.parse('$_baseUrl/$serviceName/$methodName'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
          ...?metadata,
        },
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        TalkerConfig.logInfo('gRPC call successful: $serviceName.$methodName');
        return Success(data as T);
      } else {
        return Error(
          Failure(
            'gRPC call failed: HTTP ${response.statusCode}',
            code: 'GRPC_ERROR',
          ),
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'gRPC call failed: $serviceName.$methodName',
        e,
        stackTrace,
      );
      return Error(Failure('gRPC call failed: $e'));
    }
  }

  /// Stream gRPC service method
  Stream<Result<T>> stream<T>(
    String serviceName,
    String methodName,
    Map<String, dynamic> request, {
    Duration? timeout,
    Map<String, String>? metadata,
  }) {
    try {
      if (!_isInitialized) {
        throw Exception('gRPC client not initialized');
      }

      // Simulate gRPC stream with periodic updates
      return Stream.periodic(const Duration(seconds: 2), (count) {
        TalkerConfig.logInfo(
          'gRPC stream data received: $serviceName.$methodName',
        );
        return Success(
          {
                'service': serviceName,
                'method': methodName,
                'data': request,
                'timestamp': DateTime.now().toIso8601String(),
                'count': count,
              }
              as T,
        );
      }).take(5);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'gRPC stream setup failed: $serviceName.$methodName',
        e,
        stackTrace,
      );
      return Stream.value(Error(Failure('gRPC stream setup failed: $e')));
    }
  }

  /// Close gRPC client
  Future<void> close() async {
    try {
      _isInitialized = false;
      TalkerConfig.logInfo('gRPC client closed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to close gRPC client', e, stackTrace);
    }
  }

  Future<String?> _getAuthToken() async {
    // TODO: Get from secure storage
    return 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// gRPC Service Definitions
class GrpcServices {
  static const String salesService = 'SalesService';
  static const String customerService = 'CustomerService';
  static const String inventoryService = 'InventoryService';
  static const String paymentService = 'PaymentService';
  static const String reportService = 'ReportService';
}

/// gRPC Method Definitions
class GrpcMethods {
  // Sales Service
  static const String getSales = 'GetSales';
  static const String getSaleById = 'GetSaleById';
  static const String createSale = 'CreateSale';
  static const String updateSale = 'UpdateSale';
  static const String deleteSale = 'DeleteSale';
  static const String streamSales = 'StreamSales';

  // Customer Service
  static const String getCustomers = 'GetCustomers';
  static const String getCustomerById = 'GetCustomerById';
  static const String createCustomer = 'CreateCustomer';
  static const String updateCustomer = 'UpdateCustomer';
  static const String deleteCustomer = 'DeleteCustomer';
  static const String searchCustomers = 'SearchCustomers';

  // Inventory Service
  static const String getInventory = 'GetInventory';
  static const String getItemById = 'GetItemById';
  static const String createItem = 'CreateItem';
  static const String updateItem = 'UpdateItem';
  static const String deleteItem = 'DeleteItem';
  static const String updateStock = 'UpdateStock';

  // Payment Service
  static const String processPayment = 'ProcessPayment';
  static const String refundPayment = 'RefundPayment';
  static const String getPaymentStatus = 'GetPaymentStatus';
  static const String getPaymentHistory = 'GetPaymentHistory';

  // Report Service
  static const String generateReport = 'GenerateReport';
  static const String getReportById = 'GetReportById';
  static const String getReports = 'GetReports';
  static const String exportReport = 'ExportReport';
}

/// gRPC Request/Response Models
class GrpcRequest {
  final String service;
  final String method;
  final Map<String, dynamic> data;
  final Map<String, String>? metadata;

  const GrpcRequest({
    required this.service,
    required this.method,
    required this.data,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'service': service,
    'method': method,
    'data': data,
    'metadata': metadata,
  };
}

class GrpcResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, String>? metadata;

  const GrpcResponse({
    required this.success,
    this.data,
    this.error,
    this.metadata,
  });

  factory GrpcResponse.fromJson(Map<String, dynamic> json) {
    return GrpcResponse(
      success: json['success'] ?? false,
      data: json['data'],
      error: json['error'],
      metadata: json['metadata']?.cast<String, String>(),
    );
  }
}
