import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';

// Product detail provider (by ID)
final productDetailProvider =
    FutureProvider.family.autoDispose<Product, String>((ref, productId) async {
  final productService = ref.watch(productServiceProvider);
  final response = await productService.getProductById(productId);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Failed to load product');
  }
});

// Product by barcode provider (for barcode scanner)
final productByBarcodeProvider =
    FutureProvider.family.autoDispose<Product, String>((ref, barcode) async {
  final productService = ref.watch(productServiceProvider);
  final response = await productService.getProductByBarcode(barcode);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Product not found');
  }
});

// Product by SKU provider (for SKU search)
final productBySkuProvider =
    FutureProvider.family.autoDispose<Product, String>((ref, sku) async {
  final productService = ref.watch(productServiceProvider);
  final response = await productService.getProductBySku(sku);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.error?.message ?? 'Product not found');
  }
});
