import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/offline_sync_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
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

    // Listen for auth state changes to update FCM token
    ref.listen<AsyncValue<dynamic>>(authStateChangesProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.saveTokenToFirestore(user.uid);
          notificationService.listenToTokenRefresh(user.uid);
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
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
