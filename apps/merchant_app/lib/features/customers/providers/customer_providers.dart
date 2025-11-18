import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Customer filter state
final customerFilterProvider = StateProvider<String>((ref) => 'ALL');

// Customer search query
final customerSearchProvider = StateProvider<String>((ref) => '');

// Customer sort by
final customerSortByProvider = StateProvider<String>((ref) => 'RECENT');

// Customers list provider
final customersProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final customerService = ref.watch(customerServiceProvider);
  final filter = ref.watch(customerFilterProvider);
  final search = ref.watch(customerSearchProvider);
  final sortBy = ref.watch(customerSortByProvider);

  final response = await customerService.getCustomers(
    filter: filter,
    search: search,
    sortBy: sortBy,
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load customers');
  }
});

// Parse customers from the response
final customerListProvider = Provider.autoDispose<List<Customer>>((ref) {
  final customersAsync = ref.watch(customersProvider);

  return customersAsync.when(
    data: (data) {
      final customersList = data['customers'] as List?;
      if (customersList != null) {
        return customersList
            .map((json) => Customer.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Customer summary provider
final customerSummaryProvider = Provider.autoDispose<CustomerSummary?>((ref) {
  final customersAsync = ref.watch(customersProvider);

  return customersAsync.when(
    data: (data) {
      final summary = data['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        return CustomerSummary.fromJson(summary);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
