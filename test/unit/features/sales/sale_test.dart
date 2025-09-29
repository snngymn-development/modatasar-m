import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';

void main() {
  group('Sale', () {
    test('should create sale with required parameters', () {
      // Arrange
      const id = 'S-001';
      const title = 'Test Sale';
      const total = 100.0;

      // Act
      const sale = Sale(id: id, title: title, total: total);

      // Assert
      expect(sale.id, equals(id));
      expect(sale.title, equals(title));
      expect(sale.total, equals(total));
    });

    test('should support equality comparison', () {
      // Arrange
      const sale1 = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);
      const sale2 = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);
      const sale3 = Sale(id: 'S-002', title: 'Test Sale', total: 100.0);

      // Act & Assert
      expect(sale1, equals(sale2));
      expect(sale1, isNot(equals(sale3)));
    });

    test('should support hashCode', () {
      // Arrange
      const sale1 = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);
      const sale2 = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);
      const sale3 = Sale(id: 'S-002', title: 'Test Sale', total: 100.0);

      // Act & Assert
      expect(sale1.hashCode, equals(sale2.hashCode));
      expect(sale1.hashCode, isNot(equals(sale3.hashCode)));
    });

    test('should support toString', () {
      // Arrange
      const sale = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);

      // Act
      final stringRepresentation = sale.toString();

      // Assert
      expect(stringRepresentation, contains('S-001'));
      expect(stringRepresentation, contains('Test Sale'));
      expect(stringRepresentation, contains('100.0'));
    });

    test('should be immutable', () {
      // Arrange
      const sale = Sale(id: 'S-001', title: 'Test Sale', total: 100.0);

      // Act & Assert
      expect(sale.id, isA<String>());
      expect(sale.title, isA<String>());
      expect(sale.total, isA<double>());

      // Verify that fields are final (immutable) - this will cause a compile error
      // if the fields are not final, which is what we want to test
      expect(sale.id, equals('S-001'));
      expect(sale.title, equals('Test Sale'));
      expect(sale.total, equals(100.0));
    });
  });
}
