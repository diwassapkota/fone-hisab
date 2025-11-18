import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_analytics.freezed.dart';
part 'supplier_analytics.g.dart';

/// Supplier analytics for dashboard
@freezed
class SupplierAnalytics with _$SupplierAnalytics {
  const factory SupplierAnalytics({
    required int totalSuppliers,
    required double totalPayable,
    required double totalAdvance,
    required int payableCount,
    required int advanceCount,
    required int settledCount,
    required int upcomingDueCount,
    required int overdueCount,
  }) = _SupplierAnalytics;

  factory SupplierAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SupplierAnalyticsFromJson(json);
}

extension SupplierAnalyticsExtension on SupplierAnalytics {
  /// Formatted total payable
  String get totalPayableDisplay => 'Rs. ${totalPayable.toStringAsFixed(2)}';

  /// Formatted total advance
  String get totalAdvanceDisplay => 'Rs. ${totalAdvance.toStringAsFixed(2)}';

  /// Net balance (payable - advance)
  double get netBalance => totalPayable - totalAdvance;

  /// Formatted net balance
  String get netBalanceDisplay => 'Rs. ${netBalance.toStringAsFixed(2)}';

  /// Whether there are overdue payments
  bool get hasOverduePayments => overdueCount > 0;

  /// Whether there are upcoming dues
  bool get hasUpcomingDues => upcomingDueCount > 0;

  /// Total suppliers with balance (not settled)
  int get suppliersWithBalance => payableCount + advanceCount;
}
