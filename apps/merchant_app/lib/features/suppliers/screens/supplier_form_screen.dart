import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../../config/providers.dart';
import '../providers/supplier_detail_providers.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreen({
    super.key,
    this.supplierId,
  });

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _panController = TextEditingController();
  final _gstController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.supplierId != null;
    if (_isEditMode) {
      _loadSupplierData();
    }
  }

  void _loadSupplierData() async {
    final supplier = await ref.read(supplierDetailProvider(widget.supplierId!).future);
    _nameController.text = supplier.supplierName;
    _mobileController.text = supplier.mobileNumber;
    _emailController.text = supplier.email ?? '';
    _addressController.text = supplier.address ?? '';
    _panController.text = supplier.panNumber ?? '';
    _gstController.text = supplier.gstNumber ?? '';
    _notesController.text = supplier.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supplierService = ref.read(supplierServiceProvider);

      final response = _isEditMode
          ? await supplierService.updateSupplier(
              supplierId: widget.supplierId!,
              supplierName: _nameController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              email: _emailController.text.isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              address: _addressController.text.isNotEmpty
                  ? _addressController.text.trim()
                  : null,
              panNumber: _panController.text.isNotEmpty
                  ? _panController.text.trim()
                  : null,
              gstNumber: _gstController.text.isNotEmpty
                  ? _gstController.text.trim()
                  : null,
              notes: _notesController.text.isNotEmpty
                  ? _notesController.text.trim()
                  : null,
            )
          : await supplierService.createSupplier(
              supplierName: _nameController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              email: _emailController.text.isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              address: _addressController.text.isNotEmpty
                  ? _addressController.text.trim()
                  : null,
              panNumber: _panController.text.isNotEmpty
                  ? _panController.text.trim()
                  : null,
              gstNumber: _gstController.text.isNotEmpty
                  ? _gstController.text.trim()
                  : null,
              notes: _notesController.text.isNotEmpty
                  ? _notesController.text.trim()
                  : null,
            );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Supplier updated successfully'
                  : 'Supplier created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to save supplier'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Supplier' : 'Add Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Supplier Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Supplier Name *',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter supplier name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Mobile Number
            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter mobile number';
                }
                if (value.trim().length != 10) {
                  return 'Mobile number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // PAN Number
            TextFormField(
              controller: _panController,
              decoration: InputDecoration(
                labelText: 'PAN Number',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // GST Number
            TextFormField(
              controller: _gstController,
              decoration: InputDecoration(
                labelText: 'GST Number',
                prefixIcon: const Icon(Icons.receipt_long),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSupplier,
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
                  : Text(
                      _isEditMode ? 'Update Supplier' : 'Add Supplier',
                      style: AppTypography.buttonLarge,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
