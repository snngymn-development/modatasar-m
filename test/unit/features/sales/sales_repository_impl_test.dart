import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/core/network/result.dart';
import '../../../mocks/mock_dio.dart';

void main() {
  late MockDio mockDio;
  late SaleRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = SaleRepositoryImpl(dio: mockDio);
  });

  group('SaleRepositoryImpl', () {
    group('fetchSales', () {
      test('should return list of sales on success', () async {
        // Act - Repository uses mock data, no need to mock Dio
        final result = await repository.fetchSales();

        // Assert
        expect(result, isA<List<Sale>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('S-001'));
        expect(result[0].title, equals('Örnek Satış'));
        expect(result[0].total, equals(499.90));
        expect(result[1].id, equals('S-002'));
        expect(result[1].title, equals('İkinci Satış'));
        expect(result[1].total, equals(1299.00));
      });

      test(
        'should return mock data (no exceptions in current implementation)',
        () async {
          // Act - Repository uses mock data, so it always succeeds
          final result = await repository.fetchSales();

          // Assert
          expect(result, isA<List<Sale>>());
          expect(result.length, equals(2));
        },
      );
    });

    group('fetchSalesResult', () {
      test('should return Success result on success', () async {
        // Act - Repository uses mock data
        final result = await repository.fetchSalesResult();

        // Assert
        expect(result, isA<Success<List<Sale>>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);

        final successResult = result as Success<List<Sale>>;
        expect(successResult.data.length, equals(2));
        expect(successResult.data[0].id, equals('S-001'));
        expect(successResult.data[0].title, equals('Örnek Satış'));
        expect(successResult.data[0].total, equals(499.90));
        expect(successResult.data[1].id, equals('S-002'));
        expect(successResult.data[1].title, equals('İkinci Satış'));
        expect(successResult.data[1].total, equals(1299.00));
      });

      test('should return Success result (mock data implementation)', () async {
        // Act - Repository uses mock data, so it always succeeds
        final result = await repository.fetchSalesResult();

        // Assert
        expect(result, isA<Success<List<Sale>>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        final successResult = result as Success<List<Sale>>;
        expect(successResult.data.length, equals(2));
      });
    });

    group('data mapping', () {
      test('should correctly map mock data to Sale entities', () async {
        // Act
        final result = await repository.fetchSales();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('S-001'));
        expect(result[0].title, equals('Örnek Satış'));
        expect(result[0].total, equals(499.90));
        expect(result[1].id, equals('S-002'));
        expect(result[1].title, equals('İkinci Satış'));
        expect(result[1].total, equals(1299.00));
      });
    });
  });
}
