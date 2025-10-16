# 📚 Deneme1 - Kapsamlı Proje Dokümantasyonu

> Clean Core Architecture + DDD Prensipleri ile Monorepo Yapısı

---

## 📁 1. Dosya Yapısı

### Genel Dizin Ağacı

```
deneme1/
│
├─ 📦 packages/                    # Paylaşılan core paketler
│  ├─ core/                        # Domain entities, types, validation
│  │  ├─ package.json
│  │  ├─ tsconfig.json
│  │  ├─ dist/                     # Build çıktıları
│  │  └─ src/
│  │     ├─ entities/              # Domain Entities (DDD)
│  │     │  ├─ Customer.ts         # Müşteri entity
│  │     │  ├─ Order.ts            # Sipariş entity
│  │     │  ├─ Rental.ts           # Kiralama entity
│  │     │  └─ Payment.ts          # Ödeme entity
│  │     │
│  │     ├─ types/                 # Shared TypeScript types
│  │     │  ├─ common.ts           # ID, Currency, DateRange
│  │     │  └─ enums.ts            # OrderType, PaymentStatus, RecordStatus
│  │     │
│  │     ├─ validation/            # Zod validation schemas
│  │     │  ├─ index.ts
│  │     │  ├─ customer.schema.ts
│  │     │  ├─ order.schema.ts
│  │     │  └─ rental.schema.ts
│  │     │
│  │     ├─ utils/                 # Utility functions
│  │     │  ├─ date.ts             # Tarih işlemleri
│  │     │  ├─ money.ts            # Para formatı, bakiye hesaplama
│  │     │  └─ id.ts               # Unique ID üretimi
│  │     │
│  │     └─ i18n/                  # Çoklu dil desteği
│  │        ├─ index.ts
│  │        ├─ tr.ts               # Türkçe çeviriler
│  │        └─ en.ts               # İngilizce çeviriler
│  │
│  └─ shared/                      # Re-export paketi
│     ├─ package.json
│     ├─ tsconfig.json
│     ├─ dist/
│     └─ src/
│        └─ index.ts               # Core'dan tüm export'ları toplar
│
├─ 🔙 backend/
│  └─ api/                         # NestJS REST API
│     ├─ package.json
│     ├─ tsconfig.json
│     ├─ nest-cli.json
│     ├─ .env                      # Environment variables
│     │
│     ├─ prisma/                   # Prisma ORM
│     │  ├─ schema.prisma          # Database schema
│     │  ├─ dev.db                 # SQLite database (development)
│     │  └─ migrations/            # Database migrations
│     │     └─ 20251007004252_init/
│     │        └─ migration.sql
│     │
│     └─ src/
│        ├─ main.ts                # NestJS entry point + Swagger setup
│        ├─ app.module.ts          # Root module
│        │
│        ├─ common/                # Shared services
│        │  └─ prisma.service.ts   # Prisma client service
│        │
│        ├─ health/                # Health check endpoint
│        │  ├─ health.module.ts
│        │  └─ health.controller.ts
│        │
│        └─ modules/               # Feature modules (DDD Bounded Contexts)
│           │
│           ├─ customers/          # Customer domain
│           │  ├─ customers.module.ts
│           │  ├─ customers.controller.ts    # REST endpoints
│           │  ├─ customers.service.ts       # Business logic
│           │  └─ dto.ts                     # Data Transfer Objects
│           │
│           ├─ orders/             # Order domain
│           │  ├─ orders.module.ts
│           │  ├─ orders.controller.ts
│           │  ├─ orders.service.ts
│           │  └─ dto.ts
│           │
│           └─ rentals/            # Rental domain
│              ├─ rentals.module.ts
│              ├─ rentals.controller.ts
│              ├─ rentals.service.ts
│              └─ dto.ts
│
├─ 🎨 frontend/
│  │
│  ├─ web/                         # React Web Application
│  │  ├─ package.json
│  │  ├─ tsconfig.json
│  │  ├─ vite.config.ts            # Vite configuration + aliases
│  │  ├─ index.html
│  │  │
│  │  └─ src/
│  │     ├─ main.tsx               # Entry point
│  │     ├─ App.tsx                # Root component
│  │     │
│  │     ├─ pages/                 # Page components
│  │     │  └─ SalesRentalsPage.tsx
│  │     │
│  │     ├─ components/            # Reusable components
│  │     │  ├─ PageShell.tsx       # Layout wrapper
│  │     │  │
│  │     │  ├─ Filters/            # Filter components
│  │     │  │  ├─ AutocompleteSelect.tsx
│  │     │  │  ├─ DateRangeModal.tsx
│  │     │  │  └─ TagSelect.tsx
│  │     │  │
│  │     │  └─ Table/              # Data table components
│  │     │     ├─ DataTable.tsx
│  │     │     └─ columns.ts
│  │     │
│  │     └─ lib/                   # Utilities
│  │        ├─ api.ts              # Axios API client
│  │        └─ i18n.ts             # i18n helper
│  │
│  └─ mobile/                      # React Native Mobile App
│     ├─ package.json
│     ├─ metro.config.js           # Metro bundler + aliases
│     └─ src/
│        └─ App.tsx                # Mobile app entry
│
├─ 📄 Kök Dosyalar
│  ├─ package.json                 # Root workspace config
│  ├─ pnpm-workspace.yaml          # pnpm workspace definition
│  ├─ tsconfig.base.json           # Shared TypeScript config
│  ├─ .gitignore
│  ├─ .editorconfig
│  ├─ README.md                    # Project overview
│  ├─ DOCUMENTATION.md             # Bu dosya
│  └─ SETUP_COMPLETED.md           # Setup checklist
│
└─ 📂 Opsiyonel Klasörler
   ├─ docs/                        # Additional documentation
   ├─ ops/                         # Deployment configs
   └─ scripts/                     # Build/deployment scripts
```

