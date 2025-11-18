import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_analytics.freezed.dart';
part 'inventory_analytics.g.dart';

/// Inventory analytics for dashboard
@freezed
class InventoryAnalytics with _$InventoryAnalytics {
  const factory InventoryAnalytics({
    required int totalProducts,
    required int trackedProducts,
    required int totalStockQuantity,
    required double totalCostValue,
    required double totalRetailValue,
    required double potentialProfit,
    required double profitMarginPercentage,
    required int lowStockCount,
    required int outOfStockCount,
    @Default({}) Map<String, CategoryBreakdown> categoryBreakdown,
  }) = _InventoryAnalytics;

  factory InventoryAnalytics.fromJson(Map<String, dynamic> json) =>
      _$InventoryAnalyticsFromJson(json);
}

/// Category breakdown for inventory analytics
@freezed
class CategoryBreakdown with _$CategoryBreakdown {
  const factory CategoryBreakdown({
    required int productCount,
    required int totalStock,
    required double totalCostValue,
    required double totalRetailValue,
  }) = _CategoryBreakdown;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);
}

extension InventoryAnalyticsExtension on InventoryAnalytics {
  /// Formatted total cost value
  String get totalCostValueDisplay =>
      'Rs. ${totalCostValue.toStringAsFixed(2)}';

  /// Formatted total retail value
  String get totalRetailValueDisplay =>
      'Rs. ${totalRetailValue.toStringAsFixed(2)}';

  /// Formatted potential profit
  String get potentialProfitDisplay =>
      'Rs. ${potentialProfit.toStringAsFixed(2)}';

  /// Formatted profit margin
  String get profitMarginDisplay =>
      '${profitMarginPercentage.toStringAsFixed(1)}%';

  /// Whether there are stock issues
  bool get hasStockIssues => lowStockCount > 0 || outOfStockCount > 0;

  /// Total items needing attention
  int get itemsNeedingAttention => lowStockCount + outOfStockCount;
}
