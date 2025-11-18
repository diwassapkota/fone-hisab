import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../providers/product_detail_providers.dart';
import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Product Image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: product.imageUrls.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.inventory_2,
                                          size: 60,
                                          color: AppColors.gray400,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2,
                                    size: 60,
                                    color: AppColors.gray400,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          // Product Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              product.productName,
                              style: AppTypography.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (product.category != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.category!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final result = await context.pushNamed(
                        'productForm',
                        queryParameters: {'productId': productId},
                      );
                      if (result == true) {
                        ref.invalidate(productDetailProvider(productId));
                      }
                    },
                  ),
                ],
              ),

              // Price & Stock Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Stock Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStockColor(product.stockStatus).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStockColor(product.stockStatus),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _getStockLabel(product),
                              style: AppTypography.titleMedium.copyWith(
                                color: _getStockColor(product.stockStatus),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pricing Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _PriceInfo(
                                label: 'Selling Price',
                                amount: 'Rs. ${product.sellingPrice.toStringAsFixed(2)}',
                                color: AppColors.primary,
                              ),
                              _PriceInfo(
                                label: 'Cost Price',
                                amount: 'Rs. ${product.costPrice.toStringAsFixed(2)}',
                                color: AppColors.gray600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Profit Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profit per Unit',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.gray700,
                                  ),
                                ),
                                Text(
                                  'Rs. ${product.profitPerUnit.toStringAsFixed(2)} (${product.profitMarginPercentage.toStringAsFixed(1)}%)',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Product Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Details',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (product.sku != null)
                            _DetailRow(label: 'SKU', value: product.sku!),
                          if (product.barcode != null)
                            _DetailRow(label: 'Barcode', value: product.barcode!),
                          _DetailRow(label: 'Unit', value: product.unit),
                          if (product.trackInventory) ...[
                            _DetailRow(
                              label: 'Current Stock',
                              value: '${product.stockQuantity} ${product.unit}',
                            ),
                            _DetailRow(
                              label: 'Min Stock Level',
                              value: '${product.minStockLevel} ${product.unit}',
                            ),
                            _DetailRow(
                              label: 'Stock Value (Cost)',
                              value: 'Rs. ${product.stockValueAtCost.toStringAsFixed(2)}',
                            ),
                            _DetailRow(
                              label: 'Potential Profit',
                              value: 'Rs. ${product.potentialProfit.toStringAsFixed(2)}',
                            ),
                          ],
                          if (product.description != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              'Description',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.description!,
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (product.trackInventory) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.pushNamed(
                                'stockAdjustment',
                                pathParameters: {'productId': productId},
                              );
                            },
                            icon: const Icon(Icons.inventory),
                            label: const Text('Adjust Stock'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed(
                              'purchaseEntry',
                              queryParameters: {'productId': productId},
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add Purchase'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor(String status) {
    switch (status) {
      case 'IN_STOCK':
        return AppColors.success;
      case 'LOW_STOCK':
        return AppColors.warning;
      case 'OUT_OF_STOCK':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  String _getStockLabel(Product product) {
    if (!product.trackInventory) return 'Not Tracked';

    switch (product.stockStatus) {
      case 'IN_STOCK':
        return '${product.stockQuantity} ${product.unit} - In Stock';
      case 'LOW_STOCK':
        return '${product.stockQuantity} ${product.unit} - Low Stock';
      case 'OUT_OF_STOCK':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _PriceInfo({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
