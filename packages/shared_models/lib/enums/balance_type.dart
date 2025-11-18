/// Balance type for customers and suppliers
enum BalanceType {
  /// Owes money (Customer owes merchant, or Merchant owes supplier)
  udharo('UDHARO'),

  /// Advance payment (Customer paid in advance, or Merchant paid supplier in advance)
  advance('ADVANCE'),

  /// No balance - settled
  settled('SETTLED');

  const BalanceType(this.value);

  final String value;

  /// Convert from string value to enum
  static BalanceType fromString(String value) {
    return BalanceType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => BalanceType.settled,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case BalanceType.udharo:
        return 'Udharo';
      case BalanceType.advance:
        return 'Advance';
      case BalanceType.settled:
        return 'Settled';
    }
  }
}
