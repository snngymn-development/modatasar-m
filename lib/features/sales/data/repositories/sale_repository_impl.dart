import 'package:dio/dio.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../../core/logging/talker_config.dart';
import '../../../../core/network/result.dart';
import '../../../../core/error/failure.dart' as core;

class SaleRepositoryImpl implements SaleRepository {
  final Dio _dio;

  SaleRepositoryImpl({required Dio dio}) : _dio = dio;

  // Getter for testing purposes
  Dio get dio => _dio;

  @override
  Future<List<Sale>> fetchSales() async {
    try {
      TalkerConfig.logNetwork('Fetching sales data...');

      // Simulate API call with mock data for now
      // In real implementation, this would be:
      // final response = await _dio.get('/sales');
      // return (response.data as List).map((json) => Sale.fromJson(json)).toList();

      // No delay in test environment to avoid timer issues
      // await Future<void>.delayed(const Duration(milliseconds: 50));

      const sales = [
        Sale(id: 'S-001', title: 'Örnek Satış', total: 499.90),
        Sale(id: 'S-002', title: 'İkinci Satış', total: 1299.00),
      ];

      TalkerConfig.logNetwork('Successfully fetched ${sales.length} sales');
      return sales;
    } catch (error, stackTrace) {
      TalkerConfig.logError('Failed to fetch sales data', error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Result<List<Sale>>> fetchSalesResult() async {
    try {
      TalkerConfig.logNetwork('Fetching sales data with Result pattern...');

      // Simulate real API call
      // final res = await _dio.get('/sales');
      // final list = (res.data as List)
      //     .map((e) => Sale(
      //           id: e['id'] as String,
      //           title: e['title'] as String,
      //           total: (e['total'] as num).toDouble(),
      //         ))
      //     .toList();
      // return Result.ok(list);

      // Mock data for now
      // No delay in test environment to avoid timer issues
      // await Future<void>.delayed(const Duration(milliseconds: 50));

      const sales = [
        Sale(id: 'S-001', title: 'Örnek Satış', total: 499.90),
        Sale(id: 'S-002', title: 'İkinci Satış', total: 1299.00),
      ];

      TalkerConfig.logNetwork('Successfully fetched ${sales.length} sales');
      return Result.ok(sales);
    } on DioException catch (e, s) {
      TalkerConfig.logError('Dio error in fetchSalesResult', e, s);
      return Result.err(
        core.Failure(
          e.message ?? 'Network error',
          code: '${e.response?.statusCode}',
          stack: s,
          originalError: e,
        ),
      );
    } catch (e, s) {
      TalkerConfig.logError('Unexpected error in fetchSalesResult', e, s);
      return Result.err(core.Failure(e.toString(), stack: s, originalError: e));
    }
  }
}
