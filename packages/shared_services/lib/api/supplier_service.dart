import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class SupplierService {
  final DioClient _dioClient;

  SupplierService(this._dioClient);

  /// Get paginated list of suppliers with filters
  Future<ApiResponse<Map<String, dynamic>>> getSuppliers({
    int page = 0,
    int size = 20,
    String? search,
    String balanceType = 'ALL', // ALL, UDHARO, ADVANCE, SETTLED
    String sortBy = 'RECENT', // RECENT, NAME_ASC, NAME_DESC, BALANCE_HIGH, BALANCE_LOW
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'balanceType': balanceType,
        'sortBy': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dioClient.get(
        ApiConfig.suppliers,
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

  /// Get supplier by ID
  Future<ApiResponse<Supplier>> getSupplierById(String supplierId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.supplierById(supplierId),
      );

      return ApiResponse<Supplier>.fromJson(
        response.data,
        (json) => Supplier.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create new supplier
  Future<ApiResponse<Supplier>> createSupplier({
    required String supplierName,
    required String mobileNumber,
    String? email,
    String? address,
    String? panNumber,
    String? gstNumber,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.suppliers,
        data: {
          'supplierName': supplierName,
          'mobileNumber': mobileNumber,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (panNumber != null) 'panNumber': panNumber,
          if (gstNumber != null) 'gstNumber': gstNumber,
          if (notes != null) 'notes': notes,
        },
      );

      return ApiResponse<Supplier>.fromJson(
        response.data,
        (json) => Supplier.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing supplier
  Future<ApiResponse<Supplier>> updateSupplier({
    required String supplierId,
    String? supplierName,
    String? mobileNumber,
    String? email,
    String? address,
    String? panNumber,
    String? gstNumber,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.supplierById(supplierId),
        data: {
          if (supplierName != null) 'supplierName': supplierName,
          if (mobileNumber != null) 'mobileNumber': mobileNumber,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (panNumber != null) 'panNumber': panNumber,
          if (gstNumber != null) 'gstNumber': gstNumber,
          if (notes != null) 'notes': notes,
        },
      );

      return ApiResponse<Supplier>.fromJson(
        response.data,
        (json) => Supplier.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete supplier (only if balance is zero)
  Future<ApiResponse<Map<String, dynamic>>> deleteSupplier(
      String supplierId) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.supplierById(supplierId),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Set or update supplier due date
  Future<ApiResponse<Map<String, dynamic>>> setSupplierDueDate({
    required String supplierId,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.supplierDueDate(supplierId),
        data: {
          'dueDate': dueDate.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
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
}
