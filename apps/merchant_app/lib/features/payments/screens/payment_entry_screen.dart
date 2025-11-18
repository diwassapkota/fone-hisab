import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';
import '../../customers/providers/customer_providers.dart';
import '../../customers/providers/customer_detail_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class PaymentEntryScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const PaymentEntryScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<PaymentEntryScreen> createState() => _PaymentEntryScreenState();
}

class _PaymentEntryScreenState extends ConsumerState<PaymentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Customer? _selectedCustomer;
  String _paymentMode = 'CASH';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  double get amount => double.tryParse(_amountController.text) ?? 0.0;

  @override
  void initState() {
    super.initState();
    // If customerId is provided via route, load that customer
    if (widget.customerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final customerService = ref.read(customerServiceProvider);
          final response = await customerService.getCustomerById(widget.customerId!);
          if (response.success && response.data != null && mounted) {
            setState(() {
              _selectedCustomer = response.data;
            });
          }
        } catch (e) {
          // Customer not found or error loading
          print('Error loading customer: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
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
                    Expanded(
                      child: Text(
                        'Select Customer',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

                    return customersAsync.when(
                      data: (customersData) {
                        final customers = customersData['customers'] as List;

                        if (customers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_off,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: AppTypography.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.pushNamed('customerForm');
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
                            final customerData = customers[index] as Map<String, dynamic>;
                            final customer = Customer.fromJson(customerData);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  customer.name[0].toUpperCase(),
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(customer.name),
                              subtitle: Text(customer.mobileNumber),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    customer.balanceDisplay,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: customer.balanceType == 'UDHARO'
                                          ? AppColors.creditRed
                                          : customer.balanceType == 'ADVANCE'
                                              ? AppColors.advanceYellow
                                              : AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    customer.balanceType,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ],
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate customer is selected
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please select a customer'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionService = ref.read(transactionServiceProvider);

      final response = await transactionService.createPaymentEntry(
        customerId: _selectedCustomer!.id,
        amount: amount,
        paymentMode: _paymentMode,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        paymentDate: _paymentDate,
      );

      if (!mounted) return;

      if (response.success) {
        // Invalidate providers to refresh data
        ref.invalidate(customersProvider);
        ref.invalidate(customerDetailProvider(_selectedCustomer!.id));
        ref.invalidate(customerTransactionsProvider(_selectedCustomer!.id));
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(recentTransactionsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Payment of Rs. ${amount.toStringAsFixed(2)} recorded successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(response.error?.message ?? 'Failed to record payment'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Network error. Please check your connection.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selection (Required)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: _selectedCustomer != null ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    _selectedCustomer?.name ?? 'Select Customer',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _selectedCustomer != null ? null : Colors.grey[600],
                    ),
                  ),
                  subtitle: _selectedCustomer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedCustomer!.mobileNumber),
                            Text(
                              _selectedCustomer!.balanceDisplay,
                              style: TextStyle(
                                color: _selectedCustomer!.balanceType == 'UDHARO'
                                    ? AppColors.creditRed
                                    : _selectedCustomer!.balanceType == 'ADVANCE'
                                        ? AppColors.advanceYellow
                                        : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text('Required - Tap to select'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showCustomerSelectionDialog,
                ),
              ),
              const SizedBox(height: 20),

              // Payment Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Refresh UI
                },
              ),
              const SizedBox(height: 20),

              // Payment Mode
              Text(
                'Payment Mode',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Cash'),
                    selected: _paymentMode == 'CASH',
                    onSelected: (selected) {
                      setState(() {
                        _paymentMode = 'CASH';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Digital'),
                    selected: _paymentMode == 'DIGITAL',
                    onSelected: (selected) {
                      setState(() {
                        _paymentMode = 'DIGITAL';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Bank Transfer'),
                    selected: _paymentMode == 'BANK_TRANSFER',
                    onSelected: (selected) {
                      setState(() {
                        _paymentMode = 'BANK_TRANSFER';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Payment Date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Payment Date'),
                  subtitle: Text(
                    '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 20),

              // Description (Optional)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add notes about this payment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading || amount == 0 ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.debitGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment),
                      const SizedBox(width: 8),
                      Text(
                        amount > 0
                            ? 'Record Payment - Rs. ${amount.toStringAsFixed(2)}'
                            : 'Enter Payment Amount',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
