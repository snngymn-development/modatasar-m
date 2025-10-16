# Navigasyon Sistemi Dokümantasyonu

Bu dokümantasyon, tüm platformlarda (Web, Mobile, Windows) tutarlı bir şekilde çalışan navigasyon sistemini açıklar.

## 📋 Genel Bakış

Navigasyon sistemi şu ana bileşenlerden oluşur:
- **Login Sayfası**: Kullanıcı girişi
- **Dashboard**: Ana sayfa
- **Üst Menü (Toolbar)**: Sabit üst navigasyon
- **Alt Menü**: Platform-specific alt navigasyon
- **Breadcrumb**: Mevcut konum göstergesi
- **Aktif Sayfa Göstergesi**: Hangi bölümde olduğunuzu gösterir

## 🏗️ Mimari

### Paylaşılan Tipler
Tüm platformlar için ortak navigasyon tipleri `frontend/shared/types/navigation.ts` dosyasında tanımlanmıştır.

```typescript
interface NavigationItem {
  id: string;
  label: string;
  labelKey: string; // i18n key
  icon: string;
  emoji: string;
  route: string;
  parent?: string;
  order: number;
  isActive?: boolean;
  children?: NavigationItem[];
}
```

### Backend API
Navigasyon verileri backend'den `NavigationService` aracılığıyla alınır:

- `GET /api/navigation/menu` - Navigasyon menüsü
- `GET /api/navigation/breadcrumbs/:route` - Breadcrumb verileri
- `GET /api/navigation/active-section/:route` - Aktif bölüm
- `GET /api/navigation/permissions` - Kullanıcı izinleri

## 🌐 Web Frontend (React)

### Bileşenler
- `Breadcrumb.tsx` - Breadcrumb navigasyonu
- `ActivePageIndicator.tsx` - Aktif sayfa göstergesi
- `AppLayout.tsx` - Ana layout wrapper

### Kullanım
```tsx
import Breadcrumb from './components/navigation/Breadcrumb';
import ActivePageIndicator from './components/navigation/ActivePageIndicator';

// Layout içinde
<AppLayout>
  <Breadcrumb />
  <ActivePageIndicator />
  {children}
</AppLayout>
```

### Servis
```typescript
import { navigationService } from './services/navigationService';

// Navigasyon menüsünü al
const menu = await navigationService.getNavigationMenu();

// Breadcrumb'ları al
const breadcrumbs = await navigationService.getBreadcrumbs('/partners/customers');
```

## 📱 Mobile App (Flutter)

### Bileşenler
- `BreadcrumbWidget` - Breadcrumb navigasyonu
- `ActivePageIndicator` - Aktif sayfa göstergesi
- `AppLayout` - Ana layout wrapper

### Kullanım
```dart
import '../shared/navigation/breadcrumb_widget.dart';
import '../shared/navigation/active_page_indicator.dart';

// Layout içinde
AppLayout(
  currentRoute: '/partners',
  child: Column(
    children: [
      BreadcrumbWidget(currentRoute: '/partners'),
      ActivePageIndicator(currentRoute: '/partners'),
      // Diğer içerik
    ],
  ),
)
```

### Servis
```dart
import '../services/navigation_service.dart';

final navigationService = NavigationService();

// Navigasyon menüsünü al
final menu = await navigationService.getNavigationMenu();

// Breadcrumb'ları al
final breadcrumbs = await navigationService.getBreadcrumbs('/partners/customers');
```

## 🖥️ Windows App (Electron)

### Bileşenler
- `navigation-utils.js` - Navigasyon yardımcı fonksiyonları
- `navigation-types.js` - Navigasyon tipleri

### Kullanım
```javascript
const { setupNavigationListeners, updateNavigationUI } = require('./src/navigation/navigation-utils');

// Sayfa yüklendiğinde
setupNavigationListeners();

// HTML'de breadcrumb container
<div id="breadcrumb-container"></div>

// HTML'de aktif sayfa container
<div id="active-page-container"></div>
```

## 🔧 Konfigürasyon

