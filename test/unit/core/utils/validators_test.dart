import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('requiredField', () {
      test('should return null for valid non-empty string', () {
        // Arrange
        const input = 'valid input';

        // Act
        final result = Validators.requiredField(input);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for null input', () {
        // Arrange
        const String? input = null;

        // Act
        final result = Validators.requiredField(input);

        // Assert
        expect(result, equals('Bu alan zorunludur'));
      });

      test('should return error message for empty string', () {
        // Arrange
        const input = '';

        // Act
        final result = Validators.requiredField(input);

        // Assert
        expect(result, equals('Bu alan zorunludur'));
      });

      test('should return error message for whitespace only string', () {
        // Arrange
        const input = '   ';

        // Act
        final result = Validators.requiredField(input);

        // Assert
        expect(result, equals('Bu alan zorunludur'));
      });

      test('should return custom error message', () {
        // Arrange
        const input = '';
        const customMessage = 'Custom error message';

        // Act
        final result = Validators.requiredField(input, message: customMessage);

        // Assert
        expect(result, equals(customMessage));
      });
    });

    group('minLen', () {
      test('should return null for string with sufficient length', () {
        // Arrange
        const input = 'hello';
        const minLength = 3;

        // Act
        final result = Validators.minLen(input, minLength);

        // Assert
        expect(result, isNull);
      });

      test(
        'should return error message for string with insufficient length',
        () {
          // Arrange
          const input = 'hi';
          const minLength = 3;

          // Act
          final result = Validators.minLen(input, minLength);

          // Assert
          expect(result, equals('Yetersiz uzunluk'));
        },
      );

      test('should return custom error message', () {
        // Arrange
        const input = 'hi';
        const minLength = 3;
        const customMessage = 'Custom min length error';

        // Act
        final result = Validators.minLen(
          input,
          minLength,
          message: customMessage,
        );

        // Assert
        expect(result, equals(customMessage));
      });
    });

    group('maxLen', () {
      test('should return null for string within max length', () {
        // Arrange
        const input = 'hello';
        const maxLength = 10;

        // Act
        final result = Validators.maxLen(input, maxLength);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for string exceeding max length', () {
        // Arrange
        const input = 'hello world';
        const maxLength = 5;

        // Act
        final result = Validators.maxLen(input, maxLength);

        // Assert
        expect(result, equals('Maksimum uzunluk aşıldı'));
      });
    });

    group('email', () {
      test('should return null for valid email', () {
        // Arrange
        const input = 'test@example.com';

        // Act
        final result = Validators.email(input);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for invalid email', () {
        // Arrange
        const input = 'invalid-email';

        // Act
        final result = Validators.email(input);

        // Assert
        expect(result, equals('Geçerli bir email adresi giriniz'));
      });

      test('should return null for null input', () {
        // Arrange
        const String? input = null;

        // Act
        final result = Validators.email(input);

        // Assert
        expect(result, isNull);
      });
    });

    group('phone', () {
      test('should return null for valid phone number', () {
        // Arrange
        const input = '5551234567';

        // Act
        final result = Validators.phone(input);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for invalid phone number', () {
        // Arrange
        const input = '123';

        // Act
        final result = Validators.phone(input);

        // Assert
        expect(result, equals('Geçerli bir telefon numarası giriniz'));
      });
    });

    group('numeric', () {
      test('should return null for valid numeric string', () {
        // Arrange
        const input = '123';

        // Act
        final result = Validators.numeric(input);

        // Assert
        expect(result, isNull);
      });

      test('should return error message for non-numeric string', () {
        // Arrange
        const input = 'abc123';

        // Act
        final result = Validators.numeric(input);

        // Assert
        expect(result, equals('Sadece sayısal değer giriniz'));
      });
    });

    group('combine', () {
      test('should return null when all validators pass', () {
        // Arrange
        const input = 'test@example.com';

        // Act
        final result = Validators.combine([
          (String? v) => Validators.requiredField(v),
          (String? v) => Validators.email(v),
        ])(input);

        // Assert
        expect(result, isNull);
      });

      test('should return first error when any validator fails', () {
        // Arrange
        const input = 'invalid-email';

        // Act
        final result = Validators.combine([
          (String? v) => Validators.requiredField(v),
          (String? v) => Validators.email(v),
        ])(input);

        // Assert
        expect(result, equals('Geçerli bir email adresi giriniz'));
      });

      test('should return null for null input when not required', () {
        // Arrange
        const String? input = null;

        // Act
        final result = Validators.combine([
          (String? v) => Validators.email(v), // Not required
        ])(input);

        // Assert
        expect(result, isNull);
      });
    });
  });
}
