import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../../core/logging/talker_config.dart';
import '../../../../core/network/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/backend/backend_service.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  final ApiClient _apiClient;
  final BackendService _backendService;

  SaleRepositoryImpl({
    required ApiClient apiClient,
    BackendService? backendService,
  }) : _apiClient = apiClient,
       _backendService = backendService ?? BackendService();

  @override
  Future<List<Sale>> fetchSales() async {
    try {
      TalkerConfig.logNetwork('Fetching sales data...');

      // Try real backend service first
      final backendResult = await _backendService.getSales();

      if (backendResult.isSuccess) {
        final salesData = backendResult.data;
        final sales = salesData
            .map((json) => SaleModel.fromJson(json))
            .map((model) => model.toEntity())
            .toList();

        TalkerConfig.logNetwork(
          'Successfully fetched ${sales.length} sales from backend',
        );
        return sales;
      } else {
        TalkerConfig.logError(
          'Backend service failed, trying API client',
          backendResult.error,
        );

        // Fallback to API client
        final result = await _apiClient.get<Map<String, dynamic>>(
          ApiConfig.salesEndpoint,
        );

        if (result.isSuccess) {
          final response = result.data;
          final List<dynamic> data =
              response['sales'] ?? response['data'] ?? [];
          final sales = data
              .map((json) => SaleModel.fromJson(json).toEntity())
              .toList();

          TalkerConfig.logNetwork(
            'Successfully fetched ${sales.length} sales from API client',
          );
          return sales;
        } else {
          TalkerConfig.logError(
            'API client also failed, using mock data',
            result.error,
          );
          return _getMockSales();
        }
      }
    } catch (error, stackTrace) {
      TalkerConfig.logError(
        'Failed to fetch sales data, using mock data',
        error,
        stackTrace,
      );
      return _getMockSales();
    }
  }

  @override
  Future<Result<List<Sale>>> fetchSalesResult() async {
    try {
      TalkerConfig.logNetwork('Fetching sales data with Result pattern...');

      final result = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.salesEndpoint,
      );

      if (result.isSuccess) {
        final response = result.data;
        final List<dynamic> data = response['sales'] ?? response['data'] ?? [];
        final sales = data
            .map((json) => SaleModel.fromJson(json).toEntity())
            .toList();

        TalkerConfig.logNetwork('Successfully fetched ${sales.length} sales');
        return Result.ok(sales);
      } else {
        TalkerConfig.logError(
          'API error in fetchSalesResult, using mock data',
          result.error,
        );
        return Result.ok(_getMockSales());
      }
    } catch (error, stackTrace) {
      TalkerConfig.logError(
        'Unexpected error in fetchSalesResult, using mock data',
        error,
        stackTrace,
      );
      return Result.ok(_getMockSales());
    }
  }

  // Mock data fallback
  List<Sale> _getMockSales() {
    return [
      Sale(
        id: 'S-001',
        title: 'Örnek Satış 1',
        total: 499.90,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Sale(
        id: 'S-002',
        title: 'Örnek Satış 2',
        total: 1299.00,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Sale(
        id: 'S-003',
        title: 'Örnek Satış 3',
        total: 799.50,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}
