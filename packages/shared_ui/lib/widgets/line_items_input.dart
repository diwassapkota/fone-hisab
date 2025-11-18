import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';

/// Reusable widget for adding/editing line items in a transaction
class LineItemsInput extends StatefulWidget {
  final List<SaleItemRequest> items;
  final ValueChanged<List<SaleItemRequest>> onItemsChanged;
  final bool autoCalculateTotal;
  final ValueChanged<bool>? onAutoCalculateChanged;

  const LineItemsInput({
    super.key,
    required this.items,
    required this.onItemsChanged,
    this.autoCalculateTotal = false,
    this.onAutoCalculateChanged,
  });

  @override
  State<LineItemsInput> createState() => _LineItemsInputState();
}

class _LineItemsInputState extends State<LineItemsInput> {
  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onItemAdded: (item) {
          final newItems = [...widget.items, item];
          widget.onItemsChanged(newItems);
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        initialItem: widget.items[index],
        onItemAdded: (item) {
          final newItems = [...widget.items];
          newItems[index] = item;
          widget.onItemsChanged(newItems);
        },
      ),
    );
  }

  void _removeItem(int index) {
    final newItems = [...widget.items];
    newItems.removeAt(index);
    widget.onItemsChanged(newItems);
  }

  double get _totalAmount {
    return widget.items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.list_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Line Items (Optional)',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addItem,
                  color: AppColors.primary,
                  tooltip: 'Add Item',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Auto-calculate toggle
            if (widget.onAutoCalculateChanged != null)
              SwitchListTile(
                title: Text(
                  'Auto-calculate total from items',
                  style: AppTypography.bodyMedium,
                ),
                subtitle: Text(
                  widget.autoCalculateTotal
                      ? 'Total will be calculated automatically'
                      : 'Enter total amount manually',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                value: widget.autoCalculateTotal,
                onChanged: widget.onAutoCalculateChanged,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 8),

            // Items List
            if (widget.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.shopping_basket_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No items added yet',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add items to track what was sold',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final total = item.quantity * item.unitPrice;
                  final displayName = item.productName ?? 'Product';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(51),
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${item.quantity} × Rs. ${item.unitPrice.toStringAsFixed(2)}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rs. ${total.toStringAsFixed(2)}',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editItem(index);
                            } else if (value == 'delete') {
                              _removeItem(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Total Summary
            if (widget.items.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${widget.items.length} items):',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rs. ${_totalAmount.toStringAsFixed(2)}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (widget.autoCalculateTotal)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'This amount will be used as sale amount',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding/editing a line item
class _AddItemDialog extends StatefulWidget {
  final SaleItemRequest? initialItem;
  final ValueChanged<SaleItemRequest> onItemAdded;

  const _AddItemDialog({
    this.initialItem,
    required this.onItemAdded,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: widget.initialItem?.productName ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.initialItem?.quantity.toString() ?? '1',
    );
    _unitPriceController = TextEditingController(
      text: widget.initialItem?.unitPrice.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final item = SaleItemRequest(
      productName: _productNameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      unitPrice: double.parse(_unitPriceController.text),
    );

    widget.onItemAdded(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.initialItem == null ? 'Add Item' : 'Edit Item',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Name
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Rice 5kg, Sugar 1kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity and Unit Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final qty = int.tryParse(value);
                        if (qty == null || qty < 1) {
                          return 'Min 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Unit Price',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.initialItem == null ? 'Add' : 'Update',
                      ),
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
}
