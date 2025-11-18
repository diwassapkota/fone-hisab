import 'package:freezed_annotation/freezed_annotation.dart';

part 'reorder_suggestion.freezed.dart';
part 'reorder_suggestion.g.dart';

/// Reorder suggestion for low stock products
@freezed
class ReorderSuggestion with _$ReorderSuggestion {
  const factory ReorderSuggestion({
    required String productId,
    required String productName,
    required int currentStock,
    required int minStockLevel,
    required int suggestedOrderQuantity,
    String? category,
  }) = _ReorderSuggestion;

  factory ReorderSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ReorderSuggestionFromJson(json);
}

extension ReorderSuggestionExtension on ReorderSuggestion {
  /// Stock shortage amount
  int get shortageAmount => minStockLevel - currentStock;

  /// Whether product is completely out of stock
  bool get isOutOfStock => currentStock == 0;

  /// Priority level (higher is more urgent)
  String get priorityLevel {
    if (isOutOfStock) return 'CRITICAL';
    if (currentStock <= minStockLevel / 2) return 'HIGH';
    return 'MEDIUM';
  }

  /// Display text for suggestion
  String get suggestionText {
    if (isOutOfStock) {
      return 'Out of stock! Order $suggestedOrderQuantity units immediately';
    }
    return 'Low stock ($currentStock left). Suggest ordering $suggestedOrderQuantity units';
  }

  /// Color indicator for priority
  String get priorityColor {
    switch (priorityLevel) {
      case 'CRITICAL':
        return 'red';
      case 'HIGH':
        return 'orange';
      default:
        return 'yellow';
    }
  }
}
