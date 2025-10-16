# 🚀 HIZLI BAŞLATMA KILAVUZU

## ⚠️ DURUM
Tüm kod hazır ama **SQLite database lock** sorunu var. 

---

## ✅ ÇÖZÜM (3 Dakika)

### **1. VS Code'u TAMAMEN KAPAT**
```
File → Exit (veya Alt+F4)
```

### **2. VS Code'u YENİDEN AÇ**
```
C:\code\deneme1 klasörünü aç
```

### **3. Terminal Aç ve Çalıştır:**

```powershell
# A. Database temizliği
Remove-Item -Force backend/api/prisma/dev.db* -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse backend/api/prisma/prisma -ErrorAction SilentlyContinue

# B. Prisma Client generate
pnpm --filter @deneme1/api prisma generate

# C. Migration
pnpm --filter @deneme1/api prisma migrate deploy

# D. Seed data
pnpm --filter @deneme1/api prisma db seed
```

**Beklenen çıktı:**
```
✅ Migration applied
✅ Created 5 customers
✅ Created 10 products
✅ Created 10 TAILORING orders
✅ Created 5 RENTAL orders
✅ Created 8 agenda events
```

---

### **4. Backend Başlat (Terminal 1)**
```bash
pnpm dev:api
```

**Beklenen:**
```
[Nest] INFO  Application is running on: http://localhost:3000
```

**Test:**
- 🌐 http://localhost:3000/health
- 🌐 http://localhost:3000/docs (Swagger UI)

---

### **5. Frontend Başlat (Terminal 2 - YENİ)**
```bash
pnpm dev:web
```

**Beklenen:**
```
VITE ready in XXX ms
➜  Local:   http://localhost:5173/
```

**Test:**
- 🌐 http://localhost:5173
- Tab 1: 🧵 Siparişler → Tablo görünmeli (15 sipariş)
- Tab 2: 📆 Kiralama Takvimi → Mock takvim görünmeli

---

## 🧪 TEST NOKTALARI

### **Backend API (Swagger: http://localhost:3000/docs)**

Test edilecek endpoint'ler:

#### ✅ GET /transactions
```
Execute → Beklenen: 15 sipariş (10 TAILORING, 5 RENTAL)
```

#### ✅ GET /transactions/summary
```
Execute → Beklenen:
{
  "tailoringCount": 10,
  "rentalCount": 5
}
```

#### ✅ GET /products
```
Execute → Beklenen: 10 ürün
```

#### ✅ GET /agenda-events
```
Execute → Beklenen: 8 ajanda kaydı
```

---

### **Frontend UI (http://localhost:5173)**

#### **SalesRentalsPage:**
- ✅ 2 tab: "🧵 Siparişler" | "📆 Kiralama Takvimi"
- ✅ Chip sayaçları: Dikim: 10 | Kiralama: 5

#### **Tab 1: Siparişler:**
- ✅ Filtre barı (Tür EN BAŞTA)
- ✅ Tablo: 15 satır
- ✅ Kolonlar doğru:
  - Sipariş Tarihi
  - Teslim/Kira (Dikim: tek tarih | Kiralama: dönem)
  - Müşteri, Tür (🧵/📆), Organizasyon
  - Toplam, Tahsilat, Bakiye (₺ formatında)
  - Durum (renkli badge: 🟡 Aktif, 🟢 Tamamlandı, 🔴 İptal)
- ✅ Badge'e hover → Stage tooltip görünmeli

#### **Tab 2: Kiralama Takvimi:**
- ✅ Sol panel: Filtreler + Araç Paleti
- ✅ 4 araç: 🆕 Yeni Kiralama, 🧼 Kuru Temizleme, ✂️ Tadilat, 🚫 Kullanım Dışı
- ✅ Sağ panel: Haftalık grid (Pzt-Paz)
- ✅ Mock bloklar görünüyor
- ✅ Bilgilendirme: "Bu bir MOCK görünümdür"

---

## ⚠️ SORUN YAŞARSANIZ

### **Backend başlamıyor:**
```bash
# Prisma client yeniden generate
pnpm --filter @deneme1/api prisma generate

# Restart
pnpm dev:api
```

### **Frontend TypeScript hatası:**
```bash
# Core ve Shared rebuild
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build

# Restart
pnpm dev:web
```

### **Database lock devam ediyor:**
```bash
# 1. Task Manager'dan node.exe process'lerini kapat
# 2. VS Code'u tamamen kapat
# 3. Bilgisayarı yeniden başlat (son çare)
# 4. Tekrar dene
```

---

## 📊 BEKLENEN SONUÇLAR

### **Backend API:**
- ✅ 9 endpoint grubu (health, customers, products, orders, rentals, transactions, agenda-events, dashboard)
- ✅ Swagger UI interaktif
- ✅ 15 sipariş mock data
- ✅ 10 ürün mock data
- ✅ 8 ajanda kaydı mock data

### **Frontend UI:**
- ✅ 2 sekmeli sistem
- ✅ Chip sayaçları canlı
- ✅ Siparişler tablosu (15 kayıt)
  - Akıllı Teslim/Kira kolonu
  - Renkli durum badge'leri
  - Stage tooltip (hover)
  - Para formatları (₺)
- ✅ Takvim mock görünümü
  - Tool palette (4 araç)
  - Haftalık grid
  - Örnek bloklar

---

## 🎉 BAŞARILI!

Tüm adımlar tamamlandığında sistem çalışır durumda olacak!

**Oluşturulan dosyalar: 61+**
**Kod satırı: ~3500+**
**Test süresi: ~5 dakika**



