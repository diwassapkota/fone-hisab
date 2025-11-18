# TODO - Fonepay Khata Book Implementation Progress

**Last Updated**: 2025-11-18
**Project**: Supplier, Inventory & Purchase Management Features

**Latest Progress**: Phase 3 (State Management - Riverpod Providers) ✅ COMPLETE

---

## Legend
- ✅ **COMPLETED** - Fully implemented and tested
- 🚧 **IN PROGRESS** - Currently being worked on
- ⏳ **PENDING** - Not started yet
- 🔄 **NEEDS UPDATE** - Existing code that needs modification
- ⚠️ **BLOCKED** - Waiting on dependencies

---

## Phase 1: Foundation Layer (Data Models & Enums)

### 1.1 Create Enums (`packages/shared_models/lib/enums/`)

| File | Status | Description |
|------|--------|-------------|
| `stock_status.dart` | ✅ | IN_STOCK, LOW_STOCK, OUT_OF_STOCK, NOT_TRACKED |
| `balance_type.dart` | ✅ | UDHARO, ADVANCE, SETTLED (shared for customers & suppliers) |
| `purchase_transaction_type.dart` | ✅ | PURCHASE, PAYMENT |
| `adjustment_type.dart` | ✅ | ADD, REMOVE (for stock adjustments) |
| `supplier_sort_by.dart` | ✅ | RECENT, NAME_ASC, NAME_DESC, BALANCE_HIGH, BALANCE_LOW |
| `product_sort_by.dart` | ✅ | RECENT, NAME_ASC, PRICE_LOW, PRICE_HIGH, STOCK_LOW, STOCK_HIGH |
| `payment_mode.dart` | ✅ | CASH, DIGITAL, BANK_TRANSFER, CHEQUE, OTHER |

**Notes:**
- ✅ Followed pattern from existing enums (customer_filter.dart, transaction_type.dart, dispute_status.dart)
- ✅ Used uppercase for enum values
- ✅ Added helper methods: `fromString()`, `displayName`, color/icon indicators

---

### 1.2 Create Models (`packages/shared_models/lib/models/`)

| File | Status | Description | Dependencies |
|------|--------|-------------|--------------|
| `supplier.dart` | ✅ | Supplier entity with balance tracking | balance_type.dart |
| `product.dart` | ✅ | Product/inventory entity with stock tracking | stock_status.dart |
| `purchase.dart` | ✅ | Purchase transaction with items | purchase_transaction_type.dart, payment_mode.dart |
| `purchase_item.dart` | ✅ | Individual purchase line items | - |
| `inventory_analytics.dart` | ✅ | Dashboard inventory metrics | - |
| `supplier_analytics.dart` | ✅ | Dashboard supplier metrics | - |
| `stock_movement.dart` | ✅ | Stock movement history | - |
| `category.dart` | ✅ | Product category with count | - |
| `reorder_suggestion.dart` | ✅ | Low stock reorder suggestions | - |

**Notes:**
- ✅ Followed Freezed + JSON serialization pattern
- ✅ Added comprehensive extension methods for each model
- ✅ Used existing models as patterns (customer.dart, transaction.dart, sale_item.dart)
- ✅ All models match API specification from COMPLETE_API_SPECIFICATION.md

**Model Specifications:**

#### Supplier Model
```dart
@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String supplierId,
    required String supplierName,
    required String mobileNumber,
    String? email,
    String? address,
    String? panNumber,
    String? gstNumber,
    String? notes,
    @Default(0.0) double balance,
    required String balanceType, // UDHARO, ADVANCE, SETTLED
    @Default(0) int purchaseCount,
    DateTime? lastPurchaseDate,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}
```

#### Product Model
```dart
@freezed
class Product with _$Product {
  const factory Product({
    required String productId,
    required String productName,
    String? description,
    String? category,
    String? sku,
    String? barcode,
    required double costPrice,
    required double sellingPrice,
    @Default(0.0) double profitMargin,
    @Default(true) bool trackInventory,
    @Default(0) int stockQuantity,
    @Default(0) int minStockLevel,
    required String stockStatus, // IN_STOCK, LOW_STOCK, OUT_OF_STOCK, NOT_TRACKED
    @Default('PCS') String unit,
    @Default(true) bool isActive,
    @Default([]) List<String> imageUrls,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
```

