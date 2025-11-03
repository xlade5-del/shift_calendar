import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/primary_button.dart';
import '../../../theme/app_theme.dart';
import '../controllers/auth_controller.dart';

/// Password or Magic Link screen - /auth/password_or_magic
/// Purpose: Choose between password sign-in or magic link
class PasswordOrMagicScreen extends ConsumerStatefulWidget {
  final String email;

  const PasswordOrMagicScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<PasswordOrMagicScreen> createState() =>
      _PasswordOrMagicScreenState();
}

class _PasswordOrMagicScreenState
    extends ConsumerState<PasswordOrMagicScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _hasInteracted = false;
  bool _usePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 8) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  bool get _isPasswordValid {
    final password = _passwordController.text;
    return password.isNotEmpty && password.length >= 8;
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _hasInteracted = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signInWithPassword(
          widget.email,
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      if (error != null && mounted) {
        // Show network error as retry toast
        if (error.contains('Network')) {
          _showRetryToast(error);
        }
      }
    }
  }

  Future<void> _handleMagicLink() async {
    final success = await ref.read(authControllerProvider.notifier).sendMagicLink(
          widget.email,
        );

    if (success && mounted) {
      _showSuccessToast(AppStrings.magicLinkSent);
    } else {
      final error = ref.read(authControllerProvider).error;
      if (error != null && mounted) {
        if (error.contains('Network')) {
          _showRetryToast(error);
        } else {
          _showErrorToast(error);
        }
      }
    }
  }

  void _showRetryToast(String message) {
    // Error handling without snackbar
  }

  void _showSuccessToast(String message) {
    // Success handling without snackbar
  }

  void _showErrorToast(String message) {
    // Error handling without snackbar
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/email'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasInteracted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email display
                Text(
                  'Signing in as',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXS),
                Text(
                  widget.email,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: AppTheme.spacingXL),

                // Variant toggle
                Row(
                  children: [
                    Expanded(
                      child: _VariantChip(
                        label: AppStrings.usePasswordTitle,
                        isSelected: _usePassword,
                        onTap: () => setState(() => _usePassword = true),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _VariantChip(
                        label: AppStrings.useMagicLinkTitle,
                        isSelected: !_usePassword,
                        onTap: () => setState(() => _usePassword = false),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacingXL),

                // Password variant
                if (_usePassword) ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      errorText: authState.error != null &&
                              !authState.error!.contains('Network')
                          ? authState.error
                          : null,
                    ),
                    validator: _validatePassword,
                    onChanged: (value) {
                      if (_hasInteracted) {
                        setState(() {});
                      }
                    },
                    onFieldSubmitted: (_) {
                      if (_isPasswordValid) {
                        _handleSignIn();
                      }
                    },
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  PrimaryButton(
                    label: AppStrings.signInButton,
                    isEnabled: _isPasswordValid,
                    isLoading: authState.isLoading,
                    onPressed: _handleSignIn,
                  ),
                ],

                // Magic link variant
                if (!_usePassword) ...[
                  Text(
                    'We\'ll send a sign-in link to:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingS),

                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  PrimaryButton(
                    label: AppStrings.sendLinkButton,
                    isLoading: authState.isLoading,
                    onPressed: _handleMagicLink,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Variant selection chip
class _VariantChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
