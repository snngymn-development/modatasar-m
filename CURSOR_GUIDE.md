# 🤖 Cursor AI - Proje Rehberi

> **Deneme1** projesi için Cursor AI talimatları

---

## 📋 Proje Tanımı

**Bu proje nedir?**

Deneme1, **Clean Core Architecture** + **Domain Driven Design (DDD)** prensiplerine göre yapılandırılmış TypeScript monorepo'dur.

**Teknolojiler:**
- Backend: NestJS + Prisma + SQLite
- Frontend: React (Vite) + React Native (Expo)
- Shared: TypeScript entities, types, validation (Zod)

---

## 🏗️ Mimari Katmanlar

### 4 Katman Yapısı:

```
┌─────────────────────────────────────┐
│  1. DOMAIN LAYER                    │
│  packages/core/                     │
│  - Pure business logic              │
│  - NO external dependencies         │
│  - Entities, Types, Validation      │
└─────────────────────────────────────┘
              ↑
              │ extends
┌─────────────────────────────────────┐
│  2. APPLICATION LAYER               │
│  packages/shared/                   │
│  - Re-exports from core             │
│  - Presentation için hazır          │
└─────────────────────────────────────┘
              ↑                  ↑
              │                  │
    ┌─────────┴────┐    ┌───────┴──────┐
    │              │    │               │
┌───────────┐  ┌──────────────┐  ┌─────────────┐
│3. INFRA   │  │4. PRESENT.   │  │4. PRESENT.  │
│backend/api│  │frontend/web  │  │frontend/    │
│           │  │              │  │mobile       │
│NestJS +   │  │React +       │  │React        │
│Prisma     │  │Vite          │  │Native       │
└───────────┘  └──────────────┘  └─────────────┘
```

---

## 📂 Dosya Konumlandırma Kuralları

### ✅ Ortak Tipler → `packages/core/src/types/`

```typescript
// packages/core/src/types/common.ts
export type ID = string
export type Currency = number  // cents
export interface DateRange { start: string; end: string }
```

### ✅ Domain Entities → `packages/core/src/entities/`

```typescript
// packages/core/src/entities/Customer.ts
export interface Customer {
  id: ID
  name: string
  phone?: string
  email?: string
}
```

### ✅ Validation → `packages/core/src/validation/`

```typescript
// packages/core/src/validation/customer.schema.ts
import { z } from 'zod'

export const CustomerSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(2),
  phone: z.string().optional(),
  email: z.string().email().optional()
})
```

### ✅ Utility Functions → `packages/core/src/utils/`

```typescript
// packages/core/src/utils/money.ts
export const fmtTRY = (cents: number) =>
  new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency: 'TRY',
    maximumFractionDigits: 0
  }).format(cents / 100)  // ⚠️ /100 burada yapılır!
```

### ✅ Backend Services → `backend/api/src/modules/{domain}/`

```typescript
// backend/api/src/modules/customers/customers.service.ts
@Injectable()
export class CustomersService {
  constructor(private prisma: PrismaService) {}
  
  async findAll() {
    return this.prisma.customer.findMany()
  }
}
```

### ✅ Frontend Components → `frontend/web/src/components/`

```typescript
// frontend/web/src/components/CustomerCard.tsx
import React from 'react'
import type { Customer } from '@shared'

export function CustomerCard({ customer }: { customer: Customer }) {
  return <div>{customer.name}</div>
}
```

---

## 💰 Para (Currency) Kuralları - ÖNEMLİ!

### ⚠️ Database: CENTS (kuruş)

```prisma
model Order {
  total     Int  // 10000 = 100.00 TL
  collected Int  // 4000 = 40.00 TL
}
```

### ✅ Display: TL (Lira)

```typescript
// ✅ DOĞRU: fmtTRY içinde /100 yapılır
<td>{fmtTRY(order.total)}</td>        // "₺100"
<td>{fmtTRY(order.collected)}</td>    // "₺40"

// ❌ YANLIŞ: Çifte bölme!
<td>{fmtTRY(order.total / 100)}</td>  // YAPMA!
```

### 📝 fmtTRY Fonksiyonu

