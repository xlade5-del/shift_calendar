import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import 'dart:async';

/// Screen shown to users who need to verify their email
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _timer;
  int _secondsUntilCanResend = 0;

  @override
  void initState() {
    super.initState();
    // Periodically check if email has been verified
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Check if email has been verified
  Future<void> _checkEmailVerified() async {
    if (!mounted) return;

    setState(() => _isChecking = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.reloadUser();

      if (authService.isEmailVerified && mounted) {
        // Email verified! Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Silently fail - will check again in 3 seconds
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (_secondsUntilCanResend > 0) return;

    setState(() => _isResending = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Start cooldown timer
        setState(() => _secondsUntilCanResend = 60);
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            _secondsUntilCanResend--;
            if (_secondsUntilCanResend <= 0) {
              timer.cancel();
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Sign out and return to login
  Future<void> _signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentFirebaseUserProvider);
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread,
                  size: 60,
                  color: AppColors.primaryTeal,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We sent a verification email to:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email address
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryTeal,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStep(1, 'Check your inbox', Icons.inbox),
                    const SizedBox(height: 16),
                    _buildStep(2, 'Click the verification link', Icons.link),
                    const SizedBox(height: 16),
                    _buildStep(3, 'Return to this screen', Icons.phone_android),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Checking status
              if (_isChecking)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Checking verification status...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Resend button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _secondsUntilCanResend > 0 || _isResending
                      ? null
                      : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor:
                        AppColors.primaryTeal.withValues(alpha: 0.3),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          _secondsUntilCanResend > 0
                              ? 'Resend in $_secondsUntilCanResend seconds'
                              : 'Resend Verification Email',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign out button
              TextButton(
                onPressed: _signOut,
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Help text
              Text(
                'Didn\'t receive the email? Check your spam folder.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          icon,
          color: AppColors.primaryTeal.withValues(alpha: 0.5),
          size: 24,
        ),
      ],
    );
  }
}
