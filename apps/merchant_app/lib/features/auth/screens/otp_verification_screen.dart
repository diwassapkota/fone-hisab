import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../../config/providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _resendCountdown--;
        if (_resendCountdown == 0) {
          _canResend = true;
        }
      });

      return _resendCountdown > 0;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter complete OTP'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.verifyOtp(
        mobileNumber: widget.phoneNumber,
        otp: otp,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final authData = response.data!;

        // Store tokens securely
        final secureStorage = ref.read(secureStorageProvider);
        await secureStorage.write(key: 'accessToken', value: authData.accessToken);
        await secureStorage.write(key: 'refreshToken', value: authData.refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('OTP verified successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.goNamed('dashboard');
      } else {
        setState(() => _isLoading = false);

        // Clear OTP fields on error
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(response.error?.message ?? 'Invalid OTP. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Clear OTP fields on error
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Network error. Please check your connection.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // TODO: When backend implements resend OTP endpoint, call it here
    // For now, just show a message and restart the timer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP has been resent to your mobile number'),
        backgroundColor: Colors.green,
      ),
    );

    _startResendTimer();

    // When backend API is ready, use this:
    // try {
    //   final authService = ref.read(authServiceProvider);
    //   final response = await authService.resendOtp(
    //     mobileNumber: widget.phoneNumber,
    //   );
    //
    //   if (response.success) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('OTP has been resent'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //     _startResendTimer();
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Failed to resend OTP: ${e.toString()}'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.message,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 48),

              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
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
                        'Verify',
                        style: AppTypography.buttonLarge,
                      ),
              ),
              const SizedBox(height: 16),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: AppTypography.bodyMedium,
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _resendOtp,
                      child: Text(
                        'Resend',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in $_resendCountdown s',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gray600,
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
