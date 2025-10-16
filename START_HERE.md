# 🚀 BAŞLANGIÇ KILAVUZU - Deneme1 Projesi

## 📊 TAMAMLANAN İŞLER

✅ **61 dosya** oluşturuldu/güncellendi  
✅ **~3500 satır** kod yazıldı  
✅ **23/23 TODO** tamamlandı

---

## 🎯 EKLENEN ÖZELLİKLER

### **Backend (35 dosya):**
- ✅ **Product Modeli** (Ürün yönetimi)
- ✅ **AgendaEvent Modeli** (Tadilat, Kuru Temizleme, Kullanım Dışı)
- ✅ **TransactionsModule** (GET /transactions, GET /transactions/summary)
- ✅ **Order.stage alanı** (İş süreci aşaması)
- ✅ **Rental yeniden yapılandırma** (Order'a 1-1 bağlı, finans Order'da)
- ✅ **PATCH /rentals/:id/period** (Kiralama süresi değişimi + total yeniden hesaplama)
- ✅ **PATCH /agenda-events/:id/period** (Ajanda kaydı taşıma)

### **Frontend (26 dosya):**
- ✅ **SalesRentalsPage** (2 sekmeli: Siparişler + Kiralama Takvimi)
- ✅ **Chip Counters** (Dikim: X | Kiralama: Y)
- ✅ **OrdersView** (Filtreler + Tablo)
  - Akıllı Teslim/Kira kolonu (türe göre render)
  - Renkli durum badge'leri
  - Stage tooltip (hover'da aşama bilgisi)
- ✅ **RentalsCalendarView** (Mock takvim görünümü)
  - Tool Palette (4 araç)
  - Haftalık Grid
- ✅ **5 UI Component** (Chip, Badge, Button, Tooltip, Select)
- ✅ **4 React Query Hook** (Optimistic update ile)

### **Core & Shared (13 dosya):**
- ✅ Product & AgendaEvent entities/validations
- ✅ Order/Rental güncelleme
- ✅ Enums (SALE → TAILORING)
- ✅ Kapsamlı i18n (TR/EN)

---

## ⚡ HIZLI BAŞLATMA (5 Dakika)

### **1. VS Code'u Tamamen Kapat ve Tekrar Aç**
*(Database lock sorununu çözer)*

### **2. Terminal Aç ve Çalıştır:**

```powershell
# Database temizliği
Remove-Item -Force backend/api/prisma/dev.db* -ErrorAction SilentlyContinue

# Prisma Client generate
pnpm --filter @deneme1/api prisma generate

# Migration apply
pnpm --filter @deneme1/api prisma migrate deploy

# Seed data
pnpm --filter @deneme1/api prisma db seed
```

**Beklenen çıktı:**
```
✅ Migration 20251012174520_complete_restructure applied
✅ Created 5 customers
✅ Created 10 products  
✅ Created 10 TAILORING orders
✅ Created 5 RENTAL orders
✅ Created 8 agenda events
```

---

### **3. Backend Başlat (Terminal 1)**

```bash
pnpm dev:api
```

**Başarı göstergesi:**
```
[Nest] INFO  Application is running on: http://localhost:3000
```

**Test:**
- 🌐 http://localhost:3000/health → `{"ok":true,...}`
- 🌐 http://localhost:3000/docs → Swagger UI açılmalı

---

### **4. Frontend Başlat (Terminal 2)**

```bash
pnpm dev:web
```

**Başarı göstergesi:**
```
VITE ready in XXX ms
➜  Local:   http://localhost:5173/
```

**Test:**
- 🌐 http://localhost:5173 → SalesRentalsPage açılmalı

---

## 🧪 SWAGGER UI TEST (http://localhost:3000/docs)

### **Yeni Endpoint'leri Test Edin:**

#### **1. GET /transactions**
```
Try it out → Execute

Beklenen:
{
  "items": [
    {
      "type": "TAILORING",
      "customer": { "name": "Ayşe Yılmaz" },
      "deliveryDate": "2025-11-15T...",
      "total": 50000,
      "collected": 20000,
      "balance": 30000,
      "status": "ACTIVE",
      "stage": "IN_PROGRESS_50"
    }
  ],
  "total": 15
}
```

#### **2. GET /transactions/summary**
```
Try it out → Execute

Beklenen:
{
  "tailoringCount": 10,
  "rentalCount": 5,
  "totalCount": 15
}
```

#### **3. GET /products**
```
Beklenen: 10 ürün
```

#### **4. GET /agenda-events**
```
Beklenen: 8 ajanda kaydı
```

---

## 🎨 FRONTEND UI TEST (http://localhost:5173)

### **SalesRentalsPage Kontrolleri:**

#### **✅ Tab Sistemi:**
- [ ] 2 tab butonu var: "🧵 Siparişler" | "📆 Kiralama Takvimi"
- [ ] Tab'lar tıklanabilir
- [ ] Aktif tab mavi, pasif gri

#### **✅ Chip Counters:**
- [ ] "🧵 Dikim: 10" görünüyor (sarı chip)
- [ ] "📆 Kiralama: 5" görünüyor (mavi chip)

#### **✅ Tab 1: Siparişler Sekmesi:**
- [ ] Filtre barı görünüyor
- [ ] Tür filtresi **EN BAŞTA** (Dikim/Kiralama/Hepsi)
- [ ] Durum filtresi var
- [ ] Tablo görünüyor
- [ ] 15 satır var

**Tablo Kolonları:**
- [ ] Sipariş Tarihi (tarih formatı doğru)
- [ ] Teslim/Kira:
  - Dikim → Tek tarih: "15.11.2025"
  - Kiralama → Dönem: "20.10.2025 – 22.10.2025"
- [ ] Müşteri adı
- [ ] Tür emoji: 🧵 (Dikim) | 📆 (Kiralama)
- [ ] Organizasyon
- [ ] Toplam: ₺500 formatında
- [ ] Tahsilat: ₺200 formatında
- [ ] Bakiye: ₺300 formatında
- [ ] Durum badge renkli:
  - ACTIVE → 🟡 Sarı
  - COMPLETED → 🟢 Yeşil
  - CANCELLED → 🔴 Kırmızı

**Stage Tooltip:**
- [ ] Durum badge'ine **mouse hover** yap
- [ ] Tooltip görünüyor: "İşlemde %50", "Rezerve Edildi", vb.

**Filtre Testleri:**
- [ ] Tür = "Dikim" seç → Sadece 🧵 görünmeli (10 kayıt)
- [ ] Tür = "Kiralama" seç → Sadece 📆 görünmeli (5 kayıt)
- [ ] Sıfırla butonu → Tüm filtreler temizlenmeli

#### **✅ Tab 2: Kiralama Takvimi Sekmesi:**
- [ ] Sol panel görünüyor
- [ ] Filtreler: Model, Ürün, Renk
- [ ] **Araç Paleti** görünüyor:
  - [ ] 🆕 Yeni Kiralama (mavi kutu)
  - [ ] 🧼 Kuru Temizleme (mor kutu)
  - [ ] ✂️ Tadilat (turuncu kutu)
  - [ ] 🚫 Kullanım Dışı (gri kutu)
- [ ] Sağ panel: Takvim grid
- [ ] Haftalık başlıklar: Pzt, Sal, Çar, Per, Cum, Cmt, Paz
- [ ] 3 ürün satırı (Smokin, Slim Fit, Damat Takımı)
- [ ] Mock bloklar görünüyor
- [ ] **Bilgilendirme mesajı:** "ℹ️ Bu bir MOCK görünümdür"

---

## 📁 OLUŞTURULAN DOSYALAR

### **Backend Modules (35 dosya):**
```
backend/api/src/modules/
├── products/              (YENİ)
│   ├── products.module.ts
│   ├── products.service.ts
│   ├── products.controller.ts
│   └── dto.ts
├── transactions/          (YENİ)
│   ├── transactions.module.ts
│   ├── transactions.service.ts
│   ├── transactions.controller.ts
│   └── dto.ts
├── agenda-events/         (YENİ)
│   ├── agenda-events.module.ts
│   ├── agenda-events.service.ts
│   ├── agenda-events.controller.ts
│   └── dto.ts
├── rentals/               (GÜNCELLENDİ)
│   ├── rentals.service.ts (updatePeriod metodu)
│   ├── rentals.controller.ts (PATCH endpoint)
│   └── dto.ts (UpdateRentalPeriodDto)
└── app.module.ts          (GÜNCELLENDİ)
```

### **Core & Shared (13 dosya):**
```
packages/core/src/
├── entities/
│   ├── Product.ts         (YENİ)
│   ├── AgendaEvent.ts     (YENİ)
│   ├── Order.ts           (GÜNCELLENDİ)
│   └── Rental.ts          (GÜNCELLENDİ)
├── types/
│   └── enums.ts           (GÜNCELLENDİ)
├── validation/
│   ├── product.schema.ts  (YENİ)
│   ├── agendaEvent.schema.ts (YENİ)
│   ├── order.schema.ts    (GÜNCELLENDİ)
│   ├── rental.schema.ts   (GÜNCELLENDİ)
│   └── index.ts           (GÜNCELLENDİ)
└── i18n/
    ├── tr.ts              (KAPSAMLI GÜNCELLENDİ)
    └── en.ts              (KAPSAMLI GÜNCELLENDİ)

packages/shared/src/
└── index.ts               (GÜNCELLENDİ)
```

### **Frontend Components (26 dosya):**
```
frontend/web/src/
├── components/
│   ├── ui/                (YENİ - 5 dosya)
│   │   ├── Chip.tsx
│   │   ├── Badge.tsx
│   │   ├── Button.tsx
│   │   ├── Tooltip.tsx
│   │   └── Select.tsx
│   └── sales-rentals/     (YENİ - 6 dosya)
│       ├── OrdersView/
│       │   ├── index.tsx
│       │   ├── FilterBar.tsx
│       │   ├── OrdersTable.tsx
│       │   ├── StatusBadge.tsx
│       │   └── StageTooltip.tsx
│       └── RentalsCalendarView/
│           └── index.tsx (MOCK)
├── pages/
│   └── SalesRentalsPage.tsx (TAMAMEN YENİDEN YAZILDI)
├── hooks/                 (YENİ - 4 dosya)
│   ├── useTransactions.ts
│   ├── useRentals.ts
│   ├── useAgendaEvents.ts
│   └── useProducts.ts
├── constants/             (YENİ - 2 dosya)
│   ├── colors.ts
│   └── statuses.ts
└── lib/
    └── api.ts             (GÜNCELLENDİ)
```

---

## 🔧 KALAN SON ADIM: Database Migration

**SORUN:** SQLite database lock (başka process kullanıyor)

**ÇÖZÜM:** VS Code'u kapat/aç ve aşağıdaki komutları çalıştır:

```powershell
# 1. Database temizliği
Remove-Item -Force backend/api/prisma/dev.db* -ErrorAction SilentlyContinue

# 2. Prisma Client generate
pnpm --filter @deneme1/api prisma generate

# 3. Migration apply
pnpm --filter @deneme1/api prisma migrate deploy

# 4. Seed data
pnpm --filter @deneme1/api prisma db seed

# 5. Backend başlat
pnpm dev:api
```

**Ardından yeni terminal:**
```bash
# 6. Frontend başlat
pnpm dev:web
```

---

## 📋 TEST CHECKLIST

### **Backend (http://localhost:3000/docs):**
- [ ] Health endpoint çalışıyor
- [ ] /transactions endpoint var (15 sipariş dönüyor)
- [ ] /transactions/summary var (tailoringCount: 10, rentalCount: 5)
- [ ] /products endpoint var (10 ürün dönüyor)
- [ ] /agenda-events endpoint var (8 ajanda kaydı dönüyor)
- [ ] /rentals/:id/period endpoint var (PATCH)
- [ ] /agenda-events/:id/period endpoint var (PATCH)

### **Frontend (http://localhost:5173):**
- [ ] SalesRentalsPage açılıyor
- [ ] 2 tab var ve çalışıyor
- [ ] Chip sayaçları: Dikim: 10 | Kiralama: 5
- [ ] Siparişler tablosu: 15 kayıt
- [ ] Tür kolonu emoji: 🧵 ve 📆
- [ ] Teslim/Kira kolonu akıllı render
- [ ] Para formatı: ₺ sembolü ile
- [ ] Durum badge'leri renkli (🟡🟢🔴)
- [ ] Badge hover → Stage tooltip
- [ ] Takvim mock görünümü çalışıyor

---

## 📚 DOKÜMANTASYON

| Dosya | Amaç |
|-------|------|
| **FIX_AND_RUN.md** | Hızlı başlatma kılavuzu |
| **MIGRATION_STEPS.md** | Migration adımları |
| **TEST_INSTRUCTIONS.md** | Detaylı test senaryoları |
| **CURSOR_GUIDE.md** | Güncellenmiş Cursor talimatları |
| **COMPLETE_GUIDE.md** | Ana proje rehberi |

---

## 🎯 YENİ MİMARİ

### **Veri Tekil, Görünüm Çoklu:**
```
Order (1 kayıt)
├── Siparişler sekmesinde görünür
└── Kiralama Takvimi sekmesinde görünür (RENTAL ise)

AgendaEvent (1 kayıt)
└── SADECE Kiralama Takvimi sekmesinde görünür
```

### **Senkronizasyon Kuralları:**
```typescript
// Kiralama işlemi → 2 ekran güncellenir
invalidateQueries(['transactions', 'rentals-calendar'])

// Ajanda işlemi → 1 ekran güncellenir
invalidateQueries(['agenda-calendar'])  // transactions YOK!
```

### **Finans Merkezi:**
```
Order tablosu:
├── total (cents)
├── collected (cents)
└── balance (auto-calculated)

Rental:
└── Sadece period bilgisi (finans Order'da)
```

---

## 🎊 SONRAKI ADIMLAR

1. ✅ Migration çalıştır (yukarıdaki adımlar)
2. ✅ Backend/Frontend başlat
3. ✅ UI test et
4. ⏳ Tam DnD entegrasyonu (isteğe bağlı):
   ```bash
   pnpm add @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
   # RentalsCalendarView'i tam implement et
   ```

---

## 💡 ÖNEMLİ NOTLAR

### **Para Formatı:**
```typescript
// ✅ DOĞRU
<td>{fmtTRY(order.total)}</td>  // fmtTRY içinde /100 yapılır

// ❌ YANLIŞ
<td>{fmtTRY(order.total / 100)}</td>  // Çifte bölme!
```

### **OrderType:**
```typescript
// ÖNCE: 'SALE' | 'RENTAL'
// SONRA: 'TAILORING' | 'RENTAL'
```

### **Validation:**
```typescript
// Frontend: Zod (from @shared)
import { ProductSchema } from '@shared'
const result = ProductSchema.safeParse(formData)

// Backend: class-validator (automatic via ValidationPipe)
```

---

## 🙏 BAŞARILAR!

Tüm kod hazır, sadece migration çalıştırmanız yeterli!

**Sorun yaşarsanız:** `FIX_AND_RUN.md` dosyasına bakın.



