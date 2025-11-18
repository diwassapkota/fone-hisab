import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class CustomerService {
  final DioClient _dioClient;

  CustomerService(this._dioClient);

  Future<ApiResponse<Map<String, dynamic>>> getCustomers({
    int page = 0,
    int size = 20,
    String filter = 'ALL', // ALL, UDHARO, ADVANCE
    String sortBy = 'RECENT', // RECENT, DUE_AMOUNT, NAME, UPCOMING_DUE
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'filter': filter,
        'sortBy': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dioClient.get(
        ApiConfig.customers,
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

  Future<ApiResponse<Customer>> getCustomerById(String customerId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.customerById(customerId),
      );

      return ApiResponse<Customer>.fromJson(
        response.data,
        (json) => Customer.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Customer>> createCustomer({
    required String name,
    required String mobileNumber,
    String? email,
    String? address,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.customers,
        data: {
          'name': name,
          'mobileNumber': mobileNumber,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );

      return ApiResponse<Customer>.fromJson(
        response.data,
        (json) => Customer.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Customer>> updateCustomer({
    required String customerId,
    String? name,
    String? email,
    String? address,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.customerById(customerId),
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );

      return ApiResponse<Customer>.fromJson(
        response.data,
        (json) => Customer.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteCustomer(
      String customerId) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.customerById(customerId),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCustomerTransactions({
    required String customerId,
    int page = 0,
    int size = 20,
    String? startDate,
    String? endDate,
    String type = 'ALL', // SALE, PAYMENT, ALL
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'type': type,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

      final response = await _dioClient.get(
        ApiConfig.customerTransactions(customerId),
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

  Future<ApiResponse<Map<String, dynamic>>> setCustomerDueDate({
    required String customerId,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _dioClient.patch(
        ApiConfig.customerDueDate(customerId),
        data: {
          'dueDate': dueDate.toIso8601String(),
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
