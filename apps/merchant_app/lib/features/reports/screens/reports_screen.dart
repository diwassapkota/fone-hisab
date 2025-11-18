import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

enum ReportType {
  sales,
  payments,
  customers,
  summary,
}

enum DateFilter {
  today,
  yesterday,
  last7Days,
  thisMonth,
  lastMonth,
  custom,
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportType _selectedReportType = ReportType.summary;
  DateFilter _selectedDateFilter = DateFilter.thisMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Reports',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Report Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Type',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ReportTypeChip(
                        label: 'Summary',
                        icon: Icons.dashboard,
                        isSelected: _selectedReportType == ReportType.summary,
                        onTap: () => setState(() => _selectedReportType = ReportType.summary),
                      ),
                      const SizedBox(width: 8),
                      _ReportTypeChip(
                        label: 'Sales',
                        icon: Icons.shopping_cart,
                        isSelected: _selectedReportType == ReportType.sales,
                        onTap: () => setState(() => _selectedReportType = ReportType.sales),
                      ),
                      const SizedBox(width: 8),
                      _ReportTypeChip(
                        label: 'Payments',
                        icon: Icons.payment,
                        isSelected: _selectedReportType == ReportType.payments,
                        onTap: () => setState(() => _selectedReportType = ReportType.payments),
                      ),
                      const SizedBox(width: 8),
                      _ReportTypeChip(
                        label: 'Customers',
                        icon: Icons.people,
                        isSelected: _selectedReportType == ReportType.customers,
                        onTap: () => setState(() => _selectedReportType = ReportType.customers),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getDateRangeText(),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showDateFilterDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case ReportType.summary:
        return _SummaryReport(
          dateFilter: _selectedDateFilter,
          startDate: _customStartDate,
          endDate: _customEndDate,
        );
      case ReportType.sales:
        return _SalesReport(
          dateFilter: _selectedDateFilter,
          startDate: _customStartDate,
          endDate: _customEndDate,
        );
      case ReportType.payments:
        return _PaymentsReport(
          dateFilter: _selectedDateFilter,
          startDate: _customStartDate,
          endDate: _customEndDate,
        );
      case ReportType.customers:
        return const _CustomersReport();
    }
  }

  String _getDateRangeText() {
    switch (_selectedDateFilter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.yesterday:
        return 'Yesterday';
      case DateFilter.last7Days:
        return 'Last 7 Days';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.lastMonth:
        return 'Last Month';
      case DateFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}';
        }
        return 'Custom Range';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DateFilterOption(
              label: 'Today',
              isSelected: _selectedDateFilter == DateFilter.today,
              onTap: () {
                setState(() => _selectedDateFilter = DateFilter.today);
                Navigator.pop(context);
              },
            ),
            _DateFilterOption(
              label: 'Yesterday',
              isSelected: _selectedDateFilter == DateFilter.yesterday,
              onTap: () {
                setState(() => _selectedDateFilter = DateFilter.yesterday);
                Navigator.pop(context);
              },
            ),
            _DateFilterOption(
              label: 'Last 7 Days',
              isSelected: _selectedDateFilter == DateFilter.last7Days,
              onTap: () {
                setState(() => _selectedDateFilter = DateFilter.last7Days);
                Navigator.pop(context);
              },
            ),
            _DateFilterOption(
              label: 'This Month',
              isSelected: _selectedDateFilter == DateFilter.thisMonth,
              onTap: () {
                setState(() => _selectedDateFilter = DateFilter.thisMonth);
                Navigator.pop(context);
              },
            ),
            _DateFilterOption(
              label: 'Last Month',
              isSelected: _selectedDateFilter == DateFilter.lastMonth,
              onTap: () {
                setState(() => _selectedDateFilter = DateFilter.lastMonth);
                Navigator.pop(context);
              },
            ),
            _DateFilterOption(
              label: 'Custom Range',
              isSelected: _selectedDateFilter == DateFilter.custom,
              onTap: () async {
                Navigator.pop(context);
                await _selectCustomDateRange();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = DateFilter.custom;
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  void _showFilterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Advanced filters coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportAsExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel export feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ReportTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.gray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<bool>(
      title: Text(label),
      value: true,
      groupValue: isSelected,
      onChanged: (_) => onTap(),
    );
  }
}

// Placeholder report widgets
class _SummaryReport extends StatelessWidget {
  final DateFilter dateFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const _SummaryReport({
    required this.dateFilter,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Sales',
                value: 'Rs. 45,320.00',
                icon: Icons.trending_up,
                color: AppColors.creditRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Payments',
                value: 'Rs. 32,150.00',
                icon: Icons.trending_down,
                color: AppColors.debitGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Outstanding',
                value: 'Rs. 13,170.00',
                icon: Icons.account_balance_wallet,
                color: AppColors.advanceYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Transactions',
                value: '127',
                icon: Icons.receipt_long,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart placeholder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales vs Payments Trend',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Chart visualization coming soon',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesReport extends StatelessWidget {
  final DateFilter dateFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const _SalesReport({
    required this.dateFilter,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Summary',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ReportRow(label: 'Total Sales', value: 'Rs. 45,320.00'),
                _ReportRow(label: 'Cash Sales', value: 'Rs. 23,150.00'),
                _ReportRow(label: 'Credit Sales', value: 'Rs. 22,170.00'),
                _ReportRow(label: 'Number of Sales', value: '89'),
                _ReportRow(label: 'Average Sale', value: 'Rs. 509.21'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Sales Transactions',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Sales transaction list coming soon',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentsReport extends StatelessWidget {
  final DateFilter dateFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const _PaymentsReport({
    required this.dateFilter,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payments Summary',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ReportRow(label: 'Total Payments', value: 'Rs. 32,150.00'),
                _ReportRow(label: 'Cash Payments', value: 'Rs. 18,500.00'),
                _ReportRow(label: 'Digital Payments', value: 'Rs. 10,650.00'),
                _ReportRow(label: 'Bank Transfers', value: 'Rs. 3,000.00'),
                _ReportRow(label: 'Number of Payments', value: '38'),
                _ReportRow(label: 'Average Payment', value: 'Rs. 846.05'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Payment Transactions',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Payment transaction list coming soon',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomersReport extends StatelessWidget {
  const _CustomersReport();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Statistics',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ReportRow(label: 'Total Customers', value: '45'),
                _ReportRow(label: 'Active Customers', value: '38'),
                _ReportRow(label: 'Customers with Udharo', value: '23'),
                _ReportRow(label: 'Customers with Advance', value: '7'),
                _ReportRow(label: 'Settled Customers', value: '8'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.creditRed, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. 18,450',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.creditRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Top Debtor',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ram Sharma',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.people, color: AppColors.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '12',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New This Month',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              value,
              style: AppTypography.titleMedium.copyWith(
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

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[700],
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
