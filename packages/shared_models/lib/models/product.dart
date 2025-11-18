import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

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

extension ProductExtension on Product {
  /// Calculate profit per unit
  double get profitPerUnit => sellingPrice - costPrice;

  /// Calculate profit margin percentage
  double get profitMarginPercentage {
    if (costPrice == 0) return 0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  /// Whether product is in stock
  bool get isInStock => stockStatus == 'IN_STOCK';

  /// Whether product is low on stock
  bool get isLowStock => stockStatus == 'LOW_STOCK';

  /// Whether product is out of stock
  bool get isOutOfStock => stockStatus == 'OUT_OF_STOCK';

  /// Whether inventory tracking is enabled
  bool get isTracked => trackInventory && stockStatus != 'NOT_TRACKED';

  /// Whether stock needs attention (low or out)
  bool get needsStockAttention => isLowStock || isOutOfStock;

  /// Stock value at cost price
  double get stockValueAtCost => costPrice * stockQuantity;

  /// Stock value at selling price
  double get stockValueAtRetail => sellingPrice * stockQuantity;

  /// Potential profit from current stock
  double get potentialProfit => profitPerUnit * stockQuantity;

  /// Display name with SKU if available
  String get displayName {
    if (sku != null && sku!.isNotEmpty) {
      return '$productName ($sku)';
    }
    return productName;
  }

  /// Stock status display
  String get stockStatusDisplay {
    if (!trackInventory) return 'Not Tracked';
    if (stockQuantity == 0) return 'Out of Stock';
    if (stockQuantity <= minStockLevel) return 'Low Stock ($stockQuantity)';
    return 'In Stock ($stockQuantity)';
  }

  /// Formatted selling price
  String get sellingPriceDisplay => 'Rs. ${sellingPrice.toStringAsFixed(2)}';

  /// Formatted cost price
  String get costPriceDisplay => 'Rs. ${costPrice.toStringAsFixed(2)}';
}
