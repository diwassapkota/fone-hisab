import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../../config/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final secureStorage = ref.read(secureStorageProvider);

      print('[LoginScreen] Attempting login...');
      final response = await authService.login(
        mobileNumber: _phoneController.text,
        password: _passwordController.text,
      );

      print('[LoginScreen] Response success: ${response.success}');
      print('[LoginScreen] Response data: ${response.data}');

      if (response.success && response.data != null) {
        print('[LoginScreen] Storing tokens...');
        // Store tokens
        await secureStorage.write(
          key: 'access_token',
          value: response.data!.accessToken,
        );
        await secureStorage.write(
          key: 'refresh_token',
          value: response.data!.refreshToken,
        );

        print('[LoginScreen] Updating providers...');
        // Update providers
        ref.read(authTokenProvider.notifier).state = response.data!.accessToken;
        ref.read(currentUserProvider.notifier).state = response.data!.user;

        print('[LoginScreen] Navigating to dashboard...');
        if (mounted) {
          context.goNamed('dashboard');
        }
      } else {
        print('[LoginScreen] Login failed: ${response.error?.message}');
        setState(() {
          _errorMessage = response.error?.message ?? 'Login failed';
        });
      }
    } catch (e, stackTrace) {
      print('[LoginScreen] Error: $e');
      print('[LoginScreen] StackTrace: $stackTrace');
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo placeholder
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // App title
                  Text(
                    'Fonepay Business',
                    textAlign: TextAlign.center,
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 48),

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

                  // Phone number field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumber,
                      hintText: '98XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            l10n.login,
                            style: AppTypography.buttonLarge,
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed('register'),
                        child: Text(
                          l10n.register,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Temporary skip button for development
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.goNamed('dashboard'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Skip to Dashboard (Dev Only)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
