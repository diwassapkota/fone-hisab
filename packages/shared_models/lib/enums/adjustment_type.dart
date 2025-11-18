/// Stock adjustment type for manual inventory changes
enum AdjustmentType {
  /// Add stock (e.g., found missing items, correction)
  add('ADD'),

  /// Remove stock (e.g., damage, theft, correction)
  remove('REMOVE');

  const AdjustmentType(this.value);

  final String value;

  /// Convert from string value to enum
  static AdjustmentType fromString(String value) {
    return AdjustmentType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => AdjustmentType.add,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case AdjustmentType.add:
        return 'Add Stock';
      case AdjustmentType.remove:
        return 'Remove Stock';
    }
  }

  /// Icon suggestion for UI
  String get iconName {
    switch (this) {
      case AdjustmentType.add:
        return 'add_circle';
      case AdjustmentType.remove:
        return 'remove_circle';
    }
  }
}
