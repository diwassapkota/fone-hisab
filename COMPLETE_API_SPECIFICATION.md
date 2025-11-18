# Complete API Specification - Fonepay Khata Book Backend

**Version**: 1.0.0
**Last Updated**: 2024-11-18
**Base URL**: `http://your-domain.com/api/v1` or `http://localhost:8080/api/v1`

This document provides complete API specifications for all endpoints in the Fonepay Khata Book Backend, organized for easy Flutter app integration.

---

## Table of Contents

1. [Authentication & Authorization](#1-authentication--authorization)
2. [Common Patterns](#2-common-patterns)
3. [Customer Management](#3-customer-management)
4. [Transaction Management](#4-transaction-management)
5. [Ledger & Reports](#5-ledger--reports)
6. [Supplier Management](#6-supplier-management)
7. [Product & Inventory Management](#7-product--inventory-management)
8. [Purchase Management](#8-purchase-management)
9. [Analytics & Dashboard](#9-analytics--dashboard)
10. [Report Generation](#10-report-generation)
11. [Error Codes](#11-error-codes)

---

## 1. Authentication & Authorization

### Base Path: `/auth`

All authentication endpoints are **public** (no token required except logout).

#### 1.1 Register New User

```http
POST /auth/register
```

**Request Body:**
```json
{
  "mobileNumber": "9841234567",
  "password": "SecurePass123",
  "businessName": "My Shop",
  "role": "MERCHANT"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "id": "uuid",
    "mobileNumber": "9841234567",
    "businessName": "My Shop",
    "role": "MERCHANT",
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 1.2 Login

```http
POST /auth/login
```

**Request Body:**
```json
{
  "mobileNumber": "9841234567",
  "password": "SecurePass123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": "uuid",
      "mobileNumber": "9841234567",
      "businessName": "My Shop",
      "role": "MERCHANT"
    }
  }
}
```

#### 1.3 Refresh Access Token

```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new-access-token",
    "refreshToken": "new-refresh-token",
    "tokenType": "Bearer",
    "expiresIn": 86400
  }
}
```

#### 1.4 Logout

```http
POST /auth/logout
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

---

## 2. Common Patterns

### 2.1 Authentication Header

All protected endpoints require JWT token:

```http
Authorization: Bearer {accessToken}
```

### 2.2 Standard Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Optional success message",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { ... }
  },
  "timestamp": "2024-11-18T10:30:00Z",
  "path": "/api/v1/customers"
}
```

### 2.3 Pagination Format

Paginated responses include:

```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "pagination": {
      "currentPage": 0,
      "totalPages": 10,
      "totalElements": 200,
      "size": 20,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

### 2.4 Date Format

All dates use ISO-8601 format:
- Date only: `2024-11-18`
- Date-time: `2024-11-18T10:30:00Z`

---

## 3. Customer Management

### Base Path: `/customers`
### Required Role: `MERCHANT`

#### 3.1 Create Customer

```http
POST /customers
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "name": "John Doe",
  "mobileNumber": "9841234567",
  "address": "Kathmandu, Nepal",
  "panNumber": "123456789",
  "email": "john@example.com",
  "notes": "VIP customer"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Customer added successfully",
  "data": {
    "customerId": "uuid",
    "customerName": "John Doe",
    "mobileNumber": "9841234567",
    "address": "Kathmandu, Nepal",
    "balance": 0.00,
    "balanceType": "SETTLED",
    "transactionCount": 0,
    "lastTransactionDate": null,
    "dueDate": null,
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 3.2 List All Customers

```http
GET /customers?page=0&size=20&filter=ALL&sortBy=RECENT&search=john
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional, default: 0) - Page number
- `size` (optional, default: 20) - Items per page
- `filter` (optional, default: ALL) - Filter by balance type
  - `ALL` - All customers
  - `UDHARO` - Customers who owe money (positive balance)
  - `ADVANCE` - Customers with advance payment (negative balance)
  - `SETTLED` - Customers with zero balance
- `sortBy` (optional, default: RECENT) - Sort order
  - `RECENT` - Recently created first
  - `NAME_ASC` - Name A-Z
  - `NAME_DESC` - Name Z-A
  - `BALANCE_HIGH` - Highest balance first
  - `BALANCE_LOW` - Lowest balance first
- `search` (optional) - Search by name or mobile

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "customerId": "uuid",
        "customerName": "John Doe",
        "mobileNumber": "9841234567",
        "balance": 5000.00,
        "balanceType": "UDHARO",
        "transactionCount": 15,
        "lastTransactionDate": "2024-11-18",
        "dueDate": "2024-11-25"
      }
    ],
    "pagination": {
      "currentPage": 0,
      "totalPages": 5,
      "totalElements": 100,
      "size": 20,
      "hasNext": true,
      "hasPrevious": false
    },
    "summary": {
      "totalCustomers": 100,
      "totalUdharo": 150000.00,
      "totalAdvance": 20000.00,
      "udharoCount": 60,
      "advanceCount": 10,
      "settledCount": 30
    }
  }
}
```

#### 3.3 Get Customer by ID

```http
GET /customers/{customerId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "customerId": "uuid",
    "customerName": "John Doe",
    "mobileNumber": "9841234567",
    "address": "Kathmandu, Nepal",
    "panNumber": "123456789",
    "email": "john@example.com",
    "notes": "VIP customer",
    "balance": 5000.00,
    "balanceType": "UDHARO",
    "transactionCount": 15,
    "lastTransactionDate": "2024-11-18",
    "dueDate": "2024-11-25",
    "createdAt": "2024-11-01T10:30:00",
    "updatedAt": "2024-11-18T10:30:00"
  }
}
```

#### 3.4 Update Customer

```http
PUT /customers/{customerId}
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "mobileNumber": "9841234567",
  "address": "New Address",
  "panNumber": "123456789",
  "email": "newemail@example.com",
  "notes": "Updated notes"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Customer updated successfully",
  "data": { ... }
}
```

#### 3.5 Delete Customer

```http
DELETE /customers/{customerId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Customer deleted successfully",
  "data": null
}
```

**Error (400 Bad Request) - Customer has balance:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Cannot delete customer with non-zero balance",
    "details": {
      "customerId": "uuid",
      "currentBalance": 5000.00,
      "balanceType": "UDHARO"
    }
  }
}
```

