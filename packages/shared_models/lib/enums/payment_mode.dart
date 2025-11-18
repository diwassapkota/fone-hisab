/// Payment mode for transactions
enum PaymentMode {
  /// Cash payment
  cash('CASH'),

  /// Digital payment (Fonepay, eSewa, etc.)
  digital('DIGITAL'),

  /// Bank transfer
  bankTransfer('BANK_TRANSFER'),

  /// Cheque payment
  cheque('CHEQUE'),

  /// Other payment methods
  other('OTHER');

  const PaymentMode(this.value);

  final String value;

  /// Convert from string value to enum
  static PaymentMode fromString(String value) {
    return PaymentMode.values.firstWhere(
      (mode) => mode.value == value.toUpperCase(),
      orElse: () => PaymentMode.other,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.digital:
        return 'Digital';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.other:
        return 'Other';
    }
  }

  /// Icon name suggestion for UI
  String get iconName {
    switch (this) {
      case PaymentMode.cash:
        return 'payments';
      case PaymentMode.digital:
        return 'phone_android';
      case PaymentMode.bankTransfer:
        return 'account_balance';
      case PaymentMode.cheque:
        return 'receipt';
      case PaymentMode.other:
        return 'more_horiz';
    }
  }
}
