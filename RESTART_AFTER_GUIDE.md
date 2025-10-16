# 🔄 BİLGİSAYAR RESTART SONRASI KILAVUZ

## ✅ MEVCUT DURUM

Tüm kod hazır! 61 dosya başarıyla oluşturuldu.  
**Sadece database migration çalıştırılmayı bekliyor.**

---

## 🚀 RESTART SONRASI ADIMLAR (5 Dakika)

### **Adım 1: VS Code'u Aç**
```
C:\code\deneme1 klasörünü açın
```

### **Adım 2: Terminal Aç ve Çalıştır**

**Kopyalayın ve yapıştırın (tek seferde):**

```powershell
# Klasöre git
cd C:\code\deneme1\backend\api

# Database dosyalarını sil (eski lock'lu dosyalar)
Remove-Item -Force prisma\dev.db -ErrorAction SilentlyContinue
Remove-Item -Force prisma\dev.db-journal -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse prisma\prisma -ErrorAction SilentlyContinue

# Migration uygula
npx prisma migrate deploy

# Prisma Client generate (yeni types)
npx prisma generate

# Seed data (5 müşteri, 10 ürün, 15 sipariş, 8 ajanda)
npx prisma db seed
```

**Beklenen çıktı:**
```
✅ Migration 20251012174520_complete_restructure applied
✅ Prisma Client generated
✅ Created 5 customers
✅ Created 10 products
✅ Created 10 TAILORING orders
✅ Created 5 RENTAL orders
✅ Created 8 agenda events
🎉 Database seeding completed successfully!
```

---

### **Adım 3: Backend Başlat (Terminal 1)**

```powershell
cd C:\code\deneme1
pnpm dev:api
```

**Başarı göstergesi:**
```
[Nest] INFO  Application is running on: http://localhost:3000
```

**Hemen test edin:**
- 🌐 http://localhost:3000/health → `{"ok":true,...}`
- 🌐 http://localhost:3000/docs → Swagger UI

---

### **Adım 4: Frontend Başlat (YENİ Terminal)**

**YENİ terminal açın (Terminal → New Terminal):**

```powershell
cd C:\code\deneme1
pnpm dev:web
```

**Başarı göstergesi:**
```
VITE ready in XXX ms
➜  Local:   http://localhost:5173/
```

---

## 🧪 TEST ADIMLARI

### **A. Backend Test (Swagger UI)**

**Tarayıcı:** http://localhost:3000/docs

**Yeni endpoint'leri kontrol edin (Try it out → Execute):**

