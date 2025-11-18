enum CustomerFilter {
  all,
  udharo, // Customers with outstanding credit
  advance, // Customers with advance payment
}

extension CustomerFilterExtension on CustomerFilter {
  String get displayName {
    switch (this) {
      case CustomerFilter.all:
        return 'All Customers';
      case CustomerFilter.udharo:
        return 'Udharo';
      case CustomerFilter.advance:
        return 'Advance';
    }
  }

  String get nepaliName {
    switch (this) {
      case CustomerFilter.all:
        return 'सबै ग्राहक';
      case CustomerFilter.udharo:
        return 'उधारो';
      case CustomerFilter.advance:
        return 'अग्रिम';
    }
  }
}
