# 🔧 DATABASE MIGRATION ADIMLARI

## ⚠️ DURUM

SQLite database **lock hatası** veriyor. Bu sorunu çözmek için:

---

## ✅ ÇÖZÜM (3 Seçenek)

### **SEÇENEK 1: Basit Yol (Önerilen)**

1. **Tüm terminalleri kapat** (backend/frontend çalışan varsa)

2. **VS Code'u tamamen kapat ve tekrar aç**

3. **Migration komutunu çalıştır:**
   ```bash
   cd backend/api
   npx prisma migrate dev --name complete_restructure
   npx prisma db seed
   ```

---

### **SEÇENEK 2: Manuel SQL (Hızlı)**

1. **SQLite GUI tool kullan** (örn: DB Browser for SQLite)

2. **`backend/api/prisma/dev.db` dosyasını aç**

3. **`backend/api/prisma/manual_migration.sql` içeriğini çalıştır**

4. **Seed'i manuel çalıştır:**
   ```bash
   cd backend/api
   npx prisma db seed
   ```

---

### **SEÇENEK 3: Tam Temizlik (En Güvenli)**

1. **Bilgisayarı yeniden başlat** (tüm lock'lar serbest kalır)

2. **Terminal aç:**
   ```bash
   cd C:\code\deneme1\backend\api
   
   # Tüm SQLite dosyalarını sil
   Remove-Item -Force prisma/dev.db*
   Remove-Item -Force -Recurse prisma/prisma -ErrorAction SilentlyContinue
   Remove-Item -Force -Recurse prisma/migrations -ErrorAction SilentlyContinue
   
   # Fresh migration
   npx prisma migrate dev --name complete_restructure
   
   # Seed
   npx prisma db seed
   ```

---

## 🚀 MİGRATION TAMAMLANDIKTAN SONRA

### **1. Prisma Client Generate**
```bash
pnpm --filter @deneme1/api prisma:gen
```

### **2. Backend Başlat**
```bash
pnpm dev:api
```

**Beklenen çıktı:**
```
[Nest] INFO  Nest application successfully started
[Nest] INFO  Application is running on: http://localhost:3000
```

### **3. Swagger Test**
**Tarayıcı:** http://localhost:3000/docs

**Yeni endpoint'leri kontrol et:**
- ✅ `/transactions` (GET)
- ✅ `/transactions/summary` (GET)
- ✅ `/products` (GET, POST, PUT, DELETE)
- ✅ `/agenda-events` (GET, POST, PATCH /:id/period, DELETE)
- ✅ `/rentals/:id/period` (PATCH)

### **4. Frontend Başlat (Yeni Terminal)**
```bash
pnpm dev:web
```

**Beklenen:**
```
VITE ready in XXX ms
➜  Local:   http://localhost:5173/
```

### **5. UI Test**
**Tarayıcı:** http://localhost:5173

- ✅ SalesRentalsPage açılıyor
- ✅ 2 tab var (Siparişler, Kiralama Takvimi)
- ✅ Chip sayaçları: Dikim: 10 | Kiralama: 5
- ✅ Tab 1: Siparişler tablosu (15 kayıt)
- ✅ Tab 2: Mock takvim görünümü

---

## 📝 DOĞRULAMA NOKTALARI

### **Backend API Test (Swagger UI):**

#### **GET /transactions**
```json
{
  "items": [
    {
      "id": "order-1",
      "type": "TAILORING",
      "customer": { "name": "Ayşe Yılmaz" },
      "deliveryDate": "2025-11-15T...",
      "total": 50000,
      "collected": 20000,
      "balance": 30000,
      "status": "ACTIVE",
      "stage": "IN_PROGRESS_50"
    },
    {
      "id": "order-11",
      "type": "RENTAL",
      "customer": { "name": "Ayşe Yılmaz" },
      "rental": {
        "start": "2025-10-20T...",
        "end": "2025-10-22T...",
        "productId": "prod-1"
      },
      "total": 20000,
      "collected": 20000,
      "status": "ACTIVE",
      "stage": "PICKED_UP"
    }
  ],
  "total": 15,
  "page": 1
}
```

#### **GET /transactions/summary**
```json
{
  "tailoringCount": 10,
  "rentalCount": 5,
  "totalCount": 15
}
```

#### **GET /products**
```json
[
  {
    "id": "prod-1",
    "name": "Smokin Takım Elbise",
    "model": "Classic",
    "color": "Siyah",
    "size": "L",
    "category": "Takım Elbise",
    "tags": ["Düğün", "Gala", "Smokin"],
    "status": "AVAILABLE"
  }
]
```

#### **GET /agenda-events**
```json
[
  {
    "id": "agenda-1",
    "productId": "prod-1",
    "type": "ALTERATION",
    "start": "2025-10-23T...",
    "end": "2025-10-24T...",
    "note": "Kol boyu tadilat"
  }
]
```

---

### **Frontend UI Test:**

#### **SalesRentalsPage:**
- ✅ 2 tab butonu aktif/pasif stil değişimi
- ✅ Chip sayaçları: Dikim 🟡 (10) | Kiralama 🔵 (5)

#### **OrdersView (Tab 1):**
- ✅ Tür filtresi EN BAŞTA (Dikim/Kiralama/Hepsi)
- ✅ Durum filtresi çalışıyor
- ✅ Tablo: 15 satır
- ✅ Tür kolonu: 🧵 (Dikim) | 📆 (Kiralama)
- ✅ Teslim/Kira kolonu:
  - Dikim → 15.11.2025
  - Kiralama → 20.10.2025 – 22.10.2025
- ✅ Para formatı: ₺500, ₺200, ₺60 (cents otomatik çevrildi)
- ✅ Durum badge'leri renkli:
  - ACTIVE → 🟡 Amber
  - COMPLETED → 🟢 Green
  - CANCELLED → 🔴 Red
- ✅ Badge'e hover → stage tooltip ("İşlemde %50", "Rezerve Edildi", vb.)

#### **RentalsCalendarView (Tab 2):**
- ✅ Sol panel: Filtreler + Araç Paleti
- ✅ 4 araç:
  - 🆕 Yeni Kiralama (mavi)
  - 🧼 Kuru Temizleme (mor)
  - ✂️ Tadilat (turuncu)
  - 🚫 Kullanım Dışı (gri)
- ✅ Sağ panel: Haftalık grid (Pzt-Paz)
- ✅ Mock bloklar görünüyor
- ✅ Bilgilendirme: "Bu bir MOCK görünümdür"

---

## 🎉 BAŞARILI TEST SONUÇLARI BEKLENİYOR

Migration tamamlandığında tüm sistem çalışır durumda olacak!



