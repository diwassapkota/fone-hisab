import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/customer_detail_providers.dart';
import '../providers/customer_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));
    final transactions = ref.watch(transactionListProvider(customerId));
    final summary = ref.watch(transactionSummaryProvider(customerId));

    return Scaffold(
      body: customerAsync.when(
        data: (customer) {
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
                                  child: Text(
                                    customer.name[0].toUpperCase(),
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: AppTypography.headlineSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        customer.mobileNumber,
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
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      _showOptionsMenu(context, ref, customer);
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
                            customer.balanceDisplay,
                            style: AppTypography.displaySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getBalanceColor(customer.balanceType),
                            ),
                          ),
                          if (customer.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getDueDateColor(customer.dueDate!).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getDueDateColor(customer.dueDate!),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _getDueDateColor(customer.dueDate!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due: ${_formatDate(customer.dueDate!)}',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: _getDueDateColor(customer.dueDate!),
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
                                icon: Icons.add,
                                label: 'Add Sale',
                                onTap: () {
                                  context.pushNamed(
                                    'salesEntry',
                                    queryParameters: {'customerId': customerId},
                                  );
                                },
                              ),
                              _ActionButton(
                                icon: Icons.payment,
                                label: 'Got Payment',
                                onTap: () {
                                  context.pushNamed(
                                    'paymentEntry',
                                    queryParameters: {'customerId': customerId},
                                  );
                                },
                              ),
                              _ActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                onTap: () {
                                  _shareCustomerReport(context, customer, summary);
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

              // Transaction Summary
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
                              'Transaction Summary',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Total Sales',
                              value: 'Rs. ${summary.totalSales.toStringAsFixed(2)}',
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

              // Transaction History Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction History',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _showFilterDialog(context, ref);
                        },
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filter'),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction List
              transactionsAsync.when(
                data: (_) {
                  if (transactions.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('No transactions yet'),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = transactions[index];
                        return _TransactionCard(transaction: transaction);
                      },
                      childCount: transactions.length,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(customerDetailProvider(customerId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showOptionsMenu(BuildContext context, WidgetRef ref, Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Customer'),
              onTap: () {
                context.pop();
                context.pushNamed(
                  'customerForm',
                  queryParameters: {'customerId': customer.id},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Set Due Date'),
              subtitle: customer.dueDate != null
                  ? Text('Current: ${_formatDate(customer.dueDate!)}')
                  : null,
              onTap: () {
                context.pop();
                _showSetDueDateDialog(context, ref, customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Report'),
              onTap: () {
                context.pop();
                _showReportOptions(context, ref, customer);
              },
            ),
            if (customer.balance == 0)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Customer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.pop();
                  _confirmDelete(context, ref, customer);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}?\n\n'
          'This action cannot be undone. All transaction history with this customer will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await _deleteCustomer(context, ref, customer);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, WidgetRef ref, Customer customer) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting customer...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final customerService = ref.read(customerServiceProvider);
      final response = await customerService.deleteCustomer(customer.id);

      if (!context.mounted) return;

      // Close loading dialog
      context.pop();

      if (response.success) {
        // Invalidate providers to refresh data
        ref.invalidate(customersProvider);
        ref.invalidate(dashboardSummaryProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} has been deleted'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to customer list
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to delete customer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(transactionFilterProvider(customerId));
    String selectedType = currentFilter.type;
    DateTime? startDate = currentFilter.startDate != null
        ? DateTime.parse(currentFilter.startDate!)
        : null;
    DateTime? endDate = currentFilter.endDate != null
        ? DateTime.parse(currentFilter.endDate!)
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Filter
                Text(
                  'Transaction Type',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: selectedType == 'ALL',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedType = 'ALL');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Sales'),
                      selected: selectedType == 'SALE',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedType = 'SALE');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Payments'),
                      selected: selectedType == 'PAYMENT',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedType = 'PAYMENT');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Range Filter
                Text(
                  'Date Range',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Start Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'Not set',
                  ),
                  trailing: startDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => startDate = null);
                          },
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),

                // End Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'Not set',
                  ),
                  trailing: endDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => endDate = null);
                          },
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear all filters
                ref.read(transactionFilterProvider(customerId).notifier).state =
                    const TransactionFilter();
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply filters
                ref.read(transactionFilterProvider(customerId).notifier).state =
                    TransactionFilter(
                      type: selectedType,
                      startDate: startDate?.toIso8601String().split('T')[0],
                      endDate: endDate?.toIso8601String().split('T')[0],
                    );
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareCustomerReport(BuildContext context, Customer customer, TransactionSummary? summary) {
    final StringBuffer report = StringBuffer();
    report.writeln('====== CUSTOMER REPORT ======');
    report.writeln('');
    report.writeln('Customer: ${customer.name}');
    report.writeln('Mobile: ${customer.mobileNumber}');
    if (customer.email != null) {
      report.writeln('Email: ${customer.email}');
    }
    if (customer.address != null) {
      report.writeln('Address: ${customer.address}');
    }
    report.writeln('');
    report.writeln('Current Balance: ${customer.balanceDisplay}');
    report.writeln('Balance Status: ${customer.balanceType}');
    report.writeln('');

    if (summary != null) {
      report.writeln('====== TRANSACTION SUMMARY ======');
      report.writeln('Total Sales: Rs. ${summary.totalSales.toStringAsFixed(2)}');
      report.writeln('Total Payments: Rs. ${summary.totalPayments.toStringAsFixed(2)}');
      report.writeln('Total Transactions: ${summary.transactionCount}');
      report.writeln('');
    }

    report.writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
    report.writeln('');
    report.writeln('---');
    report.writeln('Generated by Fonepay Khata Book');

    // For now, just copy to clipboard
    // In future, use share_plus package: Share.share(report.toString())
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report copied to clipboard. You can now paste and share it.'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // TODO: Install share_plus package and use:
    // Share.share(
    //   report.toString(),
    //   subject: 'Customer Report - ${customer.name}',
    // );
  }

  void _showSetDueDateDialog(BuildContext context, WidgetRef ref, Customer customer) {
    DateTime selectedDate = customer.dueDate ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Due Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set payment due date for ${customer.name}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: const Text('Due Date'),
              subtitle: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  selectedDate = picked;
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                }
              },
            ),
          ],
        ),
        actions: [
          if (customer.dueDate != null)
            TextButton(
              onPressed: () async {
                context.pop();
                await _clearDueDate(context, ref, customer);
              },
              child: const Text('Clear Due Date'),
            ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await _setDueDate(context, ref, customer, selectedDate);
            },
            child: const Text('Set Due Date'),
          ),
        ],
      ),
    );
  }

  Future<void> _setDueDate(BuildContext context, WidgetRef ref, Customer customer, DateTime dueDate) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Setting due date...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final customerService = ref.read(customerServiceProvider);
      final response = await customerService.setCustomerDueDate(
        customerId: customer.id,
        dueDate: dueDate,
      );

      if (!context.mounted) return;
      context.pop(); // Close loading dialog

      if (response.success) {
        ref.invalidate(customerDetailProvider(customer.id));
        ref.invalidate(customersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Due date set to ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to set due date'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      context.pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearDueDate(BuildContext context, WidgetRef ref, Customer customer) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Clearing due date...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final customerService = ref.read(customerServiceProvider);
      // Set a far future date to essentially clear it (backend might need a specific endpoint)
      final response = await customerService.setCustomerDueDate(
        customerId: customer.id,
        dueDate: DateTime.now().add(const Duration(days: 36500)), // 100 years in future
      );

      if (!context.mounted) return;
      context.pop(); // Close loading dialog

      if (response.success) {
        ref.invalidate(customerDetailProvider(customer.id));
        ref.invalidate(customersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Due date cleared'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to clear due date'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      context.pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportOptions(BuildContext context, WidgetRef ref, Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download Report',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Report'),
              subtitle: const Text('Download as PDF file'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF report generation coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                // TODO: Implement PDF download
                // Call backend API: /reports/customer?customerId=${customer.id}&format=PDF
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel Report'),
              subtitle: const Text('Download as Excel file'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Excel report generation coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                // TODO: Implement Excel download
                // Call backend API: /reports/customer?customerId=${customer.id}&format=EXCEL
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: Colors.blue),
              title: const Text('Text Summary'),
              subtitle: const Text('Share as text message'),
              onTap: () {
                final summary = ref.read(transactionSummaryProvider(customer.id));
                context.pop();
                _shareCustomerReport(context, customer, summary);
              },
            ),
          ],
        ),
      ),
    );
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall,
          ),
        ],
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
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSale = transaction.type == 'SALE';
    final color = isSale ? AppColors.creditRed : AppColors.debitGreen;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSale ? Icons.shopping_cart : Icons.payment,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.typeDisplay,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(transaction.billDate),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction.displayAmount,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Balance: Rs. ${transaction.balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (transaction.description != null && transaction.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                transaction.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
            if (isSale) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Sale: Rs. ${transaction.saleAmount.toStringAsFixed(2)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Paid: Rs. ${transaction.paymentAmount.toStringAsFixed(2)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ],
            // Show line items if available
            if (transaction.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${transaction.items.length} ${transaction.items.length == 1 ? 'item' : 'items'}',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...transaction.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.productName}',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (transaction.items.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${transaction.items.length - 3} more items',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

// Helper functions
Color _getBalanceColor(String balanceType) {
  if (balanceType == 'UDHARO') return AppColors.creditRed;
  if (balanceType == 'ADVANCE') return AppColors.advanceYellow;
  return AppColors.success;
}

Color _getDueDateColor(DateTime dueDate) {
  final now = DateTime.now();
  final difference = dueDate.difference(now).inDays;

  if (difference < 0) {
    // Overdue
    return AppColors.creditRed;
  } else if (difference <= 3) {
    // Due soon (within 3 days)
    return AppColors.advanceYellow;
  } else {
    // Future date
    return AppColors.debitGreen;
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
