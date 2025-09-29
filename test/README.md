# Test Documentation

Bu klasör Flutter uygulaması için test dosyalarını içerir.

## Klasör Yapısı

```
test/
├── unit/                    # Unit testler
│   ├── core/               # Core modül testleri
│   │   ├── network/        # Network katmanı testleri
│   │   └── utils/          # Utility sınıfları testleri
│   └── features/           # Feature testleri
│       └── sales/          # Sales feature testleri
├── widget/                 # Widget testleri
│   └── features/           # Feature widget testleri
│       └── sales/          # Sales widget testleri
├── mocks/                  # Mock objeler
├── test_helpers.dart       # Test yardımcı fonksiyonları
├── run_tests.dart          # Test runner
└── README.md              # Bu dosya
```

## Test Türleri

### Unit Tests
- **Amaç**: Tekil sınıfların ve fonksiyonların test edilmesi
- **Konum**: `test/unit/`
- **Örnekler**: Result pattern, Validators, Sale entity

### Widget Tests
- **Amaç**: UI bileşenlerinin test edilmesi
- **Konum**: `test/widget/`
- **Örnekler**: SalesPage, form widgetları

### Integration Tests
- **Amaç**: Tüm sistemin birlikte test edilmesi
- **Konum**: `test/integration/`
- **Örnekler**: API entegrasyonu, navigation flow

## Test Çalıştırma

### Tüm Testleri Çalıştır
```bash
flutter test
```

### Sadece Unit Testleri Çalıştır
```bash
flutter test test/unit/
```

### Sadece Widget Testleri Çalıştır
```bash
flutter test test/widget/
```

### Belirli Bir Test Dosyasını Çalıştır
```bash
flutter test test/unit/core/network/result_test.dart
```

### Coverage ile Test Çalıştır
```bash
flutter test --coverage
```

## Mock Objeler

### MockDio
```dart
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}
```

### MockSaleRepository
```dart
import 'package:mocktail/mocktail.dart';
import '../../lib/features/sales/domain/repositories/sale_repository.dart';

class MockSaleRepository extends Mock implements SaleRepository {}
```

## Test Helper'ları

### TestWidgetHelper
```dart
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}
```

### WidgetTesterExtensions
```dart
await tester.pumpAndSettleWidget(widget);
tester.expectWidget<CircularProgressIndicator>();
tester.expectText('Loading...');
```

## Test Best Practices

### 1. Test İsimlendirme
```dart
test('should return null for valid email', () {
  // Test implementation
});
```

### 2. Arrange-Act-Assert Pattern
```dart
test('should create success result with data', () {
  // Arrange
  const testData = 'test data';
  
  // Act
  final result = Result.ok(testData);
  
  // Assert
  expect(result, isA<Success<String>>());
});
```

### 3. Mock Kullanımı
```dart
setUp(() {
  mockRepository = MockSaleRepository();
  when(() => mockRepository.fetchSales())
    .thenAnswer((_) async => mockSales);
});
```

### 4. Widget Test Setup
```dart
testWidgets('should display loading indicator', (tester) async {
  await tester.pumpWidget(createTestWidget());
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Coverage Hedefleri

- **Unit Tests**: %90+ coverage
- **Widget Tests**: %80+ coverage
- **Integration Tests**: %70+ coverage

## Test Verileri

### MockSaleData
```dart
class MockSaleData {
  static const List<Sale> mockSales = [
    Sale(id: 'S-001', title: 'Test Satış 1', total: 100.0),
    Sale(id: 'S-002', title: 'Test Satış 2', total: 200.0),
  ];
}
```

### TestDataHelper
```dart
class TestDataHelper {
  static const List<Map<String, dynamic>> mockSalesJson = [
    {'id': 'S-001', 'title': 'Test Satış 1', 'total': 100.0},
  ];
}
```

## Troubleshooting

### Mock Registration Hatası
```dart
setUpAll(() {
  MockRegistration.registerFallbackValues();
});
```

### Provider Override Hatası
```dart
ProviderScope(
  overrides: [
    dioProvider.overrideWithValue(mockDio),
  ],
  child: widget,
)
```

### Widget Test Timeout
```dart
await tester.pumpAndSettle(const Duration(seconds: 5));
```