#### Purchase Model
```dart
@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required String purchaseId,
    required String transactionType, // PURCHASE, PAYMENT
    required String supplierId,
    required String supplierName,
    required double purchaseAmount,
    required double paymentAmount,
    double? balanceAfter,
    required String paymentMode,
    required DateTime billDate,
    String? billNumber,
    String? description,
    @Default([]) List<String> billImages,
    @Default([]) List<PurchaseItem> items,
    required DateTime createdAt,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}
```

---

### 1.3 Update Export Files

| File | Status | Tasks |
|------|--------|-------|
| `packages/shared_models/lib/shared_models.dart` | ✅ | Exported all 9 new models and 7 new enums |

**Code Generation:**
✅ **COMPLETED**: Generated 36 files (18 .freezed.dart + 18 .g.dart) successfully.
- All models now have Freezed and JSON serialization code
- `flutter analyze` shows only 1 pre-existing warning (not related to new models)
- Phase 1 is now 100% complete and ready for Phase 2

---

## Phase 2: Services Layer (API Integration)

### 2.1 Update API Config (`packages/shared_services/lib/config/api_config.dart`)

| Status | Endpoints Added |
|--------|------------------|
| ✅ | **Supplier Endpoints**: 3 endpoints (list, by ID, due date) |
| ✅ | **Product Endpoints**: 7 endpoints (list, by ID/barcode/SKU, adjust stock, low stock, categories) |
| ✅ | **Purchase Endpoints**: 5 endpoints (create, payment, list, ledger, summary) |
| ✅ | **Analytics Endpoints**: 5 endpoints (dashboard, inventory, suppliers, reorder, top-selling) |
| ✅ | **Report Endpoints**: 4 endpoints (supplier ledger PDF, purchase Excel, inventory PDF, stock movements Excel) |

**Total: 24 new API endpoints added**

---

### 2.2 Create API Services (`packages/shared_services/lib/api/`)

| File | Status | Methods Implemented |
|------|--------|---------------------|
| `supplier_service.dart` | ✅ | 6 methods: getSuppliers, getSupplierById, createSupplier, updateSupplier, deleteSupplier, setSupplierDueDate |
| `product_service.dart` | ✅ | 10 methods: getProducts, getProductById, getProductByBarcode, getProductBySku, createProduct, updateProduct, deleteProduct, adjustStock, getLowStockProducts, getCategories |
| `purchase_service.dart` | ✅ | 9 methods: createPurchase, createSupplierPayment, getPurchases, getPurchaseById, updatePurchase, deletePurchase, getSupplierLedger, getPurchaseSummary |
| `analytics_service.dart` | ✅ | 5 methods: getDashboardAnalytics, getInventoryAnalytics, getSupplierAnalytics, getReorderSuggestions, getTopSellingProducts |

**Total: 4 services created with 30 methods**

**Notes:**
- ✅ All services follow existing patterns (CustomerService, TransactionService)
- ✅ Comprehensive error handling with try-catch blocks
- ✅ All methods return ApiResponse<T> for consistent response handling
- ✅ Query parameters properly formatted
- ✅ Date formatting handled (ISO 8601 format for API)

---

### 2.3 Update Service Exports

| File | Status | Tasks |
|------|--------|-------|
| `packages/shared_services/lib/shared_services.dart` | ✅ | Exported all 4 new service classes (Supplier, Product, Purchase, Analytics) |

---

## Phase 3: State Management (Riverpod Providers) ✅ COMPLETE

### 3.1 Update Service Providers (`apps/merchant_app/lib/config/providers.dart`)

| Provider | Status | Description |
|----------|--------|-------------|
| `supplierServiceProvider` | ✅ | Supplier service instance |
| `productServiceProvider` | ✅ | Product service instance |
| `purchaseServiceProvider` | ✅ | Purchase service instance |
| `analyticsServiceProvider` | ✅ | Analytics service instance |
| `reportServiceProvider` | ⏳ | Report service instance (deferred to Phase 2) |

**Notes:**
- ✅ All 4 service providers added to config/providers.dart
- ✅ Follows existing pattern with DioClient dependency injection