---

## 🏗️ 2. Mimari Yapısı

### 2.1. Clean Core Architecture

```
┌─────────────────────────────────────────┐
│         Frontend Applications           │
│  ┌──────────┐  ┌──────────┐            │
│  │   Web    │  │  Mobile  │            │
│  │ (React)  │  │   (RN)   │            │
│  └────┬─────┘  └────┬─────┘            │
└───────┼─────────────┼──────────────────┘
        │             │
        └──────┬──────┘
               ↓
┌─────────────────────────────────────────┐
│         @deneme1/shared                 │
│  (Re-exports from @deneme1/core)       │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         @deneme1/core                   │
│  ┌────────────────────────────────┐    │
│  │  Domain Entities               │    │
│  │  - Customer, Order, Rental     │    │
│  └────────────────────────────────┘    │
│  ┌────────────────────────────────┐    │
│  │  Types & Enums                 │    │
│  │  - Common types, Status enums  │    │
│  └────────────────────────────────┘    │
│  ┌────────────────────────────────┐    │
│  │  Validation (Zod)              │    │
│  │  - Runtime type checking       │    │
│  └────────────────────────────────┘    │
│  ┌────────────────────────────────┐    │
│  │  Utils & i18n                  │    │
│  │  - Business logic utilities    │    │
│  └────────────────────────────────┘    │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Backend API (NestJS)            │
│  ┌────────────────────────────────┐    │
│  │  Controllers (REST API)        │    │
│  │  - HTTP request handling       │    │
│  └────────────┬───────────────────┘    │
│               ↓                         │
│  ┌────────────────────────────────┐    │
│  │  Services (Business Logic)     │    │
│  │  - Domain operations           │    │
│  └────────────┬───────────────────┘    │
│               ↓                         │
│  ┌────────────────────────────────┐    │
│  │  Prisma ORM                    │    │
│  │  - Database access layer       │    │
│  └────────────┬───────────────────┘    │
└───────────────┼─────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│         SQLite Database                 │
│  - Customer, Order, Rental tables      │
└─────────────────────────────────────────┘
```