```typescript
/**
 * ⚠️ ÖNEMLİ: Bu fonksiyon CENTS alır, TL döner
 * @param cents - Kuruş cinsinden (örn: 10000 = ₺100)
 * @returns Formatlanmış string (örn: "₺100")
 */
export const fmtTRY = (cents: number) =>
  new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency: 'TRY',
    maximumFractionDigits: 0
  }).format(cents / 100)  // ← /100 BURADA
```

---

## 🎯 Yeni Feature Ekleme Adımları

### Örnek: "Product" Modülü Ekle

#### 1. Domain Entity Oluştur
```bash
Dosya: packages/core/src/entities/Product.ts
```
```typescript
import type { ID, Currency } from '../types/common'

export interface Product {
  id: ID
  name: string
  description?: string
  price: Currency  // cents
  stock: number
  createdAt: string
}
```

#### 2. Validation Schema Ekle
```bash
Dosya: packages/core/src/validation/product.schema.ts
```
```typescript
import { z } from 'zod'

export const ProductSchema = z.object({
  id: z.string(),
  name: z.string().min(1),
  description: z.string().optional(),
  price: z.number().positive(),
  stock: z.number().int().nonnegative(),
  createdAt: z.string()
})
```

#### 3. Prisma Model Ekle
```bash
Dosya: backend/api/prisma/schema.prisma
```
```prisma
model Product {
  id          String   @id @default(cuid())
  name        String
  description String?
  price       Int      // cents
  stock       Int
  createdAt   DateTime @default(now())
}
```

#### 4. Migration Çalıştır
```bash
cd backend/api
npx prisma migrate dev --name add_products
```

#### 5. NestJS Module Oluştur
```bash
Klasör: backend/api/src/modules/products/
```

**products.module.ts:**
```typescript
import { Module } from '@nestjs/common'
import { ProductsController } from './products.controller'
import { ProductsService } from './products.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [ProductsController],
  providers: [ProductsService, PrismaService]
})
export class ProductsModule {}
```

**products.service.ts:**
```typescript
import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}
  
  async findAll() {
    return this.prisma.product.findMany()
  }
}
```

**products.controller.ts:**
```typescript
import { Controller, Get, Post, Body } from '@nestjs/common'
import { ApiTags, ApiOperation } from '@nestjs/swagger'
import { ProductsService } from './products.service'

@ApiTags('products')
@Controller('products')
export class ProductsController {
  constructor(private readonly service: ProductsService) {}
  
  @Get()
  @ApiOperation({ summary: 'Get all products' })
  findAll() {
    return this.service.findAll()
  }
}
```

**dto.ts:**
```typescript
import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, Min } from 'class-validator'

export class CreateProductDto {
  @ApiProperty()
  @IsString()
  name: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  description?: string

  @ApiProperty()
  @IsNumber()
  @Min(0)
  price: number

  @ApiProperty()
  @IsNumber()
  @Min(0)
  stock: number
}
```

#### 6. AppModule'e Ekle
```typescript
// backend/api/src/app.module.ts
import { ProductsModule } from './modules/products/products.module'

@Module({
  imports: [
    HealthModule,
    CustomersModule,
    OrdersModule,
    RentalsModule,
    ProductsModule  // ← EKLE
  ],
  // ...
})
```

#### 7. Frontend API Integration
```typescript
// frontend/web/src/lib/api.ts
export const getProducts = () => api.get('/products')
export const createProduct = (data: any) => api.post('/products', data)
```

---

## 🚫 Antipatterns (Bunları YAPMA!)

### ❌ Business Logic'i UI'da
```typescript
// ❌ YANLIŞ
function CustomerCard({ customer }) {
  const balance = customer.total - customer.collected  // Business logic UI'da!
  return <div>{balance}</div>
}

// ✅ DOĞRU
import { calcBalance } from '@core/utils/money'
function CustomerCard({ customer }) {
  return <div>{fmtTRY(calcBalance(customer.total, customer.collected))}</div>
}
```

### ❌ any Type Kullanımı
```typescript
// ❌ YANLIŞ
const data: any = await api.get('/customers')

// ✅ DOĞRU
import type { Customer } from '@shared'
const data: Customer[] = await api.get('/customers')
```

