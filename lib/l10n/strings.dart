/// Localized strings for the app
/// Generated from docs/flows/auth.yaml
class AppStrings {
  // Auth flow strings
  static const String emailLabel = 'Work email';
  static const String invalidEmail = "That doesn't look right";
  static const String passwordLabel = 'Password';
  static const String magicLinkSent = "We've sent a sign-in link.";

  // CTA labels
  static const String continueButton = 'Continue';
  static const String signInButton = 'Sign in';
  static const String sendLinkButton = 'Send link';

  // Error messages
  static const String requiredField = 'This field is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String networkError = 'Something went wrong. Please try again.';
  static const String retryButton = 'Retry';

  // Auth variants
  static const String usePasswordTitle = 'Sign in with password';
  static const String useMagicLinkTitle = 'Get a magic link';
  static const String orDivider = 'OR';
}
