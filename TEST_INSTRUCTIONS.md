# 🧪 TEST TALİMATLARI

## ⚠️ ÖNEMLİ: Database Lock Sorunu

SQLite database dosyası şu an kilitli. Muhtemelen:
- VS Code SQLite extension açık
- Prisma Studio çalışıyor
- Başka bir process kullanıyor

---

## 🔧 ÇÖZÜM: Manuel Migration

### **1. Tüm DB bağlantılarını kapat**

```bash
# Eğer backend çalışıyorsa, durdurun (Ctrl+C)
# Prisma Studio açıksa kapatın
# VS Code SQLite extension'ı kapatın
```

### **2. Database dosyalarını manuel sil**

**PowerShell'de:**
```powershell
cd C:\code\deneme1\backend\api
Remove-Item -Force -Recurse prisma/migrations
Remove-Item -Force prisma/dev.db*
Remove-Item -Force prisma/prisma/dev.db* -ErrorAction SilentlyContinue
```

**Veya Windows Explorer'da:**
- `backend/api/prisma/migrations` klasörünü sil
- `backend/api/prisma/dev.db` dosyasını sil
- `backend/api/prisma/dev.db-journal` dosyasını sil
- `backend/api/prisma/prisma/` klasörünü kontrol et, varsa sil

### **3. Migration oluştur**

```bash
cd backend/api
npx prisma migrate dev --name complete_restructure
```

**Beklenen çıktı:**
```
✔ Migration created
✔ Database tables created:
  - Customer
  - Product (NEW)
  - Order (UPDATED)
  - Rental (UPDATED)
  - AgendaEvent (NEW)
```

### **4. Seed data yükle**

```bash
npx prisma db seed
```

**Beklenen çıktı:**
```
✅ Created 5 customers
✅ Created 10 products
✅ Created 10 TAILORING orders
✅ Created 5 RENTAL orders with rentals
✅ Created 8 agenda events
```

---

## 🚀 TEST ADIMLARI

### **Test 1: Backend Başlat**

```bash
# Terminal 1
pnpm dev:api
```

**Beklenen:**
```
[Nest] INFO  Nest application successfully started
[Nest] INFO  Application is running on: http://localhost:3000
```

### **Test 2: Swagger UI Kontrol**

**Tarayıcı:** http://localhost:3000/docs

**Kontrol edilecekler:**
- ✅ `/transactions` endpoint var mı? (GET)
- ✅ `/transactions/summary` endpoint var mı? (GET)
- ✅ `/products` endpoint'leri var mı? (GET, POST, PUT, DELETE)
- ✅ `/agenda-events` endpoint'leri var mı? (GET, POST, PATCH, DELETE)
- ✅ `/rentals/:id/period` endpoint var mı? (PATCH)

### **Test 3: API Endpoint Testleri**

**Swagger UI'dan "Try it out" ile test edin:**

#### **GET /transactions**
```
Parametre yok
Beklenen: 15 sipariş (10 TAILORING, 5 RENTAL)
```

#### **GET /transactions/summary**
```
Beklenen:
{
  "tailoringCount": 10,
  "rentalCount": 5,
  "totalCount": 15
}
```

#### **GET /products**
```
Beklenen: 10 ürün
```

#### **GET /agenda-events**
```
Beklenen: 8 ajanda kaydı (3 Tadilat, 3 Kuru Temizleme, 2 Kullanım Dışı)
```

### **Test 4: Frontend Başlat**

```bash
# Terminal 2 (yeni terminal)
pnpm dev:web
```

**Beklenen:**
```
VITE ready in XXX ms
➜  Local:   http://localhost:5173/
```

### **Test 5: UI Testleri**

**Tarayıcı:** http://localhost:5173

#### **5.1. SalesRentalsPage Açılışı**
- ✅ 2 tab butonu görünüyor mu? (🧵 Siparişler | 📆 Kiralama Takvimi)
- ✅ Chip sayaçları görünüyor mu? (Dikim: 10 | Kiralama: 5)

#### **5.2. Siparişler Sekmesi (Tab 1)**
- ✅ Filtre barı var mı? (Tür, Durum filtreleri)
- ✅ Tablo görünüyor mu?
- ✅ 15 sipariş listeleniyor mu?
- ✅ Tür kolonu: 🧵 ve 📆 emojileri doğru mu?
- ✅ Teslim/Kira kolonu: Dikim için tek tarih, Kiralama için dönem mi?
- ✅ Tutar formatı: ₺XXX şeklinde mi?
- ✅ Durum badge'leri renkli mi? (ACTIVE 🟡, COMPLETED 🟢, CANCELLED 🔴)
- ✅ Durum badge'lerine hover yapınca stage tooltip görünüyor mu?

#### **5.3. Kiralama Takvimi Sekmesi (Tab 2)**
- ✅ Sol panel: Filtreler + Araç Paleti görünüyor mu?
- ✅ Araç Paleti: 4 tool var mı? (🆕 Yeni Kiralama, 🧼 Kuru Temizleme, ✂️ Tadilat, 🚫 Kullanım Dışı)
- ✅ Sağ panel: Mock takvim grid görünüyor mu?
- ✅ Haftalık başlıklar: Pzt, Sal, Çar... var mı?
- ✅ Örnek bloklar görünüyor mu?
- ✅ "Bu bir MOCK görünümdür" mesajı var mı?

---

## 🔍 TEST SONUÇLARI KONTROL LİSTESI

### Backend API:
- [ ] Health endpoint çalışıyor (/health)
- [ ] Customers endpoint çalışıyor (/customers)
- [ ] Products endpoint çalışıyor (/products) ← YENİ
- [ ] Transactions endpoint çalışıyor (/transactions) ← YENİ
- [ ] Transactions summary çalışıyor (/transactions/summary) ← YENİ
- [ ] Rentals endpoint çalışıyor (/rentals)
- [ ] Rentals period endpoint çalışıyor (PATCH /rentals/:id/period) ← YENİ
- [ ] Agenda events endpoint çalışıyor (/agenda-events) ← YENİ
- [ ] Agenda period endpoint çalışıyor (PATCH /agenda-events/:id/period) ← YENİ

### Frontend UI:
- [ ] SalesRentalsPage yükleniyor
- [ ] Tab sistem çalışıyor
- [ ] Chip sayaçları doğru
- [ ] OrdersView tablo render ediliyor
- [ ] Filtreler çalışıyor
- [ ] Durum badge'leri renkli
- [ ] Stage tooltip hover'da görünüyor
- [ ] RentalsCalendarView mock grid görünüyor
- [ ] Responsive layout (mobil/desktop)

---



