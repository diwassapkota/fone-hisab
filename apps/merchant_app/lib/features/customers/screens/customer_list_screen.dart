import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../providers/customer_providers.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
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
        ref.read(customerSearchProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final customersAsync = ref.watch(customersProvider);
    final customers = ref.watch(customerListProvider);
    final summary = ref.watch(customerSummaryProvider);
    final currentFilter = ref.watch(customerFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              final result = await context.pushNamed('customerForm');
              if (result == true) {
                // Refresh customer list
                ref.invalidate(customersProvider);
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
                hintText: l10n.searchCustomers,
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
                      title: 'Total Udharo',
                      amount: 'Rs. ${summary.totalUdharoAmount.toStringAsFixed(0)}',
                      count: '${summary.udharoCustomers} customers',
                      color: AppColors.creditRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Advance',
                      amount: 'Rs. ${summary.totalAdvanceAmount.toStringAsFixed(0)}',
                      count: '${summary.advanceCustomers} customers',
                      color: AppColors.advanceYellow,
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
                  label: l10n.all,
                  isSelected: currentFilter == 'ALL',
                  onTap: () {
                    ref.read(customerFilterProvider.notifier).state = 'ALL';
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.udharo,
                  isSelected: currentFilter == 'UDHARO',
                  onTap: () {
                    ref.read(customerFilterProvider.notifier).state = 'UDHARO';
                  },
                  color: AppColors.creditRed,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.advance,
                  isSelected: currentFilter == 'ADVANCE',
                  onTap: () {
                    ref.read(customerFilterProvider.notifier).state = 'ADVANCE';
                  },
                  color: AppColors.advanceYellow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer List
          Expanded(
            child: customersAsync.when(
              data: (_) {
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noCustomersFound,
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
                    ref.invalidate(customersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _CustomerCard(
                        customer: customer,
                        onTap: () {
                          context.pushNamed(
                            'customerDetail',
                            pathParameters: {'id': customer.id},
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
                      'Error loading customers',
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
                        ref.invalidate(customersProvider);
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
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('salesEntry'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Entry',
          style: AppTypography.buttonMedium.copyWith(color: Colors.white),
        ),
      ),*/
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

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
  });

  Color get _balanceColor {
    if (customer.balanceType == 'UDHARO') return AppColors.creditRed;
    if (customer.balanceType == 'ADVANCE') return AppColors.advanceYellow;
    return AppColors.success;
  }

  IconData get _balanceIcon {
    if (customer.balanceType == 'UDHARO') return Icons.arrow_upward;
    if (customer.balanceType == 'ADVANCE') return Icons.arrow_downward;
    return Icons.check_circle;
  }

  String get _balanceLabel {
    if (customer.balanceType == 'UDHARO') {
      return 'Rs. ${customer.balance.toStringAsFixed(2)} Udharo';
    } else if (customer.balanceType == 'ADVANCE') {
      return 'Rs. ${customer.balance.abs().toStringAsFixed(2)} Advance';
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
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: AppTypography.titleMedium.copyWith(
                    color: _balanceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.mobileNumber,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    if (customer.lastTransactionDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last: ${_formatDate(customer.lastTransactionDate!)}',
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
