import 'package:freezed_annotation/freezed_annotation.dart';
import 'purchase_item.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required String purchaseId,
    required String transactionType, // PURCHASE, PAYMENT
    required String supplierId,
    required String supplierName,
    required double purchaseAmount,
    required double paymentAmount,
    double? balanceAfter,
    required String paymentMode, // CASH, DIGITAL, BANK_TRANSFER, CHEQUE
    required DateTime billDate,
    String? billNumber,
    String? description,
    @Default([]) List<String> billImages,
    @Default([]) List<PurchaseItem> items,
    required DateTime createdAt,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}

extension PurchaseExtension on Purchase {
  /// Display formatted amount based on transaction type
  String get displayAmount {
    final amount = transactionType == 'PURCHASE' ? purchaseAmount : paymentAmount;
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  /// Type display for UI
  String get typeDisplay {
    return transactionType == 'PURCHASE' ? 'Purchase' : 'Payment';
  }

  /// Whether this is a purchase transaction
  bool get isPurchase => transactionType == 'PURCHASE';

  /// Whether this is a payment transaction
  bool get isPayment => transactionType == 'PAYMENT';

  /// Whether transaction has line items
  bool get hasItems => items.isNotEmpty;

  /// Get total number of items
  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique products
  int get uniqueProductsCount => items.length;

  /// Calculate remaining balance (purchase - payment)
  double get remainingAmount => purchaseAmount - paymentAmount;

  /// Whether this is a credit purchase (partial or no payment)
  bool get isCreditPurchase => purchaseAmount > paymentAmount;

  /// Whether this is a full payment purchase
  bool get isFullPayment => purchaseAmount == paymentAmount;
}
