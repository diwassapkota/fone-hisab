import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

// Purchase form state
class PurchaseFormState {
  final String? supplierId;
  final String? supplierName;
  final double purchaseAmount;
  final double paymentAmount;
  final String paymentMode;
  final DateTime billDate;
  final String? billNumber;
  final String? description;
  final List<String> billImages;
  final List<PurchaseItemRequest> items;

  const PurchaseFormState({
    this.supplierId,
    this.supplierName,
    this.purchaseAmount = 0.0,
    this.paymentAmount = 0.0,
    this.paymentMode = 'CASH',
    required this.billDate,
    this.billNumber,
    this.description,
    this.billImages = const [],
    this.items = const [],
  });

  PurchaseFormState copyWith({
    String? supplierId,
    String? supplierName,
    double? purchaseAmount,
    double? paymentAmount,
    String? paymentMode,
    DateTime? billDate,
    String? billNumber,
    String? description,
    List<String>? billImages,
    List<PurchaseItemRequest>? items,
  }) {
    return PurchaseFormState(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      billDate: billDate ?? this.billDate,
      billNumber: billNumber ?? this.billNumber,
      description: description ?? this.description,
      billImages: billImages ?? this.billImages,
      items: items ?? this.items,
    );
  }

  // Calculate remaining amount (for display)
  double get remainingAmount => purchaseAmount - paymentAmount;

  // Check if form is valid
  bool get isValid => supplierId != null && purchaseAmount > 0 && items.isNotEmpty;

  // Check if this is a full payment
  bool get isFullPayment => purchaseAmount == paymentAmount;

  // Check if this is partial payment
  bool get isPartialPayment => paymentAmount > 0 && paymentAmount < purchaseAmount;

  // Check if this is full credit (no payment)
  bool get isFullCredit => paymentAmount == 0;
}

// Purchase form state provider
final purchaseFormProvider = StateNotifierProvider<PurchaseFormNotifier, PurchaseFormState>((ref) {
  return PurchaseFormNotifier();
});

// Purchase form notifier
class PurchaseFormNotifier extends StateNotifier<PurchaseFormState> {
  PurchaseFormNotifier()
      : super(PurchaseFormState(
          billDate: DateTime.now(),
        ));

  void setSupplier(String supplierId, String supplierName) {
    state = state.copyWith(
      supplierId: supplierId,
      supplierName: supplierName,
    );
  }

  void setPurchaseAmount(double amount) {
    state = state.copyWith(purchaseAmount: amount);
  }

  void setPaymentAmount(double amount) {
    state = state.copyWith(paymentAmount: amount);
  }

  void setPaymentMode(String mode) {
    state = state.copyWith(paymentMode: mode);
  }

  void setBillDate(DateTime date) {
    state = state.copyWith(billDate: date);
  }

  void setBillNumber(String? number) {
    state = state.copyWith(billNumber: number);
  }

  void setDescription(String? desc) {
    state = state.copyWith(description: desc);
  }

  void addBillImage(String imagePath) {
    state = state.copyWith(
      billImages: [...state.billImages, imagePath],
    );
  }

  void removeBillImage(String imagePath) {
    state = state.copyWith(
      billImages: state.billImages.where((img) => img != imagePath).toList(),
    );
  }

  void setItems(List<PurchaseItemRequest> items) {
    state = state.copyWith(items: items);
    // Recalculate purchase amount based on items
    final total = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    state = state.copyWith(purchaseAmount: total);
  }

  void addItem(PurchaseItemRequest item) {
    final newItems = [...state.items, item];
    setItems(newItems);
  }

  void updateItem(int index, PurchaseItemRequest item) {
    final newItems = [...state.items];
    newItems[index] = item;
    setItems(newItems);
  }

  void removeItem(int index) {
    final newItems = [...state.items];
    newItems.removeAt(index);
    setItems(newItems);
  }

  void reset() {
    state = PurchaseFormState(
      billDate: DateTime.now(),
    );
  }
}

// Supplier payment form state (simpler - just payment, no items)
class SupplierPaymentFormState {
  final String? supplierId;
  final String? supplierName;
  final double paymentAmount;
  final String paymentMode;
  final DateTime billDate;
  final String? description;

  const SupplierPaymentFormState({
    this.supplierId,
    this.supplierName,
    this.paymentAmount = 0.0,
    this.paymentMode = 'CASH',
    required this.billDate,
    this.description,
  });

  SupplierPaymentFormState copyWith({
    String? supplierId,
    String? supplierName,
    double? paymentAmount,
    String? paymentMode,
    DateTime? billDate,
    String? description,
  }) {
    return SupplierPaymentFormState(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      billDate: billDate ?? this.billDate,
      description: description ?? this.description,
    );
  }

  bool get isValid => supplierId != null && paymentAmount > 0;
}

// Supplier payment form provider
final supplierPaymentFormProvider =
    StateNotifierProvider<SupplierPaymentFormNotifier, SupplierPaymentFormState>((ref) {
  return SupplierPaymentFormNotifier();
});

// Supplier payment form notifier
class SupplierPaymentFormNotifier extends StateNotifier<SupplierPaymentFormState> {
  SupplierPaymentFormNotifier()
      : super(SupplierPaymentFormState(
          billDate: DateTime.now(),
        ));

  void setSupplier(String supplierId, String supplierName) {
    state = state.copyWith(
      supplierId: supplierId,
      supplierName: supplierName,
    );
  }

  void setPaymentAmount(double amount) {
    state = state.copyWith(paymentAmount: amount);
  }

  void setPaymentMode(String mode) {
    state = state.copyWith(paymentMode: mode);
  }

  void setBillDate(DateTime date) {
    state = state.copyWith(billDate: date);
  }

  void setDescription(String? desc) {
    state = state.copyWith(description: desc);
  }

  void reset() {
    state = SupplierPaymentFormState(
      billDate: DateTime.now(),
    );
  }
}