#### 3.6 Set Due Date

```http
PATCH /customers/{customerId}/due-date
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "dueDate": "2024-12-01"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Due date updated successfully",
  "data": null
}
```

---

## 4. Transaction Management

### Base Path: `/transactions`
### Required Role: `MERCHANT`

#### 4.1 Create Sales Entry

```http
POST /transactions/sales
Authorization: Bearer {accessToken}
```

**Request Body (Simple Sale - No Items):**
```json
{
  "customerId": "uuid",
  "saleAmount": 5000.00,
  "paymentAmount": 2000.00,
  "paymentMode": "CASH",
  "billDate": "2024-11-18",
  "description": "Sale of goods",
  "billImages": ["url1", "url2"]
}
```

**Request Body (Itemized Sale - With Products):**
```json
{
  "customerId": "uuid",
  "saleAmount": 5000.00,
  "paymentAmount": 2000.00,
  "paymentMode": "CASH",
  "billDate": "2024-11-18",
  "description": "Sale of goods",
  "billImages": ["url1", "url2"],
  "items": [
    {
      "productId": "uuid",
      "quantity": 2,
      "unitPrice": 1500.00
    },
    {
      "productName": "Custom Item",
      "quantity": 1,
      "unitPrice": 2000.00
    }
  ]
}
```

**Notes:**
- `saleAmount`: Total sale amount
- `paymentAmount`: Amount paid by customer (can be 0 for full credit)
- `paymentMode`: CASH, DIGITAL, BANK_TRANSFER, CHEQUE
- `items`: Optional array for itemized sales
  - Can use `productId` for catalog products (with stock tracking)
  - Can use `productName` for ad-hoc items (no stock tracking)
- Stock is automatically deducted for tracked products

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Sale recorded successfully",
  "data": {
    "transactionId": "uuid",
    "transactionType": "SALE",
    "customerId": "uuid",
    "customerName": "John Doe",
    "saleAmount": 5000.00,
    "paymentAmount": 2000.00,
    "balanceAfter": 8000.00,
    "paymentMode": "CASH",
    "billDate": "2024-11-18",
    "description": "Sale of goods",
    "billImages": ["url1", "url2"],
    "items": [
      {
        "productId": "uuid",
        "productName": "Product A",
        "quantity": 2,
        "unitPrice": 1500.00,
        "totalPrice": 3000.00
      }
    ],
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

**Error (400 Bad Request) - Insufficient Stock:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Insufficient stock for product 'Product A'. Available: 1, Requested: 2",
    "details": {
      "productId": "uuid",
      "productName": "Product A",
      "availableStock": 1,
      "requestedQuantity": 2
    }
  }
}
```

#### 4.2 Create Payment Entry

```http
POST /transactions/payment
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "customerId": "uuid",
  "paymentAmount": 3000.00,
  "paymentMode": "DIGITAL",
  "billDate": "2024-11-18",
  "description": "Payment received"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Payment recorded successfully",
  "data": {
    "transactionId": "uuid",
    "transactionType": "PAYMENT",
    "customerId": "uuid",
    "customerName": "John Doe",
    "saleAmount": 0.00,
    "paymentAmount": 3000.00,
    "balanceAfter": 2000.00,
    "paymentMode": "DIGITAL",
    "billDate": "2024-11-18",
    "description": "Payment received",
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 4.3 Get Transaction by ID

```http
GET /transactions/{transactionId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "transactionId": "uuid",
    "transactionType": "SALE",
    "customerId": "uuid",
    "customerName": "John Doe",
    "saleAmount": 5000.00,
    "paymentAmount": 2000.00,
    "balanceAfter": 8000.00,
    "paymentMode": "CASH",
    "billDate": "2024-11-18",
    "description": "Sale of goods",
    "billImages": ["url1", "url2"],
    "items": [
      {
        "productId": "uuid",
        "productName": "Product A",
        "quantity": 2,
        "unitPrice": 1500.00,
        "totalPrice": 3000.00
      }
    ],
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 4.4 Get Transaction Items

```http
GET /transactions/{transactionId}/items
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "productId": "uuid",
      "productName": "Product A",
      "quantity": 2,
      "unitPrice": 1500.00,
      "totalPrice": 3000.00
    },
    {
      "productId": null,
      "productName": "Custom Item",
      "quantity": 1,
      "unitPrice": 2000.00,
      "totalPrice": 2000.00
    }
  ]
}
```

#### 4.5 Get Customer Transactions

```http
GET /transactions/customer/{customerId}?page=0&size=20&type=ALL
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `type` (optional, default: ALL) - Filter by type
  - `ALL` - All transactions
  - `SALE` - Only sales
  - `PAYMENT` - Only payments

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "transactionId": "uuid",
        "transactionType": "SALE",
        "saleAmount": 5000.00,
        "paymentAmount": 2000.00,
        "balanceAfter": 8000.00,
        "billDate": "2024-11-18",
        "createdAt": "2024-11-18T10:30:00"
      }
    ],
    "pageable": { ... },
    "totalElements": 50,
    "totalPages": 3,
    "size": 20,
    "number": 0
  }
}
```

#### 4.6 Get Merchant Recent Transactions

```http
GET /transactions/merchant-recent-transactions/{limit}
Authorization: Bearer {accessToken}
```

**Path Parameters:**
- `limit` - Number of recent transactions to return

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "transactionId": "uuid",
      "transactionType": "SALE",
      "customerId": "uuid",
      "customerName": "John Doe",
      "saleAmount": 5000.00,
      "paymentAmount": 2000.00,
      "balanceAfter": 8000.00,
      "billDate": "2024-11-18",
      "createdAt": "2024-11-18T10:30:00"
    }
  ]
}
```

