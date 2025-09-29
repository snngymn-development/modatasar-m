# Flutter POS Kasa Sistemi - Şablon Proje

Bu proje, Flutter ile geliştirilmiş modern bir POS (Point of Sale) kasa sistemi şablonudur.

## 🚀 Özellikler

- ✅ **Clean Architecture** + **Feature-first** yapı
- ✅ **Riverpod** state management
- ✅ **GoRouter** navigation
- ✅ **Freezed** + **JsonSerializable** code generation
- ✅ **Drift** offline-first database
- ✅ **Sentry** error reporting
- ✅ **Talker** logging
- ✅ **Material 3** design
- ✅ **Responsive** design
- ✅ **CI/CD** ready (GitHub Actions)
- ✅ **Comprehensive testing** (Unit + Widget + Integration)

## 📁 Proje Yapısı

```
lib/
├── core/                    # Temel altyapı
│   ├── auth/               # Kimlik doğrulama
│   ├── analytics/          # Analitik servisleri
│   ├── config/             # Konfigürasyon
│   ├── data/               # Veri katmanı
│   ├── di/                 # Dependency injection
│   ├── error/              # Hata yönetimi
│   ├── logging/            # Loglama
│   ├── network/            # Ağ katmanı
│   ├── routing/            # Routing
│   ├── theme/              # Tema
│   └── utils/              # Yardımcı fonksiyonlar
├── features/               # Özellik modülleri
│   ├── sales/              # Satış modülü
│   └── inventory/          # Envanter modülü
└── main.dart               # Uygulama giriş noktası
```

## 🛠️ Kurulum

### 1. Projeyi Klonla
```bash
git clone <repo-url>
cd deneme1
```

### 2. Bağımlılıkları Yükle
```bash
flutter pub get
```

### 3. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Testleri Çalıştır
```bash
flutter test
```

### 5. Uygulamayı Başlat
```bash
# Web için
flutter run -d chrome --dart-define=API_BASE=https://api.example.com --dart-define=SENTRY_DSN=

# Android için
flutter run -d android --dart-define=API_BASE=https://api.example.com --dart-define=SENTRY_DSN=

# iOS için
flutter run -d ios --dart-define=API_BASE=https://api.example.com --dart-define=SENTRY_DSN=
```

## 🎯 Yeni Feature Ekleme

### Cursor Komutları ile Hızlı Başlangıç

```bash
# 1. Ürünler modülü
create feature products

# 2. Müşteriler modülü
create feature customers

# 3. Sepet modülü
create feature cart

# 4. Satışlar modülü (mevcut)
create feature sales

# 5. Ödemeler modülü
create feature payments

# 6. Envanter modülü (mevcut)
create feature inventory
```

### Manuel Feature Ekleme

1. `lib/features/<feature_name>/` klasörü oluştur
2. Alt klasörleri oluştur:
   - `data/` - Veri katmanı
   - `domain/` - İş mantığı
   - `presentation/` - UI katmanı
3. Gerekli dosyaları oluştur (entity, repository, usecase, page, vb.)
4. Routing'e ekle
5. Testleri yaz

## 🔧 Konfigürasyon

### Environment Variables

```bash
# API Base URL
--dart-define=API_BASE=https://api.example.com

# Sentry DSN
--dart-define=SENTRY_DSN=your_sentry_dsn

# Feature Flags
--dart-define=FEATURE_FLAGS_ENABLED=true
```

### Feature Flags

`assets/config/feature_flags.json` dosyasından yönetilir:

```json
{
  "new_ui": false,
  "dark_mode": true,
  "analytics_enabled": true,
  "crash_reporting": true,
  "offline_mode": false,
  "beta_features": false,
  "push_notifications": true,
  "deep_linking": true,
  "biometric_auth": false,
  "social_login": false
}
```

## 🧪 Test Stratejisi

### Test Türleri

1. **Unit Tests** - İş mantığı testleri
2. **Widget Tests** - UI bileşen testleri
3. **Integration Tests** - End-to-end testler

### Test Çalıştırma

```bash
# Tüm testler
flutter test

# Sadece unit testler
flutter test test/unit/

# Sadece widget testler
flutter test test/widget/

# Sadece integration testler
flutter test test/integration/

# Coverage ile
flutter test --coverage
```

## 🚀 CI/CD

GitHub Actions ile otomatik:

- Code formatting
- Linting
- Testing
- Building (Web, Windows, Android, iOS)
- Coverage reporting

## 📱 Platform Desteği

- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🔒 Güvenlik

- Bearer token authentication
- Secure token storage
- Auto-refresh token flow
- PII-free logging
- Environment-based secrets

## 📊 Monitoring

- **Sentry** - Error tracking
- **Talker** - Development logging
- **Analytics** - User behavior tracking
- **Performance** - App performance monitoring

## 🤝 Katkıda Bulunma

1. Fork yap
2. Feature branch oluştur (`git checkout -b feature/amazing-feature`)
3. Commit yap (`git commit -m 'Add amazing feature'`)
4. Push yap (`git push origin feature/amazing-feature`)
5. Pull Request oluştur

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🆘 Destek

Sorunlar için GitHub Issues kullanın veya dokümantasyonu kontrol edin.

---

**Not**: Bu şablon, production-ready bir Flutter uygulaması için gerekli tüm altyapıyı içerir. Yeni projelerde bu şablonu kullanarak hızlıca başlayabilirsiniz.
