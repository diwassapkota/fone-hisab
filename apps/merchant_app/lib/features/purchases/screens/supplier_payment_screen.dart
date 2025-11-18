import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';
import '../providers/purchase_form_providers.dart';
import '../../suppliers/providers/supplier_providers.dart';
import '../../suppliers/providers/supplier_detail_providers.dart';

class SupplierPaymentScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierPaymentScreen({
    super.key,
    this.supplierId,
  });

  @override
  ConsumerState<SupplierPaymentScreen> createState() =>
      _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState extends ConsumerState<SupplierPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplierId != null) {
      // Pre-select supplier if provided
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final supplier = await ref.read(
          supplierDetailProvider(widget.supplierId!).future,
        );
        ref.read(supplierPaymentFormProvider.notifier).setSupplier(
              supplier.supplierId,
              supplier.supplierName,
            );
      });
    }
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(supplierPaymentFormProvider);

    if (formState.supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (formState.paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final response = await purchaseService.createSupplierPayment(
        supplierId: formState.supplierId!,
        paymentAmount: formState.paymentAmount,
        paymentMode: formState.paymentMode,
        billDate: formState.billDate,
        description: formState.description,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(supplierPaymentFormProvider.notifier).reset();
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to record payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierPaymentFormProvider);
    final suppliers = ref.watch(supplierListProvider);

    // Get supplier balance if supplier is selected
    final supplierBalance = widget.supplierId != null
        ? ref.watch(supplierDetailProvider(widget.supplierId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Payment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Supplier Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Select Supplier'),
                subtitle: Text(formState.supplierName ?? 'No supplier selected'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: widget.supplierId == null
                    ? () {
                        _showSupplierSelection(context, suppliers);
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Current Balance Card (if supplier selected)
            if (formState.supplierId != null && supplierBalance != null)
              supplierBalance.when(
                data: (supplier) => Card(
                  color: _getBalanceColor(supplier.balanceType).withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Balance',
                          style: AppTypography.labelMedium.copyWith(
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
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            if (formState.supplierId != null && supplierBalance != null)
              const SizedBox(height: 16),

            // Payment Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Payment Date'),
                subtitle: Text(
                  '${formState.billDate.day}/${formState.billDate.month}/${formState.billDate.year}',
                ),
                trailing: const Icon(Icons.edit, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: formState.billDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    ref.read(supplierPaymentFormProvider.notifier).setBillDate(date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Payment Amount
            TextFormField(
              controller: _paymentAmountController,
              decoration: InputDecoration(
                labelText: 'Payment Amount *',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: 'Rs. ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                ref.read(supplierPaymentFormProvider.notifier).setPaymentAmount(amount);
              },
            ),
            const SizedBox(height: 16),

            // Payment Mode
            DropdownButtonFormField<String>(
              value: formState.paymentMode,
              decoration: InputDecoration(
                labelText: 'Payment Mode',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                DropdownMenuItem(value: 'DIGITAL', child: Text('Digital')),
                DropdownMenuItem(
                  value: 'BANK_TRANSFER',
                  child: Text('Bank Transfer'),
                ),
                DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(supplierPaymentFormProvider.notifier).setPaymentMode(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Payment reference, invoice number, etc.',
              ),
              maxLines: 3,
              onChanged: (value) {
                ref.read(supplierPaymentFormProvider.notifier).setDescription(value);
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _makePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.debitGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment),
                        const SizedBox(width: 8),
                        Text(
                          'Make Payment',
                          style: AppTypography.buttonLarge,
                        ),
                      ],
                    ),
            ),
          ],
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

  void _showSupplierSelection(BuildContext context, List<Supplier> suppliers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Supplier'),
        content: SizedBox(
          width: double.maxFinite,
          child: suppliers.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No suppliers found'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.store,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(supplier.supplierName),
                      subtitle: Text(supplier.mobileNumber),
                      trailing: Text(
                        supplier.balanceDisplay,
                        style: TextStyle(
                          color: _getBalanceColor(supplier.balanceType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        ref.read(supplierPaymentFormProvider.notifier).setSupplier(
                              supplier.supplierId,
                              supplier.supplierName,
                            );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
