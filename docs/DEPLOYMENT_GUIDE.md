# Deployment Kılavuzu

Flutter POS Kasa Sistemi'nin production ortamına deploy edilmesi için detaylı kılavuz.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Ön Gereksinimler](#ön-gereksinimler)
- [Environment Setup](#environment-setup)
- [Build Process](#build-process)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## 🔍 Genel Bakış

Bu kılavuz, Flutter POS Kasa Sistemi'ni production ortamına deploy etmek için gerekli adımları içerir.

### Desteklenen Platformlar
- **Android**: APK ve AAB formatları
- **iOS**: IPA formatı
- **Web**: PWA (Progressive Web App)
- **Windows**: MSI ve EXE formatları
- **macOS**: DMG formatı
- **Linux**: AppImage ve DEB formatları

## 🛠️ Ön Gereksinimler

### Geliştirme Ortamı
- **Flutter SDK**: 3.24.0+
- **Dart SDK**: 3.5.0+
- **Android Studio**: 2023.1+
- **Xcode**: 15.0+ (iOS için)
- **Visual Studio**: 2022+ (Windows için)
- **VS Code**: 1.80+ (opsiyonel)

### Sistem Gereksinimleri
- **RAM**: 8GB minimum, 16GB önerilen
- **Disk**: 50GB boş alan
- **İşlemci**: Intel i5 veya AMD Ryzen 5
- **İşletim Sistemi**: Windows 10+, macOS 12+, Ubuntu 20.04+

### Gerekli Araçlar
```bash
# Flutter SDK
flutter --version

# Android SDK
flutter doctor --android-licenses

# Xcode (macOS)
xcode-select --install

# Git
git --version

# Docker (opsiyonel)
docker --version
```

## ⚙️ Environment Setup

### 1. Repository Klonlama
```bash
git clone https://github.com/your-org/pos-kasa-system.git
cd pos-kasa-system
```

### 2. Dependencies Yükleme
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Environment Variables
`.env` dosyası oluşturun:
```env
# API Configuration
API_BASE_URL=https://api.pos-kasa.com/v1
API_TIMEOUT=30000

# Sentry Configuration
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id

# Firebase Configuration
FIREBASE_PROJECT_ID=pos-kasa-prod
FIREBASE_API_KEY=your-firebase-api-key

# Security
ENCRYPTION_KEY=your-32-character-encryption-key
JWT_SECRET=your-jwt-secret-key

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/pos_kasa
REDIS_URL=redis://localhost:6379

# Monitoring
LOG_LEVEL=INFO
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

### 4. Platform-Specific Setup

#### Android
```bash
# Android keystore oluşturma
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# key.properties dosyası
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=upload-keystore.jks
```

#### iOS
```bash
# iOS certificates ve provisioning profiles
# Apple Developer Console'dan gerekli sertifikaları indirin
# Xcode'da signing ayarlarını yapılandırın
```

#### Web
```bash
# Web build için gerekli ayarlar
flutter config --enable-web
```

## 🏗️ Build Process

### 1. Pre-Build Checks
```bash
# Code analysis
flutter analyze

# Tests
flutter test

# Format check
dart format --set-exit-if-changed .

# Dependencies check
flutter pub deps
```

### 2. Build Commands

#### Android APK
```bash
flutter build apk --release --target-platform android-arm64
```

#### Android AAB (Play Store)
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release --no-codesign
```

#### Web
```bash
flutter build web --release --web-renderer html
```

#### Windows
```bash
flutter build windows --release
```

#### macOS
```bash
flutter build macos --release
```

#### Linux
```bash
flutter build linux --release
```

### 3. Build Scripts

#### build.sh (Unix/Linux/macOS)
```bash
#!/bin/bash
set -e

echo "Starting build process..."

# Clean previous builds
flutter clean
flutter pub get

# Run tests
flutter test

# Build for all platforms
echo "Building Android APK..."
flutter build apk --release

echo "Building Android AAB..."
flutter build appbundle --release

echo "Building Web..."
flutter build web --release

echo "Building Windows..."
flutter build windows --release

echo "Building macOS..."
flutter build macos --release

echo "Building Linux..."
flutter build linux --release

echo "Build completed successfully!"
```

#### build.bat (Windows)
```batch
@echo off
setlocal

echo Starting build process...

REM Clean previous builds
flutter clean
flutter pub get

REM Run tests
flutter test

REM Build for all platforms
echo Building Android APK...
flutter build apk --release

echo Building Android AAB...
flutter build appbundle --release

echo Building Web...
flutter build web --release

echo Building Windows...
flutter build windows --release

echo Build completed successfully!
```

## 🚀 Deployment

### 1. Android Deployment

#### Google Play Store
```bash
# AAB dosyasını yükleyin
# android/app/build/outputs/bundle/release/app-release.aab

# Play Console'da:
# 1. Release Management > App Releases
# 2. Production > Create Release
# 3. AAB dosyasını yükleyin
# 4. Release notes ekleyin
# 5. Review ve publish
```

#### APK Distribution
```bash
# APK dosyasını dağıtın
# android/app/build/outputs/flutter-apk/app-release.apk
```

### 2. iOS Deployment

#### App Store
```bash
# Xcode'da:
# 1. Product > Archive
# 2. Distribute App
# 3. App Store Connect
# 4. Upload
```

#### TestFlight
```bash
# App Store Connect'te:
# 1. TestFlight > iOS
# 2. Build'leri yönetin
# 3. Test kullanıcıları ekleyin
```

### 3. Web Deployment

#### Static Hosting (Netlify/Vercel)
```bash
# Build output'u deploy edin
# build/web/ klasörünü hosting servisine yükleyin

# Netlify için netlify.toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### Docker Deployment
```dockerfile
# Dockerfile
FROM nginx:alpine

COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Docker build ve run
docker build -t pos-kasa-web .
docker run -p 80:80 pos-kasa-web
```

### 4. Desktop Deployment

#### Windows
```bash
# MSI installer oluşturma
# Inno Setup veya NSIS kullanın

# Portable version
# build/windows/runner/Release/ klasörünü zip'leyin
```

#### macOS
```bash
# DMG oluşturma
# create-dmg kullanın

# App Store için notarization gerekli
```

#### Linux
```bash
# AppImage oluşturma
# linuxdeploy kullanın

# DEB package oluşturma
# dpkg-deb kullanın
```

## 📊 Monitoring

### 1. Application Monitoring

#### Sentry Integration
```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

#### Performance Monitoring
```dart
// Performance tracking
PerformanceMonitor.instance.startTrace('user_action');
// ... perform action
PerformanceMonitor.instance.stopTrace('user_action');
```

### 2. Server Monitoring

#### Health Checks
```bash
# API health check
curl https://api.pos-kasa.com/health

# Database health check
curl https://api.pos-kasa.com/health/database
```

#### Log Monitoring
```bash
# Application logs
tail -f /var/log/pos-kasa/app.log

# Error logs
tail -f /var/log/pos-kasa/error.log
```

### 3. Analytics

#### Firebase Analytics
```dart
// Analytics events
FirebaseAnalytics.instance.logEvent(
  name: 'purchase_completed',
  parameters: {
    'value': 29.99,
    'currency': 'USD',
  },
);
```

## 🔧 Troubleshooting

### Yaygın Sorunlar

#### Build Hataları
```bash
# Flutter clean
flutter clean
flutter pub get

# Dependencies güncelleme
flutter pub upgrade

# Cache temizleme
flutter pub cache clean
```

#### Platform-Specific Hatalar

**Android:**
```bash
# Gradle sync
cd android
./gradlew clean
./gradlew build

# Keystore sorunları
keytool -list -v -keystore android/app/upload-keystore.jks
```

**iOS:**
```bash
# Xcode clean
# Product > Clean Build Folder

# Pods güncelleme
cd ios
pod install --repo-update
```

**Web:**
```bash
# Web renderer değiştirme
flutter build web --web-renderer canvaskit
```

#### Runtime Hataları

**Memory Issues:**
```dart
// Memory monitoring
PerformanceMonitor.instance.recordMetric('memory_usage', memoryUsage);
```

**Network Issues:**
```dart
// Network monitoring
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

### Debug Araçları

#### Flutter Inspector
```bash
flutter run --debug
# Flutter Inspector'ı açın
```

#### Performance Overlay
```dart
// main.dart
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

#### Log Viewer
```dart
// Talker integration
TalkerConfig.logInfo('Debug message');
TalkerConfig.logError('Error message', error, stackTrace);
```

## 📚 Ek Kaynaklar

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [iOS App Store](https://developer.apple.com/app-store)
- [Web Deployment](https://docs.flutter.dev/platform-integration/web)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices)

## 🆘 Destek

Deployment ile ilgili sorularınız için:
- **Email**: devops@pos-kasa.com
- **Slack**: #deployment-support
- **Documentation**: https://docs.pos-kasa.com/deployment