---

### 3.2 Supplier Providers (`apps/merchant_app/lib/features/suppliers/providers/`)

| File | Status | Providers | Pattern Reference |
|------|--------|-----------|-------------------|
| `supplier_providers.dart` | ✅ | supplierFilterProvider, supplierSearchProvider, supplierSortByProvider, suppliersProvider, supplierListProvider, supplierSummaryProvider | customer_providers.dart |
| `supplier_detail_providers.dart` | ✅ | supplierDetailProvider, supplierPurchasesProvider, purchaseListProvider, purchaseSummaryProvider, purchaseFilterProvider | customer_detail_providers.dart |

**Implementation Details:**
- ✅ `supplier_providers.dart`: List, filter (ALL/PAYABLE/ADVANCE/SETTLED), search, sort providers
- ✅ `supplier_detail_providers.dart`: Detail, ledger with purchase filter (ALL/PURCHASE/PAYMENT)
- ✅ Uses FutureProvider.autoDispose for API calls
- ✅ Uses StateProvider for UI state (filters, search)
- ✅ PurchaseFilter class for managing supplier ledger filters

---

### 3.3 Product Providers (`apps/merchant_app/lib/features/products/providers/`)

| File | Status | Providers |
|------|--------|-----------|
| `product_providers.dart` | ✅ | productSearchProvider, productCategoryProvider, productStockStatusProvider, productSortByProvider, productsProvider, productListProvider, lowStockProductsProvider, categoriesProvider |
| `product_detail_providers.dart` | ✅ | productDetailProvider, productByBarcodeProvider, productBySkuProvider |

**Implementation Details:**
- ✅ `product_providers.dart`: Comprehensive filtering by category, stock status, search, sort
- ✅ `product_detail_providers.dart`: Detail by ID, lookup by barcode/SKU
- ✅ Categories provider for filter dropdowns
- ✅ Low stock products provider for alerts
- ✅ Stock movements deferred to future enhancement

---

### 3.4 Purchase Providers (`apps/merchant_app/lib/features/purchases/providers/`)

| File | Status | Providers |
|------|--------|-----------|
| `purchase_providers.dart` | ✅ | purchaseTypeFilterProvider, purchaseSupplierFilterProvider, purchaseDateRangeProvider, purchasesProvider, purchaseListProvider, purchaseSummaryGlobalProvider, purchaseDetailProvider |
| `purchase_form_providers.dart` | ✅ | purchaseFormProvider (StateNotifier), supplierPaymentFormProvider (StateNotifier) |

**Implementation Details:**
- ✅ `purchase_providers.dart`: List with filters (type, supplier, date range)
- ✅ `purchase_form_providers.dart`: Complete form state management
  - PurchaseFormState: Full purchase entry with items
  - SupplierPaymentFormState: Simple payment entry
  - Both use StateNotifier pattern for complex state management
- ✅ PurchaseDateRange class for date filtering
- ✅ Auto-calculation of totals from line items

---

### 3.5 Enhanced Dashboard Providers

| File | Status | Tasks |
|------|--------|-------|
| `apps/merchant_app/lib/features/dashboard/providers/dashboard_providers.dart` | ✅ | Added inventoryAnalyticsProvider, supplierAnalyticsProvider, reorderSuggestionsProvider, dashboardAnalyticsProvider, topSellingProductsProvider |

**Current Providers:**
- ✅ `dashboardSummaryProvider` (customer summary)
- ✅ `recentTransactionsProvider`

**New Providers Added:**
- ✅ `dashboardAnalyticsProvider` - Complete dashboard analytics (inventory + supplier + customer)
- ✅ `inventoryAnalyticsProvider` - Total stock value, low stock count, profit margins
- ✅ `supplierAnalyticsProvider` - Total payables, supplier count, overdue payments
- ✅ `reorderSuggestionsProvider` - Products needing reorder based on min stock levels
- ✅ `topSellingProductsProvider` - Top 10 selling products for dashboard

**Summary:**
✅ **Phase 3 Complete** - All state management providers implemented
- 4 service providers in config
- 7 provider files across 3 features (suppliers, products, purchases)
- 5 new analytics providers in dashboard
- Total: ~35 individual providers created
- All following Riverpod best practices with autoDispose
- Pattern consistent with existing customer providers

