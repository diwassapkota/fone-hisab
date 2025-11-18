/// Stock status for products
enum StockStatus {
  /// In stock - quantity above minimum level
  inStock('IN_STOCK'),

  /// Low stock - quantity at or below minimum level
  lowStock('LOW_STOCK'),

  /// Out of stock - quantity is zero
  outOfStock('OUT_OF_STOCK'),

  /// Not tracked - inventory tracking disabled for this product
  notTracked('NOT_TRACKED');

  const StockStatus(this.value);

  final String value;

  /// Convert from string value to enum
  static StockStatus fromString(String value) {
    return StockStatus.values.firstWhere(
      (status) => status.value == value.toUpperCase(),
      orElse: () => StockStatus.notTracked,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.notTracked:
        return 'Not Tracked';
    }
  }

  /// Color indicator for UI (using Material color names)
  String get colorIndicator {
    switch (this) {
      case StockStatus.inStock:
        return 'green';
      case StockStatus.lowStock:
        return 'orange';
      case StockStatus.outOfStock:
        return 'red';
      case StockStatus.notTracked:
        return 'grey';
    }
  }

  /// Whether this status indicates stock issues
  bool get needsAttention {
    return this == StockStatus.lowStock || this == StockStatus.outOfStock;
  }
}
