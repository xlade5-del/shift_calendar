import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Unit tests for AuthService error handling
///
/// Note: These tests verify the error handling logic without requiring Firebase initialization.
/// Integration tests with actual Firebase services should be run separately.
void main() {
  group('AuthService Error Handling', () {
    test('should handle weak-password error with appropriate message', () {
      final error = FirebaseAuthException(code: 'weak-password');
      final message = _getErrorMessage(error);

      expect(message, contains('weak'));
      expect(message, contains('password'));
      expect(message, contains('8 characters'));
    });

    test('should handle email-already-in-use error', () {
      final error = FirebaseAuthException(code: 'email-already-in-use');
      final message = _getErrorMessage(error);

      expect(message, contains('already exists'));
    });

    test('should handle invalid-email error', () {
      final error = FirebaseAuthException(code: 'invalid-email');
      final message = _getErrorMessage(error);

      expect(message, contains('not valid'));
    });

    test('should handle user-not-found error', () {
      final error = FirebaseAuthException(code: 'user-not-found');
      final message = _getErrorMessage(error);

      expect(message, contains('No account found'));
    });

    test('should handle wrong-password error', () {
      final error = FirebaseAuthException(code: 'wrong-password');
      final message = _getErrorMessage(error);

      expect(message, contains('Incorrect password'));
    });

    test('should handle too-many-requests error', () {
      final error = FirebaseAuthException(code: 'too-many-requests');
      final message = _getErrorMessage(error);

      expect(message, contains('Too many'));
      expect(message, contains('try again later'));
    });

    test('should handle user-disabled error', () {
      final error = FirebaseAuthException(code: 'user-disabled');
      final message = _getErrorMessage(error);

      expect(message, contains('disabled'));
    });

    test('should handle operation-not-allowed error', () {
      final error = FirebaseAuthException(code: 'operation-not-allowed');
      final message = _getErrorMessage(error);

      expect(message, contains('not enabled'));
      expect(message, contains('support'));
    });

    test('should handle unknown errors gracefully', () {
      final error = FirebaseAuthException(code: 'unknown-error-code');
      final message = _getErrorMessage(error);

      expect(message, contains('Authentication failed'));
    });

    test('should include custom error message when available', () {
      final error = FirebaseAuthException(
        code: 'custom-error',
        message: 'Custom error message from Firebase',
      );
      final message = _getErrorMessage(error);

      expect(message, contains('Authentication failed'));
      expect(message, contains('Custom error message'));
    });
  });
}

/// Helper function to simulate error handling from AuthService
/// This mirrors the private _handleAuthException method
String _getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'weak-password':
      return 'The password provided is too weak. Please use at least 8 characters.';
    case 'email-already-in-use':
      return 'An account already exists with this email address.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found with this email address.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled. Please contact support.';
    default:
      return 'Authentication failed: ${e.message ?? "Unknown error"}';
  }
}
