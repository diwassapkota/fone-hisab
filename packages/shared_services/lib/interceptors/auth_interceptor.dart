import 'package:dio/dio.dart';

/// Interceptor to add authentication headers to requests
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function() onUnauthorized;

  AuthInterceptor({
    required this.getToken,
    required this.onUnauthorized,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      await onUnauthorized();
    }
    handler.next(err);
  }
}