#### 4.7 Delete Transaction

```http
DELETE /transactions/{transactionId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Transaction deleted successfully",
  "data": null
}
```

**Note:** Can only delete if customer's current balance = 0

---

## 5. Ledger & Reports

### Base Path: `/ledger`
### Required Role: `MERCHANT`

#### 5.1 Get Customer Ledger

```http
GET /ledger/customer/{customerId}?startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `startDate` (required) - ISO date format (2024-01-01)
- `endDate` (required) - ISO date format (2024-12-31)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "customerId": "uuid",
    "customerName": "John Doe",
    "startDate": "2024-01-01",
    "endDate": "2024-12-31",
    "openingBalance": 0.00,
    "closingBalance": 5000.00,
    "totalSales": 50000.00,
    "totalPayments": 45000.00,
    "transactions": [
      {
        "transactionId": "uuid",
        "date": "2024-11-18",
        "type": "SALE",
        "description": "Sale of goods",
        "debit": 5000.00,
        "credit": 0.00,
        "balance": 5000.00
      },
      {
        "transactionId": "uuid",
        "date": "2024-11-19",
        "type": "PAYMENT",
        "description": "Payment received",
        "debit": 0.00,
        "credit": 3000.00,
        "balance": 2000.00
      }
    ]
  }
}
```

#### 5.2 Get Daily Summary

```http
GET /ledger/daily?date=2024-11-18
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `date` (required) - ISO date format

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "date": "2024-11-18",
    "totalSales": 50000.00,
    "totalPayments": 30000.00,
    "netChange": 20000.00,
    "transactionCount": 25,
    "saleCount": 18,
    "paymentCount": 7,
    "cashReceived": 15000.00,
    "digitalReceived": 15000.00
  }
}
```

#### 5.3 Get Date Range Summary

```http
GET /ledger/summary?startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `startDate` (required)
- `endDate` (required)

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-11-18",
      "totalSales": 50000.00,
      "totalPayments": 30000.00,
      "netChange": 20000.00,
      "transactionCount": 25
    },
    {
      "date": "2024-11-19",
      "totalSales": 40000.00,
      "totalPayments": 35000.00,
      "netChange": 5000.00,
      "transactionCount": 20
    }
  ]
}
```

---

## 6. Supplier Management

### Base Path: `/api/v1/suppliers`
### Required Role: `MERCHANT`

#### 6.1 Create Supplier

```http
POST /api/v1/suppliers
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "supplierName": "ABC Suppliers Pvt Ltd",
  "mobileNumber": "9841234567",
  "email": "abc@suppliers.com",
  "address": "Kathmandu, Nepal",
  "panNumber": "123456789",
  "gstNumber": "GST123456",
  "notes": "Main supplier for electronics"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Supplier created successfully",
  "data": {
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "mobileNumber": "9841234567",
    "email": "abc@suppliers.com",
    "address": "Kathmandu, Nepal",
    "balance": 0.00,
    "balanceType": "SETTLED",
    "purchaseCount": 0,
    "lastPurchaseDate": null,
    "dueDate": null,
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 6.2 List All Suppliers

```http
GET /api/v1/suppliers?page=0&size=20&search=ABC&balanceType=ALL&sortBy=RECENT
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `search` (optional) - Search by name, mobile, or email
- `balanceType` (optional, default: ALL)
  - `ALL` - All suppliers
  - `UDHARO` - Suppliers we owe money to (payable)
  - `ADVANCE` - Suppliers who owe us (advance paid)
  - `SETTLED` - Zero balance suppliers
