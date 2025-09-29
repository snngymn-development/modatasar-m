import '../entities/sale.dart';
import '../../../../core/network/result.dart';

/// Repository interface for sales data operations
///
/// Usage:
/// ```dart
/// final sales = await repository.fetchSales();
/// final result = await repository.fetchSalesResult();
/// result.when(
///   success: (sales) => print('${sales.length} sales loaded'),
///   error: (failure) => print('Error: ${failure.message}'),
/// );
/// ```
abstract class SaleRepository {
  /// Fetches all sales data
  /// Returns: List of Sale entities
  Future<List<Sale>> fetchSales();

  /// Fetches sales data with Result pattern for error handling
  /// Returns: Result with success/error states
  Future<Result<List<Sale>>> fetchSalesResult();
}
