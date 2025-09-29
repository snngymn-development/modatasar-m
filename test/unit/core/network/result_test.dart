import 'package:flutter_test/flutter_test.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success result with data', () {
        // Arrange
        const testData = 'test data';

        // Act
        final result = Result.ok(testData);

        // Assert
        expect(result, isA<Success<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect((result as Success<String>).data, equals(testData));
      });

      test('should return data with dataOrNull', () {
        // Arrange
        const testData = 'test data';
        final result = Result.ok(testData);

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, equals(testData));
      });

      test('should return data with getOrElse', () {
        // Arrange
        const testData = 'test data';
        const defaultValue = 'default';
        final result = Result.ok(testData);

        // Act
        final data = result.getOrElse(defaultValue);

        // Assert
        expect(data, equals(testData));
      });
    });

    group('Error', () {
      test('should create error result with failure', () {
        // Arrange
        final failure = Failure('test error');

        // Act
        final result = Result.err(failure);

        // Assert
        expect(result, isA<Error<dynamic>>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect((result as Error<dynamic>).failure, equals(failure));
      });

      test('should return null with dataOrNull', () {
        // Arrange
        final failure = Failure('test error');
        final result = Result.err(failure);

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, isNull);
      });

      test('should return default value with getOrElse', () {
        // Arrange
        final failure = Failure('test error');
        const defaultValue = 'default';
        final result = Result.err(failure);

        // Act
        final data = result.getOrElse(defaultValue);

        // Assert
        expect(data, equals(defaultValue));
      });
    });

    group('when method', () {
      test('should call success callback for Success', () {
        // Arrange
        const testData = 'test data';
        final result = Result.ok(testData);
        String? successData;
        String? errorMessage;

        // Act
        result.when(
          success: (data) => successData = data,
          error: (failure) => errorMessage = failure.message,
        );

        // Assert
        expect(successData, equals(testData));
        expect(errorMessage, isNull);
      });

      test('should call error callback for Error', () {
        // Arrange
        final failure = Failure('test error');
        final result = Result.err(failure);
        String? successData;
        String? errorMessage;

        // Act
        result.when(
          success: (data) => successData = data,
          error: (failure) => errorMessage = failure.message,
        );

        // Assert
        expect(successData, isNull);
        expect(errorMessage, equals('test error'));
      });
    });

    group('map method', () {
      test('should map success data', () {
        // Arrange
        const testData = 'test';
        final result = Result.ok(testData);

        // Act
        final mappedResult = result.map((data) => data.toUpperCase());

        // Assert
        expect(mappedResult, isA<Success<String>>());
        expect((mappedResult as Success<String>).data, equals('TEST'));
      });

      test('should preserve error in map', () {
        // Arrange
        final failure = Failure('test error');
        final result = Result.err(failure);

        // Act
        final mappedResult = result.map((data) => data.toUpperCase());

        // Assert
        expect(mappedResult, isA<Error<dynamic>>());
        expect((mappedResult as Error<dynamic>).failure, equals(failure));
      });
    });
  });
}