### ❌ Validation Atlamak
```typescript
// ❌ YANLIŞ
await prisma.customer.create({ data: formData })  // Validation yok!

// ✅ DOĞRU
const validated = CustomerSchema.parse(formData)  // Zod validation
await prisma.customer.create({ data: validated })
```

### ❌ Para Formatında Manuel /100
```typescript
// ❌ YANLIŞ
<td>{fmtTRY(order.total / 100)}</td>  // fmtTRY zaten /100 yapıyor!

// ✅ DOĞRU
<td>{fmtTRY(order.total)}</td>        // Utility halledecek
```

---

## ✅ Best Practices

### ✅ Import Order
```typescript
// 1. React/External
import React from 'react'
import { useEffect, useState } from 'react'

// 2. Shared packages
import { Customer, TEXT } from '@shared'
import { fmtTRY } from '@core/utils/money'

// 3. Local @ alias
import { api } from '@/lib/api'
import { PageShell } from '@/components/PageShell'

// 4. Relative (sadece yakın dosyalar için)
import { MyLocalHelper } from './helpers'
```

### ✅ Type Annotations
```typescript
// ✅ Her zaman type belirt
const customer: Customer = { ... }
const orders: Order[] = await getOrders()
const price: Currency = 10000

// ❌ Type belirtme
const customer = { ... }  // any olur
```

### ✅ Error Handling
```typescript
// Backend
async findOne(id: string) {
  const customer = await this.prisma.customer.findUnique({ where: { id } })
  if (!customer) {
    throw new NotFoundException(`Customer #${id} not found`)
  }
  return customer
}

// Frontend
try {
  const customer = await api.get(`/customers/${id}`)
} catch (error) {
  console.error('Failed to load customer:', error)
  // Show toast/notification
}
```

---

## 🔄 Workflow

### Yeni Backend Endpoint

1. Service method yaz (`*.service.ts`)
2. Controller endpoint yaz (`*.controller.ts`)
3. DTO ekle (`dto.ts`)
4. Swagger decorators ekle (`@ApiOperation`, `@ApiResponse`)
5. Test et: http://localhost:3000/docs

### Yeni Frontend Component

1. Component oluştur (`components/{Name}.tsx`)
2. @shared'den types import et
3. @core/utils'den utility kullan
4. @ alias ile local import yap
5. Test et: http://localhost:5173

### Database Schema Değişikliği

1. `schema.prisma` güncelle
2. `npx prisma migrate dev --name change_description`
3. `pnpm prisma:gen` (Prisma client)
4. Service/Controller güncelle
5. DTO güncelle

---

## 🎨 UI Component Pattern

```typescript
// ✅ Tip-safe, utility kullanan, temiz component
import React from 'react'
import type { Order } from '@shared'
import { fmtTRY, calcBalance } from '@core/utils/money'
import { TEXT } from '@shared'

interface OrderCardProps {
  order: Order
}

export function OrderCard({ order }: OrderCardProps) {
  const balance = calcBalance(order.total, order.collected)
  
  return (
    <div className="border rounded p-4">
      <h3>{TEXT.tr.table.customer}</h3>
      <p>{TEXT.tr.table.total}: {fmtTRY(order.total)}</p>
      <p>{TEXT.tr.table.collected}: {fmtTRY(order.collected)}</p>
      <p>{TEXT.tr.table.balance}: {fmtTRY(balance)}</p>
    </div>
  )
}
```

---

## 🗄️ Database Patterns

### Para Tutarları (Currency)

```typescript
// Backend: Save in CENTS
const order = await prisma.order.create({
  data: {
    total: 10000,      // 100.00 TL
    collected: 4000    // 40.00 TL
  }
})

// Frontend: Display with fmtTRY
<span>{fmtTRY(order.total)}</span>  // "₺100"
```

### Tarih Formatları

```typescript
// Backend: DateTime
deliveryDate: new Date('2025-10-15')

// Frontend: ISO string
deliveryDate: '2025-10-15'

// Display
import { iso } from '@core/utils/date'
const dateStr = iso(new Date())  // "2025-10-11"
```

### ID Generation

```typescript
// Prisma auto-generates
@id @default(cuid())

