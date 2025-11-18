import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../../config/providers.dart';
import '../providers/customer_detail_providers.dart';
import '../providers/customer_providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? customerId; // For edit mode

  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCustomer = false;
  String? _errorMessage;

  bool get isEditMode => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadCustomerData();
    }
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoadingCustomer = true;
    });

    try {
      final customerService = ref.read(customerServiceProvider);
      final response = await customerService.getCustomerById(widget.customerId!);

      if (response.success && response.data != null) {
        final customer = response.data!;
        _nameController.text = customer.name;
        _mobileController.text = customer.mobileNumber;
        _emailController.text = customer.email ?? '';
        _addressController.text = customer.address ?? '';
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? 'Failed to load customer';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading customer: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCustomer = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customerService = ref.read(customerServiceProvider);

      final response = isEditMode
          ? await customerService.updateCustomer(
              customerId: widget.customerId!,
              name: _nameController.text.trim(),
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            )
          : await customerService.createCustomer(
              name: _nameController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            );

      if (response.success && mounted) {
        // Invalidate providers to refresh data
        ref.invalidate(customersProvider);
        if (isEditMode) {
          ref.invalidate(customerDetailProvider(widget.customerId!));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer ${isEditMode ? 'updated' : 'created'} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? 'Failed to save customer';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
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
        title: Text(isEditMode ? 'Edit Customer' : 'Add Customer'),
      ),
      body: _isLoadingCustomer
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name field
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Customer Name *',
                  hintText: 'Enter customer name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile number field
              TextFormField(
                controller: _mobileController,
                enabled: !_isLoading && !isEditMode, // Disable in edit mode
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber + ' *',
                  hintText: '98XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: isEditMode ? 'Mobile number cannot be changed' : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.trim().length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Mobile number must contain only digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field (optional)
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'customer@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address field (optional)
              TextFormField(
                controller: _addressController,
                enabled: !_isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  hintText: 'Enter customer address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
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
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditMode ? 'Update Customer' : 'Add Customer',
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
