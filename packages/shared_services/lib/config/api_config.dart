/// API configuration for backend services
class ApiConfig {
  ApiConfig._();

  // Base URLs
  static const String devBaseUrl = 'http://localhost:8080/api/v1';
  static const String stagingBaseUrl = 'https://staging-api.fonepay.com/khatabook/v1';
  static const String prodBaseUrl = 'https://api.fonepay.com/khatabook/v1';

  // Current environment
  static Environment currentEnvironment = Environment.dev;

  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.dev:
        return devBaseUrl;
      case Environment.staging:
        return stagingBaseUrl;
      case Environment.prod:
        return prodBaseUrl;
    }
  }

  // API Endpoints - Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Customer endpoints
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
  static String customerTransactions(String id) => '/transactions/customer/$id';
  static String customerDueDate(String id) => '/customers/$id/due-date';

  // Merchant endpoints
  static const String merchants = '/merchants';
  static String merchantById(String id) => '/merchants/$id';
  static const String merchantTransactions = '/merchant-transactions';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static const String salesEntry = '/transactions/sales';
  static const String paymentEntry = '/transactions/payment';
  static String merchantRecentTransactions(int limit) => '/transactions/merchant-recent-transactions/$limit';

  // Ledger endpoints
  static const String ledger = '/ledger';
  static String customerLedger(String customerId) => '/ledger/customer/$customerId';
  static String merchantLedger(String merchantId) => '/ledger/merchant/$merchantId';

  // Report endpoints
  static const String reports = '/reports';
  static const String customerReport = '/reports/customer';
  static const String merchantReport = '/reports/merchant';
  static const String transactionReport = '/reports/transactions';

  // Dispute endpoints
  static const String disputes = '/disputes';
  static String disputeById(String id) => '/disputes/$id';
  static String raiseDispute = '/disputes/raise';
  static String resolveDispute(String id) => '/disputes/$id/resolve';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String sendPaymentReminder = '/notifications/payment-reminder';

  // File upload
  static const String uploadBill = '/files/upload/bill';
  static const String uploadImage = '/files/upload/image';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

enum Environment {
  dev,
  staging,
  prod,
}
