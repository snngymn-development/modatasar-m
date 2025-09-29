import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/sales/presentation/sales_page.dart';

void main() {
  group('SalesPage Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SalesPage())),
      );

      // Wait for async operations to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Just check that the widget renders without crashing
      expect(find.byType(SalesPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display app bar with title', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SalesPage())),
      );

      // Wait for async operations to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('POS Kasa Sistemi'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SalesPage())),
      );

      // Wait for async operations to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });

    testWidgets('should display POS module cards', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SalesPage())),
      );

      // Wait for async operations to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Check for main elements
      expect(find.text('Hoş Geldiniz!'), findsOneWidget);
      expect(
        find.text(
          'POS Kasa Sistemine başlamak için aşağıdaki modülleri kullanın',
        ),
        findsOneWidget,
      );
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
