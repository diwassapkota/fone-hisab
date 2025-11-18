import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class AnalyticsService {
  final DioClient _dioClient;

  AnalyticsService(this._dioClient);

  /// Get complete dashboard analytics (inventory + supplier metrics)
  Future<ApiResponse<Map<String, dynamic>>> getDashboardAnalytics() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.analyticsDashboard,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get inventory analytics
  Future<ApiResponse<InventoryAnalytics>> getInventoryAnalytics() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.inventoryAnalytics,
      );

      return ApiResponse<InventoryAnalytics>.fromJson(
        response.data,
        (json) => InventoryAnalytics.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get supplier analytics
  Future<ApiResponse<SupplierAnalytics>> getSupplierAnalytics() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.supplierAnalytics,
      );

      return ApiResponse<SupplierAnalytics>.fromJson(
        response.data,
        (json) => SupplierAnalytics.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get reorder suggestions for low stock products
  Future<ApiResponse<List<ReorderSuggestion>>> getReorderSuggestions() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.reorderSuggestions,
      );

      return ApiResponse<List<ReorderSuggestion>>.fromJson(
        response.data,
        (json) {
          final dataList = json as List;
          return dataList
              .map((item) =>
                  ReorderSuggestion.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get top selling products
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopSellingProducts({
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.topSellingProducts(limit),
      );

      return ApiResponse<List<Map<String, dynamic>>>.fromJson(
        response.data,
        (json) {
          final dataList = json as List;
          return dataList
              .map((item) => item as Map<String, dynamic>)
              .toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
