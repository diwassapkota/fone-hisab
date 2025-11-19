import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_summary.freezed.dart';
part 'customer_summary.g.dart';

@freezed
class CustomerSummary with _$CustomerSummary {
  const factory CustomerSummary({
    required int totalCustomers,
    required int udharoCustomers,
    required int advanceCustomers,
    required double totalUdharoAmount,
    required double totalAdvanceAmount,
  }) = _CustomerSummary;

  factory CustomerSummary.fromJson(Map<String, dynamic> json) =>
      _$CustomerSummaryFromJson(json);
}

@freezed
class TransactionSummary with _$TransactionSummary {
  const factory TransactionSummary({
    required double totalSales,
    required double totalPayments,
    required int transactionCount,
    double? openingBalance,
    double? closingBalance,
  }) = _TransactionSummary;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      _$TransactionSummaryFromJson(json);
}

@freezed
class SupplierSummary with _$SupplierSummary {
  const factory SupplierSummary({
    required int totalSuppliers,
    required int payableSuppliers,
    required int advanceSuppliers,
    required double totalPayableAmount,
    required double totalAdvanceAmount,
  }) = _SupplierSummary;

  factory SupplierSummary.fromJson(Map<String, dynamic> json) =>
      _$SupplierSummaryFromJson(json);
}

@freezed
class PurchaseSummary with _$PurchaseSummary {
  const factory PurchaseSummary({
    required double totalPurchases,
    required double totalPayments,
    required int transactionCount,
    double? openingBalance,
    double? closingBalance,
  }) = _PurchaseSummary;

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) =>
      _$PurchaseSummaryFromJson(json);
}
