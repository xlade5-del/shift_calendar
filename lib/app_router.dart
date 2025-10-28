import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/free_time_finder_screen.dart';
import 'screens/partner/partner_invite_screen.dart';
import 'screens/partner/partner_accept_screen.dart';
import 'screens/partner/partner_management_screen.dart';
import 'screens/event/add_event_screen.dart';
import 'screens/event/edit_event_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'models/event_model.dart';

/// Centralized routing configuration for the app
///
/// Usage in widgets:
/// - Navigate: Navigator.pushNamed(context, AppRouter.calendar)
/// - Navigate with args: Navigator.pushNamed(context, AppRouter.editEvent, arguments: event)
/// - Replace: Navigator.pushReplacementNamed(context, AppRouter.home)
/// - Pop: Navigator.pop(context)
class AppRouter {
  // Route names as constants
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String freeTimeFinder = '/free-time-finder';
  static const String partnerInvite = '/partner-invite';
  static const String partnerAccept = '/partner-accept';
  static const String partnerManagement = '/partner-management';
  static const String addEvent = '/add-event';
  static const String editEvent = '/edit-event';
  static const String notificationSettings = '/notification-settings';

  /// Initial route for the app (handled by AuthWrapper)
  static const String initialRoute = '/';

  /// Generate routes based on route settings
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen(), settings);

      case signup:
        return _buildRoute(const SignupScreen(), settings);

      case home:
        return _buildRoute(const HomeScreen(), settings);

      case calendar:
        return _buildRoute(const CalendarScreen(), settings);

      case freeTimeFinder:
        return _buildRoute(const FreeTimeFinderScreen(), settings);

      case partnerInvite:
        return _buildRoute(const PartnerInviteScreen(), settings);

      case partnerAccept:
        return _buildRoute(const PartnerAcceptScreen(), settings);

      case partnerManagement:
        return _buildRoute(const PartnerManagementScreen(), settings);

      case addEvent:
        return _buildRoute(const AddEventScreen(), settings);

      case editEvent:
        // Expects EventModel as argument
        final event = settings.arguments as EventModel?;
        if (event == null) {
          return _buildErrorRoute(settings, 'Event data is required');
        }
        return _buildRoute(EditEventScreen(event: event), settings);

      case notificationSettings:
        return _buildRoute(const NotificationSettingsScreen(), settings);

      default:
        return _buildErrorRoute(settings, 'Route not found');
    }
  }

  /// Build a MaterialPageRoute with slide transition
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Build an error route for undefined routes
  static MaterialPageRoute _buildErrorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $message',
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${settings.name}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }

  /// Navigation helpers for common patterns

  /// Navigate to a new screen
  static Future<T?> push<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current screen
  static Future<T?> pushReplacement<T, TO>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, TO>(context, routeName, arguments: arguments);
  }

  /// Navigate and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current screen
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
