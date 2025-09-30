import 'package:mocktail/mocktail.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/features/sales/domain/repositories/sale_repository.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart' as core;

class MockSaleRepository extends Mock implements SaleRepository {}

// Mock data for tests
class MockSaleData {
  static List<Sale> get mockSales => [
    Sale(
      id: 'S-001',
      title: 'Örnek Satış',
      total: 499.90,
      createdAt: DateTime.now(),
    ),
    Sale(
      id: 'S-002',
      title: 'İkinci Satış',
      total: 1299.00,
      createdAt: DateTime.now(),
    ),
  ];

  static Result<List<Sale>> get mockSuccessResult => Result.ok(mockSales);

  static Result<List<Sale>> get mockErrorResult => Result.err(
    core.Failure(
      'Test error message',
      code: 'TEST_ERROR',
      stack: StackTrace.current,
      originalError: Exception('Test exception'),
    ),
  );
}
