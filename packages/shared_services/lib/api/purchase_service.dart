import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class PurchaseService {
  final DioClient _dioClient;

  PurchaseService(this._dioClient);

  /// Create purchase with items (stock auto-updates)
  Future<ApiResponse<Purchase>> createPurchase({
    required String supplierId,
    required double purchaseAmount,
    required double paymentAmount,
    required String paymentMode, // CASH, DIGITAL, BANK_TRANSFER, CHEQUE
    required DateTime billDate,
    String? billNumber,
    String? description,
    List<String>? billImages,
    required List<PurchaseItemRequest> items,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.purchases,
        data: {
          'supplierId': supplierId,
          'purchaseAmount': purchaseAmount,
          'paymentAmount': paymentAmount,
          'paymentMode': paymentMode,
          'billDate': billDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          if (billNumber != null) 'billNumber': billNumber,
          if (description != null) 'description': description,
          if (billImages != null) 'billImages': billImages,
          'items': items.map((item) => {
            'productId': item.productId,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
          }).toList(),
        },
      );

      return ApiResponse<Purchase>.fromJson(
        response.data,
        (json) => Purchase.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Record payment to supplier
  Future<ApiResponse<Purchase>> createSupplierPayment({
    required String supplierId,
    required double paymentAmount,
    required String paymentMode,
    required DateTime billDate,
    String? description,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.supplierPayment,
        data: {
          'supplierId': supplierId,
          'paymentAmount': paymentAmount,
          'paymentMode': paymentMode,
          'billDate': billDate.toIso8601String().split('T')[0],
          if (description != null) 'description': description,
        },
      );

      return ApiResponse<Purchase>.fromJson(
        response.data,
        (json) => Purchase.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated list of purchases with filters
  Future<ApiResponse<Map<String, dynamic>>> getPurchases({
    int page = 0,
    int size = 20,
    String? supplierId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (supplierId != null) 'supplierId': supplierId,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

      final response = await _dioClient.get(
        ApiConfig.purchases,
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get purchase by ID
  Future<ApiResponse<Purchase>> getPurchaseById(String purchaseId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.purchaseById(purchaseId),
      );

      return ApiResponse<Purchase>.fromJson(
        response.data,
        (json) => Purchase.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update purchase (limited fields only)
  Future<ApiResponse<Purchase>> updatePurchase({
    required String purchaseId,
    String? billNumber,
    String? description,
    String? paymentMode,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.purchaseById(purchaseId),
        data: {
          if (billNumber != null) 'billNumber': billNumber,
          if (description != null) 'description': description,
          if (paymentMode != null) 'paymentMode': paymentMode,
        },
      );

      return ApiResponse<Purchase>.fromJson(
        response.data,
        (json) => Purchase.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete purchase (only if supplier balance is zero)
  Future<ApiResponse<Map<String, dynamic>>> deletePurchase(
      String purchaseId) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.purchaseById(purchaseId),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get supplier ledger (purchases and payments)
  Future<ApiResponse<Map<String, dynamic>>> getSupplierLedger({
    required String supplierId,
    required String startDate,
    required String endDate,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'startDate': startDate,
        'endDate': endDate,
        'page': page.toString(),
        'size': size.toString(),
      };

      final response = await _dioClient.get(
        ApiConfig.supplierLedger(supplierId),
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get purchase summary for date range
  Future<ApiResponse<Map<String, dynamic>>> getPurchaseSummary({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParams = {
        'startDate': startDate,
        'endDate': endDate,
      };

      final response = await _dioClient.get(
        ApiConfig.purchaseSummary,
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
