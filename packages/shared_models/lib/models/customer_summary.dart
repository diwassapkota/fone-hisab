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
