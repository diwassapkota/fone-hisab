# Backend API Recommendations for Better UX

This document outlines recommended backend changes to improve customer experience in the Fonepay Khata Book application.

## Priority 1: Critical Missing Endpoints

### 1. OTP Verification Endpoint
**Issue**: The frontend expects `/auth/verify-otp` but it's not documented in the OpenAPI spec.

**Recommendation**: Add the following endpoint:
```
POST /api/v1/auth/verify-otp
Content-Type: application/json

Request Body:
{
  "mobileNumber": "string",
  "otp": "string"
}

Response (200 OK):
{
  "success": true,
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "user": {
      "id": "string",
      "name": "string",
      "mobileNumber": "string",
      "email": "string",
      "businessName": "string"
    }
  }
}
```

**Alternative**: If OTP verification is not yet implemented, we can temporarily skip it in the frontend and go directly from register to login.

---

## Priority 2: Performance Optimizations

### 2. Customer Search Optimization
**Current**: The `/customers` endpoint supports search via query parameter but may not have database indexing.

**Recommendation**:
- Add database index on `customers.name` and `customers.mobileNumber` fields
- Implement full-text search for better search performance
- Consider trigram similarity search for fuzzy matching (e.g., PostgreSQL pg_trgm extension)

**Expected Impact**:
- Faster search results, especially with 1000+ customers
- Better user experience with instant search

---

### 3. Batch Operations for Offline Sync
**Current**: Individual POST/PUT/DELETE operations for each entity.

**Recommendation**: Add batch endpoints for offline sync scenarios:
```
POST /api/v1/transactions/batch
Content-Type: application/json

Request Body:
{
  "transactions": [
    {
      "customerId": "string",
      "type": "SALE",
      "saleAmount": 1000.0,
      "paymentAmount": 500.0,
      "paymentMode": "CASH",
      "billDate": "2025-11-15T10:30:00Z",
      "description": "string",
      "clientTimestamp": "2025-11-15T10:30:00Z",
      "tempId": "temp-123" // Client-generated ID for conflict resolution
    }
  ]
}

Response (200 OK):
{
  "success": true,
  "data": {
    "created": [
      {
        "tempId": "temp-123",
        "id": "uuid-from-server",
        "transaction": { /* full transaction object */ }
      }
    ],
    "failed": [
      {
        "tempId": "temp-456",
        "error": "Customer not found"
      }
    ]
  }
}
```

**Expected Impact**:
- Faster sync when app comes back online
- Reduced network calls (10 transactions = 1 API call instead of 10)
- Better error handling for partial failures

---

## Priority 3: Enhanced Customer Experience

### 4. Customer Transaction Summary in List
**Current**: `/customers` returns customer list, but summary requires separate calls to `/transactions/customer/{id}/summary`.

**Recommendation**: Add optional `includeSummary=true` query parameter to `/customers` endpoint:
```
GET /api/v1/customers?includeSummary=true&page=0&size=20

Response:
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "string",
        "name": "string",
        "mobileNumber": "string",
        "balance": 1500.0,
        "balanceType": "UDHARO",
        "summary": {
          "totalSales": 10000.0,
          "totalPayments": 8500.0,
          "transactionCount": 25,
          "lastTransactionDate": "2025-11-14T15:30:00Z"
        }
      }
    ],
    "totalCustomers": 150,
    "page": 0,
    "size": 20
  }
}
```

**Expected Impact**:
- Richer customer list UI without extra API calls
- Faster screen load time
- Better UX with transaction counts visible in list

---

### 5. Optimistic Locking for Concurrent Updates
**Current**: No version control or timestamp checking for updates.

**Recommendation**: Add `version` or `updatedAt` field to entities and implement optimistic locking:
```
PUT /api/v1/customers/{id}
Content-Type: application/json

Request Body:
{
  "name": "Updated Name",
  "version": 5  // or "updatedAt": "2025-11-15T10:00:00Z"
}

Response (409 Conflict) if version mismatch:
{
  "success": false,
  "error": {
    "code": "VERSION_CONFLICT",
    "message": "Customer was updated by another user. Please refresh and try again.",
    "currentVersion": 6
  }
}
```

**Expected Impact**:
- Prevents data loss from concurrent edits
- Better multi-device support
- Clear error messages to users

---

### 6. Pagination Metadata Standardization
**Current**: Response includes `totalCustomers` but frontend needs more metadata for infinite scroll.

**Recommendation**: Standardize pagination response format:
```json
{
  "success": true,
  "data": {
    "content": [ /* array of items */ ],
    "pagination": {
      "page": 0,
      "size": 20,
      "totalElements": 150,
      "totalPages": 8,
      "isFirst": true,
      "isLast": false,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

**Expected Impact**:
- Better infinite scroll implementation
- Accurate "Load More" button states
- Consistent pagination across all endpoints

---

## Priority 4: Advanced Features

### 7. Real-time Notifications via WebSocket
**Current**: Polling-based notification checking.

**Recommendation**: Implement WebSocket endpoint for real-time updates:
```
ws://localhost:8080/ws/notifications?token=<jwt-token>

Message Format:
{
  "type": "TRANSACTION_CREATED",
  "data": {
    "transactionId": "string",
    "customerId": "string",
    "amount": 1000.0,
    "type": "SALE"
  },
  "timestamp": "2025-11-15T10:30:00Z"
}
```

**Expected Impact**:
- Instant dispute notifications
- Real-time balance updates
- Better collaborative experience (multiple users/devices)

---

### 8. Transaction Filters and Sorting
**Current**: `/transactions/customer/{id}` returns all transactions without advanced filtering.

**Recommendation**: Add query parameters for filtering and sorting:
```
GET /api/v1/transactions/customer/{id}?
  type=SALE&
  paymentMode=CASH&
  startDate=2025-11-01&
  endDate=2025-11-15&
  minAmount=1000&
  maxAmount=5000&
  sortBy=billDate&
  sortOrder=DESC&
  page=0&
  size=20