- `sortBy` (optional, default: RECENT)
  - `RECENT` - Recently created first
  - `NAME_ASC` - Name A-Z
  - `NAME_DESC` - Name Z-A
  - `BALANCE_HIGH` - Highest balance first
  - `BALANCE_LOW` - Lowest balance first

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "supplierId": "uuid",
        "supplierName": "ABC Suppliers Pvt Ltd",
        "mobileNumber": "9841234567",
        "balance": 25000.00,
        "balanceType": "UDHARO",
        "purchaseCount": 15,
        "lastPurchaseDate": "2024-11-18",
        "dueDate": "2024-11-25"
      }
    ],
    "pageable": { ... },
    "totalElements": 50,
    "totalPages": 3
  }
}
```

#### 6.3 Get Supplier by ID

```http
GET /api/v1/suppliers/{supplierId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "mobileNumber": "9841234567",
    "email": "abc@suppliers.com",
    "address": "Kathmandu, Nepal",
    "panNumber": "123456789",
    "gstNumber": "GST123456",
    "notes": "Main supplier for electronics",
    "balance": 25000.00,
    "balanceType": "UDHARO",
    "purchaseCount": 15,
    "lastPurchaseDate": "2024-11-18",
    "dueDate": "2024-11-25",
    "createdAt": "2024-11-01T10:30:00",
    "updatedAt": "2024-11-18T10:30:00"
  }
}
```

#### 6.4 Update Supplier

```http
PUT /api/v1/suppliers/{supplierId}
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "supplierName": "ABC Suppliers Pvt Ltd (Updated)",
  "mobileNumber": "9841234567",
  "email": "newemail@suppliers.com",
  "address": "New Address",
  "panNumber": "123456789",
  "gstNumber": "GST123456",
  "notes": "Updated notes"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Supplier updated successfully",
  "data": { ... }
}
```

#### 6.5 Delete Supplier

```http
DELETE /api/v1/suppliers/{supplierId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Supplier deleted successfully",
  "data": null
}
```

**Error (400 Bad Request) - Supplier has balance:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Cannot delete supplier with outstanding balance",
    "details": {
      "supplierId": "uuid",
      "currentBalance": 25000.00,
      "balanceType": "UDHARO"
    }
  }
}
```

#### 6.6 Set Supplier Due Date

```http
PUT /api/v1/suppliers/{supplierId}/due-date
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "dueDate": "2024-12-01"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Due date set successfully",
  "data": null
}
```

---

## 7. Product & Inventory Management

### Base Path: `/api/v1/products`
### Required Role: `MERCHANT`

#### 7.1 Create Product

```http
POST /api/v1/products
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "productName": "Samsung Galaxy S24",
  "description": "Latest Samsung flagship phone",
  "category": "Electronics",
  "sku": "SAM-S24-001",
  "barcode": "1234567890123",
  "costPrice": 80000.00,
  "sellingPrice": 95000.00,
  "trackInventory": true,
  "stockQuantity": 10,
  "minStockLevel": 2,
  "unit": "PCS",
  "isActive": true
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "productId": "uuid",
    "productName": "Samsung Galaxy S24",
    "description": "Latest Samsung flagship phone",
    "category": "Electronics",
    "sku": "SAM-S24-001",
    "barcode": "1234567890123",
    "costPrice": 80000.00,
    "sellingPrice": 95000.00,
    "profitMargin": 18.75,
    "trackInventory": true,
    "stockQuantity": 10,
    "minStockLevel": 2,
    "stockStatus": "IN_STOCK",
    "unit": "PCS",
    "isActive": true,
    "imageUrls": [],
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 7.2 List All Products

```http
GET /api/v1/products?page=0&size=20&search=samsung&category=Electronics&inStock=true&lowStock=false&sortBy=NAME_ASC
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `search` (optional) - Search by name, SKU, or barcode
- `category` (optional) - Filter by category
- `inStock` (optional) - Filter by stock availability (true/false)
- `lowStock` (optional) - Filter low stock items (true/false)
- `sortBy` (optional, default: RECENT)
  - `RECENT` - Recently created first
  - `NAME_ASC` - Name A-Z
  - `NAME_DESC` - Name Z-A
  - `PRICE_LOW` - Lowest price first
  - `PRICE_HIGH` - Highest price first
  - `STOCK_LOW` - Lowest stock first
  - `STOCK_HIGH` - Highest stock first

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "productId": "uuid",
        "productName": "Samsung Galaxy S24",
        "category": "Electronics",
        "sku": "SAM-S24-001",
        "barcode": "1234567890123",
        "sellingPrice": 95000.00,
        "stockQuantity": 10,
        "stockStatus": "IN_STOCK",
        "imageUrls": ["url1"],
        "isActive": true
      }
    ],
    "pageable": { ... },
    "totalElements": 150,
    "totalPages": 8
  }
}
```

#### 7.3 Get Product by ID

```http
GET /api/v1/products/{productId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "productId": "uuid",
    "productName": "Samsung Galaxy S24",
    "description": "Latest Samsung flagship phone",
    "category": "Electronics",
    "sku": "SAM-S24-001",
    "barcode": "1234567890123",
    "costPrice": 80000.00,
    "sellingPrice": 95000.00,
    "profitMargin": 18.75,
    "trackInventory": true,
    "stockQuantity": 10,
    "minStockLevel": 2,
    "stockStatus": "IN_STOCK",
    "unit": "PCS",
    "isActive": true,
    "imageUrls": ["url1", "url2"],
    "createdAt": "2024-11-01T10:30:00",
    "updatedAt": "2024-11-18T10:30:00"
  }
}
```

#### 7.4 Get Product by Barcode

```http
GET /api/v1/products/barcode/{barcode}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": { ... }
}
```

#### 7.5 Get Product by SKU

```http
GET /api/v1/products/sku/{sku}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": { ... }
}
```

#### 7.6 Update Product

```http
PUT /api/v1/products/{productId}
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "productName": "Samsung Galaxy S24 (Updated)",
  "description": "Updated description",
  "category": "Electronics",
  "sku": "SAM-S24-001",
  "barcode": "1234567890123",
  "costPrice": 80000.00,
  "sellingPrice": 98000.00,
  "minStockLevel": 3,
  "unit": "PCS",
  "isActive": true
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": { ... }
}
```

#### 7.7 Delete Product

```http
DELETE /api/v1/products/{productId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Product deleted successfully",
  "data": null
}
```

#### 7.8 Adjust Stock Manually

```http
POST /api/v1/products/{productId}/adjust-stock
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "adjustmentType": "ADD",
  "quantity": 5,
  "reason": "Stock correction after physical count"
}
```

**adjustmentType values:**
- `ADD` - Add to stock
- `REMOVE` - Remove from stock

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Stock adjusted successfully",
  "data": {
    "productId": "uuid",
    "productName": "Samsung Galaxy S24",
    "previousStock": 10,
    "adjustedQuantity": 5,
    "newStock": 15,
    "adjustmentType": "ADD"
  }
}
```

