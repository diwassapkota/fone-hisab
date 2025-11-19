import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../providers/purchase_providers.dart';

class PurchaseListScreen extends ConsumerStatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  ConsumerState<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends ConsumerState<PurchaseListScreen> {
  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchasesProvider);
    final purchases = ref.watch(purchaseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.pushNamed('purchaseEntry');
              if (result == true) {
                ref.invalidate(purchasesProvider);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section (can be enhanced later)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Purchase History',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Purchase List
          Expanded(
            child: purchasesAsync.when(
              data: (_) {
                if (purchases.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No purchases found',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed('purchaseEntry');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Purchase'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(purchasesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return _PurchaseCard(purchase: purchase);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading purchases',
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(purchasesProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase.supplierName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.advanceYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Rs. ${purchase.purchaseAmount.toStringAsFixed(2)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.advanceYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bill Number & Date
            Row(
              children: [
                if (purchase.billNumber != null) ...[
                  Icon(Icons.receipt, size: 16, color: AppColors.gray500),
                  const SizedBox(width: 4),
                  Text(
                    purchase.billNumber!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.calendar_today, size: 16, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  _formatDate(purchase.billDate),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Payment Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: Rs. ${purchase.paymentAmount.toStringAsFixed(2)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.debitGreen,
                  ),
                ),
                if (purchase.purchaseAmount > purchase.paymentAmount)
                  Text(
                    'Due: Rs. ${(purchase.purchaseAmount - purchase.paymentAmount).toStringAsFixed(2)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.creditRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
