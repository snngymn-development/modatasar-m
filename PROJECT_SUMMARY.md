# 📊 Deneme1 - Proje Özeti

## 🎯 Genel Bakış

**Proje Adı**: Deneme1  
**Mimari**: Clean Core Architecture + Domain-Driven Design (DDD)  
**Yapı**: Monorepo (pnpm workspaces)  
**Dil**: TypeScript  
**Veritabanı**: SQLite (Prisma ORM)  
**Backend**: NestJS  
**Frontend**: React (Vite) + React Native (Expo)

---

## 📁 Ana Klasör Yapısı

```
deneme1/
├─ packages/
│  ├─ core/         → Domain entities, types, validation, i18n
│  └─ shared/       → Re-exports from core
│
├─ backend/
│  └─ api/          → NestJS REST API + Prisma
│
└─ frontend/
   ├─ web/          → React + Vite
   └─ mobile/       → React Native + Expo
```

---

## 🏗️ Mimari Katmanları

### 1. **Domain Layer** (packages/core)
```typescript
entities/      → Customer, Order, Rental, Payment
types/         → Common types, Enums
validation/    → Zod schemas
utils/         → date, money, id utilities
i18n/          → TR/EN translations
```

### 2. **Application Layer** (backend/api)
```typescript
modules/
├─ customers/  → CRUD operations
├─ orders/     → CRUD operations
└─ rentals/    → CRUD operations
```

### 3. **Infrastructure Layer**
- **Prisma ORM**: Database access
- **SQLite**: Development database
- **NestJS**: Web framework

### 4. **Presentation Layer**
- **React Web**: Desktop/tablet UI
- **React Native**: Mobile UI

---

## 💾 Database Schema

```sql
Customer
├─ id (PK)
├─ name
├─ phone
├─ email
└─ relations → orders[], rentals[]

Order
├─ id (PK)
├─ type (SALE/RENTAL)
├─ customerId (FK → Customer)
├─ organization
├─ deliveryDate
├─ total
├─ collected
├─ paymentStatus (PENDING/PAID/PARTIAL)
├─ status (ACTIVE/CANCELLED/COMPLETED)
└─ createdAt

Rental
├─ id (PK)
├─ customerId (FK → Customer)
├─ organization
├─ start
├─ end
├─ total
├─ collected
├─ paymentStatus
├─ status
└─ createdAt
```

---

## 🚀 Hızlı Başlangıç

### Kurulum
```bash
pnpm install
pnpm --filter @deneme1/api prisma:migrate
```

### Çalıştırma
```bash
# Backend
pnpm dev:api      # → http://localhost:3000
                  # → http://localhost:3000/docs (Swagger)

# Frontend
pnpm dev:web      # → http://localhost:5173

# Mobile
pnpm dev:rn
```

---

## 📚 API Endpoints

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | /customers | Tüm müşterileri listele |
| GET | /customers/:id | Müşteri detayı |
| POST | /customers | Yeni müşteri |
| PUT | /customers/:id | Müşteri güncelle |
| DELETE | /customers/:id | Müşteri sil |
| | | |
| GET | /orders | Tüm siparişleri listele |
| GET | /orders/:id | Sipariş detayı |
| POST | /orders | Yeni sipariş |
| PUT | /orders/:id | Sipariş güncelle |
| DELETE | /orders/:id | Sipariş sil |
| | | |
| GET | /rentals | Tüm kiralamaları listele |
| GET | /rentals/:id | Kiralama detayı |
| POST | /rentals | Yeni kiralama |
| PUT | /rentals/:id | Kiralama güncelle |
| DELETE | /rentals/:id | Kiralama sil |
| | | |
| GET | /health | Health check |

---

## 🎨 Frontend Özellikleri

### Components
- **PageShell**: Layout wrapper
- **AutocompleteSelect**: Arama özellikli dropdown
- **DateRangeModal**: Tarih aralığı seçici
- **DataTable**: Dinamik tablo
- **Filters**: Filtreleme bileşenleri

### Pages
- **SalesRentalsPage**: Satış/kiralama yönetimi

### Utilities
- **api.ts**: HTTP client (axios)
- **i18n.ts**: Çoklu dil desteği
- **money.ts**: Para formatı
- **date.ts**: Tarih işlemleri

---

## 🔧 Teknolojiler

### Backend
- **NestJS** v10 - Node.js framework
- **Prisma** v5 - ORM
- **SQLite** - Database
- **Swagger** - API documentation
- **TypeScript** v5

