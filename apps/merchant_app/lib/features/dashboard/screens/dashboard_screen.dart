import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../../customers/screens/customer_list_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const CustomerListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEntryOptions(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Entry',
                style: AppTypography.buttonMedium.copyWith(color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.customers,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment),
            label: l10n.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  void _showAddEntryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Entry',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calculate, color: AppColors.primary),
              ),
              title: const Text('Quick Calculator'),
              subtitle: const Text('Calculate amount then create sale'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('calculator');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.creditRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shopping_cart, color: AppColors.creditRed),
              ),
              title: const Text('Sales Entry'),
              subtitle: const Text('Record a new sale transaction'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('salesEntry');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.debitGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: AppColors.debitGreen),
              ),
              title: const Text('Receive Payment'),
              subtitle: const Text('Customer paid you (reduces udharo)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('paymentEntry');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(recentTransactionsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.pushNamed('notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(recentTransactionsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              dashboardSummaryAsync.when(
                data: (summary) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Udharo',
                            amount: 'Rs. ${summary.totalUdharo.toStringAsFixed(2)}',
                            color: AppColors.creditRed,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Advance',
                            amount: 'Rs. ${summary.totalAdvance.toStringAsFixed(2)}',
                            color: AppColors.advanceYellow,
                            icon: Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Customers',
                            amount: '${summary.totalCustomers}',
                            color: AppColors.debitGreen,
                            icon: Icons.people,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'This Month',
                            amount: 'Rs. ${summary.thisMonth.toStringAsFixed(2)}',
                            color: AppColors.info,
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _LoadingCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _LoadingCard()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _LoadingCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _LoadingCard()),
                      ],
                    ),
                  ],
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load dashboard data',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.invalidate(dashboardSummaryProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions
                    },
                    child: Text(
                      'View All',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transaction list
              recentTransactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recent transactions',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _TransactionItem(
                        transaction: transaction,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load transactions',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 12,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 20,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                    color: color.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isSale = transaction.type == 'SALE';
    final color = isSale ? AppColors.creditRed : AppColors.debitGreen;
    final customerName = transaction.customer?.name ?? 'General Sale';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(51),
          child: Icon(
            isSale ? Icons.shopping_cart : Icons.payment,
            color: color,
          ),
        ),
        title: Text(
          customerName,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${transaction.typeDisplay} • ${_formatDate(transaction.billDate)}',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          transaction.displayAmount,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
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


