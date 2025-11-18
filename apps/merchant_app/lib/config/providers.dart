import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_services/shared_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  return DioClient(
    getToken: () async {
      return await secureStorage.read(key: 'access_token');
    },
    onUnauthorized: () async {
      // Clear token and navigate to login
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(currentUserProvider.notifier).state = null;
    },
  );
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthService(dioClient);
});

// Customer Service Provider
final customerServiceProvider = Provider<CustomerService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CustomerService(dioClient);
});

// Transaction Service Provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TransactionService(dioClient);
});

// Supplier Service Provider
final supplierServiceProvider = Provider<SupplierService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SupplierService(dioClient);
});

// Product Service Provider
final productServiceProvider = Provider<ProductService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductService(dioClient);
});

// Purchase Service Provider
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PurchaseService(dioClient);
});

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnalyticsService(dioClient);
});

// Auth Token Provider (stores current JWT token)
final authTokenProvider = StateProvider<String?>((ref) => null);

// Current User Provider
final currentUserProvider = StateProvider<dynamic>((ref) => null);
