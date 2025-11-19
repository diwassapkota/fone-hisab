import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../providers/supplier_detail_providers.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierDetailScreen({
    super.key,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierDetailProvider(supplierId));
    final purchasesAsync = ref.watch(supplierPurchasesProvider(supplierId));
    final purchases = ref.watch(purchaseListProvider(supplierId));
    final summary = ref.watch(purchaseSummaryProvider(supplierId));

    return Scaffold(
      body: supplierAsync.when(
        data: (supplier) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.store,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        supplier.supplierName,
                                        style: AppTypography.headlineSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        supplier.mobileNumber,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final result = await context.pushNamed(
                        'supplierForm',
                        queryParameters: {'supplierId': supplierId},
                      );
                      if (result == true) {
                        ref.invalidate(supplierDetailProvider(supplierId));
                      }
                    },
                  ),
                ],
              ),

              // Balance Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Current Balance',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            supplier.balanceDisplay,
                            style: AppTypography.displaySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getBalanceColor(supplier.balanceType),
                            ),
                          ),
                          if (supplier.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getDueDateColor(supplier.dueDate!).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getDueDateColor(supplier.dueDate!),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _getDueDateColor(supplier.dueDate!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due: ${_formatDate(supplier.dueDate!)}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: _getDueDateColor(supplier.dueDate!),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ActionButton(
                                icon: Icons.add_shopping_cart,
                                label: 'Add Purchase',
                                onTap: () {
                                  context.pushNamed(
                                    'purchaseEntry',
                                    queryParameters: {'supplierId': supplierId},
                                  );
                                },
                              ),
                              _ActionButton(
                                icon: Icons.payment,
                                label: 'Make Payment',
                                onTap: () {
                                  context.pushNamed(
                                    'supplierPayment',
                                    queryParameters: {'supplierId': supplierId},
                                  );
                                },
                              ),
                              _ActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                onTap: () {
                                  // Share functionality
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Purchase Summary
              if (summary != null)
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
                              'Purchase Summary',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Total Purchases',
                              value: 'Rs. ${summary.totalPurchases.toStringAsFixed(2)}',
                              color: AppColors.creditRed,
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Total Payments',
                              value: 'Rs. ${summary.totalPayments.toStringAsFixed(2)}',
                              color: AppColors.debitGreen,
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Transactions',
                              value: '${summary.transactionCount}',
                              color: AppColors.gray700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Purchase History Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Purchase History',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Show filter dialog
                        },
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filter'),
                      ),
                    ],
                  ),
                ),
              ),

              // Purchase List
              purchasesAsync.when(
                data: (_) {
                  if (purchases.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('No purchases yet'),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final purchase = purchases[index];
                        return _PurchaseCard(purchase: purchase);
                      },
                      childCount: purchases.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Color _getBalanceColor(String balanceType) {
    switch (balanceType) {
      case 'PAYABLE':
        return AppColors.creditRed;
      case 'ADVANCE':
        return AppColors.debitGreen;
      default:
        return AppColors.success;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return AppColors.error; // Overdue
    } else if (difference <= 3) {
      return AppColors.warning; // Due soon
    } else {
      return AppColors.success; // Future
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseCard({
    required this.purchase,
  });

  Color get _typeColor {
    return purchase.transactionType == 'PURCHASE'
        ? AppColors.creditRed
        : AppColors.debitGreen;
  }

  IconData get _typeIcon {
    return purchase.transactionType == 'PURCHASE'
        ? Icons.shopping_cart
        : Icons.payment;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor.withValues(alpha: 0.1),
          child: Icon(_typeIcon, color: _typeColor, size: 20),
        ),
        title: Text(
          purchase.transactionType == 'PURCHASE' ? 'Purchase' : 'Payment',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(purchase.billDate),
          style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${purchase.purchaseAmount.toStringAsFixed(2)}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: _typeColor,
              ),
            ),
            if (purchase.items.isNotEmpty)
              Text(
                '${purchase.items.length} items',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                ),
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
