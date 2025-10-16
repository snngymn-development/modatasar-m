# 🎯 Yeni Feature Modülü - Template

> Bu template'i kullanarak yeni modül ekleyebilirsin.  
> **Copy-paste yaparak** veya **Cursor'a göstererek** kullan.

---

## 🔧 HIZLI KULLANIM

### Cursor'a Şöyle Söyle:

```
"FEATURE_TEMPLATE.md dosyasını kullanarak Product modülü oluştur.
Tüm {{Feature}} ve {{feature}} değişkenlerini 'Product' ve 'product' ile değiştir."
```

### Manuel Kullanım:

1. **{{Feature}}** → `Product` (PascalCase)
2. **{{feature}}** → `product` (kebab-case/camelCase)
3. **{{Features}}** → `Products` (çoğul)
4. **{{features}}** → `products` (çoğul)

---

## 📁 1. DOMAIN LAYER (packages/core)

### 1.1. Entity

**Dosya:** `packages/core/src/entities/{{Feature}}.ts`

```typescript
import type { ID, Currency } from '../types/common'

/**
 * {{Feature}} domain entity
 */
export interface {{Feature}} {
  id: ID
  name: string
  description?: string
  price?: Currency     // cents (opsiyonel)
  createdAt: string    // ISO date
}
```

### 1.2. Validation Schema

**Dosya:** `packages/core/src/validation/{{feature}}.schema.ts`

```typescript
import { z } from 'zod'

export const {{Feature}}Schema = z.object({
  id: z.string(),
  name: z.string().min(1, 'Name is required'),
  description: z.string().optional(),
  price: z.number().int().nonnegative().optional(),
  createdAt: z.string()
})

export type {{Feature}}Input = z.infer<typeof {{Feature}}Schema>
```

### 1.3. Validation Index Export

**Dosya:** `packages/core/src/validation/index.ts`

```typescript
// Mevcut exports...
export * from './{{feature}}.schema'  // ← EKLE
```

### 1.4. Shared Export

**Dosya:** `packages/shared/src/index.ts`

```typescript
// Mevcut exports...
export * from '@core/entities/{{Feature}}'
export * from '@core/validation/{{feature}}.schema'  // ← EKLE
```

**Build:**
```bash
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build
```

---

## 💾 2. DATABASE LAYER (Prisma)

### 2.1. Prisma Model

**Dosya:** `backend/api/prisma/schema.prisma`

```prisma
model {{Feature}} {
  id          String   @id @default(cuid())
  name        String
  description String?
  price       Int?     // cents
  createdAt   DateTime @default(now())
}
```

### 2.2. Migration

```bash
cd backend/api
npx prisma migrate dev --name add_{{features}}
npx prisma generate
```

---

## 🔙 3. BACKEND LAYER (NestJS)

### Klasör: `backend/api/src/modules/{{features}}/`

### 3.1. Module

**Dosya:** `{{features}}.module.ts`

```typescript
import { Module } from '@nestjs/common'
import { {{Features}}Controller } from './{{features}}.controller'
import { {{Features}}Service } from './{{features}}.service'
import { PrismaService } from '../../common/prisma.service'

@Module({
  controllers: [{{Features}}Controller],
  providers: [{{Features}}Service, PrismaService]
})
export class {{Features}}Module {}
```

### 3.2. Service

**Dosya:** `{{features}}.service.ts`