### Platform Ayarları
Her platform için farklı konfigürasyonlar `PLATFORM_CONFIGS` içinde tanımlanmıştır:

```typescript
const PLATFORM_CONFIGS = {
  web: {
    showTopBar: true,
    showBottomBar: true,
    showBreadcrumbs: true,
    maxBreadcrumbItems: 5,
    enableKeyboardNavigation: true,
  },
  mobile: {
    showTopBar: true,
    showBottomBar: true,
    showBreadcrumbs: true,
    maxBreadcrumbItems: 3,
    enableKeyboardNavigation: false,
  },
  windows: {
    showTopBar: true,
    showBottomBar: true,
    showBreadcrumbs: true,
    maxBreadcrumbItems: 5,
    enableKeyboardNavigation: true,
  },
};
```

## 🎨 Tasarım Prensipleri

### Tutarlılık
- Tüm platformlarda aynı navigasyon yapısı
- Tutarlı ikon ve emoji kullanımı
- Aynı renk şeması ve tipografi

### Responsive
- Mobile'da daha kompakt görünüm
- Desktop'ta daha detaylı bilgi
- Platform-specific optimizasyonlar

### Erişilebilirlik
- Keyboard navigasyonu (Web/Windows)
- Screen reader desteği
- ARIA etiketleri

## 🚀 Geliştirme

### Yeni Sayfa Ekleme
1. `frontend/shared/types/navigation.ts` dosyasına yeni route ekleyin
2. Backend'de `NavigationService`'i güncelleyin
3. Platform-specific bileşenleri güncelleyin
4. i18n çevirilerini ekleyin

### Yeni Platform Ekleme
1. `PLATFORM_CONFIGS`'e yeni platform ekleyin
2. Platform-specific navigasyon bileşenleri oluşturun
3. Servis katmanını implement edin
4. Test sayfaları oluşturun

## 🧪 Test

### Test Sayfaları
- `/partners` - Ana bölüm testi
- `/partners/customers` - Alt sayfa testi
- Breadcrumb ve aktif sayfa göstergesi test edilebilir

### Test Komutları
```bash
# Web
npm run dev

# Mobile
flutter run

# Windows
npm start
```

## 📚 API Referansı

### NavigationService (Backend)
```typescript
class NavigationService {
  getNavigationMenu(): NavigationItem[]
  getBreadcrumbs(route: string): BreadcrumbItem[]
  getActiveSection(route: string): string
  getNavigationPermissions(userRole: string): Record<string, boolean>
}
```

### Frontend Services
```typescript
// Web
navigationService.getNavigationMenu()
navigationService.getBreadcrumbs(route)
navigationService.getActiveSection(route)
navigationService.getNavigationPermissions()

// Flutter
NavigationService().getNavigationMenu()
NavigationService().getBreadcrumbs(route)
NavigationService().getActiveSection(route)
NavigationService().getNavigationPermissions()
```

## 🔒 Güvenlik

### İzin Sistemi
- Role-based permissions
- Backend'de doğrulama
- Frontend'de UI kontrolü

### Güvenli Route'lar
- Tüm navigasyon API'leri JWT ile korunmuş
- Kullanıcı rolüne göre menü filtreleme
- Unauthorized erişim engelleme

## 🐛 Sorun Giderme

### Yaygın Sorunlar
1. **Breadcrumb görünmüyor**: Route mapping kontrol edin
2. **Aktif sayfa göstergesi çalışmıyor**: Navigation service kontrol edin
3. **Mobile'da layout bozuk**: AppLayout parametrelerini kontrol edin

### Debug
```typescript
// Web
console.log(navigationService.getNavigationMenu());

// Flutter
print(await NavigationService().getNavigationMenu());
```

## 📈 Performans

### Optimizasyonlar
- Navigation cache
- Lazy loading
- Platform-specific optimizasyonlar

### Monitoring
- Navigation API response times
- Cache hit rates
- User navigation patterns

---

Bu dokümantasyon navigasyon sisteminin tüm yönlerini kapsar. Sorularınız için geliştirici ekibiyle iletişime geçin.