### 2.2. Domain-Driven Design (DDD) Katmanları

#### **Domain Layer** (`packages/core/src/entities/`)
- **Customer**: Müşteri aggregate root
- **Order**: Sipariş aggregate root
- **Rental**: Kiralama aggregate root
- **Payment**: Ödeme value object

#### **Application Layer** (`backend/api/src/modules/`)
- **Controllers**: HTTP endpoint'leri
- **Services**: Business logic ve use case'ler
- **DTOs**: Data transfer objects (validation)

#### **Infrastructure Layer**
- **Prisma**: Database ORM
- **NestJS**: Web framework
- **SQLite**: Database

#### **Presentation Layer**
- **React Web**: SPA application
- **React Native**: Mobile application

### 2.3. Bounded Contexts

```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   Customer BC    │  │    Order BC      │  │    Rental BC     │
│                  │  │                  │  │                  │
│  - Customer      │  │  - Order         │  │  - Rental        │
│  - CRUD ops      │  │  - Order Items   │  │  - Period        │
│  - Search        │  │  - Delivery      │  │  - Return        │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

---

## 💾 3. Data Yönetimi

### 3.1. Database Schema (Prisma)

```prisma
// Customer Table
model Customer {
  id      String   @id @default(cuid())
  name    String
  phone   String?
  email   String?
  orders  Order[]
  rentals Rental[]
}

// Order Table
model Order {
  id            String    @id @default(cuid())
  type          String    // SALE, RENTAL
  customerId    String
  customer      Customer  @relation(fields: [customerId], references: [id])
  organization  String?
  deliveryDate  DateTime?
  total         Int       // Amount in cents
  collected     Int       // Amount collected in cents
  paymentStatus String    // PENDING, PAID, PARTIAL
  status        String    // ACTIVE, CANCELLED, COMPLETED
  createdAt     DateTime  @default(now())
}

// Rental Table
model Rental {
  id            String    @id @default(cuid())
  customerId    String
  customer      Customer  @relation(fields: [customerId], references: [id])
  organization  String?
  start         DateTime
  end           DateTime
  total         Int
  collected     Int
  paymentStatus String
  status        String
  createdAt     DateTime  @default(now())
}
```

### 3.2. Type Definitions (TypeScript)

```typescript
// packages/core/src/types/enums.ts
export enum OrderType { 
  SALE = 'SALE', 
  RENTAL = 'RENTAL' 
}

export enum PaymentStatus { 
  PENDING = 'PENDING', 
  PAID = 'PAID', 
  PARTIAL = 'PARTIAL' 
}

export enum RecordStatus { 
  ACTIVE = 'ACTIVE', 
  CANCELLED = 'CANCELLED', 
  COMPLETED = 'COMPLETED' 
}

// packages/core/src/types/common.ts
export type ID = string
export type Currency = number
export interface DateRange { 
  start: string
  end: string 
}
```

### 3.3. Validation (Zod)

```typescript
// packages/core/src/validation/customer.schema.ts
import { z } from 'zod'

export const CustomerSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(2),
  phone: z.string().optional(),
  email: z.string().email().optional()
})

// Runtime validation
const customer = CustomerSchema.parse(data) // Throws if invalid
```

### 3.4. Data Flow

```
Frontend         Backend          Database
   │                │                │
   │ POST /customers│                │
   ├───────────────>│                │
   │                │ INSERT         │
   │                ├───────────────>│
   │                │<───────────────┤
   │                │ Customer       │
   │<───────────────┤                │
   │ Customer       │                │
