import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';

class QuickCalculatorScreen extends StatefulWidget {
  const QuickCalculatorScreen({super.key});

  @override
  State<QuickCalculatorScreen> createState() => _QuickCalculatorScreenState();
}

enum CalculatorMode { simple, items }

class CalculatorItem {
  final double quantity;
  final double price;
  final String? description;

  CalculatorItem({
    required this.quantity,
    required this.price,
    this.description,
  });

  double get total => quantity * price;

  String get displayText {
    final desc = description?.isNotEmpty == true ? '$description: ' : '';
    return '$desc$quantity × Rs. ${price.toStringAsFixed(2)} = Rs. ${total.toStringAsFixed(2)}';
  }
}

class _QuickCalculatorScreenState extends State<QuickCalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _currentValue = 0;
  double _previousValue = 0;
  double _operandValue = 0; // Store the actual second operand
  String _operation = '';
  bool _shouldResetDisplay = false;

  // Enhanced calculator features
  CalculatorMode _mode = CalculatorMode.simple;
  List<CalculatorItem> _items = [];
  double _discountPercent = 0;
  double _taxPercent = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Calculator'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Mode toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: SegmentedButton<CalculatorMode>(
              segments: const [
                ButtonSegment(
                  value: CalculatorMode.simple,
                  icon: Icon(Icons.calculate, size: 18),
                  label: Text('Simple'),
                ),
                ButtonSegment(
                  value: CalculatorMode.items,
                  icon: Icon(Icons.list, size: 18),
                  label: Text('Items'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<CalculatorMode> selection) {
                setState(() {
                  _mode = selection.first;
                  if (_mode == CalculatorMode.items) {
                    _clear();
                  }
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppColors.primary.withValues(alpha: 0.3);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.white;
                }),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.backgroundLight,
                  ],
                ),
              ),
              child: _mode == CalculatorMode.simple
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expression display
                        if (_expression.isNotEmpty)
                          Text(
                            _expression,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        // Current value display
                        Text(
                          'Rs. ${_formatAmount(_display)}',
                          style: AppTypography.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 48,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                        ),
                      ],
                    )
                  : _buildItemsList(),
            ),
          ),

          // Calculator Buttons
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _mode == CalculatorMode.simple
                  ? _buildSimpleCalculatorButtons()
                  : _buildItemsCalculatorButtons(),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _currentValue > 0 ? () => _createSale() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.creditRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(
                      _currentValue > 0
                          ? 'Create Sale - Rs. ${_formatAmount(_display)}'
                          : 'Enter amount to create sale',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _currentValue > 0 ? () => _receivePayment() : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.debitGreen,
                      side: BorderSide(
                        color: _currentValue > 0 ? AppColors.debitGreen : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.payment),
                    label: Text(
                      'Receive Payment',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCalculatorButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildButton('C', isSpecial: true, onTap: _clear),
              _buildButton('⌫', isSpecial: true, onTap: _backspace),
              _buildButton('%', isOperator: true, onTap: () => _handleOperation('%')),
              _buildButton('÷', isOperator: true, onTap: () => _handleOperation('÷')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('7', onTap: () => _handleNumber('7')),
              _buildButton('8', onTap: () => _handleNumber('8')),
              _buildButton('9', onTap: () => _handleNumber('9')),
              _buildButton('×', isOperator: true, onTap: () => _handleOperation('×')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('4', onTap: () => _handleNumber('4')),
              _buildButton('5', onTap: () => _handleNumber('5')),
              _buildButton('6', onTap: () => _handleNumber('6')),
              _buildButton('-', isOperator: true, onTap: () => _handleOperation('-')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('1', onTap: () => _handleNumber('1')),
              _buildButton('2', onTap: () => _handleNumber('2')),
              _buildButton('3', onTap: () => _handleNumber('3')),
              _buildButton('+', isOperator: true, onTap: () => _handleOperation('+')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('00', onTap: () => _handleNumber('00')),
              _buildButton('0', onTap: () => _handleNumber('0')),
              _buildButton('.', onTap: () => _handleDecimal()),
              _buildButton('=', isOperator: true, onTap: _calculate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCalculatorButtons() {
    return Column(
      children: [
        // Add Item Button (takes full width)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                onTap: _showAddItemDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Add Item',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Discount Row
        Expanded(
          child: Row(
            children: [
              _buildButton('C', isSpecial: true, onTap: _clear),
              _buildActionButton(
                'Discount',
                Icons.local_offer,
                () => _showDiscountDialog(),
                color: AppColors.advanceYellow,
              ),
            ],
          ),
        ),

        // Tax Row
        Expanded(
          child: Row(
            children: [
              _buildActionButton(
                'Tax (13%)',
                Icons.receipt,
                () => _applyTax(13),
                color: AppColors.debitGreen,
              ),
              _buildActionButton(
                'Custom Tax',
                Icons.percent,
                () => _showTaxDialog(),
                color: AppColors.debitGreen,
              ),
            ],
          ),
        ),

        // Quick Discount Buttons
        Expanded(
          child: Row(
            children: [
              _buildButton('5%', onTap: () => _applyDiscount(5)),
              _buildButton('10%', onTap: () => _applyDiscount(10)),
              _buildButton('15%', onTap: () => _applyDiscount(15)),
              _buildButton('20%', onTap: () => _applyDiscount(20)),
            ],
          ),
        ),

        // Clear Discount/Tax
        Expanded(
          child: Row(
            children: [
              _buildButton(
                'Clear Discount',
                isSpecial: true,
                onTap: () {
                  setState(() {
                    _discountPercent = 0;
                    _updateTotalFromItems();
                  });
                },
              ),
              _buildButton(
                'Clear Tax',
                isSpecial: true,
                onTap: () {
                  setState(() {
                    _taxPercent = 0;
                    _updateTotalFromItems();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String label, {
    bool isOperator = false,
    bool isSpecial = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: isOperator
              ? AppColors.primary
              : isSpecial
                  ? Colors.grey[200]
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: isOperator ? 2 : 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.headlineMedium.copyWith(
                  color: isOperator
                      ? Colors.white
                      : isSpecial
                          ? AppColors.primary
                          : Colors.black87,
                  fontWeight: isOperator ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumber(String number) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        if (_display == '0') {
          _display = number;
        } else {
          _display += number;
        }
      }
      _currentValue = double.tryParse(_display) ?? 0;
    });
  }

  void _handleDecimal() {
    setState(() {
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _handleOperation(String op) {
    setState(() {
      // Store current value before any calculation
      final currentOperand = _currentValue;

      if (_operation.isNotEmpty) {
        // Calculate intermediate result first
        _calculateIntermediate();

        // Add the ORIGINAL operand (before calc) to expression
        _expression += '${_formatAmount(currentOperand.toString())} $op ';
      } else {
        // Build cumulative expression
        if (_expression.isEmpty || _expression.endsWith('=')) {
          // Starting fresh or after equals
          _expression = '${_formatAmount(currentOperand.toString())} $op ';
        }
      }

      _previousValue = _currentValue;  // Now _currentValue is the result after intermediate calc
      _operation = op;
      _shouldResetDisplay = true;
    });
  }

  void _calculateIntermediate() {
    if (_operation.isEmpty) return;

    _operandValue = _currentValue;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _previousValue + _currentValue;
        break;
      case '-':
        result = _previousValue - _currentValue;
        break;
      case '×':
        result = _previousValue * _currentValue;
        break;
      case '÷':
        if (_currentValue != 0) {
          result = _previousValue / _currentValue;
        } else {
          return;
        }
        break;
      case '%':
        result = _previousValue * (_currentValue / 100);
        break;
    }

    // Update values without setState (already inside setState from caller)
    _currentValue = result;
    _display = result.toStringAsFixed(2);
  }

  void _calculate() {
    if (_operation.isEmpty) return;

    // Store the current value as the second operand before calculation
    _operandValue = _currentValue;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _previousValue + _currentValue;
        break;
      case '-':
        result = _previousValue - _currentValue;
        break;
      case '×':
        result = _previousValue * _currentValue;
        break;
      case '÷':
        if (_currentValue != 0) {
          result = _previousValue / _currentValue;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot divide by zero'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        break;
      case '%':
        result = _previousValue * (_currentValue / 100);
        break;
    }

    setState(() {
      _display = result.toStringAsFixed(2);
      // Complete the expression by adding the last operand and equals
      if (_expression.isEmpty) {
        _expression = '${_formatAmount(_previousValue.toString())} $_operation ${_formatAmount(_operandValue.toString())} =';
      } else if (!_expression.endsWith('=')) {
        _expression += '${_formatAmount(_operandValue.toString())} =';
      }
      _currentValue = result;
      _operation = '';
      _shouldResetDisplay = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _currentValue = 0;
      _previousValue = 0;
      _operandValue = 0;
      _operation = '';
      _shouldResetDisplay = false;

      // Clear items mode data
      if (_mode == CalculatorMode.items) {
        _items.clear();
        _discountPercent = 0;
        _taxPercent = 0;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
        _currentValue = double.tryParse(_display) ?? 0;
      } else {
        _display = '0';
        _currentValue = 0;
      }
    });
  }

  String _formatAmount(String amount) {
    final value = double.tryParse(amount) ?? 0;
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _createSale() {
    if (_currentValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to sales entry with calculated amount
    context.pushNamed(
      'salesEntry',
      queryParameters: {
        'calculatedAmount': _currentValue.toStringAsFixed(2),
      },
    );
  }

  void _receivePayment() {
    if (_currentValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to payment entry with calculated amount
    context.pushNamed(
      'paymentEntry',
      queryParameters: {
        'calculatedAmount': _currentValue.toStringAsFixed(2),
      },
    );
  }

  // Enhanced calculator methods
  void _showAddItemDialog() {
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Rice 5kg',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'e.g., 2',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price per unit',
                hintText: 'e.g., 150.00',
                prefixText: 'Rs. ',
              ),
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
              final quantity = double.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;

              if (quantity > 0 && price > 0) {
                setState(() {
                  _items.add(CalculatorItem(
                    quantity: quantity,
                    price: price,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ));
                  _updateTotalFromItems();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid quantity and price'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updateTotalFromItems() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.total);
    final discount = subtotal * (_discountPercent / 100);
    final afterDiscount = subtotal - discount;
    final tax = afterDiscount * (_taxPercent / 100);
    final total = afterDiscount + tax;

    _currentValue = total;
    _display = total.toStringAsFixed(2);
  }

  void _applyDiscount(double percent) {
    setState(() {
      _discountPercent = percent;
      _updateTotalFromItems();
    });
  }

  void _applyTax(double percent) {
    setState(() {
      _taxPercent = percent;
      _updateTotalFromItems();
    });
  }

  void _showDiscountDialog() {
    final controller = TextEditingController(
      text: _discountPercent > 0 ? _discountPercent.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Discount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Discount Percentage',
            hintText: 'e.g., 15',
            suffixText: '%',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final percent = double.tryParse(controller.text) ?? 0;
              if (percent >= 0 && percent <= 100) {
                _applyDiscount(percent);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value between 0 and 100'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showTaxDialog() {
    final controller = TextEditingController(
      text: _taxPercent > 0 ? _taxPercent.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Tax'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Tax Percentage',
            hintText: 'e.g., 13',
            suffixText: '%',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final percent = double.tryParse(controller.text) ?? 0;
              if (percent >= 0 && percent <= 100) {
                _applyTax(percent);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value between 0 and 100'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.total);
    final discount = subtotal * (_discountPercent / 100);
    final afterDiscount = subtotal - discount;
    final tax = afterDiscount * (_taxPercent / 100);
    final total = afterDiscount + tax;

    return Column(
      children: [
        // Items list
        if (_items.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: Key('item_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _items.removeAt(index);
                      _currentValue = _items.fold<double>(0, (sum, item) => sum + item.total);
                      _display = _currentValue.toStringAsFixed(2);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.displayText,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_items.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:', style: AppTypography.bodyMedium),
                    Text('Rs. ${subtotal.toStringAsFixed(2)}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (_discountPercent > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount ($_discountPercent%):', style: AppTypography.bodySmall.copyWith(color: Colors.red)),
                      Text('- Rs. ${discount.toStringAsFixed(2)}', style: AppTypography.bodySmall.copyWith(color: Colors.red)),
                    ],
                  ),
                ],
                if (_taxPercent > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax ($_taxPercent%):', style: AppTypography.bodySmall.copyWith(color: Colors.green)),
                      Text('+ Rs. ${tax.toStringAsFixed(2)}', style: AppTypography.bodySmall.copyWith(color: Colors.green)),
                    ],
                  ),
                ],
                const Divider(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Rs. ${_items.isEmpty ? _formatAmount(_display) : total.toStringAsFixed(2)}',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation history coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
