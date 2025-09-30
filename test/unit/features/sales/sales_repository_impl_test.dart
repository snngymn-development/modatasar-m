import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/network/api_client.dart';
import 'package:deneme1/core/error/failure.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late SaleRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = SaleRepositoryImpl(apiClient: mockApiClient);
  });

  group('SaleRepositoryImpl', () {
    group('fetchSales', () {
      test('should return list of sales on success', () async {
        // Arrange
        // Mock sales data is not needed for this test
        when(
          () => mockApiClient.get<Map<String, dynamic>>('/sales'),
        ).thenAnswer(
          (_) async => Result.ok({
            'sales': [
              {
                'id': 'S-001',
                'title': 'Test Sale 1',
                'total': 100.0,
                'created_at': DateTime.now().toIso8601String(),
              },
              {
                'id': 'S-002',
                'title': 'Test Sale 2',
                'total': 200.0,
                'created_at': DateTime.now().toIso8601String(),
              },
            ],
          }),
        );

        // Act
        final result = await repository.fetchSales();

        // Assert
        expect(result, isA<List<Sale>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('S-001'));
        expect(result[0].title, equals('Test Sale 1'));
        expect(result[0].total, equals(100.0));
        expect(result[1].id, equals('S-002'));
        expect(result[1].title, equals('Test Sale 2'));
        expect(result[1].total, equals(200.0));
      });

      test('should return mock data on API error', () async {
        // Arrange
        when(
          () => mockApiClient.get<Map<String, dynamic>>('/sales'),
        ).thenAnswer((_) async => Result.err(Failure('Network error')));

        // Act
        final result = await repository.fetchSales();

        // Assert - Should return mock data instead of throwing
        expect(result, isA<List<Sale>>());
        expect(result.length, greaterThan(0));
        expect(result[0].id, equals('S-001'));
      });
    });

    group('fetchSalesResult', () {
      test('should return Success result on success', () async {
        // Arrange
        when(
          () => mockApiClient.get<Map<String, dynamic>>('/sales'),
        ).thenAnswer(
          (_) async => Result.ok({
            'sales': [
              {
                'id': 'S-001',
                'title': 'Test Sale 1',
                'total': 100.0,
                'created_at': DateTime.now().toIso8601String(),
              },
              {
                'id': 'S-002',
                'title': 'Test Sale 2',
                'total': 200.0,
                'created_at': DateTime.now().toIso8601String(),
              },
            ],
          }),
        );

        // Act
        final result = await repository.fetchSalesResult();

        // Assert
        expect(result, isA<Success<List<Sale>>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);

        final successResult = result as Success<List<Sale>>;
        expect(successResult.data.length, equals(2));
        expect(successResult.data[0].id, equals('S-001'));
        expect(successResult.data[0].title, equals('Test Sale 1'));
        expect(successResult.data[0].total, equals(100.0));
        expect(successResult.data[1].id, equals('S-002'));
        expect(successResult.data[1].title, equals('Test Sale 2'));
        expect(successResult.data[1].total, equals(200.0));
      });

      test('should return Success with mock data on API error', () async {
        // Arrange
        when(
          () => mockApiClient.get<Map<String, dynamic>>('/sales'),
        ).thenAnswer((_) async => Result.err(Failure('Network error')));

        // Act
        final result = await repository.fetchSalesResult();

        // Assert - Should return Success with mock data instead of Error
        expect(result, isA<Success<List<Sale>>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);

        final successResult = result as Success<List<Sale>>;
        expect(successResult.data.length, greaterThan(0));
        expect(successResult.data[0].id, equals('S-001'));
      });
    });
  });
}
