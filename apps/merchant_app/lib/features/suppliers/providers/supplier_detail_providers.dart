import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Purchase filter state for supplier ledger
class PurchaseFilter {
  final String type; // ALL, PURCHASE, PAYMENT
  final String? startDate;
  final String? endDate;

  const PurchaseFilter({
    this.type = 'ALL',
    this.startDate,
    this.endDate,
  });

  PurchaseFilter copyWith({
    String? type,
    String? startDate,
    String? endDate,
  }) {
    return PurchaseFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Purchase filter provider for each supplier
final purchaseFilterProvider = StateProvider.family<PurchaseFilter, String>(
  (ref, supplierId) => const PurchaseFilter(),
);

// Supplier detail provider
final supplierDetailProvider =
    FutureProvider.family.autoDispose<Supplier, String>((ref, supplierId) async {
  final supplierService = ref.watch(supplierServiceProvider);
  final response = await supplierService.getSupplierById(supplierId);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load supplier');
  }
});

// Supplier purchases/ledger provider (with filtering)
final supplierPurchasesProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, String>(
        (ref, supplierId) async {
  final purchaseService = ref.watch(purchaseServiceProvider);
  final filter = ref.watch(purchaseFilterProvider(supplierId));

  final response = await purchaseService.getSupplierLedger(
    supplierId: supplierId,
    startDate: filter.startDate ?? '',
    endDate: filter.endDate ?? '',
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(
        response.error?.message ?? 'Failed to load supplier ledger');
  }
});

// Parse purchases from the response (paginated content)
final purchaseListProvider =
    Provider.family.autoDispose<List<Purchase>, String>((ref, supplierId) {
  final purchasesAsync = ref.watch(supplierPurchasesProvider(supplierId));

  return purchasesAsync.when(
    data: (data) {
      // Backend returns paginated response with 'content' array
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

// Purchase summary provider (for supplier ledger)
final purchaseSummaryProvider =
    Provider.family.autoDispose<PurchaseSummary?, String>((ref, supplierId) {
  final purchasesAsync = ref.watch(supplierPurchasesProvider(supplierId));

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
