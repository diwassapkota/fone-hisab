/// Sort options for supplier list
enum SupplierSortBy {
  /// Recently created first
  recent('RECENT'),

  /// Name A-Z
  nameAsc('NAME_ASC'),

  /// Name Z-A
  nameDesc('NAME_DESC'),

  /// Highest balance first (highest payable)
  balanceHigh('BALANCE_HIGH'),

  /// Lowest balance first
  balanceLow('BALANCE_LOW');

  const SupplierSortBy(this.value);

  final String value;

  /// Convert from string value to enum
  static SupplierSortBy fromString(String value) {
    return SupplierSortBy.values.firstWhere(
      (sort) => sort.value == value.toUpperCase(),
      orElse: () => SupplierSortBy.recent,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case SupplierSortBy.recent:
        return 'Recently Added';
      case SupplierSortBy.nameAsc:
        return 'Name (A-Z)';
      case SupplierSortBy.nameDesc:
        return 'Name (Z-A)';
      case SupplierSortBy.balanceHigh:
        return 'Highest Balance';
      case SupplierSortBy.balanceLow:
        return 'Lowest Balance';
    }
  }
}