```typescript
import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../common/prisma.service'
import { Create{{Feature}}Dto, Update{{Feature}}Dto } from './dto'

@Injectable()
export class {{Features}}Service {
  constructor(private prisma: PrismaService) {}

  create(dto: Create{{Feature}}Dto) {
    return this.prisma.{{feature}}.create({ data: dto })
  }

  findAll() {
    return this.prisma.{{feature}}.findMany()
  }

  async findOne(id: string) {
    const item = await this.prisma.{{feature}}.findUnique({ where: { id } })
    if (!item) {
      throw new NotFoundException(`{{Feature}} #${id} not found`)
    }
    return item
  }

  update(id: string, dto: Update{{Feature}}Dto) {
    return this.prisma.{{feature}}.update({ where: { id }, data: dto })
  }

  remove(id: string) {
    return this.prisma.{{feature}}.delete({ where: { id } })
  }
}
```

### 3.3. Controller

**Dosya:** `{{features}}.controller.ts`

```typescript
import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { {{Features}}Service } from './{{features}}.service'
import { Create{{Feature}}Dto, Update{{Feature}}Dto } from './dto'

@ApiTags('{{features}}')
@Controller('{{features}}')
export class {{Features}}Controller {
  constructor(private readonly service: {{Features}}Service) {}