#### 7.9 Get Low Stock Products

```http
GET /api/v1/products/low-stock?page=0&size=20
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "productId": "uuid",
        "productName": "Product A",
        "stockQuantity": 1,
        "minStockLevel": 5,
        "stockStatus": "LOW_STOCK",
        "sellingPrice": 1000.00
      }
    ],
    "totalElements": 10
  }
}
```

#### 7.10 Get Product Categories

```http
GET /api/v1/products/categories
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "category": "Electronics",
      "productCount": 50
    },
    {
      "category": "Clothing",
      "productCount": 30
    }
  ]
}
```

---

## 8. Purchase Management

### Base Path: `/api/v1/purchases`
### Required Role: `MERCHANT`

#### 8.1 Create Purchase with Items

```http
POST /api/v1/purchases
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "supplierId": "uuid",
  "purchaseAmount": 100000.00,
  "paymentAmount": 50000.00,
  "paymentMode": "BANK_TRANSFER",
  "billDate": "2024-11-18",
  "billNumber": "INV-2024-001",
  "description": "Purchase of electronics",
  "billImages": ["url1", "url2"],
  "items": [
    {
      "productId": "uuid",
      "quantity": 10,
      "unitPrice": 8000.00
    },
    {
      "productId": "uuid2",
      "quantity": 5,
      "unitPrice": 4000.00
    }
  ]
}
```

**Notes:**
- `purchaseAmount`: Total purchase amount
- `paymentAmount`: Amount paid to supplier (can be 0 for full credit)
- `items`: Array of purchased products
- Stock is automatically updated for tracked products
- Cost price is recalculated using weighted average method

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Purchase created successfully",
  "data": {
    "purchaseId": "uuid",
    "transactionType": "PURCHASE",
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "purchaseAmount": 100000.00,
    "paymentAmount": 50000.00,
    "balanceAfter": 75000.00,
    "paymentMode": "BANK_TRANSFER",
    "billDate": "2024-11-18",
    "billNumber": "INV-2024-001",
    "description": "Purchase of electronics",
    "billImages": ["url1", "url2"],
    "items": [
      {
        "productId": "uuid",
        "productName": "Samsung Galaxy S24",
        "quantity": 10,
        "unitPrice": 8000.00,
        "totalPrice": 80000.00
      },
      {
        "productId": "uuid2",
        "productName": "iPhone 15",
        "quantity": 5,
        "unitPrice": 4000.00,
        "totalPrice": 20000.00
      }
    ],
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 8.2 Record Supplier Payment

```http
POST /api/v1/purchases/payment
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "supplierId": "uuid",
  "paymentAmount": 25000.00,
  "paymentMode": "CASH",
  "billDate": "2024-11-18",
  "description": "Payment to supplier"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Payment recorded successfully",
  "data": {
    "purchaseId": "uuid",
    "transactionType": "PAYMENT",
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "purchaseAmount": 0.00,
    "paymentAmount": 25000.00,
    "balanceAfter": 50000.00,
    "paymentMode": "CASH",
    "billDate": "2024-11-18",
    "description": "Payment to supplier",
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 8.3 List All Purchases

```http
GET /api/v1/purchases?page=0&size=20&supplierId=uuid&startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `supplierId` (optional) - Filter by supplier
- `startDate` (optional) - Filter by date range
- `endDate` (optional) - Filter by date range

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "purchaseId": "uuid",
        "transactionType": "PURCHASE",
        "supplierName": "ABC Suppliers Pvt Ltd",
        "purchaseAmount": 100000.00,
        "paymentAmount": 50000.00,
        "balanceAfter": 75000.00,
        "billDate": "2024-11-18",
        "billNumber": "INV-2024-001"
      }
    ],
    "totalElements": 50,
    "totalPages": 3
  }
}
```

#### 8.4 Get Purchase by ID

```http
GET /api/v1/purchases/{purchaseId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "purchaseId": "uuid",
    "transactionType": "PURCHASE",
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "purchaseAmount": 100000.00,
    "paymentAmount": 50000.00,
    "balanceAfter": 75000.00,
    "paymentMode": "BANK_TRANSFER",
    "billDate": "2024-11-18",
    "billNumber": "INV-2024-001",
    "description": "Purchase of electronics",
    "billImages": ["url1", "url2"],
    "items": [
      {
        "productId": "uuid",
        "productName": "Samsung Galaxy S24",
        "quantity": 10,
        "unitPrice": 8000.00,
        "totalPrice": 80000.00
      }
    ],
    "createdAt": "2024-11-18T10:30:00"
  }
}
```

#### 8.5 Update Purchase

```http
PUT /api/v1/purchases/{purchaseId}
Authorization: Bearer {accessToken}
```

**Request Body (Limited Fields):**
```json
{
  "billNumber": "INV-2024-001-UPDATED",
  "description": "Updated description",
  "paymentMode": "CASH"
}
```

**Note:** Cannot update amounts or items to maintain balance integrity

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Purchase updated successfully",
  "data": { ... }
}
```

