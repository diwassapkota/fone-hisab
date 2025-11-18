import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    required String mobileNumber,
    String? email,
    String? address,
    @Default(0.0) double balance, // Positive = customer owes (udharo), Negative = advance payment
    required String balanceType, // "UDHARO", "ADVANCE", "SETTLED"
    DateTime? dueDate,
    DateTime? lastTransactionDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

extension CustomerExtension on Customer {
  bool get hasUdharo => balance > 0;
  bool get hasAdvance => balance < 0;
  bool get isCleared => balance == 0;

  String get balanceDisplay {
    if (balance == 0) return 'Rs. 0 (Cleared)';
    if (balance > 0) return 'Rs. ${balance.toStringAsFixed(2)} Udharo';
    return 'Rs. ${balance.abs().toStringAsFixed(2)} Advance';
  }
}
