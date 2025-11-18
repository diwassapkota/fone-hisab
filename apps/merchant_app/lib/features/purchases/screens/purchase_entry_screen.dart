import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';
import '../../../config/providers.dart';
import '../providers/purchase_form_providers.dart';
import '../../suppliers/providers/supplier_providers.dart';

class PurchaseEntryScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const PurchaseEntryScreen({
    super.key,
    this.supplierId,
  });

  @override
  ConsumerState<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends ConsumerState<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentAmountController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'CASH';

  @override
  void initState() {
    super.initState();
    if (widget.supplierId != null) {
      // Pre-select supplier if provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load supplier and set it in the form provider
      });
    }
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _descriptionController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(purchaseFormProvider);

    if (formState.supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (formState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final response = await purchaseService.createPurchase(
        supplierId: formState.supplierId!,
        purchaseAmount: formState.purchaseAmount,
        paymentAmount: formState.paymentAmount,
        paymentMode: formState.paymentMode,
        billDate: formState.billDate,
        billNumber: formState.billNumber,
        description: formState.description,
        billImages: formState.billImages,
        items: formState.items,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(purchaseFormProvider.notifier).reset();
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to record purchase'),
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
    final formState = ref.watch(purchaseFormProvider);
    final suppliers = ref.watch(supplierListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Entry'),
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
                onTap: () async {
                  // Show supplier selection dialog
                  _showSupplierSelection(context, suppliers);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bill Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Bill Date'),
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
                    ref.read(purchaseFormProvider.notifier).setBillDate(date);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bill Number
            TextFormField(
              controller: _billNumberController,
              decoration: InputDecoration(
                labelText: 'Bill Number',
                prefixIcon: const Icon(Icons.receipt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(purchaseFormProvider.notifier).setBillNumber(value);
              },
            ),
            const SizedBox(height: 16),

            // Items Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Purchase Items',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _showAddItemDialog();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (formState.items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No items added yet'),
                        ),
                      )
                    else
                      ...formState.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ListTile(
                          title: Text(item.productName ?? 'Product'),
                          subtitle: Text(
                            '${item.quantity} × Rs. ${item.unitCost.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rs. ${(item.quantity * item.unitCost).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  ref.read(purchaseFormProvider.notifier).removeItem(index);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${formState.purchaseAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(purchaseFormProvider.notifier).setPaymentMode(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Payment Amount
            TextFormField(
              controller: _paymentAmountController,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '0 for full credit',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                ref.read(purchaseFormProvider.notifier).setPaymentAmount(amount);
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
              ),
              maxLines: 2,
              onChanged: (value) {
                ref.read(purchaseFormProvider.notifier).setDescription(value);
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _savePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
                  : const Text('Record Purchase', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierSelection(BuildContext context, List<Supplier> suppliers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Supplier'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier.supplierName),
                subtitle: Text(supplier.mobileNumber),
                onTap: () {
                  ref.read(purchaseFormProvider.notifier).setSupplier(
                        supplier.supplierId,
                        supplier.supplierName,
                      );
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: 'Unit Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final item = PurchaseItemRequest(
                productName: nameController.text,
                quantity: int.tryParse(quantityController.text) ?? 0,
                unitCost: double.tryParse(costController.text) ?? 0.0,
              );
              ref.read(purchaseFormProvider.notifier).addItem(item);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
