import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Product category filter (ALL, or specific category)
final productCategoryProvider = StateProvider<String>((ref) => 'ALL');

// Product stock status filter (ALL, IN_STOCK, LOW_STOCK, OUT_OF_STOCK, NOT_TRACKED)
final productStockStatusProvider = StateProvider<String>((ref) => 'ALL');

// Product search query
final productSearchProvider = StateProvider<String>((ref) => '');

// Product sort by (RECENT, NAME_ASC, NAME_DESC, PRICE_LOW, PRICE_HIGH, STOCK_LOW, STOCK_HIGH)
final productSortByProvider = StateProvider<String>((ref) => 'RECENT');

// Products list provider
final productsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final category = ref.watch(productCategoryProvider);
  final stockStatus = ref.watch(productStockStatusProvider);
  final search = ref.watch(productSearchProvider);
  final sortBy = ref.watch(productSortByProvider);

  final response = await productService.getProducts(
    category: category == 'ALL' ? null : category,
    stockStatus: stockStatus,
    search: search,
    sortBy: sortBy,
  );

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load products');
  }
});

// Parse products from the response
final productListProvider = Provider.autoDispose<List<Product>>((ref) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    data: (data) {
      final productsList = data['products'] as List?;
      if (productsList != null) {
        return productsList
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Categories provider (for filter dropdown)
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final response = await productService.getCategories();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    return [];
  }
});

// Low stock products provider (for alerts/notifications)
final lowStockProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final response = await productService.getLowStockProducts();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    return [];
  }
});