#### 8.6 Delete Purchase

```http
DELETE /api/v1/purchases/{purchaseId}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Purchase deleted successfully",
  "data": null
}
```

**Note:** Can only delete if supplier's current balance = 0

#### 8.7 Get Supplier Ledger

```http
GET /api/v1/purchases/supplier/{supplierId}/ledger?startDate=2024-01-01&endDate=2024-12-31&page=0&size=20
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "supplierId": "uuid",
    "supplierName": "ABC Suppliers Pvt Ltd",
    "startDate": "2024-01-01",
    "endDate": "2024-12-31",
    "openingBalance": 50000.00,
    "closingBalance": 75000.00,
    "totalPurchases": 500000.00,
    "totalPayments": 475000.00,
    "transactions": {
      "content": [
        {
          "purchaseId": "uuid",
          "date": "2024-11-18",
          "type": "PURCHASE",
          "description": "Purchase of electronics",
          "debit": 100000.00,
          "credit": 0.00,
          "balance": 150000.00
        },
        {
          "purchaseId": "uuid",
          "date": "2024-11-19",
          "type": "PAYMENT",
          "description": "Payment to supplier",
          "debit": 0.00,
          "credit": 50000.00,
          "balance": 100000.00
        }
      ],
      "totalElements": 50,
      "totalPages": 3
    }
  }
}
```

#### 8.8 Get Purchase Summary

```http
GET /api/v1/purchases/summary?startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "startDate": "2024-01-01",
    "endDate": "2024-12-31",
    "totalPurchaseAmount": 1000000.00,
    "totalPaymentAmount": 800000.00,
    "outstandingPayable": 200000.00,
    "purchaseCount": 150,
    "paymentCount": 120,
    "averagePurchaseAmount": 6666.67,
    "supplierCount": 25
  }
}
```

---

## 9. Analytics & Dashboard

### Base Path: `/api/v1/analytics`
### Required Role: `MERCHANT`

#### 9.1 Get Complete Dashboard Analytics

```http
GET /api/v1/analytics/dashboard
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "inventory": {
      "totalProducts": 150,
      "trackedProducts": 140,
      "totalStockQuantity": 5000,
      "totalCostValue": 5000000.00,
      "totalRetailValue": 6500000.00,
      "potentialProfit": 1500000.00,
      "profitMarginPercentage": 30.00,
      "lowStockCount": 15,
      "outOfStockCount": 5,
      "categoryBreakdown": {
        "Electronics": {
          "productCount": 50,
          "totalStock": 2000,
          "totalCostValue": 2000000.00,
          "totalRetailValue": 2600000.00
        },
        "Clothing": {
          "productCount": 100,
          "totalStock": 3000,
          "totalCostValue": 3000000.00,
          "totalRetailValue": 3900000.00
        }
      }
    },
    "suppliers": {
      "totalSuppliers": 25,
      "totalPayable": 500000.00,
      "totalAdvance": 50000.00,
      "payableCount": 15,
      "advanceCount": 3,
      "settledCount": 7,
      "upcomingDueCount": 5,
      "overdueCount": 2
    },
    "generatedAt": "2024-11-18"
  }
}
```

#### 9.2 Get Inventory Analytics

```http
GET /api/v1/analytics/inventory
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "totalProducts": 150,
    "trackedProducts": 140,
    "totalStockQuantity": 5000,
    "totalCostValue": 5000000.00,
    "totalRetailValue": 6500000.00,
    "potentialProfit": 1500000.00,
    "profitMarginPercentage": 30.00,
    "lowStockCount": 15,
    "outOfStockCount": 5,
    "categoryBreakdown": {
      "Electronics": {
        "productCount": 50,
        "totalStock": 2000,
        "totalCostValue": 2000000.00,
        "totalRetailValue": 2600000.00
      }
    }
  }
}
```

