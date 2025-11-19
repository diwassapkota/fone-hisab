import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../providers/supplier_providers.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == value) {
        ref.read(supplierSearchProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suppliersAsync = ref.watch(suppliersProvider);
    final suppliers = ref.watch(supplierListProvider);
    final summary = ref.watch(supplierSummaryProvider);
    final currentFilter = ref.watch(supplierFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              final result = await context.pushNamed('supplierForm');
              if (result == true) {
                // Refresh supplier list
                ref.invalidate(suppliersProvider);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search suppliers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.gray50,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Summary Cards (if available)
          if (summary != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Payable',
                      amount: 'Rs. ${summary.totalPayableAmount.toStringAsFixed(0)}',
                      count: '${summary.payableSuppliers} suppliers',
                      color: AppColors.creditRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Advance',
                      amount: 'Rs. ${summary.totalAdvanceAmount.toStringAsFixed(0)}',
                      count: '${summary.advanceSuppliers} suppliers',
                      color: AppColors.debitGreen,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: currentFilter == 'ALL',
                  onTap: () {
                    ref.read(supplierFilterProvider.notifier).state = 'ALL';
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Payable',
                  isSelected: currentFilter == 'PAYABLE',
                  onTap: () {
                    ref.read(supplierFilterProvider.notifier).state = 'PAYABLE';
                  },
                  color: AppColors.creditRed,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Advance',
                  isSelected: currentFilter == 'ADVANCE',
                  onTap: () {
                    ref.read(supplierFilterProvider.notifier).state = 'ADVANCE';
                  },
                  color: AppColors.debitGreen,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Settled',
                  isSelected: currentFilter == 'SETTLED',
                  onTap: () {
                    ref.read(supplierFilterProvider.notifier).state = 'SETTLED';
                  },
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Supplier List
          Expanded(
            child: suppliersAsync.when(
              data: (_) {
                if (suppliers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 80,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No suppliers found',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(suppliersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      return _SupplierCard(
                        supplier: supplier,
                        onTap: () {
                          context.pushNamed(
                            'supplierDetail',
                            pathParameters: {'id': supplier.supplierId},
                          );
                        },
                      );
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
                      'Error loading suppliers',
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
                        ref.invalidate(suppliersProvider);
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String count;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.gray300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.gray700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
  });

  Color get _balanceColor {
    if (supplier.balanceType == 'PAYABLE') return AppColors.creditRed;
    if (supplier.balanceType == 'ADVANCE') return AppColors.debitGreen;
    return AppColors.success;
  }

  IconData get _balanceIcon {
    if (supplier.balanceType == 'PAYABLE') return Icons.arrow_upward;
    if (supplier.balanceType == 'ADVANCE') return Icons.arrow_downward;
    return Icons.check_circle;
  }

  String get _balanceLabel {
    if (supplier.balanceType == 'PAYABLE') {
      return 'Rs. ${supplier.balance.toStringAsFixed(2)} Payable';
    } else if (supplier.balanceType == 'ADVANCE') {
      return 'Rs. ${supplier.balance.abs().toStringAsFixed(2)} Advance';
    } else {
      return 'Settled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _balanceColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.store,
                  color: _balanceColor,
                ),
              ),
              const SizedBox(width: 12),

              // Supplier Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.supplierName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      supplier.mobileNumber,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    if (supplier.lastPurchaseDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last: ${_formatDate(supplier.lastPurchaseDate!)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _balanceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _balanceIcon,
                          size: 14,
                          color: _balanceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _balanceLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: _balanceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (supplier.dueDate != null && supplier.isOverdue) ...[
                    const SizedBox(height: 4),
                    Text(
                      'OVERDUE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
