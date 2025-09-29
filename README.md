# Flutter Production-Ready Template

Bu proje, production-ready Flutter uygulamaları için kapsamlı bir template'tir. Clean Architecture, modern state management, ve best practice'ler ile geliştirilmiştir.

## 🚀 Özellikler

### Mimari
- **Clean Architecture** (Domain → Data → Presentation)
- **Feature-First** klasör yapısı
- **Riverpod** state management
- **GoRouter** navigation
- **Result/Failure** pattern ile hata yönetimi

### Geliştirme Araçları
- **Freezed** + **JSON Serialization** code generation
- **Talker** comprehensive logging
- **Dio** HTTP client with interceptors
- **Material 3** design system
- **i18n** support (TR/EN)

### Kalite Kontrolü
- **Pre-commit hooks** (format + analyze + test)
- **GitHub Actions** CI/CD
- **Unit & Widget tests** with mocktail
- **OpenAPI** contract-first development

## 📁 Proje Yapısı

```
lib/
├── core/                    # Core utilities
│   ├── config/             # App configuration
│   ├── di/                 # Dependency injection
│   ├── enums/              # Centralized enums
│   ├── error/              # Error handling
│   ├── logging/            # Logging system
│   ├── network/            # Network layer
│   ├── routing/            # Navigation
│   ├── theme/              # Material 3 theming
│   └── utils/              # Utilities
├── features/               # Feature modules
│   └── sales/              # Example feature
│       ├── data/           # Data layer
│       ├── domain/         # Domain layer
│       └── presentation/   # UI layer
└── generated/              # Generated code
    └── api/                # OpenAPI generated client
```

## 🛠️ Kurulum

### Gereksinimler
- Flutter 3.24.0+
- Dart 3.5.0+
- Node.js (OpenAPI generation için)

### Adımlar

1. **Repository'yi klonlayın**
   ```bash
   git clone <repository-url>
   cd deneme1
   ```

2. **Dependencies'leri yükleyin**
   ```bash
   flutter pub get
   ```

3. **Code generation çalıştırın**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 🧪 Test

### Tüm testleri çalıştır
```bash
flutter test
```

### Coverage ile test
```bash
flutter test --coverage
```

### Belirli test dosyası
```bash
flutter test test/unit/core/network/result_test.dart
```

## 🔧 Geliştirme

### Yeni Feature Oluşturma
```bash
# Cursor'da şu komutu kullanın:
create feature inventory
```

### API Client Oluşturma
```bash
# OpenAPI specification'dan client oluştur
generate api
```

### Code Formatting
```bash
dart format .
```

### Code Analysis
```bash
flutter analyze
```

## 📚 Kullanım Örnekleri

### Result Pattern ile Hata Yönetimi
```dart
final result = await repository.fetchData();
result.when(
  success: (data) => print('Success: $data'),
  error: (failure) => print('Error: ${failure.message}'),
);
```

### Validation
```dart
final validator = Validators.combine([
  (v) => Validators.requiredField(v),
  (v) => Validators.email(v),
]);
final error = validator('test@example.com');
```

### Logging
```dart
TalkerConfig.logBusiness('User action performed');
TalkerConfig.logNetwork('API call started');
TalkerConfig.logError('Something went wrong', error, stackTrace);
```

## 🚀 CI/CD

### Pre-commit Hook
Her commit öncesi otomatik olarak:
- Code formatting
- Static analysis
- Test execution

### GitHub Actions
Her PR'da otomatik olarak:
- Format verification
- Analysis
- Test execution
- Build verification

## 📖 API Development

### OpenAPI Specification
API contract'ı `api/openapi.yaml` dosyasında tanımlanır.

### Client Generation
```bash
dart run scripts/generate_api.dart
```

## 🎨 Theming

Material 3 design system kullanılır. Tema ayarları `lib/core/theme/app_theme.dart` dosyasında bulunur.

## 🌍 Internationalization

Türkçe ve İngilizce dil desteği mevcuttur. Yeni diller eklemek için:

1. `lib/app.dart` dosyasında `supportedLocales` listesine ekleyin
2. ARB dosyalarını oluşturun
3. `flutter gen-l10n` komutunu çalıştırın

## 📝 Altın Kurallar

1. **UI sadece UseCase + Entity görür** - DTO import'u yok
2. **Material 3 + ColorScheme** - Deprecated API yok
3. **Overflow-safe** - Expanded/Flexible, ellipsis kullan
4. **Null-safety & immutability** - `!` kaçın, `?` `??` `??=` kullan
5. **Enum'lar tek merkez** - `core/enums`, tek extension, exhaustive switch
6. **Hata akışı** - `Result.ok` / `Result.err(Failure)`
7. **Her public API için usage snippet** - Cursor için örnekli dokümantasyon

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [GoRouter](https://pub.dev/packages/go_router) - Navigation
- [Talker](https://pub.dev/packages/talker) - Logging
- [Freezed](https://pub.dev/packages/freezed) - Code generation