import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Purchase type filter (ALL, PURCHASE, PAYMENT)
final purchaseTypeFilterProvider = StateProvider<String>((ref) => 'ALL');

// Purchase supplier filter (optional - filter by specific supplier)
final purchaseSupplierFilterProvider = StateProvider<String?>((ref) => null);

// Purchase date range filter
class PurchaseDateRange {
  final String? startDate;
  final String? endDate;

  const PurchaseDateRange({this.startDate, this.endDate});

  PurchaseDateRange copyWith({
    String? startDate,
    String? endDate,
  }) {
    return PurchaseDateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

final purchaseDateRangeProvider = StateProvider<PurchaseDateRange>(
  (ref) => const PurchaseDateRange(),
);

// Purchases list provider
final purchasesProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final purchaseService = ref.watch(purchaseServiceProvider);
  final typeFilter = ref.watch(purchaseTypeFilterProvider);
  final supplierFilter = ref.watch(purchaseSupplierFilterProvider);
  final dateRange = ref.watch(purchaseDateRangeProvider);

  final response = await purchaseService.getPurchases(
    supplierId: supplierFilter,
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load purchases');
  }
});

// Parse purchases from the response
final purchaseListProvider = Provider.autoDispose<List<Purchase>>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);

  return purchasesAsync.when(
    data: (data) {
      final purchasesList = data['content'] as List?;
      if (purchasesList != null) {
        return purchasesList
            .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Purchase summary provider (aggregated stats)
final purchaseSummaryGlobalProvider = Provider.autoDispose<PurchaseSummary?>((ref) {
  final purchasesAsync = ref.watch(purchasesProvider);

  return purchasesAsync.when(
    data: (data) {
      final summary = data['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        return PurchaseSummary.fromJson(summary);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Individual purchase detail provider
final purchaseDetailProvider =
    FutureProvider.family.autoDispose<Purchase, String>((ref, purchaseId) async {
  final purchaseService = ref.watch(purchaseServiceProvider);
  final response = await purchaseService.getPurchaseById(purchaseId);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load purchase');
  }
});
