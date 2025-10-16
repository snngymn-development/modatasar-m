# DENEME1 API DOKÜMANTASYONU

## 📋 Genel Bilgiler

- **Base URL**: `http://localhost:3001/api`
- **Version**: `v1`
- **Authentication**: JWT Bearer Token
- **Content-Type**: `application/json`

## 🔐 Authentication

### Login
```http
POST /api/auth/login
Content-Type: application/json

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
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "username": "username",
      "firstName": "John",
      "lastName": "Doe",
      "roles": ["USER"]
    }
  }
}
```

### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Logout
```http
POST /api/auth/logout
Authorization: Bearer <access_token>
```

## 👥 Users

### Get All Users
```http
GET /api/users
Authorization: Bearer <access_token>
```

### Get User by ID
```http
GET /api/users/:id
Authorization: Bearer <access_token>
```

### Create User
```http
POST /api/users
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "email": "newuser@example.com",
  "username": "newuser",
  "firstName": "Jane",
  "lastName": "Smith",
  "password": "password123"
}
```

### Update User
```http
PUT /api/users/:id
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "firstName": "Updated Name",
  "lastName": "Updated Lastname"
}
```

### Delete User
```http
DELETE /api/users/:id
Authorization: Bearer <access_token>
```

## 📦 Products

### Get All Products
```http
GET /api/products
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10)
- `search`: Search term
- `category`: Category ID
- `sortBy`: Sort field (name, price, createdAt)
- `sortOrder`: Sort order (asc, desc)

### Get Product by ID
```http
GET /api/products/:id
Authorization: Bearer <access_token>
```

### Create Product
```http
POST /api/products
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Product Name",
  "description": "Product Description",
  "sku": "SKU123",
  "price": 99.99,
  "cost": 50.00,
  "categoryId": "category_id",
  "stock": 100,
  "minStock": 10,
  "tags": ["tag1", "tag2"]
}
```

### Update Product
```http
PUT /api/products/:id
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Updated Product Name",
  "price": 129.99
}
```

### Delete Product
```http
DELETE /api/products/:id
Authorization: Bearer <access_token>
```

## 🛒 Orders

### Get All Orders
```http
GET /api/orders
Authorization: Bearer <access_token>
```

### Get Order by ID
```http
GET /api/orders/:id
Authorization: Bearer <access_token>
```

### Create Order
```http
POST /api/orders
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "customerId": "customer_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 2,
      "price": 99.99
    }
  ],
  "notes": "Order notes"
}
```

### Update Order Status
```http
PATCH /api/orders/:id/status
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "status": "CONFIRMED"
}
```

## 👤 Customers

### Get All Customers
```http
GET /api/customers
Authorization: Bearer <access_token>
```

### Get Customer by ID
```http
GET /api/customers/:id
Authorization: Bearer <access_token>
```

### Create Customer
```http
POST /api/customers
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Customer Name",
  "email": "customer@example.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "City",
  "country": "Country"
}
```

## 📁 Files

### Upload File
```http
POST /api/files/upload
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

file: <file>
```

### Get File
```http
GET /api/files/:id
Authorization: Bearer <access_token>
```

### Delete File
```http
DELETE /api/files/:id
Authorization: Bearer <access_token>
```

## 🏥 Health Check

### System Health
```http
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "services": {
    "database": "ok",
    "redis": "ok",
    "storage": "ok"
  }
}
```

## 📊 Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  }
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions"
  }
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Resource not found"
  }
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred"
  }
}
```

## 🔒 Rate Limiting

- **Limit**: 100 requests per minute per IP
- **Headers**: 
  - `X-RateLimit-Limit`: Request limit
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Reset time

## 📝 Pagination

### Query Parameters
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 100)

### Response Format
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## 🔍 Filtering & Sorting

### Filtering
- Use query parameters to filter results
- Example: `?status=active&category=electronics`

### Sorting
- `sortBy`: Field to sort by
- `sortOrder`: `asc` or `desc`
- Example: `?sortBy=createdAt&sortOrder=desc`

## 📱 WebSocket Events

### Connection
```javascript
const ws = new WebSocket('ws://localhost:3001/ws');
```

### Events
- `order.created`: New order created
- `order.updated`: Order status updated
- `product.updated`: Product information updated
- `user.online`: User came online
- `user.offline`: User went offline