---

## Phase 4: UI Screens

### 4.1 Supplier Management (`apps/merchant_app/lib/features/suppliers/`)

#### Screens
| File | Status | Description |
|------|--------|-------------|
| `screens/supplier_list_screen.dart` | ⏳ | List with filters, search, sort |
| `screens/supplier_detail_screen.dart` | ⏳ | Details, ledger, purchase history |
| `screens/supplier_form_screen.dart` | ⏳ | Add/Edit supplier form |

#### Widgets (Optional)
| File | Status | Description |
|------|--------|-------------|
| `widgets/supplier_card.dart` | ⏳ | Reusable supplier list item |
| `widgets/supplier_filter_chips.dart` | ⏳ | Filter chips for All/Payable/Advance |

---

### 4.2 Product/Inventory Management (`apps/merchant_app/lib/features/products/`)

#### Screens
| File | Status | Description |
|------|--------|-------------|
| `screens/product_list_screen.dart` | ⏳ | Product catalog with filters |
| `screens/product_detail_screen.dart` | ⏳ | Product details, stock history |
| `screens/product_form_screen.dart` | ⏳ | Add/Edit product form |
| `screens/stock_adjustment_screen.dart` | ⏳ | Manual stock adjustments |
| `screens/low_stock_screen.dart` | ⏳ | Low stock alerts with reorder suggestions |
| `screens/category_list_screen.dart` | ⏳ | Browse products by category |

#### Widgets (Optional)
| File | Status | Description |
|------|--------|-------------|
| `widgets/product_card.dart` | ⏳ | Product list item with stock badge |
| `widgets/product_picker.dart` | ⏳ | Product selection widget for sales/purchases |
| `widgets/stock_badge.dart` | ⏳ | Stock status indicator (IN_STOCK/LOW/OUT) |

---

### 4.3 Purchase Management (`apps/merchant_app/lib/features/purchases/`)

#### Screens
| File | Status | Description |
|------|--------|-------------|
| `screens/purchase_entry_screen.dart` | ⏳ | Record purchase with items |
| `screens/supplier_payment_screen.dart` | ⏳ | Record payment to supplier |
| `screens/purchase_list_screen.dart` | ⏳ | All purchases with filters |
| `screens/purchase_detail_screen.dart` | ⏳ | Purchase details with items |

#### Reusable Components
- ✅ `LineItemsInput` widget - Already exists in shared_ui, can reuse for purchases
- ✅ `LineItemsDisplay` widget - Already exists in shared_ui

---

### 4.4 Enhanced Sales Entry

| File | Status | Tasks |
|------|--------|-------|
| `apps/merchant_app/lib/features/sales/screens/sales_entry_screen.dart` | 🔄 | Add product picker option (select from inventory instead of manual entry) |

**Enhancement:**
- ✅ Line items already implemented
- ⏳ Add "Select from Inventory" button in line items dialog
- ⏳ Show product picker with search
- ⏳ Auto-fill product name, unit price from catalog
- ⏳ Validate stock availability before sale

---

### 4.5 Enhanced Dashboard

| File | Status | Tasks |
|------|--------|-------|
| `apps/merchant_app/lib/features/dashboard/screens/dashboard_screen.dart` | 🔄 | Add inventory & supplier summary cards |

**Current Dashboard:**
- ✅ Customer summary cards (Total Udharo, Advance, Customers, This Month)
- ✅ Recent transactions list
- ✅ Add Entry FAB with Sales/Payment options

**Enhancements:**
- ⏳ Add inventory summary cards (Total Stock Value, Low Stock Count)
- ⏳ Add supplier summary card (Total Payables)
- ⏳ Add quick access to Suppliers/Products sections
- ⏳ Update "Add Entry" modal to include "Purchase Entry" and "Supplier Payment"

---

### 4.6 Enhanced Reports

| File | Status | Tasks |
|------|--------|-------|
| `apps/merchant_app/lib/features/reports/screens/reports_screen.dart` | 🔄 | Add supplier & inventory reports |

**Current Reports:**
- ✅ Customer ledger reports

