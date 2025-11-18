import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class TransactionService {
  final DioClient _dioClient;

  TransactionService(this._dioClient);

  Future<ApiResponse<Map<String, dynamic>>> createSalesEntry({
    String? customerId, // Made optional for general sales
    required double saleAmount,
    required double paymentAmount,
    required String paymentMode, // CASH, DIGITAL, BANK_TRANSFER
    String? description,
    required DateTime billDate,
    List<String>? billImages, // Base64 encoded images
    List<SaleItemRequest>? items, // Optional line items for detailed transaction
    bool autoCalculateSaleAmount = false, // Auto-calculate sale amount from items
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.salesEntry,
        data: {
          if (customerId != null) 'customerId': customerId,
          'saleAmount': saleAmount,
          'paymentAmount': paymentAmount,
          'paymentMode': paymentMode,
          if (description != null) 'description': description,
          'billDate': billDate.toIso8601String(),
          if (billImages != null && billImages.isNotEmpty)
            'billImages': billImages,
          if (items != null && items.isNotEmpty)
            'items': items.map((item) => {
              if (item.productId != null) 'productId': item.productId,
              if (item.productName != null) 'productName': item.productName,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
            }).toList(),
          'autoCalculateSaleAmount': autoCalculateSaleAmount,
        },
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createPaymentEntry({
    required String customerId,
    required double amount,
    required String paymentMode,
    String? description,
    required DateTime paymentDate,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.paymentEntry,
        data: {
          'customerId': customerId,
          'amount': amount,
          'paymentMode': paymentMode,
          if (description != null) 'description': description,
          'paymentDate': paymentDate.toIso8601String(),
        },
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<dynamic>>> getMerchantRecentTransactions(int limit) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.merchantRecentTransactions(limit),
      );

      return ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
