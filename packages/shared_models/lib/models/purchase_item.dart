import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_item.freezed.dart';
part 'purchase_item.g.dart';

/// Represents a line item in a purchase transaction
@freezed
class PurchaseItem with _$PurchaseItem {
  const factory PurchaseItem({
    /// Product ID from catalog
    required String productId,

    /// Product name (fetched from catalog)
    required String productName,

    /// Quantity of items purchased
    required int quantity,

    /// Price per unit at time of purchase
    required double unitPrice,

    /// Total price (quantity × unitPrice)
    required double totalPrice,
  }) = _PurchaseItem;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemFromJson(json);
}

/// Request DTO for creating a purchase item
@freezed
class PurchaseItemRequest with _$PurchaseItemRequest {
  const factory PurchaseItemRequest({
    /// Product ID from catalog (required for purchases)
    required String productId,

    /// Quantity must be at least 1
    required int quantity,

    /// Unit price must be positive
    required double unitPrice,
  }) = _PurchaseItemRequest;

  factory PurchaseItemRequest.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemRequestFromJson(json);
}

extension PurchaseItemExtension on PurchaseItem {
  /// Display formatted total
  String get totalDisplay => 'Rs. ${totalPrice.toStringAsFixed(2)}';

  /// Display formatted unit price
  String get unitPriceDisplay => 'Rs. ${unitPrice.toStringAsFixed(2)}';

  /// Display quantity with label
  String get quantityDisplay => '$quantity ${quantity > 1 ? 'items' : 'item'}';
}

extension PurchaseItemRequestExtension on PurchaseItemRequest {
  /// Validate that productId is provided
  bool get isValid => productId.isNotEmpty && quantity > 0 && unitPrice > 0;

  /// Calculate total price
  double get calculatedTotal => quantity * unitPrice;
}