#### ✅ GET /transactions
```json
Beklenen: 15 sipariş
Response örneği:
{
  "items": [
    {
      "type": "TAILORING",
      "customer": { "name": "Ayşe Yılmaz" },
      "deliveryDate": "2025-11-15",
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

#### ✅ GET /transactions/summary
```json
Beklenen:
{
  "tailoringCount": 10,
  "rentalCount": 5,
  "totalCount": 15
}
```

#### ✅ GET /products
```
Beklenen: 10 ürün
```

#### ✅ GET /agenda-events
```
Beklenen: 8 ajanda kaydı (3 Tadilat, 3 Kuru Temizleme, 2 Kullanım Dışı)
```

#### ✅ PATCH /rentals/:id/period
```
Test: Bir rental ID'si ile period değiştirmeyi deneyin
```

---

### **B. Frontend Test (UI)**

**Tarayıcı:** http://localhost:5173

#### **1. SalesRentalsPage Açılışı**
- [ ] Sayfa yükleniyor
- [ ] 2 tab butonu var: "🧵 Siparişler" | "📆 Kiralama Takvimi"
- [ ] Chip sayaçları var: "🧵 Dikim: 10" | "📆 Kiralama: 5"

#### **2. Tab 1: Siparişler Sekmesi**
- [ ] Tab'a tıklayın
- [ ] Filtre barı görünüyor (Tür EN BAŞTA)
- [ ] Tablo render oluyor
- [ ] 15 sipariş listeleniyor

**Tablo Kontrolleri:**
- [ ] Sipariş Tarihi kolonu: Tarih formatı doğru
- [ ] Teslim/Kira kolonu: 
  - Dikim (🧵) → Tek tarih: "15.11.2025"
  - Kiralama (📆) → Dönem: "20.10.2025 – 22.10.2025"
- [ ] Müşteri adı görünüyor
- [ ] Tür emoji: 🧵 ve 📆
- [ ] Para formatı: ₺500, ₺200, ₺300 (cents → TL)
- [ ] Durum badge'leri renkli:
  - 🟡 Amber (ACTIVE)
  - 🟢 Green (COMPLETED)
  - 🔴 Red (CANCELLED)

**Stage Tooltip:**
- [ ] Durum badge'ine **mouse hover** yapın
- [ ] Tooltip görünüyor: "İşlemde %50", "Rezerve Edildi", vb.

**Filtre Testleri:**
- [ ] Tür = "Dikim" seç → Sadece 🧵 görünmeli (10 kayıt)
- [ ] Tür = "Kiralama" seç → Sadece 📆 görünmeli (5 kayıt)
- [ ] Tür = "Hepsi" → 15 kayıt
- [ ] Durum = "Aktif" seç → Sadece ACTIVE
- [ ] Sıfırla butonu → Filtreler temizlenmeli

#### **3. Tab 2: Kiralama Takvimi Sekmesi**
- [ ] Tab'a tıklayın
- [ ] Sol panel görünüyor
- [ ] **Araç Paleti:**
  - [ ] 🆕 Yeni Kiralama (mavi)
  - [ ] 🧼 Kuru Temizleme (mor)
  - [ ] ✂️ Tadilat (turuncu)
  - [ ] 🚫 Kullanım Dışı (gri)
- [ ] Sağ panel: Takvim grid
- [ ] Haftalık başlıklar: Pzt, Sal, Çar, Per, Cum, Cmt, Paz
- [ ] 3 ürün satırı: Smokin, Slim Fit, Damat Takımı
- [ ] Mock bloklar görünüyor
- [ ] **Bilgilendirme:** "ℹ️ Bu bir MOCK görünümdür"

---

## ⚠️ SORUN YAŞARSANIZ

### **Migration hatası:**
```powershell
# Database lock devam ediyorsa:
# 1. Task Manager açın
# 2. "Node.js" process'lerini kapatın
# 3. VS Code'u kapatın
# 4. Tekrar deneyin
```

### **TypeScript hatası (Prisma types):**
```powershell
# Prisma Client yeniden generate
cd C:\code\deneme1\backend\api
npx prisma generate

# Backend restart
cd C:\code\deneme1
pnpm dev:api
```

### **Frontend hatası:**
```powershell
# Core ve Shared rebuild
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build

# Frontend restart
pnpm dev:web
```

---

## 📊 BEKLENEN SONUÇ

### **Backend API (http://localhost:3000/docs):**
- ✅ 9 endpoint grubu
- ✅ 3 yeni modül: products, transactions, agenda-events
- ✅ 2 yeni PATCH endpoint: /rentals/:id/period, /agenda-events/:id/period
- ✅ Swagger interactive

### **Frontend UI (http://localhost:5173):**
- ✅ 2 sekmeli SalesRentalsPage
- ✅ Chip counters (Dikim: 10, Kiralama: 5)
- ✅ OrdersView: Filtreler + Tablo (15 kayıt)
  - Akıllı Teslim/Kira kolonu
  - Renkli durum badge'leri
  - Stage tooltip
- ✅ RentalsCalendarView: Mock takvim
  - Tool Palette (4 araç)
  - Haftalık Grid
  - Örnek bloklar

---

## 📁 YARDIM DOSYALARI

Detaylı bilgi için:

| Dosya | İçerik |
|-------|--------|
| **START_HERE.md** | Genel başlangıç kılavuzu |
| **FIX_AND_RUN.md** | Hızlı sorun çözümleri |
| **MIGRATION_STEPS.md** | Migration detayları |
| **TEST_INSTRUCTIONS.md** | Test senaryoları |
| **CURSOR_GUIDE.md** | Güncellenmiş proje kuralları |

---

## 🎯 ÖZET

**Tek adım kaldı:**
1. ✅ Bilgisayar restart
2. ⏳ Migration çalıştır (yukarıdaki komutlar)
3. ✅ Backend başlat
4. ✅ Frontend başlat
5. ✅ Test et

**Tüm kod hazır, sadece database'i sıfırlamak gerekiyor!**