**New Reports to Add:**
- ⏳ Supplier Ledger (PDF)
- ⏳ Purchase History (Excel)
- ⏳ Inventory Valuation (PDF)
- ⏳ Stock Movement (Excel)

---

## Phase 5: Navigation & Integration

### 5.1 Update Routes (`apps/merchant_app/lib/routes/app_router.dart`)

| Routes to Add | Status |
|---------------|--------|
| `/suppliers`, `/suppliers/:id`, `/supplier-form` | ⏳ |
| `/products`, `/products/:id`, `/product-form` | ⏳ |
| `/stock-adjustment/:productId` | ⏳ |
| `/low-stock-alerts` | ⏳ |
| `/purchase-entry`, `/supplier-payment` | ⏳ |
| `/purchases`, `/purchases/:id` | ⏳ |

**Current Routes:**
- ✅ Authentication routes (login, register, OTP)
- ✅ Dashboard
- ✅ Customer routes (list, detail, form)
- ✅ Sales & payment entry
- ✅ Calculator, Reports, Settings, Notifications

---

### 5.2 Update Bottom Navigation

| File | Status | Options |
|------|--------|---------|
| `dashboard_screen.dart` | 🔄 | **Option A**: Add 5th tab "Inventory"<br>**Option B**: Keep 4 tabs, add Inventory to hamburger menu<br>**Option C**: Replace Reports tab with More tab |

**Current Bottom Nav:**
1. ✅ Dashboard
2. ✅ Customers
3. ✅ Reports
4. ✅ Settings

**Proposed Bottom Nav (Option A):**
1. Dashboard
2. Customers
3. **Inventory** (new - shows Suppliers/Products tabs)
4. Reports
5. Settings

---

### 5.3 Update Add Entry Modal

| File | Status | Tasks |
|------|--------|-------|
| `dashboard_screen.dart` | 🔄 | Add Purchase Entry and Supplier Payment options |

**Current Options:**
- ✅ Quick Calculator
- ✅ Sales Entry
- ✅ Receive Payment

**New Options to Add:**
- ⏳ Purchase Entry (buy from supplier)
- ⏳ Supplier Payment (pay supplier)

---

## Phase 6: Localization & Polish

### 6.1 Add Localization Strings

| File | Status | New Keys |
|------|--------|----------|
| `packages/core/lib/l10n/app_en.arb` | ⏳ | supplier, suppliers, payable, purchase, inventory, product, stock, lowStock, outOfStock, category, barcode, sku, costPrice, sellingPrice, reorder, etc. |
| `packages/core/lib/l10n/app_ne.arb` | ⏳ | Nepali translations for all new keys |

**Estimated New Keys:** ~50-60 strings

---

### 6.2 Shared UI Components (Optional Enhancements)

| File | Status | Description |
|------|--------|-------------|
| `packages/shared_ui/lib/widgets/product_picker_dialog.dart` | ⏳ | Product selection dialog with search |
| `packages/shared_ui/lib/widgets/stock_badge.dart` | ⏳ | Colored badge for stock status |
| `packages/shared_ui/lib/widgets/supplier_card.dart` | ⏳ | Reusable supplier list item |

**Existing Shared Widgets:**
- ✅ `line_items_input.dart`
- ✅ `line_items_display.dart`

---

## Phase 7: Testing & Validation

### 7.1 Unit Tests

| Test Suite | Status | Coverage |
|------------|--------|----------|
| `supplier_model_test.dart` | ⏳ | JSON serialization/deserialization |
| `product_model_test.dart` | ⏳ | JSON, stock status logic |
| `purchase_model_test.dart` | ⏳ | JSON serialization |
| `supplier_service_test.dart` | ⏳ | API calls with mocked responses |
| `product_service_test.dart` | ⏳ | API calls with mocked responses |
| `purchase_service_test.dart` | ⏳ | API calls with mocked responses |
| `supplier_providers_test.dart` | ⏳ | State management logic |
| `product_providers_test.dart` | ⏳ | State management logic |

---

### 7.2 Integration Tests