// Manual generation (if needed)
import { uid } from '@core/utils/id'
const id = uid('product_')  // "product_abc123"
```

---

## 🌍 i18n Pattern

### Yeni Çeviri Ekle

```typescript
// 1. packages/core/src/i18n/tr.ts
export default {
  products: {
    title: 'Ürünler',
    add: 'Yeni Ürün',
    edit: 'Düzenle',
    delete: 'Sil'
  }
}

// 2. packages/core/src/i18n/en.ts
export default {
  products: {
    title: 'Products',
    add: 'New Product',
    edit: 'Edit',
    delete: 'Delete'
  }
}

// 3. Kullanım
import { TEXT } from '@shared'
const title = TEXT.tr.products.title  // "Ürünler"
```

---

## 🧪 Testing Pattern (Gelecek)

### Backend Test
```typescript
// backend/api/src/modules/customers/customers.service.spec.ts
describe('CustomersService', () => {
  it('should find all customers', async () => {
    const customers = await service.findAll()
    expect(customers).toBeDefined()
  })
})
```

### Frontend Test
```typescript
// frontend/web/src/components/__tests__/CustomerCard.test.tsx
import { render, screen } from '@testing-library/react'
import { CustomerCard } from '../CustomerCard'

test('renders customer name', () => {
  const customer = { id: '1', name: 'John' }
  render(<CustomerCard customer={customer} />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

---

## 🔌 API Integration Pattern

```typescript
// frontend/web/src/lib/api.ts
import axios from 'axios'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000'
})

// Customers
export const getCustomers = () => api.get<Customer[]>('/customers')
export const getCustomer = (id: string) => api.get<Customer>(`/customers/${id}`)
export const createCustomer = (data: CreateCustomerDto) => 
  api.post<Customer>('/customers', data)

// Orders
export const getOrders = () => api.get<Order[]>('/orders')
export const createOrder = (data: CreateOrderDto) => 
  api.post<Order>('/orders', data)
```

---

## 📚 Cursor'a Sorulabilecek Sorular

### Yeni Özellik
```
"Customer modülüne benzer şekilde Product modülü ekle.
Backend'de CRUD endpoints, frontend'de ProductCard component oluştur.
Para tutarını cents olarak sakla, fmtTRY ile göster."
```

### Hata Düzeltme
```
"CustomerCard component'inde para formatı yanlış görünüyor.
fmtTRY fonksiyonu zaten /100 yapıyor, çifte bölme yapılmamalı."
```

### Refactoring
```
"OrdersService içindeki business logic'i ayrı bir domain service'e taşı.
packages/core/src/services/ klasörü oluştur."
```

### Validation
```
"CreateOrderDto'ya deliveryDate validation ekle.
Tarih gelecekte olmalı, bugünden önce olamaz."
```

---

## 🎯 Önemli Notlar

### 1. Path Aliases

```typescript
@         → frontend/web/src/
@core     → packages/core/src/
@shared   → packages/shared/src/
```

### 2. Import Stratejisi

```typescript
// Frontend → @shared kullan (core'dan değil!)
import { Customer } from '@shared'  // ✅
import { Customer } from '@core/entities/Customer'  // ❌

// Backend → @core kullanılabilir
import { Customer } from '@core/entities/Customer'  // ✅
```

### 3. Validation Stratejisi

**İki Katmanlı:**
- Frontend: Zod (`@shared` validation schemas)
- Backend: class-validator (DTOs) + ValidationPipe

### 4. Database Operations

```typescript
// ✅ Service layer'da yap
class CustomersService {
  async findAll() {
    return this.prisma.customer.findMany()
  }
}

// ❌ Controller'da yapma
@Get()
findAll() {
  return this.prisma.customer.findMany()  // ❌ Controller'da Prisma!
}
```

---

## 📖 Referans Dosyalar

| Dosya | Amaç | Satır |
|-------|------|-------|
| **COMPLETE_GUIDE.md** | Ana rehber | 2400+ |
| **CRITICAL_FIXES.md** | Kritik düzeltmeler | 200+ |
| **ALL_CHANGES_SUMMARY.md** | Tek sayfa özet | 400+ |
| **.cursorrules** | Cursor kuralları | - |

---

## 🚀 Hızlı Komutlar

```bash
# Development
pnpm dev:api       # Backend (http://localhost:3000)
pnpm dev:web       # Frontend (http://localhost:5173)
pnpm dev:mobile    # Mobile

# Database
pnpm prisma:gen
pnpm prisma:migrate
pnpm prisma:seed

# Build
pnpm build

# Codegen
pnpm codegen
```

---

## 🎊 Özet

**Cursor'a kod ürettirirken:**

1. ✅ Bu dosyayı referans olarak kullan
2. ✅ Clean Core Architecture'a uy
3. ✅ DDD prensiplerine dikkat et
4. ✅ Type-safe kod yaz
5. ✅ Para formatını doğru kullan (fmtTRY)
6. ✅ Validation'ı unutma
7. ✅ Path aliases kullan

**Bu kurallar projenin tutarlılığını korur! 🎯**

---

**📍 Bu dosyanın konumu:** `.cursorrules` (Cursor otomatik okur)  
**📍 Detaylı rehber:** `COMPLETE_GUIDE.md` (2400+ satır)

---

## 🆕 YENİ MODELLER ve MİMARİ (2025-10-12 Güncellemesi)

### 1. Product Model (Eklendi)
```typescript
// packages/core/src/entities/Product.ts
interface Product {
  id: ID
  name: string
  model?: string
  color?: string
  size?: string
  category?: string
  tags: string  // Comma-separated
  status: 'AVAILABLE' | 'IN_USE' | 'MAINTENANCE'
  createdAt: string
}

// Backend: modules/products/ (GET, POST, PUT, DELETE /products)
```

### 2. AgendaEvent Model (Eklendi)
```typescript
// packages/core/src/entities/AgendaEvent.ts
interface AgendaEvent {
  id: ID
  productId: ID
  type: 'DRY_CLEANING' | 'ALTERATION' | 'OUT_OF_SERVICE'
  start: string
  end: string
  note?: string
  createdAt: string
}

// Backend: modules/agenda-events/
// ⚠️ SADECE Takvim sekmesinde görünür, Siparişler'e düşmez!
```

### 3. Order/Rental İlişkisi Güncellendi
```typescript
// Order → stage eklendi, rental 1-to-1
interface Order {
  // ... mevcut
  stage?: string  // 'CREATED', 'IN_PROGRESS_50', 'BOOKED', vb.
  rental?: Rental  // 1-to-1 relation
}

// Rental → Order'a bağlı (finans Order'da)
interface Rental {
  id: ID
  orderId: ID      // Order'a 1-1 bağlı
  productId: ID    // Hangi ürün
  period: DateRange
  organization?: string
  // total, collected, status → Order'da
}
```

### 4. Yeni API Endpoints
```
GET  /transactions              # Siparişler sekmesi (Order + Rental JOIN)
GET  /transactions/summary      # Chip sayaçları
PATCH /rentals/:id/period       # Kiralama taşıma (total yeniden hesaplanır)
PATCH /agenda-events/:id/period # Ajanda taşıma
```

### 5. Frontend: SalesRentalsPage (2 Sekme Yapısı)
```typescript
// pages/SalesRentalsPage.tsx
// Tab 1: 🧵 Siparişler → OrdersView (filtreler + tablo)
// Tab 2: 📆 Kiralama Takvimi → RentalsCalendarView (tool palette + timeline)

// Header: Tab buttons + Chip counters (Dikim: X | Kiralama: Y)
```

### 6. Kritik Senkronizasyon Kuralları
```typescript
// Kiralama işlemleri → 2 ekran güncellenir
onSuccess: () => {
  invalidateQueries(['transactions'])      // Siparişler
  invalidateQueries(['rentals-calendar'])  // Takvim
}

// Ajanda işlemleri → 1 ekran güncellenir
onSuccess: () => {
  invalidateQueries(['agenda-calendar'])   // Sadece Takvim
  // ❌ transactions invalidate EDİLMEZ!
}
```

### 7. OrderType Değişti
```typescript
// ÖNCE: type: 'SALE' | 'RENTAL'
// SONRA: type: 'TAILORING' | 'RENTAL'
```

### 8. Veri Tekil, Görünüm Çoklu
- Tek `Order` kaydı → Hem Siparişler hem Takvim'de görünür (kiralama ise)
- `AgendaEvent` → Sadece Takvim'de görünür
- Finans → Order tablosunda (merkezi)

---

**Başarılı geliştirmeler! 💪**

