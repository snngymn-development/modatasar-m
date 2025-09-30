import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/talker_config.dart';
import '../error/failure.dart';
import '../network/result.dart';

/// Supabase database service for real-time PostgreSQL
///
/// Usage:
/// ```dart
/// final supabase = SupabaseService();
/// await supabase.initialize();
/// final result = await supabase.getSales();
/// ```
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;
  bool _isInitialized = false;

  /// Initialize Supabase service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://your-project.supabase.co',
        ),
        anonKey: const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'your-anon-key',
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
      TalkerConfig.logInfo('Supabase service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize Supabase service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase service not initialized');
    }
    return _client;
  }

  /// Get sales data
  Future<Result<List<Map<String, dynamic>>>> getSales({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('sales')
          .select('''
            id,
            customer_id,
            total,
            status,
            created_at,
            updated_at,
            items:sales_items(
              id,
              product_id,
              quantity,
              price
            )
          ''')
          .order('created_at', ascending: false)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

      final sales = response.map<Map<String, dynamic>>((item) => item).toList();
      return Success(sales);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get sales from Supabase', e, stackTrace);
      return Error(Failure('Failed to get sales: $e'));
    }
  }

  /// Get sale by ID
  Future<Result<Map<String, dynamic>?>> getSaleById(String id) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('sales')
          .select('''
            id,
            customer_id,
            total,
            status,
            created_at,
            updated_at,
            items:sales_items(
              id,
              product_id,
              quantity,
              price
            )
          ''')
          .eq('id', id)
          .single();

      return Success(response as Map<String, dynamic>?);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to get sale by ID from Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to get sale: $e'));
    }
  }

  /// Create sale
  Future<Result<Map<String, dynamic>>> createSale(
    Map<String, dynamic> saleData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      // Start transaction
      final response = await _client.rpc(
        'create_sale',
        params: {'sale_data': saleData},
      );

      return Success(response);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to create sale in Supabase', e, stackTrace);
      return Error(Failure('Failed to create sale: $e'));
    }
  }

  /// Update sale
  Future<Result<Map<String, dynamic>>> updateSale(
    String id,
    Map<String, dynamic> saleData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('sales')
          .update(saleData)
          .eq('id', id)
          .select()
          .single();

      return Success(response);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to update sale in Supabase', e, stackTrace);
      return Error(Failure('Failed to update sale: $e'));
    }
  }

  /// Delete sale
  Future<Result<void>> deleteSale(String id) async {
    try {
      if (!_isInitialized) await initialize();

      await _client.from('sales').delete().eq('id', id);
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to delete sale from Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to delete sale: $e'));
    }
  }

  /// Get customers
  Future<Result<List<Map<String, dynamic>>>> getCustomers({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('customers')
          .select('id, name, email, phone, created_at, updated_at')
          .order('created_at', ascending: false)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

      final customers = response
          .map<Map<String, dynamic>>((item) => item)
          .toList();
      return Success(customers);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to get customers from Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to get customers: $e'));
    }
  }

  /// Create customer
  Future<Result<Map<String, dynamic>>> createCustomer(
    Map<String, dynamic> customerData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      return Success(response);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to create customer in Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to create customer: $e'));
    }
  }

  /// Get inventory
  Future<Result<List<Map<String, dynamic>>>> getInventory({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('inventory')
          .select(
            'id, name, sku, price, stock, category, created_at, updated_at',
          )
          .order('created_at', ascending: false)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

      final inventory = response
          .map<Map<String, dynamic>>((item) => item)
          .toList();
      return Success(inventory);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to get inventory from Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to get inventory: $e'));
    }
  }

  /// Update inventory stock
  Future<Result<Map<String, dynamic>>> updateStock(
    String id,
    int newStock,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client
          .from('inventory')
          .update({
            'stock': newStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return Success(response);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to update stock in Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to update stock: $e'));
    }
  }

  /// Subscribe to real-time sales updates
  Stream<Result<Map<String, dynamic>>> subscribeToSales() {
    try {
      if (!_isInitialized) {
        throw Exception('Supabase service not initialized');
      }

      return _client
          .from('sales')
          .stream(primaryKey: ['id'])
          .map((data) {
            TalkerConfig.logInfo('Real-time sales update received');
            return Success(data as Map<String, dynamic>);
          })
          .handleError((error, stackTrace) {
            TalkerConfig.logError(
              'Real-time sales subscription error',
              error,
              stackTrace,
            );
            return Error(Failure('Real-time subscription failed: $error'));
          });
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to subscribe to sales', e, stackTrace);
      return Stream.value(Error(Failure('Failed to subscribe to sales: $e')));
    }
  }

  /// Subscribe to real-time inventory updates
  Stream<Result<Map<String, dynamic>>> subscribeToInventory() {
    try {
      if (!_isInitialized) {
        throw Exception('Supabase service not initialized');
      }

      return _client
          .from('inventory')
          .stream(primaryKey: ['id'])
          .map((data) {
            TalkerConfig.logInfo('Real-time inventory update received');
            return Success(data as Map<String, dynamic>);
          })
          .handleError((error, stackTrace) {
            TalkerConfig.logError(
              'Real-time inventory subscription error',
              error,
              stackTrace,
            );
            return Error(Failure('Real-time subscription failed: $error'));
          });
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to subscribe to inventory', e, stackTrace);
      return Stream.value(
        Error(Failure('Failed to subscribe to inventory: $e')),
      );
    }
  }

  /// Execute custom SQL query
  Future<Result<List<Map<String, dynamic>>>> executeQuery(String query) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _client.rpc(
        'execute_sql',
        params: {'query': query},
      );

      final results = (response as List).cast<Map<String, dynamic>>();
      return Success(results);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to execute SQL query in Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to execute query: $e'));
    }
  }

  /// Get database statistics
  Future<Result<Map<String, dynamic>>> getDatabaseStats() async {
    try {
      if (!_isInitialized) await initialize();

      final stats = <String, dynamic>{};

      // Get table counts (simplified)
      final salesCount = await _client.from('sales').select('id');
      final customersCount = await _client.from('customers').select('id');
      final inventoryCount = await _client.from('inventory').select('id');

      stats['sales_count'] = salesCount.length;
      stats['customers_count'] = customersCount.length;
      stats['inventory_count'] = inventoryCount.length;
      stats['last_updated'] = DateTime.now().toIso8601String();

      return Success(stats);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to get database stats from Supabase',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to get database stats: $e'));
    }
  }

  /// Close Supabase connection
  Future<void> close() async {
    try {
      await _client.dispose();
      _isInitialized = false;
      TalkerConfig.logInfo('Supabase service closed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to close Supabase service', e, stackTrace);
    }
  }
}