| Test Scenario | Status | Description |
|---------------|--------|-------------|
| `supplier_flow_test.dart` | ⏳ | Create supplier → Record purchase → Verify stock update |
| `purchase_flow_test.dart` | ⏳ | Purchase → Check balance → Make payment → Verify settlement |
| `inventory_flow_test.dart` | ⏳ | Add product → Purchase → Sale → Verify stock changes |
| `low_stock_alert_test.dart` | ⏳ | Stock falls below min → Low stock alert appears |

---

### 7.3 Manual Testing Checklist

#### Supplier Management
- [ ] Create new supplier with all fields
- [ ] Update supplier information
- [ ] Filter suppliers by balance type (All/Payable/Advance/Settled)
- [ ] Search suppliers by name/mobile
- [ ] Sort suppliers by name, balance
- [ ] View supplier detail and ledger
- [ ] Set/update due date
- [ ] Try to delete supplier with balance (should fail)
- [ ] Delete supplier with zero balance (should succeed)

#### Inventory Management
- [ ] Create product with inventory tracking
- [ ] Create product without inventory tracking
- [ ] Update product details (price, stock level)
- [ ] View products by category
- [ ] Filter by stock status (In Stock, Low Stock, Out of Stock)
- [ ] Search products by name, SKU, barcode
- [ ] Perform manual stock adjustment (add/remove)
- [ ] View stock movement history
- [ ] View low stock alerts
- [ ] View reorder suggestions

#### Purchase Management
- [ ] Create purchase with multiple items
- [ ] Verify stock auto-updates after purchase
- [ ] Verify cost price recalculation (weighted average)
- [ ] Create purchase with partial payment
- [ ] Create purchase with full payment
- [ ] Create purchase with zero payment (full credit)
- [ ] Record supplier payment
- [ ] View purchase history
- [ ] Filter purchases by supplier
- [ ] View supplier ledger
- [ ] Generate supplier ledger PDF report
- [ ] Generate purchase history Excel report

#### Sales Integration
- [ ] Create sale selecting from inventory
- [ ] Verify stock deduction after sale
- [ ] Try to sell more than available stock (should fail)
- [ ] Mix inventory products and ad-hoc items in single sale
- [ ] Sale of non-tracked product (no stock validation)

#### Dashboard & Reports
- [ ] View updated dashboard with inventory analytics
- [ ] View supplier payables summary
- [ ] View low stock count on dashboard
- [ ] Generate inventory valuation PDF
- [ ] Generate stock movement Excel
- [ ] View reorder suggestions

---

## Code Generation Checklist

After creating/modifying models, run:

```bash
# Generate Freezed and JSON serialization code
cd packages/shared_models
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch mode during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

Files that will be generated:
- [ ] `supplier.freezed.dart`, `supplier.g.dart`
- [ ] `product.freezed.dart`, `product.g.dart`
- [ ] `purchase.freezed.dart`, `purchase.g.dart`
- [ ] `purchase_item.freezed.dart`, `purchase_item.g.dart`
- [ ] `inventory_analytics.freezed.dart`, `inventory_analytics.g.dart`
- [ ] `supplier_analytics.freezed.dart`, `supplier_analytics.g.dart`
- [ ] `stock_movement.freezed.dart`, `stock_movement.g.dart`
- [ ] `category.freezed.dart`, `category.g.dart`
- [ ] `reorder_suggestion.freezed.dart`, `reorder_suggestion.g.dart`

---

## Dependencies to Check/Add

| Package | Current Version | Required For | Status |
|---------|----------------|--------------|--------|
| `freezed_annotation` | ^2.4.4 | ✅ Models | ✅ Installed |
| `json_annotation` | ^4.9.0 | ✅ JSON serialization | ✅ Installed |
| `flutter_riverpod` | ^2.6.1 | ✅ State management | ✅ Installed |
| `go_router` | ^14.6.2 | ✅ Navigation | ✅ Installed |
| `dio` | - | ✅ HTTP client | ✅ Installed (via shared_services) |
| `hive` | ^2.2.3 | ✅ Local storage | ✅ Installed |
| `file_picker` | - | 📦 File selection for bill images | ⏳ Check if needed |
| `open_file` | - | 📦 Open downloaded reports | ⏳ Check if needed |
| `barcode_scan2` or `mobile_scanner` | - | 📦 Barcode scanning | ⏳ Optional |
| `fl_chart` | - | 📦 Analytics charts | ⏳ Optional |

---

## Implementation Timeline (Estimated)

| Phase | Duration | Status |
|-------|----------|--------|
| **Phase 1**: Foundation (Models & Enums) | 2 days | ⏳ |
| **Phase 2**: Services (API Integration) | 2 days | ⏳ |
| **Phase 3**: Providers (State Management) | 2 days | ⏳ |
| **Phase 4.1-4.2**: Supplier & Product UI | 4 days | ⏳ |
| **Phase 4.3-4.4**: Purchase UI & Sales Integration | 3 days | ⏳ |
| **Phase 4.5-4.6**: Dashboard & Reports | 2 days | ⏳ |
| **Phase 5**: Navigation & Integration | 1 day | ⏳ |
| **Phase 6**: Localization & Polish | 2 days | ⏳ |
| **Phase 7**: Testing & Validation | 2 days | ⏳ |
| **Total** | **~15-20 days** | |

---

## Current Sprint Focus

### Sprint 1: Foundation & Services (4 days)
🚧 **CURRENT SPRINT**

**Goals:**
1. ✅ Update CLAUDE.md
2. ✅ Create TODO.md
3. ⏳ Create all enums and models (Phase 1)
4. ⏳ Implement all API services (Phase 2)
5. ⏳ Run code generation
6. ⏳ Write unit tests for models

**Starting with:**
- Supplier models and enums
- Supplier service implementation
- Test with API calls

---

## Notes & Decisions

### Architecture Decisions
- ✅ Reuse `SaleItem` pattern for `PurchaseItem`
- ✅ Reuse `LineItemsInput/Display` widgets for purchases
- ✅ Follow Customer-Supplier symmetry (similar balance logic, opposite signs)
- ✅ Use Freezed + JSON for all models (consistency)
- ✅ Use Riverpod FutureProvider pattern (consistency)

### Design Decisions
- ⏳ **Navigation**: Need to decide on bottom nav structure (4 tabs vs 5 tabs)
- ⏳ **Dashboard**: Add inventory cards or separate tab?
- ⏳ **Product Picker**: Inline or dialog for product selection?

### Backend Assumptions
- ✅ Backend API fully implemented (per COMPLETE_API_SPECIFICATION.md)
- ✅ Stock auto-updates handled by backend
- ✅ Weighted average cost calculation handled by backend
- ✅ Balance calculations handled by backend

---

## Risk & Mitigation

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| Backend API changes | High | Maintain API spec document, version endpoints | ✅ Spec documented |
| Complex state management | Medium | Follow existing patterns, extensive testing | ⏳ |
| Stock sync issues | High | Backend handles atomically, optimistic UI updates | ⏳ Need to test |
| Report generation performance | Medium | Backend generates, app just downloads | ✅ Backend handles |

---

## Questions to Resolve

1. **Bottom Navigation**: 4 tabs or 5 tabs?
   - Option A: Add "Inventory" as 5th tab
   - Option B: Keep 4 tabs, add to hamburger menu
   - **Decision**: TBD

2. **Product Selection**: How should users select products in sales/purchases?
   - Option A: Barcode scanner
   - Option B: Search dialog
   - Option C: Both
   - **Decision**: Start with search, add barcode later

3. **Low Stock Notifications**: Push notifications or in-app only?
   - **Decision**: Start with in-app, add push later

4. **File Dependencies**: Need file_picker and open_file?
   - **Decision**: Check existing bill image handling first

---

## Success Criteria

### MVP (Minimum Viable Product)
- [ ] Suppliers: CRUD, list, detail, ledger
- [ ] Products: CRUD, list, detail, stock tracking
- [ ] Purchases: Create with items, stock auto-update
- [ ] Supplier Payments: Record payments
- [ ] Dashboard: Show inventory & supplier metrics
- [ ] Reports: Basic supplier ledger and inventory reports

### Nice to Have (v2)
- [ ] Barcode scanning
- [ ] Advanced analytics charts
- [ ] Push notifications for low stock
- [ ] Bulk import/export
- [ ] Multi-location inventory

---

**Project Status**: 🚧 Foundation Phase - Ready to Start Implementation
**Next Action**: Begin Phase 1 - Create Enums and Models