```

---

## ✨ 4. Kod Kalitesi

### 4.1. TypeScript Configuration

**Strict Mode Enabled:**
```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler"
  }
}
```

**Path Aliases:**
```json
{
  "paths": {
    "@core/*": ["packages/core/src/*"],
    "@shared/*": ["packages/shared/src/*"]
  }
}
```

### 4.2. Code Style

- **EditorConfig**: Consistent formatting
- **2 spaces** indentation
- **LF** line endings
- **UTF-8** encoding
- **Trailing newlines** required

### 4.3. Validation Strategy

**Server-side (NestJS):**
- DTOs with class-validator decorators
- Automatic validation pipe

**Shared (Zod):**
- Runtime type checking
- Schema validation
- Type inference

### 4.4. Error Handling

```typescript
// Backend: NestJS Exception Filters
try {
  return await this.service.findOne(id)
} catch (error) {
  throw new NotFoundException(`Customer #${id} not found`)
}

// Frontend: Axios Interceptors
api.interceptors.response.use(
  response => response,
  error => {
    // Handle errors globally
    console.error('API Error:', error)
    return Promise.reject(error)
  }
)
```

---

## 📖 5. Dokümantasyon

### 5.1. API Documentation (Swagger)

**Automatic API Docs:**
```typescript
// backend/api/src/main.ts
const config = new DocumentBuilder()
  .setTitle('Deneme1 API')
  .setDescription('OpenAPI spec for clients')
  .setVersion('1.0.0')
  .build()
  
SwaggerModule.setup('docs', app, document)
```

**Access:** http://localhost:3000/docs

### 5.2. Code Comments

```typescript
/**
 * Calculates the remaining balance for an order/rental
 * @param price - Total price in cents
 * @param collected - Amount collected in cents
 * @returns Remaining balance (always >= 0)
 */
export const calcBalance = (price: number, collected: number) =>
  Math.max(Number(price || 0) - Number(collected || 0), 0)
```

### 5.3. README Files

- **Root README.md**: Project overview
- **SETUP_COMPLETED.md**: Setup checklist
- **DOCUMENTATION.md**: This comprehensive guide

---

## 🆕 6. Yeni Proje Yapısı

### 6.1. Değişiklikler

#### **Önceki Yapı:**
```
❌ apps/web/                    # Gereksiz apps klasörü
❌ backend/api/src/auth/        # Kullanılmayan auth
❌ backend/api/src/users/       # Kullanılmayan users
❌ frontend/mobile/lib/         # Flutter dosyaları
❌ frontend/windows/            # Electron uygulaması
❌ Karmaşık modül yapısı
```

#### **Yeni Yapı:**
```
✅ packages/core/               # Clean core architecture
✅ packages/shared/             # Simple re-exports
✅ backend/api/                 # Simplified NestJS
   ├─ modules/customers/        # DDD bounded context
   ├─ modules/orders/           # DDD bounded context
   └─ modules/rentals/          # DDD bounded context
✅ frontend/web/                # Simple React + Vite
✅ frontend/mobile/             # React Native (clean)
```

### 6.2. Basitleştirmeler

1. **Tek Veritabanı**: PostgreSQL yerine SQLite (kolay setup)
2. **Minimal Modüller**: Sadece Customer, Order, Rental
3. **Tek Dil**: TypeScript everywhere
4. **Monorepo**: pnpm workspaces ile optimize edilmiş
5. **Type Safety**: Tam TypeScript desteği

---

## 🚀 7. Kullanıma Hazır Özellikler

### 7.1. Backend API Endpoints

#### **Customers**
```http
GET    /customers        # List all customers
GET    /customers/:id    # Get customer by ID
POST   /customers        # Create customer
PUT    /customers/:id    # Update customer
DELETE /customers/:id    # Delete customer
```

#### **Orders**
```http
GET    /orders           # List all orders
GET    /orders/:id       # Get order by ID
POST   /orders           # Create order
PUT    /orders/:id       # Update order
DELETE /orders/:id       # Delete order
```

#### **Rentals**
```http
GET    /rentals          # List all rentals
GET    /rentals/:id      # Get rental by ID
POST   /rentals          # Create rental
PUT    /rentals/:id      # Update rental
DELETE /rentals/:id      # Delete rental
```

#### **Health Check**
```http
GET    /health           # Health check endpoint
```

### 7.2. Frontend Components

#### **Pages**
- `SalesRentalsPage`: Ana satış/kiralama sayfası

#### **Components**
- `PageShell`: Layout wrapper
- `AutocompleteSelect`: Arama özellikli dropdown
- `DateRangeModal`: Tarih aralığı seçici
- `DataTable`: Dinamik data table
- `TagSelect`: Multi-select component

#### **Utilities**
- `api.ts`: Axios HTTP client
- `i18n.ts`: i18n helper functions
- `money.ts`: Para formatı utilities
- `date.ts`: Tarih utilities

### 7.3. Shared Core Features

#### **Entities**
- Type-safe domain models
- Runtime validation ready

#### **i18n Support**
```typescript
// Türkçe
TEXT.tr.filters.customer  // "Müşteri"
TEXT.tr.status.ACTIVE     // "Aktif"

