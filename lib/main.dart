import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/offline_sync_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('ℹ️  Firebase already initialized');
    } else {
      debugPrint('❌ Firebase initialization error: $e');
      rethrow;
    }
  }

  // Connect to Firebase Emulators in DEBUG mode
  // TEMPORARILY DISABLED: Testing production API key
  // if (kDebugMode) {
  //   await _connectToFirebaseEmulators();
  // }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

/// Connect to local Firebase emulators for development
/// Only runs in debug mode (flutter run)
/// Production builds automatically use production Firebase
Future<void> _connectToFirebaseEmulators() async {
  // Use 'localhost' for iOS simulator/web
  // Use '10.0.2.2' for Android emulator (special alias for host machine)
  const String host = kIsWeb ? 'localhost' : '10.0.2.2';

  try {
    // Connect Firestore to emulator
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    debugPrint('🔧 Firestore connected to emulator: $host:8080');

    // Connect Auth to emulator
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    debugPrint('🔧 Auth connected to emulator: $host:9099');

    // Note: Functions emulator connection would be added here if needed
    // FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

    debugPrint('✅ Firebase Emulators connected successfully');
  } catch (e) {
    debugPrint('⚠️  Failed to connect to Firebase Emulators: $e');
    debugPrint('   Make sure emulators are running: firebase emulators:start');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VelloShift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
    );
  }
}

// Auth Wrapper to handle authentication state
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize services when app starts
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize offline sync service (auto-starts monitoring)
    try {
      ref.read(offlineSyncServiceProvider);
      print('Offline sync service initialized successfully');
    } catch (e) {
      print('Error initializing offline sync: $e');
    }

    // Initialize notification service
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();

      // Wait for user to be authenticated before saving token
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        await notificationService.saveTokenToFirestore(user.uid);
        notificationService.listenToTokenRefresh(user.uid);
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

    // Listen for auth state changes to update FCM token and invalidate providers
    ref.listen<AsyncValue<dynamic>>(authStateChangesProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          // User signed in - update FCM token and invalidate providers to fetch fresh data
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.saveTokenToFirestore(user.uid);
          notificationService.listenToTokenRefresh(user.uid);

          // Invalidate user data provider to fetch fresh profile data
          ref.invalidate(currentUserDataProvider);
          ref.invalidate(hasPartnerProvider);
          ref.invalidate(partnerDataProvider);
        } else {
          // User signed out - invalidate all user-related providers
          ref.invalidate(currentUserDataProvider);
          ref.invalidate(hasPartnerProvider);
          ref.invalidate(partnerDataProvider);
          ref.invalidate(hasCompletedOnboardingProvider);
        }
      });
    });

    return authState.when(
      data: (user) {
        // If user is not logged in, show welcome screen
        if (user == null) {
          return const WelcomeScreen();
        }

        // If user's email is not verified, show email verification screen
        // TODO: Re-enable email verification before production
        // TEMPORARILY DISABLED FOR TESTING
        // if (!user.emailVerified) {
        //   return const EmailVerificationScreen();
        // }

        // If user is logged in and verified, check onboarding status
        return hasCompletedOnboarding.when(
          data: (completed) {
            // If onboarding not complete, show onboarding screen
            if (!completed) {
              return const OnboardingScreen();
            }

            // If onboarding complete, show home screen
            return const HomeScreen();
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
