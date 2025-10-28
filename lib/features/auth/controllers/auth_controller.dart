import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state for tracking authentication status
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? email;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.email,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? email,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
    );
  }
}

/// Auth controller with simulated authentication
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState());

  final _random = Random();

  /// Sign in with email and password
  /// Simulates 500-800ms delay with random success/failure (20% fail rate)
  Future<bool> signInWithPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate network delay (500-800ms)
      final delay = 500 + _random.nextInt(300);
      await Future.delayed(Duration(milliseconds: delay));

      // Simulate random failure (20% chance)
      if (_random.nextDouble() < 0.2) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
        return false;
      }

      // Success
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error. Please try again.',
      );
      return false;
    }
  }

  /// Send magic link to email
  /// Simulates 500-800ms delay with random success/failure (10% fail rate)
  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate network delay (500-800ms)
      final delay = 500 + _random.nextInt(300);
      await Future.delayed(Duration(milliseconds: delay));

      // Simulate random failure (10% chance)
      if (_random.nextDouble() < 0.1) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to send magic link',
        );
        return false;
      }

      // Success
      state = state.copyWith(
        isLoading: false,
        email: email,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error. Please try again.',
      );
      return false;
    }
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Sign out
  void signOut() {
    state = AuthState();
  }
}

/// Provider for auth controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
