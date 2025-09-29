import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/core/utils/validators.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';

void main() {
  group('Basic Tests', () {
    test('Sale entity should work correctly', () {
      const sale = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);
      expect(sale.id, 'S-001');
      expect(sale.title, 'Test Sale');
      expect(sale.total, 100.0);
    });

    test('Validators should work correctly', () {
      expect(Validators.requiredField('test'), isNull);
      expect(Validators.requiredField(''), 'Bu alan zorunludur');
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('invalid'), 'Geçerli bir email adresi giriniz');
    });

    test('Result pattern should work correctly', () {
      final success = Result.ok('test data');
      final error = Result.err(Failure('test error'));

      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(error.isSuccess, isFalse);
      expect(error.isFailure, isTrue);
    });
  });
}
