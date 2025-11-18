import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

/// Stock movement history record
@freezed
class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String movementId,
    required String productId,
    required String productName,
    required String movementType, // PURCHASE, SALE, ADJUSTMENT_IN, ADJUSTMENT_OUT
    required int quantity,
    required int stockBefore,
    required int stockAfter,
    String? referenceId, // Transaction/Purchase ID
    String? description,
    required DateTime createdAt,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
}

extension StockMovementExtension on StockMovement {
  /// Whether this is a stock increase
  bool get isIncrease =>
      movementType == 'PURCHASE' || movementType == 'ADJUSTMENT_IN';

  /// Whether this is a stock decrease
  bool get isDecrease =>
      movementType == 'SALE' || movementType == 'ADJUSTMENT_OUT';

  /// Display quantity with sign
  String get quantityDisplay {
    final sign = isIncrease ? '+' : '-';
    return '$sign$quantity';
  }

  /// Movement type display
  String get typeDisplay {
    switch (movementType) {
      case 'PURCHASE':
        return 'Purchase';
      case 'SALE':
        return 'Sale';
      case 'ADJUSTMENT_IN':
        return 'Adjustment (In)';
      case 'ADJUSTMENT_OUT':
        return 'Adjustment (Out)';
      default:
        return movementType;
    }
  }

  /// Color indicator for UI
  String get colorIndicator {
    return isIncrease ? 'green' : 'red';
  }
}