#### 9.3 Get Supplier Analytics

```http
GET /api/v1/analytics/suppliers
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "totalSuppliers": 25,
    "totalPayable": 500000.00,
    "totalAdvance": 50000.00,
    "payableCount": 15,
    "advanceCount": 3,
    "settledCount": 7,
    "upcomingDueCount": 5,
    "overdueCount": 2
  }
}
```

#### 9.4 Get Reorder Suggestions

```http
GET /api/v1/analytics/reorder-suggestions
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Found 15 products that need reordering",
  "data": [
    {
      "productId": "uuid",
      "productName": "Samsung Galaxy S24",
      "currentStock": 2,
      "minStockLevel": 5,
      "suggestedOrderQuantity": 10,
      "category": "Electronics"
    },
    {
      "productId": "uuid2",
      "productName": "iPhone 15",
      "currentStock": 0,
      "minStockLevel": 3,
      "suggestedOrderQuantity": 6,
      "category": "Electronics"
    }
  ]
}
```

#### 9.5 Get Top Selling Products

```http
GET /api/v1/analytics/top-selling?limit=10
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `limit` (optional, default: 10) - Number of products to return

**Response (200 OK):**
```json
{
  "success": true,
  "data": []
}
```

**Note:** Currently returns empty list. Will be implemented when sales analytics data is available.

---

## 10. Report Generation

### Base Path: `/reports`
### Required Role: `MERCHANT`

All report endpoints return file downloads (PDF or Excel).

#### 10.1 Generate Customer Ledger Report

```http
POST /reports/customer/{customerId}
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "format": "PDF",
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

**format values:**
- `PDF` - PDF format
- `EXCEL` - Excel format

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Report generated successfully",
  "data": {
    "reportUrl": "/api/v1/reports/download/John_Doe_20241118_103000_abc12345.pdf",
    "fileName": "John_Doe_20241118_103000_abc12345.pdf",
    "expiresAt": "2024-11-19T10:30:00",
    "format": "PDF"
  }
}
```

#### 10.2 Download Report

```http
GET /reports/download/{fileName}
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
- Returns file download with appropriate Content-Type
- PDF: `application/pdf`
- Excel: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

#### 10.3 Generate Supplier Ledger PDF

```http
GET /reports/supplier/{supplierId}/ledger/pdf?startDate=2024-01-01&endDate=2024-12-31
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `startDate` (required) - ISO date
- `endDate` (required) - ISO date

**Response (200 OK):**
- Direct PDF file download
- Filename: `supplier_ledger_{supplierId}_2024-11-18.pdf`

**Report Contents:**
- Merchant business name header
- Supplier details (name, mobile)
- Date range
- Opening balance
- Transaction table (Date, Type, Description, Purchase (Dr), Payment (Cr), Balance)
- Closing balance
- Total purchases and payments summary

#### 10.4 Generate Purchase History Excel

```http
GET /reports/purchases/excel?startDate=2024-01-01&endDate=2024-12-31&supplierId=uuid
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `startDate` (required) - ISO date
- `endDate` (required) - ISO date
- `supplierId` (optional) - Filter by specific supplier

**Response (200 OK):**
- Direct Excel file download
- Filename: `purchase_history_2024-01-01_to_2024-12-31.xlsx`

**Report Contents:**
- All purchase records for date range
- Columns: Date, Bill Number, Supplier, Purchase Amount, Payment Amount, Balance After, Payment Mode, Description
- Summary row with totals

#### 10.5 Generate Inventory Valuation PDF

```http
GET /reports/inventory/valuation/pdf?category=Electronics&lowStockOnly=false
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `category` (optional) - Filter by product category
- `lowStockOnly` (optional) - Show only low stock products (true/false)

**Response (200 OK):**
- Direct PDF file download
- Filename: `inventory_valuation_2024-11-18.pdf`

**Report Contents:**
- Product list with stock quantities, cost price, selling price
- Stock value calculation (cost × quantity)
- Stock status indicators (OK/LOW/OUT/N/T)
- Category breakdown
- Total cost value and retail value
- Potential profit and profit margin percentage

#### 10.6 Generate Stock Movement Excel

```http
GET /reports/stock-movements/excel?startDate=2024-01-01&endDate=2024-12-31&productId=uuid
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `startDate` (required) - ISO date
- `endDate` (required) - ISO date
- `productId` (optional) - Filter by specific product

**Response (200 OK):**
- Direct Excel file download
- Filename: `stock_movements_2024-01-01_to_2024-12-31.xlsx`

**Report Contents:**
- All stock movements for date range
- Columns: Date, Product, Type, Quantity (+/-), Stock Before, Stock After, Reference, Description
- Movement types: PURCHASE, SALE, ADJUSTMENT_IN, ADJUSTMENT_OUT

---

## 11. Error Codes

### Standard Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `AUTHENTICATION_FAILED` | 401 | Invalid credentials |
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Duplicate resource (e.g., SKU, barcode) |
| `INTERNAL_SERVER_ERROR` | 500 | Server error |

