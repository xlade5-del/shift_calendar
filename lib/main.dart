import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deb ShiftSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2),
          ),
        ),
      ),
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
    // Initialize notification service when app starts
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
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
        // If user is logged in, show home screen
        if (user != null) {
          return const HomeScreen();
        }
        // If user is not logged in, show login screen
        return const LoginScreen();
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
