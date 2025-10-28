import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/primary_button.dart';
import '../../../theme/app_theme.dart';

/// Email capture screen - /auth/email
/// Purpose: Capture and validate email before proceeding
class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  bool _hasInteracted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (!_isValidEmail(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  bool get _isFormValid {
    final email = _emailController.text;
    return email.isNotEmpty && _isValidEmail(email);
  }

  void _handleContinue() {
    setState(() {
      _hasInteracted = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      // Navigate to password/magic link screen with email
      context.go('/auth/password_or_magic', extra: _emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasInteracted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Title
                Text(
                  'Welcome',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingS),

                Text(
                  'Sign in to continue',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: AppTheme.spacingXL),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: AppStrings.emailLabel,
                    hintText: 'you@company.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                  onChanged: (value) {
                    if (_hasInteracted) {
                      setState(() {});
                    }
                  },
                ),

                const Spacer(flex: 2),

                // Continue button (enabled when valid)
                PrimaryButton(
                  label: AppStrings.continueButton,
                  isEnabled: _isFormValid,
                  onPressed: _handleContinue,
                ),

                SizedBox(height: AppTheme.spacingM),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
