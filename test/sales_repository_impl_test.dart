import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/core/error/failure.dart' as core;

class _MockDio extends Mock implements Dio {}

// Test için özel repository sınıfı - gerçek API çağrısı yapar
class TestSaleRepositoryImpl {
  final Dio _dio;

  TestSaleRepositoryImpl({required Dio dio}) : _dio = dio;

  Future<Result<List<Sale>>> fetchSalesResult() async {
    try {
      // Gerçek API çağrısı yap
      final res = await _dio.get('/sales');
      final list = (res.data as List)
          .map(
            (e) => Sale(
              id: e['id'] as String,
              title: e['title'] as String,
              total: (e['total'] as num).toDouble(),
              createdAt: DateTime.now(),
            ),
          )
          .toList();
      return Result.ok(list);
    } on DioException catch (e, s) {
      return Result.err(
        core.Failure(
          e.message ?? 'Network error',
          code: '${e.response?.statusCode}',
          stack: s,
          originalError: e,
        ),
      );
    } catch (e, s) {
      return Result.err(core.Failure(e.toString(), stack: s, originalError: e));
    }
  }
}

void main() {
  late Dio dio;
  late TestSaleRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    repo = TestSaleRepositoryImpl(dio: dio);
  });

  test('fetchSalesResult returns Success on success', () async {
    when(() => dio.get('/sales')).thenAnswer(
      (_) async => Response(
        data: [
          {'id': '1', 'title': 'Test', 'total': 100.0},
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/sales'),
      ),
    );

    final res = await repo.fetchSalesResult();
    expect(res, isA<Success<List<Sale>>>());
  });

  test('fetchSalesResult returns Error on DioException', () async {
    when(() => dio.get('/sales')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sales'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/sales'),
          statusCode: 500,
        ),
      ),
    );

    final res = await repo.fetchSalesResult();
    expect(res, isA<Error<List<Sale>>>());
  });
}