### Common Error Scenarios

#### Insufficient Stock
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Insufficient stock for product 'Samsung Galaxy S24'. Available: 1, Requested: 2",
    "details": {
      "productId": "uuid",
      "productName": "Samsung Galaxy S24",
      "availableStock": 1,
      "requestedQuantity": 2
    }
  }
}
```

#### Cannot Delete with Balance
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Cannot delete customer with non-zero balance",
    "details": {
      "customerId": "uuid",
      "currentBalance": 5000.00,
      "balanceType": "UDHARO"
    }
  }
}
```

#### Resource Not Found
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Customer not found with id: uuid123"
  },
  "timestamp": "2024-11-18T10:30:00Z",
  "path": "/api/v1/customers/uuid123"
}
```

#### Duplicate SKU/Barcode
```json
{
  "success": false,
  "error": {
    "code": "CONFLICT",
    "message": "Product with SKU 'SAM-S24-001' already exists",
    "details": {
      "field": "sku",
      "value": "SAM-S24-001",
      "existingProductId": "uuid"
    }
  }
}
```

---

## 12. Testing Endpoints

### Base URL for Testing

**Local Development:**
```
http://localhost:8080/api/v1
```

**Staging:**
```
http://staging.your-domain.com/api/v1
```

### Postman Collection

A complete Postman collection is available with:
- All endpoints pre-configured
- Environment variables for base URL and tokens
- Sample requests and responses
- Pre-request scripts for authentication

### cURL Examples

#### Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "mobileNumber": "9841234567",
    "password": "SecurePass123"
  }'
```

#### Create Customer (with token)
```bash
curl -X POST http://localhost:8080/api/v1/customers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "John Doe",
    "mobileNumber": "9841234567",
    "address": "Kathmandu, Nepal"
  }'
```

---

## 13. Mobile App Integration Tips

### 13.1 Token Management

**Store Tokens Securely:**
- Use Flutter Secure Storage for tokens
- Store both access token and refresh token
- Implement automatic token refresh before expiry

```dart
// Example token refresh logic
if (tokenExpiresAt.isBefore(DateTime.now().add(Duration(minutes: 5)))) {
  await refreshAccessToken();
}
```

### 13.2 Error Handling

**Standardized Error Handling:**
```dart
try {
  final response = await api.createCustomer(data);
  if (response.success) {
    // Handle success
  }
} on ApiException catch (e) {
  if (e.code == 'VALIDATION_ERROR') {
    // Show validation errors
    showDialog(context, e.message);
  } else if (e.statusCode == 401) {
    // Redirect to login
    navigateToLogin();
  }
}
```

### 13.3 Pagination

**Implement Infinite Scroll:**
```dart
// Example pagination logic
int currentPage = 0;
bool hasMore = true;

Future<void> loadMore() async {
  if (!hasMore) return;

  final response = await api.getCustomers(page: currentPage);
  customers.addAll(response.data.customers);

  hasMore = response.data.pagination.hasNext;
  currentPage++;
}
```

### 13.4 Offline Support

**Cache Critical Data:**
- Customer list
- Product catalog
- Recent transactions
- Sync when online

### 13.5 Search & Filter

**Debounce Search Queries:**
```dart
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(Duration(milliseconds: 500), () {
    performSearch(query);
  });
}
```

### 13.6 Report Downloads

**Handle File Downloads:**
```dart
Future<void> downloadReport(String url) async {
  final response = await dio.download(
    url,
    savePath,
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  // Open file or show success message
}
```

---

## 14. Change Log

### Version 1.0.0 (2024-11-18)

**Phase 1 - Core Features:**
- ✅ Customer Management (CRUD)
- ✅ Transaction Management (Sales & Payments)
- ✅ Ledger Management
- ✅ Supplier Management (CRUD)
- ✅ Product & Inventory Management
- ✅ Purchase Management with automatic stock updates
- ✅ Sales-Inventory Integration with stock deduction

**Phase 2 - Analytics & Reports:**
- ✅ Dashboard Analytics (inventory, suppliers, reorder suggestions)
- ✅ Customer Ledger Reports (PDF/Excel)
- ✅ Supplier Ledger Reports (PDF)
- ✅ Purchase History Reports (Excel)
- ✅ Inventory Valuation Reports (PDF)
- ✅ Stock Movement Reports (Excel)

**Pending Features:**
- ⏳ Phase 3: Notifications & Alerts
- ⏳ Phase 4: Advanced Features (barcode generation, returns, multi-location)
- ⏳ Phase 5: Comprehensive Testing

---

## 15. Support & Documentation

### Additional Resources

- **CLAUDE.md** - Development guidelines and patterns
- **TODO.md** - Complete implementation roadmap
- **SUPPLIER_INVENTORY_API.md** - Detailed supplier/inventory API docs
- **BACKEND_API_SPEC.md** - Original backend API specifications

### Getting Help

For issues or questions:
1. Check this API specification
2. Review error messages and codes
3. Check application logs
4. Contact backend team

---

**End of API Specification**

This document covers all implemented endpoints as of November 18, 2024. For latest updates, check the git repository and TODO.md file.
