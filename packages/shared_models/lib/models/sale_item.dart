import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_item.freezed.dart';
part 'sale_item.g.dart';

/// Represents a line item in a sales transaction
@freezed
class SaleItem with _$SaleItem {
  const factory SaleItem({
    /// Optional reference to product from catalog
    String? productId,

    /// Product name (fetched from catalog or manually entered for ad-hoc items)
    required String productName,

    /// Quantity of items
    required int quantity,

    /// Price per unit
    required double unitPrice,

    /// Total price (quantity × unitPrice)
    required double totalPrice,
  }) = _SaleItem;

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
}

/// Request DTO for creating a sale item
@freezed
class SaleItemRequest with _$SaleItemRequest {
  const factory SaleItemRequest({
    /// Either productId OR productName must be provided
    String? productId,
    String? productName,

    /// Quantity must be at least 1
    required int quantity,

    /// Unit price must be positive
    required double unitPrice,
  }) = _SaleItemRequest;

  factory SaleItemRequest.fromJson(Map<String, dynamic> json) =>
      _$SaleItemRequestFromJson(json);
}

extension SaleItemExtension on SaleItem {
  /// Display formatted total
  String get totalDisplay => 'Rs. ${totalPrice.toStringAsFixed(2)}';

  /// Display formatted unit price
  String get unitPriceDisplay => 'Rs. ${unitPrice.toStringAsFixed(2)}';

  /// Display quantity with label
  String get quantityDisplay => '$quantity ${quantity > 1 ? 'items' : 'item'}';
}

extension SaleItemRequestExtension on SaleItemRequest {
  /// Validate that either productId or productName is provided
  bool get isValid =>
      (productId != null && productId!.isNotEmpty) ||
      (productName != null && productName!.isNotEmpty);

  /// Calculate total price
  double get calculatedTotal => quantity * unitPrice;
}