```

**Expected Impact**:
- Powerful transaction search
- Better reporting capabilities
- Reduced data transfer (filter on server, not client)

---

### 9. Bulk Delete with Validation
**Current**: Individual delete operations.

**Recommendation**: Add bulk delete endpoint with validation:
```
DELETE /api/v1/customers/bulk
Content-Type: application/json

Request Body:
{
  "customerIds": ["id1", "id2", "id3"]
}

Response (200 OK):
{
  "success": true,
  "data": {
    "deleted": ["id1", "id3"],
    "failed": [
      {
        "customerId": "id2",
        "reason": "Customer has outstanding balance of Rs. 1500"
      }
    ]
  }
}
```

**Expected Impact**:
- Faster bulk operations
- Clear validation errors
- Better merchant productivity

---

### 10. Export Endpoints for Reports
**Current**: Reports are likely generated client-side from transaction data.

**Recommendation**: Add server-side report generation endpoints:
```
POST /api/v1/reports/customer/{id}/export
Content-Type: application/json

Request Body:
{
  "format": "PDF", // or "EXCEL", "CSV"
  "startDate": "2025-11-01",
  "endDate": "2025-11-15",
  "includeTransactions": true,
  "includeSummary": true
}

Response (200 OK):
{
  "success": true,
  "data": {
    "downloadUrl": "https://cdn.fonepay.com/reports/abc123.pdf",
    "expiresAt": "2025-11-15T12:00:00Z"
  }
}
```

**Expected Impact**:
- Professional PDF reports
- Reduced mobile data usage
- Consistent formatting across devices

---

## Priority 5: Data Integrity and Validation

### 11. Transaction Amount Validation
**Current**: Assumes client-side validation only.

**Recommendation**: Add server-side validation rules:
```java
@PostMapping("/transactions/sales")
public ResponseEntity<ApiResponse<Transaction>> createSale(@Valid @RequestBody SaleRequest request) {
    // Validate amounts
    if (request.getSaleAmount() <= 0) {
        throw new ValidationException("Sale amount must be greater than 0");
    }
    if (request.getPaymentAmount() < 0) {
        throw new ValidationException("Payment amount cannot be negative");
    }
    if (request.getPaymentAmount() > request.getSaleAmount()) {
        // This is allowed (advance payment scenario)
        // But log it for analytics
        logger.info("Advance payment: customerId={}, amount={}",
            request.getCustomerId(),
            request.getPaymentAmount() - request.getSaleAmount());
    }
    // ...
}
```

**Expected Impact**:
- Prevent data corruption from client bugs
- Consistent business rules enforcement
- Better audit trail

---

### 12. Soft Delete Instead of Hard Delete
**Current**: Likely hard deletes for customers.

**Recommendation**: Implement soft delete with `deletedAt` timestamp:
```java
@Entity
public class Customer {
    // ... other fields

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "deleted_by")
    private String deletedBy; // User ID who deleted
}

// Repository query
@Query("SELECT c FROM Customer c WHERE c.deletedAt IS NULL")
List<Customer> findAllActive();
```

**Expected Impact**:
- Data recovery in case of accidental deletion
- Better compliance with data retention policies
- Audit trail for deleted records

---

## Implementation Priority

### Phase 1 (Week 1): Critical for MVP
1. OTP Verification Endpoint
2. Customer Search Optimization (database indexing)
3. Pagination Metadata Standardization

### Phase 2 (Week 2-3): Enhanced UX
4. Customer Transaction Summary in List
5. Transaction Filters and Sorting
6. Transaction Amount Validation
7. Soft Delete Implementation

### Phase 3 (Week 4+): Advanced Features
8. Batch Operations for Offline Sync
9. Optimistic Locking
10. Real-time Notifications
11. Bulk Delete with Validation
12. Export Endpoints for Reports

---

## Additional Recommendations

### API Response Consistency
Ensure all endpoints follow this structure:
```json
{
  "success": true/false,
  "data": { /* response data */ },
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {} // Optional additional context
  },
  "timestamp": "2025-11-15T10:30:00Z"
}
```

### Error Codes Standardization
Define consistent error codes:
- `VALIDATION_ERROR`: Input validation failed
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `CONFLICT`: Resource conflict (e.g., duplicate, version mismatch)
- `INTERNAL_ERROR`: Server error

### Rate Limiting
Implement rate limiting to prevent abuse:
- 100 requests per minute per user for regular endpoints
- 10 requests per minute for export/report endpoints
- Return `429 Too Many Requests` with `Retry-After` header

---

## Questions for Backend Team

1. **OTP Implementation**: Is OTP verification planned? If not, should we skip it for MVP?
2. **Database**: Which database are you using (PostgreSQL, MySQL, MongoDB)? This affects indexing recommendations.
3. **File Storage**: Where should bill images be stored (S3, local storage, CDN)?
4. **Notification Service**: Do you have infrastructure for push notifications (FCM, APNS)?
5. **Export Formats**: Which report formats are priority (PDF, Excel, CSV)?
6. **Multi-tenancy**: Is the app single-merchant or multi-tenant? This affects data isolation.

---

## Testing Recommendations

Once backend changes are implemented:

1. **Load Testing**: Test with 10,000+ customers and 100,000+ transactions
2. **Concurrent User Testing**: Simulate multiple devices editing same customer
3. **Offline Sync Testing**: Test batch operations with 50+ queued transactions
4. **Network Failure Testing**: Ensure proper error messages and retry logic

---

## Contact

For any questions or clarifications, please reach out to the frontend team.

Last Updated: 2025-11-15