### Frontend Web
- **React** v18
- **Vite** v5 - Build tool
- **Axios** - HTTP client
- **TypeScript** v5

### Frontend Mobile
- **React Native** v0.75
- **Expo** v51
- **Metro** - Bundler

### Shared
- **Zod** v3 - Validation
- **pnpm** v9 - Package manager
- **TypeScript** v5 - Type system

---

## 📦 Package Scripts

```bash
# Build
pnpm build                  # Tüm paketleri build et
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build
pnpm --filter @deneme1/api build
pnpm --filter @deneme1/web build

# Development
pnpm dev:api               # Backend geliştirme
pnpm dev:web               # Frontend geliştirme
pnpm dev:rn                # Mobile geliştirme

# Database
pnpm --filter @deneme1/api prisma:gen      # Prisma client üret
pnpm --filter @deneme1/api prisma:migrate  # Migration çalıştır

# OpenAPI
pnpm --filter @deneme1/api openapi:emit    # Swagger JSON üret
pnpm --filter @deneme1/api codegen:rn      # RN client üret
pnpm --filter @deneme1/api codegen:all     # Tüm codegen
```

---

## 🌍 i18n Desteği

```typescript
// Türkçe
import { TEXT } from '@shared'
TEXT.tr.filters.customer     // "Müşteri"
TEXT.tr.table.total          // "Toplam"
TEXT.tr.status.ACTIVE        // "Aktif"

// English
TEXT.en.filters.customer     // "Customer"
TEXT.en.table.total          // "Total"
TEXT.en.status.ACTIVE        // "Active"
```

---

## ✅ Type Safety

### Domain Entities
```typescript
import { Customer, Order, Rental } from '@shared'

const customer: Customer = {
  id: 'cuid123',
  name: 'John Doe',
  email: 'john@example.com'
}
```

### Validation
```typescript
import { CustomerSchema } from '@core/validation'

const result = CustomerSchema.safeParse(data)
if (result.success) {
  // Valid customer
} else {
  // Validation errors
  console.error(result.error)
}
```

### Enums
```typescript
import { OrderType, PaymentStatus, RecordStatus } from '@shared'

const order: Order = {
  type: OrderType.SALE,
  paymentStatus: PaymentStatus.PENDING,
  status: RecordStatus.ACTIVE
}
```

---

## 🎯 Best Practices

✅ **DO's:**
- Domain logic'i `packages/core`'da tut
- TypeScript strict mode kullan
- Zod ile validation yap
- Prisma migrations kullan
- RESTful API tasarla
- Swagger documentation güncelle

❌ **DON'Ts:**
- `any` type kullanma
- Domain logic'i frontend'e yazma
- Database'i manuel düzenleme
- Breaking API changes yapma
- Validation'ı atla

---

## 📊 Proje İstatistikleri

- **Packages**: 3 (core, shared, api)
- **Frontend Apps**: 2 (web, mobile)
- **Domain Entities**: 4 (Customer, Order, Rental, Payment)
- **API Endpoints**: 16 (CRUD × 3 modules + health)
- **Database Tables**: 3 (Customer, Order, Rental)
- **Languages**: 2 (TR, EN)
- **Dependencies**: ~1300 npm packages

---

## 🔄 Workflow

### Yeni Feature Ekleme
1. **Domain Entity** oluştur (`packages/core/src/entities/`)
2. **Validation Schema** ekle (`packages/core/src/validation/`)
3. **Prisma Model** tanımla (`backend/api/prisma/schema.prisma`)
4. **Migration** çalıştır (`pnpm prisma:migrate`)
5. **NestJS Module** oluştur (`backend/api/src/modules/`)
6. **Frontend Integration** yap (`frontend/web/src/`)

### Database Değişikliği
1. `schema.prisma` güncelle
2. `npx prisma migrate dev --name change_name`
3. Prisma client'ı yeniden üret

### API Değişikliği
1. Controller/Service güncelle
2. DTO'ları güncelle
3. Swagger documentation otomatik güncellenir
4. OpenAPI JSON üret: `pnpm openapi:emit`

---

## 📖 Dokümantasyon

- **DOCUMENTATION.md**: Kapsamlı dokümantasyon
- **README.md**: Proje özeti
- **SETUP_COMPLETED.md**: Kurulum checklist
- **Swagger**: http://localhost:3000/docs

---

## 🎉 Başarıyla Kuruldu!

Proje Clean Core Architecture + DDD prensipleriyle baştan sona yeniden yapılandırıldı.

**Geliştirmeye hazır!** 🚀

