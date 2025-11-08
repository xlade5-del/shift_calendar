import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/onboarding_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Onboarding service provider
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

// Check if user has completed onboarding
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return await onboardingService.hasCompletedOnboarding();
});

// Auth state changes stream provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current Firebase user provider
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.whenData((user) => user).value;
});

// Current user data provider (from Firestore)
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) return null;

  final authService = ref.watch(authServiceProvider);
  return await authService.getUserData(user.uid);
});

// Auth state notifier for login/signup operations
class AuthStateNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Auth state notifier provider
final authStateNotifierProvider = NotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>(() {
  return AuthStateNotifier();
});

// ============================================================================
// Firestore Providers
// ============================================================================

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Partner data provider (real-time stream)
final partnerDataProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value(null);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.partnerDataStream(user.uid);
});

// Check if user has a partner
final hasPartnerProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) return false;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.hasPartner(user.uid);
});
