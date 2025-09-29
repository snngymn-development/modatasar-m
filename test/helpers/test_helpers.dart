import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:deneme1/core/auth/auth_service.dart';
import 'package:deneme1/core/analytics/analytics.dart';

/// Test helpers for common test setup
class TestHelpers {
  /// Create a test widget with providers
  static Widget createTestWidget({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );
  }

  /// Create a test widget with routing
  static Widget createTestWidgetWithRouting({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );
  }

  /// Pump and settle with timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Create mock Dio
  static MockDio createMockDio() {
    return MockDio();
  }

  /// Setup mock Dio responses
  static void setupMockDioResponses(MockDio mockDio) {
    // Setup common mock responses
    when(() => mockDio.get(any())).thenAnswer(
      (_) async => Response(
        data: {'success': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/'),
      ),
    );

    when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        data: {'success': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/'),
      ),
    );

    when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        data: {'success': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/'),
      ),
    );

    when(() => mockDio.delete(any())).thenAnswer(
      (_) async => Response(
        data: {'success': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/'),
      ),
    );
  }

  /// Create test data
  static Map<String, dynamic> createTestUser() {
    return {
      'id': 'test-user-1',
      'email': 'test@example.com',
      'name': 'Test User',
    };
  }

  static Map<String, dynamic> createTestSale() {
    return {'id': 'S-001', 'title': 'Test Sale', 'total': 100.0};
  }

  /// Wait for async operations
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Find widget by type and text
  static Finder findByTypeAndText<T extends Widget>(String text) {
    return find.byWidgetPredicate(
      (widget) => widget is T && widget.toString().contains(text),
    );
  }

  /// Verify widget is visible
  static void verifyWidgetVisible(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify widget is not visible
  static void verifyWidgetNotVisible(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verify text is displayed
  static void verifyTextDisplayed(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify text is not displayed
  static void verifyTextNotDisplayed(String text) {
    expect(find.text(text), findsNothing);
  }
}

/// Mock classes for testing
class MockDio extends Mock implements Dio {}

class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements Analytics {}

/// Test data factories
class TestDataFactory {
  static List<Map<String, dynamic>> createSalesList(int count) {
    return List.generate(
      count,
      (index) => {
        'id': 'S-${(index + 1).toString().padLeft(3, '0')}',
        'title': 'Test Sale ${index + 1}',
        'total': (index + 1) * 100.0,
      },
    );
  }

  static Map<String, dynamic> createApiResponse({
    required String message,
    dynamic data,
    int statusCode = 200,
  }) {
    return {
      'message': message,
      'data': data,
      'status_code': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> createErrorResponse({
    required String message,
    String? code,
    int statusCode = 400,
  }) {
    return {
      'error': {'message': message, 'code': code, 'status_code': statusCode},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
