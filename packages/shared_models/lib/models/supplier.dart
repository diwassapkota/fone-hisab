import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    @JsonKey(name: 'id') required String supplierId,
    required String supplierName,
    required String mobileNumber,
    String? email,
    String? address,
    String? panNumber,
    String? gstNumber,
    String? notes,
    @Default(0.0) double balance, // Positive = we owe supplier (payable), Negative = supplier owes us (advance)
    required String balanceType, // "UDHARO", "ADVANCE", "SETTLED"
    @Default(0) int purchaseCount,
    DateTime? lastPurchaseDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

extension SupplierExtension on Supplier {
  /// Whether we owe money to this supplier (payable)
  bool get hasPayable => balance > 0;

  /// Whether supplier owes us (advance paid to supplier)
  bool get hasAdvance => balance < 0;

  /// Whether balance is settled
  bool get isSettled => balance == 0;

  /// Formatted balance display
  String get balanceDisplay {
    if (balance == 0) return 'Rs. 0 (Settled)';
    if (balance > 0) return 'Rs. ${balance.toStringAsFixed(2)} Payable';
    return 'Rs. ${balance.abs().toStringAsFixed(2)} Advance';
  }

  /// Whether supplier can be deleted (only when balance is zero)
  bool get canDelete => balance == 0;

  /// Whether due date is overdue
  bool get isOverdue {
    if (dueDate == null || balance <= 0) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Days until/past due date
  int? get daysToDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    return dueDate!.difference(now).inDays;
  }

  /// Short display for supplier (name with contact)
  String get displayName => '$supplierName ($mobileNumber)';
}