// English
TEXT.en.filters.customer  // "Customer"
TEXT.en.status.ACTIVE     // "Active"
```

#### **Money Utilities**
```typescript
fmtTRY(10000)           // "₺10.000"
calcBalance(10000, 4000) // 6000
```

---

## 📋 8. Kullanım Rehberi

### 8.1. Kurulum

```bash
# 1. Bağımlılıkları yükle
pnpm install

# 2. Database migration
pnpm --filter @deneme1/api prisma:migrate

# 3. Packages build et
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build
```

### 8.2. Development

#### **Backend Başlatma**
```bash
pnpm dev:api
```
- API: http://localhost:3000
- Swagger: http://localhost:3000/docs

#### **Frontend Başlatma**
```bash
pnpm dev:web
```
- Web: http://localhost:5173

#### **Mobile Başlatma**
```bash
pnpm dev:rn
```

### 8.3. Yeni Feature Ekleme

#### **1. Yeni Entity Ekle**
```typescript
// packages/core/src/entities/Product.ts
export interface Product {
  id: ID
  name: string
  price: Currency
  stock: number
}
```

#### **2. Validation Schema**
```typescript
// packages/core/src/validation/product.schema.ts
export const ProductSchema = z.object({
  id: z.string(),
  name: z.string().min(1),
  price: z.number().positive(),
  stock: z.number().int().nonnegative()
})
```

#### **3. Prisma Schema**
```prisma
// backend/api/prisma/schema.prisma
model Product {
  id    String @id @default(cuid())
  name  String
  price Int
  stock Int
}
```

#### **4. NestJS Module**
```bash
# backend/api/src/modules/products/
├─ products.module.ts
├─ products.controller.ts
├─ products.service.ts
└─ dto.ts
```

#### **5. Frontend Integration**
```typescript
// frontend/web/src/lib/api.ts
export const getProducts = () => api.get('/products')
export const createProduct = (data) => api.post('/products', data)
```

### 8.4. Database Migration

```bash
# Yeni migration oluştur
cd backend/api
npx prisma migrate dev --name add_products

# Migration çalıştır
pnpm --filter @deneme1/api prisma:migrate

# Prisma Studio aç (GUI)
npx prisma studio
```

### 8.5. OpenAPI & Codegen

```bash
# Swagger JSON oluştur
pnpm --filter @deneme1/api openapi:emit

# React Native için client üret
pnpm --filter @deneme1/api codegen:rn

# Hepsini bir arada
pnpm --filter @deneme1/api codegen:all
```

### 8.6. Build & Deploy

```bash
# Tüm paketleri build et
pnpm build

# Sadece backend
pnpm --filter @deneme1/api build

# Sadece frontend
pnpm --filter @deneme1/web build

