import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/customers/screens/customer_list_screen.dart';
import '../features/customers/screens/customer_detail_screen.dart';
import '../features/customers/screens/customer_form_screen.dart';
import '../features/sales/screens/sales_entry_screen.dart';
import '../features/payments/screens/payment_entry_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/calculator/screens/calculator_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String dashboard = '/dashboard';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String customerForm = '/customer-form';
  static const String salesEntry = '/sales-entry';
  static const String paymentEntry = '/payment-entry';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String calculator = '/calculator';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: customers,
        name: 'customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: customerDetail,
        name: 'customerDetail',
        builder: (context, state) {
          final customerId = state.pathParameters['id'] ?? '';
          return CustomerDetailScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: customerForm,
        name: 'customerForm',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          return CustomerFormScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: salesEntry,
        name: 'salesEntry',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          final calculatedAmount = state.uri.queryParameters['calculatedAmount'];
          return SalesEntryScreen(
            customerId: customerId,
            calculatedAmount: calculatedAmount,
          );
        },
      ),
      GoRoute(
        path: paymentEntry,
        name: 'paymentEntry',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          return PaymentEntryScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: calculator,
        name: 'calculator',
        builder: (context, state) => const QuickCalculatorScreen(),
      ),
    ],
  );
}
