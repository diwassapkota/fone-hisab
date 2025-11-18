/// Transaction type for purchase-related operations
enum PurchaseTransactionType {
  /// Purchase from supplier (increases balance)
  purchase('PURCHASE'),

  /// Payment to supplier (decreases balance)
  payment('PAYMENT');

  const PurchaseTransactionType(this.value);

  final String value;

  /// Convert from string value to enum
  static PurchaseTransactionType fromString(String value) {
    return PurchaseTransactionType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => PurchaseTransactionType.purchase,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PurchaseTransactionType.purchase:
        return 'Purchase';
      case PurchaseTransactionType.payment:
        return 'Payment';
    }
  }

  /// Whether this increases supplier balance (we owe more)
  bool get increasesBalance {
    return this == PurchaseTransactionType.purchase;
  }
}
