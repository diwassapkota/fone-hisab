import 'package:freezed_annotation/freezed_annotation.dart';
import 'sale_item.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String type, // "SALE", "PAYMENT"
    required double saleAmount,
    required double paymentAmount,
    @JsonKey(name: 'balanceAfter') double? balance, // Running balance after transaction (optional for general sales)
    required String paymentMode, // "CASH", "DIGITAL", "BANK_TRANSFER", "OTHER"
    String? description,
    required DateTime billDate,
    @Default([]) List<String> billImages,
    required DateTime createdAt,
    CustomerInfo? customer,
    MerchantInfo? merchant,
    @Default([]) List<SaleItem> items, // Optional line items for detailed transactions
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

@freezed
class CustomerInfo with _$CustomerInfo {
  const factory CustomerInfo({
    required String id,
    required String name,
    required String mobileNumber,
  }) = _CustomerInfo;

  factory CustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoFromJson(json);
}

@freezed
class MerchantInfo with _$MerchantInfo {
  const factory MerchantInfo({
    required String id,
    required String businessName,
    required String name,
    required String mobileNumber,
  }) = _MerchantInfo;

  factory MerchantInfo.fromJson(Map<String, dynamic> json) =>
      _$MerchantInfoFromJson(json);
}

extension TransactionExtension on Transaction {
  String get displayAmount {
    final amount = type == 'SALE' ? saleAmount : paymentAmount;
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  String get typeDisplay {
    return type == 'SALE' ? 'Sale' : 'Payment';
  }

  bool get isSale => type == 'SALE';
  bool get isPayment => type == 'PAYMENT';

  /// Check if transaction has line items
  bool get hasItems => items.isNotEmpty;

  /// Get total number of items
  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique products
  int get uniqueProductsCount => items.length;
}