# Production start
pnpm --filter @deneme1/api start
```

### 8.7. Testing

```bash
# Backend tests
pnpm --filter @deneme1/api test

# Frontend tests
pnpm --filter @deneme1/web test

# E2E tests
pnpm test:e2e
```

---

## 🔧 9. Konfigürasyon

### 9.1. Environment Variables

**Backend (.env):**
```env
DATABASE_URL=file:./prisma/dev.db
PORT=3000
NODE_ENV=development
```

**Frontend (.env):**
```env
VITE_API_URL=http://localhost:3000
```

### 9.2. TypeScript Paths

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "paths": {
      "@core/*": ["packages/core/src/*"],
      "@shared/*": ["packages/shared/src/*"]
    }
  }
}
```

### 9.3. Vite Aliases

```typescript
// frontend/web/vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      '@core': path.resolve(__dirname, '../../packages/core/src'),
      '@shared': path.resolve(__dirname, '../../packages/shared/src')
    }
  }
})
```

### 9.4. Metro Bundler (React Native)

```javascript
// frontend/mobile/metro.config.js
module.exports = {
  resolver: {
    extraNodeModules: {
      '@core': path.resolve(__dirname, '../../packages/core/src'),
      '@shared': path.resolve(__dirname, '../../packages/shared/src'),
    },
  },
}
```

---

## 📊 10. Best Practices

### 10.1. Domain Logic
✅ **DO**: Domain logic'i `packages/core` içinde tut  
❌ **DON'T**: Business logic'i frontend'e yazma

### 10.2. Type Safety
✅ **DO**: Her zaman TypeScript types kullan  
❌ **DON'T**: `any` type kullanma

### 10.3. Validation
✅ **DO**: Hem client hem server'da validate et  
❌ **DON'T**: Sadece frontend validation'a güvenme

### 10.4. API Design
✅ **DO**: RESTful endpoint'ler oluştur  
✅ **DO**: Swagger documentation güncelle  
❌ **DON'T**: Breaking changes yap

### 10.5. Database
✅ **DO**: Prisma migrations kullan  
❌ **DON'T**: Database'i manuel düzenleme

---

## 🎯 11. Sonraki Adımlar

### 11.1. Özellik Geliştirme
- [ ] Authentication & Authorization ekle
- [ ] File upload özelliği
- [ ] Advanced filtering
- [ ] Pagination
- [ ] Search functionality

### 11.2. UI/UX İyileştirmeleri
- [ ] Responsive design
- [ ] Dark mode
- [ ] Loading states
- [ ] Error boundaries
- [ ] Toast notifications

### 11.3. Testing
- [ ] Unit tests ekle
- [ ] Integration tests
- [ ] E2E tests
- [ ] Test coverage %80+

### 11.4. DevOps
- [ ] Docker container'ları
- [ ] CI/CD pipeline
- [ ] Production deployment
- [ ] Monitoring & logging

### 11.5. Dokümantasyon
- [ ] API usage examples
- [ ] Video tutorials
- [ ] Architecture decision records
- [ ] Contributing guidelines

---

## 📞 12. Destek & Katkı

### Sorun Bildirimi
GitHub Issues kullanarak sorun bildirebilirsiniz.

### Katkıda Bulunma
1. Fork yapın
2. Feature branch oluşturun
3. Commit'leyin
4. Pull request açın

### İletişim
- Email: your.email@example.com
- GitHub: @your-username

---

## 📝 13. Changelog

### v0.1.0 (2025-10-11)
- ✅ Initial release
- ✅ Clean Core Architecture implemented
- ✅ DDD principles applied
- ✅ Customer, Order, Rental modules
- ✅ React web frontend
- ✅ React Native mobile setup
- ✅ SQLite database with Prisma
- ✅ Swagger API documentation
- ✅ i18n support (TR/EN)
- ✅ Type-safe monorepo structure

---

**🎉 Proje Hazır! Geliştirmeye Başlayabilirsiniz!**

