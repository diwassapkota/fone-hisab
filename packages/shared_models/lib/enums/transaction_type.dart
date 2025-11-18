enum TransactionType {
  credit, // Udharo - Customer owes merchant
  debit, // Payment - Customer paid merchant
  advance, // Advance payment - Customer paid more than sale amount
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.credit:
        return 'Credit (Udharo)';
      case TransactionType.debit:
        return 'Debit (Payment)';
      case TransactionType.advance:
        return 'Advance';
    }
  }

  String get nepaliName {
    switch (this) {
      case TransactionType.credit:
        return 'उधारो';
      case TransactionType.debit:
        return 'भुक्तानी';
      case TransactionType.advance:
        return 'अग्रिम';
    }
  }
}
