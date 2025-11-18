import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Supplier filter state (ALL, PAYABLE, ADVANCE, SETTLED)
final supplierFilterProvider = StateProvider<String>((ref) => 'ALL');

// Supplier search query
final supplierSearchProvider = StateProvider<String>((ref) => '');

// Supplier sort by (RECENT, NAME_ASC, NAME_DESC, BALANCE_HIGH, BALANCE_LOW)
final supplierSortByProvider = StateProvider<String>((ref) => 'RECENT');

// Suppliers list provider
final suppliersProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supplierService = ref.watch(supplierServiceProvider);
  final filter = ref.watch(supplierFilterProvider);
  final search = ref.watch(supplierSearchProvider);
  final sortBy = ref.watch(supplierSortByProvider);

  final response = await supplierService.getSuppliers(
    balanceType: filter,
    search: search,
    sortBy: sortBy,
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load suppliers');
  }
});

// Parse suppliers from the response
final supplierListProvider = Provider.autoDispose<List<Supplier>>((ref) {
  final suppliersAsync = ref.watch(suppliersProvider);

  return suppliersAsync.when(
    data: (data) {
      final suppliersList = data['suppliers'] as List?;
      if (suppliersList != null) {
        return suppliersList
            .map((json) => Supplier.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Supplier summary provider
final supplierSummaryProvider = Provider.autoDispose<SupplierSummary?>((ref) {
  final suppliersAsync = ref.watch(suppliersProvider);

  return suppliersAsync.when(
    data: (data) {
      final summary = data['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        return SupplierSummary.fromJson(summary);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
