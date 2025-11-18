/// Sort options for product list
enum ProductSortBy {
  /// Recently created first
  recent('RECENT'),

  /// Name A-Z
  nameAsc('NAME_ASC'),

  /// Name Z-A
  nameDesc('NAME_DESC'),

  /// Lowest price first
  priceLow('PRICE_LOW'),

  /// Highest price first
  priceHigh('PRICE_HIGH'),

  /// Lowest stock first (urgent items)
  stockLow('STOCK_LOW'),

  /// Highest stock first
  stockHigh('STOCK_HIGH');

  const ProductSortBy(this.value);

  final String value;

  /// Convert from string value to enum
  static ProductSortBy fromString(String value) {
    return ProductSortBy.values.firstWhere(
      (sort) => sort.value == value.toUpperCase(),
      orElse: () => ProductSortBy.recent,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ProductSortBy.recent:
        return 'Recently Added';
      case ProductSortBy.nameAsc:
        return 'Name (A-Z)';
      case ProductSortBy.nameDesc:
        return 'Name (Z-A)';
      case ProductSortBy.priceLow:
        return 'Price: Low to High';
      case ProductSortBy.priceHigh:
        return 'Price: High to Low';
      case ProductSortBy.stockLow:
        return 'Stock: Low to High';
      case ProductSortBy.stockHigh:
        return 'Stock: High to Low';
    }
  }
}
