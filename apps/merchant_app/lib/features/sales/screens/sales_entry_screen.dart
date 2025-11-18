import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../../config/providers.dart';
import '../../customers/providers/customer_providers.dart';

class SalesEntryScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? calculatedAmount;

  const SalesEntryScreen({
    super.key,
    this.customerId,
    this.calculatedAmount,
  });

  @override
  ConsumerState<SalesEntryScreen> createState() => _SalesEntryScreenState();
}

class _SalesEntryScreenState extends ConsumerState<SalesEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _saleAmountController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Customer? _selectedCustomer;
  String _paymentMode = 'CASH';
  DateTime _billDate = DateTime.now();
  bool _isLoading = false;
  List<SaleItemRequest> _lineItems = [];
  bool _autoCalculateFromItems = false;

  double get saleAmount {
    if (_autoCalculateFromItems && _lineItems.isNotEmpty) {
      return _lineItems.fold(
        0.0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
      );
    }
    return double.tryParse(_saleAmountController.text) ?? 0.0;
  }

  double get paymentAmount =>
      double.tryParse(_paymentAmountController.text) ?? 0.0;
  double get remaining => saleAmount - paymentAmount;

  // Dynamic button properties based on business logic
  Color get buttonColor {
    if (saleAmount == 0) return AppColors.gray400;
    if (saleAmount > paymentAmount) {
      // Credit scenario (Udharo)
      return AppColors.creditRed;
    } else if (saleAmount == paymentAmount) {
      // Cash sale scenario
      return AppColors.primary;
    } else {
      // Advance payment scenario
      return AppColors.advanceYellow;
    }
  }

  String get buttonLabel {
    if (saleAmount == 0) return 'Enter Sale Amount';
    if (saleAmount > paymentAmount) {
      return 'Rs. ${remaining.toStringAsFixed(2)} Udharo (Credit)';
    } else if (saleAmount == paymentAmount) {
      return 'Cash Sale - Rs. ${saleAmount.toStringAsFixed(2)}';
    } else {
      return 'Rs. ${remaining.abs().toStringAsFixed(2)} Advance';
    }
  }

  IconData get buttonIcon {
    if (saleAmount > paymentAmount) {
      return Icons.arrow_upward;
    } else if (saleAmount == paymentAmount) {
      return Icons.check_circle;
    } else {
      return Icons.arrow_downward;
    }
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill amount if coming from calculator
    if (widget.calculatedAmount != null) {
      _saleAmountController.text = widget.calculatedAmount!;
      // Also pre-fill payment amount for quick cash sales
      _paymentAmountController.text = widget.calculatedAmount!;
    }
  }

  @override
  void dispose() {
    _saleAmountController.dispose();
    _paymentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Select Customer',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Customer List
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final customersAsync = ref.watch(customersProvider);
                    final customers = ref.watch(customerListProvider);

                    return customersAsync.when(
                      data: (_) {
                        if (customers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/customer-form',
                                    );
                                    if (result == true) {
                                      ref.invalidate(customersProvider);
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Customer'),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withAlpha(51),
                                child: Text(
                                  customer.name[0].toUpperCase(),
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(customer.mobileNumber),
                              trailing: Text(
                                customer.balanceDisplay,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: customer.balanceType == 'UDHARO'
                                      ? AppColors.creditRed
                                      : customer.balanceType == 'ADVANCE'
                                          ? AppColors.advanceYellow
                                          : AppColors.debitGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: ${error.toString()}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation: if auto-calculate is enabled but no items added
    if (_autoCalculateFromItems && _lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items or disable auto-calculate'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final response = await transactionService.createSalesEntry(
        customerId: _selectedCustomer?.id, // Now optional
        saleAmount: saleAmount,
        paymentAmount: paymentAmount,
        paymentMode: _paymentMode,
        description: _descriptionController.text.trim(),
        billDate: _billDate,
        items: _lineItems.isNotEmpty ? _lineItems : null,
        autoCalculateSaleAmount: _autoCalculateFromItems,
      );

      if (response.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Sale recorded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesEntry),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selection (Optional)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: _selectedCustomer != null ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    _selectedCustomer?.name ?? 'Select Customer (Optional)',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _selectedCustomer != null ? null : Colors.grey[600],
                    ),
                  ),
                  subtitle: _selectedCustomer != null
                      ? Text(_selectedCustomer!.mobileNumber)
                      : const Text('For general sales, customer is not required'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showCustomerSelectionDialog();
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Sale Amount
              TextFormField(
                controller: _saleAmountController,
                enabled: !_autoCalculateFromItems,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.saleAmount,
                  prefixText: 'Rs. ',
                  helperText: _autoCalculateFromItems
                      ? 'Auto-calculated from line items'
                      : null,
                  helperStyle: TextStyle(
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                  suffixIcon: widget.calculatedAmount != null
                      ? Tooltip(
                          message: 'Calculated from Quick Calculator',
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calculate, size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Calc',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _autoCalculateFromItems
                          ? Tooltip(
                              message: 'Auto-calculated from items',
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              ),
                            )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (_autoCalculateFromItems) return null;
                  if (value == null || value.isEmpty) {
                    return 'Please enter sale amount';
                  }
                  if (double.tryParse(value) == 0) {
                    return 'Sale amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Amount
              TextFormField(
                controller: _paymentAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Payment Received',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount (0 for full credit)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                initialValue: _paymentMode,
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                  DropdownMenuItem(value: 'DIGITAL', child: Text('Digital')),
                  DropdownMenuItem(
                      value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentMode = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Bill Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _billDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _billDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Bill Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_billDate.day}/${_billDate.month}/${_billDate.year}',
                        style: AppTypography.bodyLarge,
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: 'Optional notes about this sale',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Line Items Section
              LineItemsInput(
                items: _lineItems,
                onItemsChanged: (items) {
                  setState(() {
                    _lineItems = items;
                    // Update sale amount field if auto-calculate is enabled
                    if (_autoCalculateFromItems) {
                      final total = items.fold(
                        0.0,
                        (sum, item) => sum + (item.quantity * item.unitPrice),
                      );
                      _saleAmountController.text = total.toStringAsFixed(2);
                    }
                  });
                },
                autoCalculateTotal: _autoCalculateFromItems,
                onAutoCalculateChanged: (value) {
                  setState(() {
                    _autoCalculateFromItems = value;
                    if (value && _lineItems.isNotEmpty) {
                      // Auto-fill sale amount from items
                      final total = _lineItems.fold(
                        0.0,
                        (sum, item) => sum + (item.quantity * item.unitPrice),
                      );
                      _saleAmountController.text = total.toStringAsFixed(2);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Transaction Summary Card
              if (saleAmount > 0)
                Card(
                  color: buttonColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sale Amount:',
                                style: AppTypography.bodyMedium),
                            Text(
                              'Rs. ${saleAmount.toStringAsFixed(2)}',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Received:',
                                style: AppTypography.bodyMedium),
                            Text(
                              'Rs. ${paymentAmount.toStringAsFixed(2)}',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              remaining >= 0 ? 'Remaining:' : 'Advance:',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Rs. ${remaining.abs().toStringAsFixed(2)}',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: buttonColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Dynamic Proceed Button
              ElevatedButton.icon(
                onPressed: (_isLoading || saleAmount == 0)
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(buttonIcon),
                label: Text(
                  _isLoading ? 'Processing...' : buttonLabel,
                  style: AppTypography.buttonLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