  @Get()
  @ApiOperation({ summary: 'Get all {{features}}' })
  @ApiResponse({ status: 200, description: 'Return all {{features}}' })
  findAll() {
    return this.service.findAll()
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get {{feature}} by id' })
  @ApiResponse({ status: 200, description: 'Return {{feature}}' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: 'Create {{feature}}' })
  @ApiResponse({ status: 201, description: '{{Feature}} created' })
  create(@Body() dto: Create{{Feature}}Dto) {
    return this.service.create(dto)
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update {{feature}}' })
  @ApiResponse({ status: 200, description: '{{Feature}} updated' })
  update(@Param('id') id: string, @Body() dto: Update{{Feature}}Dto) {
    return this.service.update(id, dto)
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete {{feature}}' })
  @ApiResponse({ status: 200, description: '{{Feature}} deleted' })
  remove(@Param('id') id: string) {
    return this.service.remove(id)
  }
}
```

### 3.4. DTO

**Dosya:** `dto.ts`

```typescript
import { ApiProperty } from '@nestjs/swagger'
import { IsString, IsNumber, IsOptional, Min } from 'class-validator'

export class Create{{Feature}}Dto {
  @ApiProperty()
  @IsString()
  name: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  description?: string

  @ApiProperty({ required: false, description: 'Price in cents' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  price?: number
}

export class Update{{Feature}}Dto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  name?: string

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  description?: string

  @ApiProperty({ required: false, description: 'Price in cents' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  price?: number
}
```

### 3.5. AppModule

**Dosya:** `backend/api/src/app.module.ts`

```typescript
// Import ekle
import { {{Features}}Module } from './modules/{{features}}/{{features}}.module'

@Module({
  imports: [
    HealthModule,
    CustomersModule,
    OrdersModule,
    RentalsModule,
    {{Features}}Module  // ← EKLE
  ],
  providers: [PrismaService],
  exports: [PrismaService]
})
export class AppModule {}
```

---

## 🎨 4. FRONTEND WEB (React + Vite)

### Klasör: `frontend/web/src/components/{{Features}}/`

### 4.1. Table Component

**Dosya:** `{{Features}}Table.tsx`

```typescript
import React from 'react'
import { fmtTRY } from '@core/utils/money'
import type { {{Feature}} } from '@shared'

interface {{Features}}TableProps {
  rows: {{Feature}}[]
}

export function {{Features}}Table({ rows }: {{Features}}TableProps) {
  return (
    <table className="w-full bg-white border rounded-lg">
      <thead>
        <tr className="text-left">
          <th className="p-2">Name</th>
          <th className="p-2">Description</th>
          <th className="p-2">Price</th>
          <th className="p-2">Created</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id} className="border-t">
            <td className="p-2">{row.name}</td>
            <td className="p-2">{row.description || '-'}</td>
            <td className="p-2">{row.price != null ? fmtTRY(row.price) : '-'}</td>
            <td className="p-2">{new Date(row.createdAt).toLocaleDateString()}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

### 4.2. Form Component

**Dosya:** `{{Feature}}Form.tsx`

```typescript
import React, { useState } from 'react'
import { {{Feature}}Schema } from '@shared'

interface {{Feature}}FormProps {
  onSubmit: (data: any) => void
}

export function {{Feature}}Form({ onSubmit }: {{Feature}}FormProps) {
  const [form, setForm] = useState({
    name: '',
    description: '',
    price: 0
  })

  const handleSubmit = () => {
    const parsed = {{Feature}}Schema.safeParse({
      id: crypto.randomUUID(),
      name: form.name,
      description: form.description || undefined,
      price: form.price ? Number(form.price) : undefined,
      createdAt: new Date().toISOString()
    })

    if (!parsed.success) {
      alert('Validation failed: ' + parsed.error.errors[0].message)
      return
    }

    onSubmit(parsed.data)
  }

  return (
    <div className="mb-4 p-4 border rounded-lg">
      <input
        placeholder="Name"
        value={form.name}
        onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
        className="border rounded p-2 mr-2"
      />
      <input
        placeholder="Description"
        value={form.description}
        onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
        className="border rounded p-2 mr-2"
      />
      <input
        type="number"
        placeholder="Price (cents)"
        value={form.price}
        onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))}
        className="border rounded p-2 mr-2"
      />
      <button onClick={handleSubmit} className="border rounded p-2 bg-blue-500 text-white">
        Save
      </button>
    </div>
  )
}
```

### 4.3. Page Component

**Dosya:** `frontend/web/src/pages/{{Features}}Page.tsx`

```typescript
import React, { useEffect, useState } from 'react'
import { get{{Features}}, create{{Feature}} } from '@/lib/api'
import { {{Feature}}Form } from '@/components/{{Features}}/{{Feature}}Form'
import { {{Features}}Table } from '@/components/{{Features}}/{{Features}}Table'
import { PageShell } from '@/components/PageShell'
import type { {{Feature}} } from '@shared'

export default function {{Features}}Page() {
  const [rows, setRows] = useState<{{Feature}}[]>([])

  const loadData = async () => {
    const { data } = await get{{Features}}()
    setRows(data)
  }

  useEffect(() => {
    loadData()
  }, [])

  const handleCreate = async (payload: any) => {
    await create{{Feature}}(payload)
    await loadData()
  }

  return (
    <PageShell title="{{Features}}">
      <{{Feature}}Form onSubmit={handleCreate} />
      <{{Features}}Table rows={rows} />
    </PageShell>
  )
}
```

### 4.4. API Client

**Dosya:** `frontend/web/src/lib/api.ts`

```typescript
// Mevcut kod...

// {{Features}} API
export const get{{Features}} = () => api.get('/{{features}}')
export const get{{Feature}} = (id: string) => api.get(`/{{features}}/${id}`)
export const create{{Feature}} = (data: any) => api.post('/{{features}}', data)
export const update{{Feature}} = (id: string, data: any) => api.put(`/{{features}}/${id}`, data)
export const delete{{Feature}} = (id: string) => api.delete(`/{{features}}/${id}`)
```

---

## 📱 5. FRONTEND MOBILE (React Native)

### 5.1. API Client

**Dosya:** `frontend/mobile/src/api/{{features}}.ts`

```typescript
import axios from 'axios'

const baseURL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000'
const api = axios.create({ baseURL })

export const get{{Features}} = () => api.get('/{{features}}')
export const get{{Feature}} = (id: string) => api.get(`/{{features}}/${id}`)
export const create{{Feature}} = (data: any) => api.post('/{{features}}', data)
```

### 5.2. Screen

**Dosya:** `frontend/mobile/src/screens/{{Features}}Screen.tsx`

```typescript
import React, { useEffect, useState } from 'react'
import { View, Text, FlatList, StyleSheet } from 'react-native'
import { get{{Features}} } from '../api/{{features}}'

export default function {{Features}}Screen() {
  const [rows, setRows] = useState<any[]>([])

  useEffect(() => {
    get{{Features}}().then((response) => setRows(response.data))
  }, [])

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{{Features}}</Text>
      <FlatList
        data={rows}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.item}>
            <Text style={styles.itemName}>{item.name}</Text>
            <Text style={styles.itemDesc}>{item.description}</Text>
          </View>
        )}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: { padding: 16 },
  title: { fontSize: 18, fontWeight: '600', marginBottom: 8 },
  item: { paddingVertical: 8, borderBottomWidth: 1, borderColor: '#eee' },
  itemName: { fontSize: 16, fontWeight: '500' },
  itemDesc: { fontSize: 14, color: '#666' }
})
```

---

## 🌍 6. i18n (Opsiyonel)

### 6.1. Türkçe Çeviriler

**Dosya:** `packages/core/src/i18n/tr.ts`

```typescript
export default {
  // Mevcut...
  {{features}}: {
    title: '{{Features}}',
    add: 'Yeni {{Feature}} Ekle',
    edit: '{{Feature}} Düzenle',
    delete: '{{Feature}} Sil',
    name: 'Ad',
    description: 'Açıklama',
    price: 'Fiyat'
  }
}
```

### 6.2. İngilizce Çeviriler

**Dosya:** `packages/core/src/i18n/en.ts`

```typescript
export default {
  // Mevcut...
  {{features}}: {
    title: '{{Features}}',
    add: 'Add {{Feature}}',
    edit: 'Edit {{Feature}}',
    delete: 'Delete {{Feature}}',
    name: 'Name',
    description: 'Description',
    price: 'Price'
  }
}
```

---

## 🚀 7. KOMUT AKIŞI

### Adım Adım:

```bash
# 1. Core & Shared build
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build

# 2. Prisma migration
cd backend/api
npx prisma migrate dev --name add_{{features}}
npx prisma generate

# 3. Backend dev
pnpm dev:api
# → http://localhost:3000/docs (Swagger'da /{{features}} görünür)

# 4. Frontend dev
pnpm dev:web
# → http://localhost:5173
```

---

## ✅ ÖRNEK: Product Modülü

### Değişken Değerleri:

- **{{Feature}}** → `Product`
- **{{feature}}** → `product`
- **{{Features}}** → `Products`
- **{{features}}** → `products`

### Oluşturulacak Dosyalar:

```
✅ packages/core/src/entities/Product.ts
✅ packages/core/src/validation/product.schema.ts
✅ packages/core/src/validation/index.ts (export ekle)
✅ packages/shared/src/index.ts (export ekle)
✅ backend/api/prisma/schema.prisma (model Product)
✅ backend/api/src/modules/products/products.module.ts
✅ backend/api/src/modules/products/products.service.ts
✅ backend/api/src/modules/products/products.controller.ts
✅ backend/api/src/modules/products/dto.ts
✅ backend/api/src/app.module.ts (ProductsModule import)
✅ frontend/web/src/components/Products/ProductsTable.tsx
✅ frontend/web/src/components/Products/ProductForm.tsx
✅ frontend/web/src/pages/ProductsPage.tsx
✅ frontend/web/src/lib/api.ts (products API functions)
✅ frontend/mobile/src/api/products.ts
✅ frontend/mobile/src/screens/ProductsScreen.tsx
```

**Toplam:** ~16 dosya oluşturulur/güncellenir

---

## 🤖 CURSOR İLE KULLANIM

### Yöntem 1: Doğrudan Prompt

```
"FEATURE_TEMPLATE.md dosyasını kullanarak Product modülü oluştur.
Tüm {{Feature}} yerine Product, {{feature}} yerine product yaz.
Dosyaları tam olarak template'teki gibi oluştur."
```

### Yöntem 2: Bölüm Bölüm

```
"FEATURE_TEMPLATE.md Bölüm 1'i kullanarak Product entity ve validation oluştur."
"FEATURE_TEMPLATE.md Bölüm 3'ü kullanarak NestJS module oluştur."
"FEATURE_TEMPLATE.md Bölüm 4'ü kullanarak React components oluştur."
```

### Yöntem 3: Manuel Copy-Paste

1. Template'i aç
2. Find & Replace: `{{Feature}}` → `Product`
3. Dosyaları oluştur
4. Build & test

---

## ⚠️ ÖNEMLİ NOTLAR

### Para Birimi (Currency)

```typescript
// ✅ DOĞRU: Database'de cents
price: 10000  // 100.00 TL

// ✅ DOĞRU: Frontend'de fmtTRY kullan
<td>{fmtTRY(product.price)}</td>  // "₺100"

// ❌ YANLIŞ: Çifte bölme yapma
<td>{fmtTRY(product.price / 100)}</td>  // fmtTRY zaten /100 yapıyor!
```

### Validation

```typescript
// ✅ Frontend: Zod
import { ProductSchema } from '@shared'
const result = ProductSchema.safeParse(formData)

// ✅ Backend: class-validator (automatic via ValidationPipe)
export class CreateProductDto {
  @IsString()
  name: string
}
```

### Path Aliases

```typescript
// ✅ Frontend
import { api } from '@/lib/api'
import { ProductCard } from '@/components/Products/ProductCard'
import { Product } from '@shared'
import { fmtTRY } from '@core/utils/money'

// ✅ Backend
import { PrismaService } from '../../common/prisma.service'
import { Product } from '@core/entities/Product'
```

---

## 🔄 SEÇENEK 2'YE (Tam CLI) GEÇİŞ

### İleride otomatik CLI sistemi istersen:

**Ne Yapılacak:**

1. **Handlebars ekle:**
```bash
pnpm add -D handlebars
```

2. **scaffold.mjs oluştur:**
```bash
# 300+ satır script
# Template'leri Handlebars ile compile eder
```

3. **Script ekle:**
```json
{
  "scripts": {
    "scaffold": "node scripts/scaffold.mjs"
  }
}
```

4. **Kullan:**
```bash
pnpm scaffold Product
# → Tüm dosyalar otomatik oluşur!
```

**Geçiş Kolaylığı:**
- ✅ Bu template'teki pattern'ler aynı
- ✅ Hiçbir kod değişmez
- ✅ Sadece otomasyon eklenir
- ✅ 1 saatte geçiş yapılır

**Ne Zaman Geç:**
- Proje büyüdüğünde (10+ modül)
- Sık feature ekliyorsan
- Ekip büyüdüğünde
- Consistency çok önemliyse

---

## 📝 CHECKLIST

Yeni modül eklerken kontrol et:

- [ ] ✅ Domain entity oluşturuldu
- [ ] ✅ Validation schema eklendi
- [ ] ✅ Validation index'e export edildi
- [ ] ✅ Shared'a export edildi
- [ ] ✅ Prisma model eklendi
- [ ] ✅ Migration çalıştırıldı
- [ ] ✅ NestJS module oluşturuldu (4 dosya)
- [ ] ✅ AppModule'e import edildi
- [ ] ✅ Frontend components oluşturuldu
- [ ] ✅ Frontend page oluşturuldu
- [ ] ✅ API client fonksiyonları eklendi
- [ ] ✅ Mobile API client oluşturuldu
- [ ] ✅ Mobile screen oluşturuldu
- [ ] ✅ i18n çevirileri eklendi
- [ ] ✅ Core & Shared build yapıldı
- [ ] ✅ Backend test edildi (Swagger)
- [ ] ✅ Frontend test edildi (Browser)

---

## 🎉 BAŞARIYLA TAMAMLA!

Template kullanarak tutarlı modüller oluşturabilirsin.

**Hatırla:**
- Para: cents (DB) → fmtTRY(cents) → "₺X" (Display)
- Validation: Zod (shared) + class-validator (backend)
- Paths: @, @core, @shared aliases kullan

**İyi geliştirmeler! 🚀**

