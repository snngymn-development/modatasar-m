# API Documentation

Bu dokümantasyon, Flutter POS Kasa Sistemi'nin API entegrasyonları ve kullanımı hakkında detaylı bilgi sağlar.

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Kimlik Doğrulama](#kimlik-doğrulama)
- [Satış API'si](#satış-apisi)
- [Envanter API'si](#envanter-apisi)
- [Müşteri API'si](#müşteri-apisi)
- [Hata Yönetimi](#hata-yönetimi)
- [Rate Limiting](#rate-limiting)
- [Güvenlik](#güvenlik)

## 🔍 Genel Bakış

### Base URL
```
Production: https://api.pos-kasa.com/v1
Development: https://dev-api.pos-kasa.com/v1
```

### Kimlik Doğrulama
Tüm API istekleri Bearer token ile kimlik doğrulaması gerektirir:

```http
Authorization: Bearer <access_token>
```

### Content-Type
```http
Content-Type: application/json
```

## 🔐 Kimlik Doğrulama

### Login
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-01-01T12:00:00Z",
    "user": {
      "id": "user123",
      "name": "John Doe",
      "email": "user@example.com",
      "role": "cashier"
    }
  }
}
```

### Token Refresh
```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Logout
```http
POST /auth/logout
```

## 💰 Satış API'si

### Satışları Listele
```http
GET /sales
```

**Query Parameters:**
- `page` (optional): Sayfa numarası (default: 1)
- `limit` (optional): Sayfa başına kayıt sayısı (default: 20)
- `start_date` (optional): Başlangıç tarihi (YYYY-MM-DD)
- `end_date` (optional): Bitiş tarihi (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": {
    "sales": [
      {
        "id": "S-001",
        "title": "T-Shirt Satışı",
        "total": 29.99,
        "description": "Mavi pamuklu t-shirt",
        "status": "completed",
        "customer_id": "C-001",
        "customer_name": "John Doe",
        "created_at": "2024-01-01T10:30:00Z",
        "updated_at": "2024-01-01T10:30:00Z",
        "items": [
          {
            "product_id": "P-001",
            "product_name": "Mavi T-Shirt",
            "quantity": 1,
            "price": 29.99,
            "total": 29.99
          }
        ]
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_records": 100,
      "per_page": 20
    }
  }
}
```

### Yeni Satış Oluştur
```http
POST /sales
```

**Request Body:**
```json
{
  "title": "T-Shirt Satışı",
  "description": "Mavi pamuklu t-shirt",
  "customer_id": "C-001",
  "items": [
    {
      "product_id": "P-001",
      "quantity": 1,
      "price": 29.99
    }
  ],
  "discount": 0,
  "tax_rate": 0.08
}
```

### Satış Detayı
```http
GET /sales/{id}
```

### Satış Güncelle
```http
PUT /sales/{id}
```

### Satış Sil
```http
DELETE /sales/{id}
```

## 📦 Envanter API'si

### Ürünleri Listele
```http
GET /inventory
```

**Query Parameters:**
- `page` (optional): Sayfa numarası
- `limit` (optional): Sayfa başına kayıt sayısı
- `category` (optional): Kategori filtresi
- `search` (optional): Arama terimi

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "P-001",
        "name": "Mavi T-Shirt",
        "category": "Giyim",
        "price": 29.99,
        "stock": 100,
        "sku": "TSH-001",
        "description": "Pamuklu mavi t-shirt",
        "image_url": "https://example.com/images/tshirt.jpg",
        "is_active": true,
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_records": 200,
      "per_page": 20
    }
  }
}
```

### Yeni Ürün Oluştur
```http
POST /inventory
```

**Request Body:**
```json
{
  "name": "Mavi T-Shirt",
  "category": "Giyim",
  "price": 29.99,
  "stock": 100,
  "sku": "TSH-001",
  "description": "Pamuklu mavi t-shirt",
  "image_url": "https://example.com/images/tshirt.jpg"
}
```

### Ürün Güncelle
```http
PUT /inventory/{id}
```

### Stok Güncelle
```http
PATCH /inventory/{id}/stock
```

**Request Body:**
```json
{
  "quantity": 50,
  "operation": "set" // "set", "add", "subtract"
}
```

## 👥 Müşteri API'si

### Müşterileri Listele
```http
GET /customers
```

**Query Parameters:**
- `page` (optional): Sayfa numarası
- `limit` (optional): Sayfa başına kayıt sayısı
- `search` (optional): Arama terimi
- `active_only` (optional): Sadece aktif müşteriler (true/false)

**Response:**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "C-001",
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "address": "123 Main St",
        "city": "New York",
        "country": "USA",
        "postal_code": "10001",
        "is_active": true,
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_records": 100,
      "per_page": 20
    }
  }
}
```

### Yeni Müşteri Oluştur
```http
POST /customers
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "New York",
  "country": "USA",
  "postal_code": "10001"
}
```

## ❌ Hata Yönetimi

### Hata Formatı
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Geçersiz veri",
    "details": {
      "field": "email",
      "reason": "Geçerli bir e-posta adresi girin"
    }
  }
}
```

### HTTP Status Kodları
- `200` - Başarılı
- `201` - Oluşturuldu
- `400` - Geçersiz İstek
- `401` - Yetkisiz
- `403` - Yasak
- `404` - Bulunamadı
- `422` - Doğrulama Hatası
- `429` - Çok Fazla İstek
- `500` - Sunucu Hatası

### Hata Kodları
- `VALIDATION_ERROR` - Doğrulama hatası
- `AUTHENTICATION_ERROR` - Kimlik doğrulama hatası
- `AUTHORIZATION_ERROR` - Yetkilendirme hatası
- `NOT_FOUND` - Kaynak bulunamadı
- `RATE_LIMIT_EXCEEDED` - Rate limit aşıldı
- `INTERNAL_ERROR` - Sunucu hatası

## 🚦 Rate Limiting

### Limitler
- **Genel API**: 1000 istek/saat
- **Login**: 5 istek/15 dakika
- **Password Reset**: 3 istek/saat
- **Veri İşlemleri**: 100 istek/dakika

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

## 🔒 Güvenlik

### HTTPS
Tüm API istekleri HTTPS üzerinden yapılmalıdır.

### Certificate Pinning
Uygulama, sunucu sertifikalarını pinler ve doğrular.

### Input Validation
Tüm girdiler doğrulanır ve sanitize edilir.

### SQL Injection Koruması
Tüm veritabanı sorguları parametrize edilmiştir.

### XSS Koruması
Tüm çıktılar escape edilmiştir.

## 📱 SDK Kullanımı

### Flutter/Dart
```dart
import 'package:deneme1/core/network/api_client.dart';

final apiClient = ApiClient();
final sales = await apiClient.getSales();
```

### JavaScript
```javascript
import { ApiClient } from './api-client';

const apiClient = new ApiClient();
const sales = await apiClient.getSales();
```

## 🔧 Geliştirme

### Test Environment
```bash
# Test API'sine erişim
curl -X GET https://dev-api.pos-kasa.com/v1/sales \
  -H "Authorization: Bearer test_token"
```

### Mock Data
Geliştirme sırasında mock data kullanılabilir:
```bash
# Mock data ile test
curl -X GET https://dev-api.pos-kasa.com/v1/sales?mock=true
```

## 📞 Destek

API ile ilgili sorularınız için:
- **Email**: api-support@pos-kasa.com
- **Dokümantasyon**: https://docs.pos-kasa.com
- **Status Page**: https://status.pos-kasa.com
