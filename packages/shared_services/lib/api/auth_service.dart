import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<ApiResponse<RegisterResponse>> register({
    required String mobileNumber,
    required String name,
    String? email,
    required String password,
    required String role, // "MERCHANT" or "CUSTOMER"
    String? businessName,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.register,
        data: {
          'mobileNumber': mobileNumber,
          'name': name,
          if (email != null) 'email': email,
          'password': password,
          'role': role,
          if (businessName != null) 'businessName': businessName,
        },
      );

      return ApiResponse<RegisterResponse>.fromJson(
        response.data,
        (json) => RegisterResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Handle error response from server
      if (e.response?.data != null) {
        return ApiResponse<RegisterResponse>.fromJson(
          e.response!.data,
          (json) => RegisterResponse.fromJson(json as Map<String, dynamic>),
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<AuthResponse>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.verifyOtp,
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
        },
      );

      return ApiResponse<AuthResponse>.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<AuthResponse>> login({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.login,
        data: {
          'mobileNumber': mobileNumber,
          'password': password,
        },
      );

      return ApiResponse<AuthResponse>.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Handle error response from server (e.g., 401 invalid credentials)
      if (e.response?.data != null) {
        // Return the error response as ApiResponse
        return ApiResponse<AuthResponse>.fromJson(
          e.response!.data,
          (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final response = await _dioClient.post(ApiConfig.logout);
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken(
      String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.refreshToken,
        data: {'refreshToken': refreshToken},
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
