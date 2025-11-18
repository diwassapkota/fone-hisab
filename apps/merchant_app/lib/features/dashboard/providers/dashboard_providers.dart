import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Dashboard summary provider
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final customerService = ref.watch(customerServiceProvider);

  // Fetch customer summary with all filters to get totals
  final response = await customerService.getCustomers(
    page: 0,
    size: 1, // We only need the summary, not the customers
    filter: 'ALL',
  );

  if (response.success && response.data != null) {
    final data = response.data!;
    final summary = data['summary'] as Map<String, dynamic>?;

    if (summary != null) {
      return DashboardSummary.fromJson(summary);
    }
  }

  throw Exception('Failed to load dashboard summary');
});

// Recent transactions provider
final recentTransactionsProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);

  try {
    final response = await transactionService.getMerchantRecentTransactions(10);

    print('[RecentTransactions] Response success: ${response.success}');
    print('[RecentTransactions] Response data type: ${response.data.runtimeType}');

    if (response.success && response.data != null) {
      // response.data is now List<dynamic>
      return response.data!
          .map((json) {
            try {
              return Transaction.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('[RecentTransactions] Error parsing transaction: $e');
              print('[RecentTransactions] Transaction JSON: $json');
              return null;
            }
          })
          .where((t) => t != null)
          .cast<Transaction>()
          .toList();
    }

    return [];
  } catch (e, stackTrace) {
    print('[RecentTransactions] Error: $e');
    print('[RecentTransactions] StackTrace: $stackTrace');
    return []; // Return empty list instead of throwing
  }
});

// Complete dashboard analytics (inventory + supplier + customer metrics)
final dashboardAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);

  final response = await analyticsService.getDashboardAnalytics();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load analytics');
  }
});

// Inventory analytics provider
final inventoryAnalyticsProvider = FutureProvider.autoDispose<InventoryAnalytics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);

  final response = await analyticsService.getInventoryAnalytics();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load inventory analytics');
  }
});

// Supplier analytics provider
final supplierAnalyticsProvider = FutureProvider.autoDispose<SupplierAnalytics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);

  final response = await analyticsService.getSupplierAnalytics();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load supplier analytics');
  }
});

// Reorder suggestions provider (low stock alerts)
final reorderSuggestionsProvider = FutureProvider.autoDispose<List<ReorderSuggestion>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);

  final response = await analyticsService.getReorderSuggestions();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    return [];
  }
});

// Top selling products provider
final topSellingProductsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);

  final response = await analyticsService.getTopSellingProducts(limit: 10);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    return [];
  }
});

// Dashboard Summary Model
class DashboardSummary {
  final int totalCustomers;
  final double totalUdharo;
  final double totalAdvance;
  final double thisMonth; // Total sales this month

  DashboardSummary({
    required this.totalCustomers,
    required this.totalUdharo,
    required this.totalAdvance,
    required this.thisMonth,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      totalUdharo: (json['totalUdharoAmount'] as num?)?.toDouble() ?? 0.0,
      totalAdvance: (json['totalAdvanceAmount'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['thisMonthSales'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
