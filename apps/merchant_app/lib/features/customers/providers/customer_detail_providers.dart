import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Transaction filter state
class TransactionFilter {
  final String type; // ALL, SALE, PAYMENT
  final String? startDate;
  final String? endDate;

  const TransactionFilter({
    this.type = 'ALL',
    this.startDate,
    this.endDate,
  });

  TransactionFilter copyWith({
    String? type,
    String? startDate,
    String? endDate,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Transaction filter provider for each customer
final transactionFilterProvider = StateProvider.family<TransactionFilter, String>(
  (ref, customerId) => const TransactionFilter(),
);

// Customer detail provider
final customerDetailProvider =
    FutureProvider.family.autoDispose<Customer, String>((ref, customerId) async {
  final customerService = ref.watch(customerServiceProvider);
  final response = await customerService.getCustomerById(customerId);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load customer');
  }
});

// Customer transactions provider (with filtering)
final customerTransactionsProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, String>(
        (ref, customerId) async {
  final customerService = ref.watch(customerServiceProvider);
  final filter = ref.watch(transactionFilterProvider(customerId));

  final response = await customerService.getCustomerTransactions(
    customerId: customerId,
    type: filter.type,
    startDate: filter.startDate,
    endDate: filter.endDate,
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(
        response.error?.message ?? 'Failed to load transactions');
  }
});

// Parse transactions from the response (paginated content)
final transactionListProvider =
    Provider.family.autoDispose<List<Transaction>, String>((ref, customerId) {
  final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));

  return transactionsAsync.when(
    data: (data) {
      // Backend returns paginated response with 'content' array
      final transactionsList = data['content'] as List?;
      if (transactionsList != null) {
        return transactionsList
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transaction summary provider
final transactionSummaryProvider =
    Provider.family.autoDispose<TransactionSummary?, String>((ref, customerId) {
  final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));

  return transactionsAsync.when(
    data: (data) {
      final summary = data['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        return TransactionSummary.fromJson(summary);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
