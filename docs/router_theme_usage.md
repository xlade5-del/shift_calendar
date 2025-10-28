# App Router & Theme Usage Guide

This guide explains how to use the centralized routing and theming system in Shift Calendar.

## App Router (`lib/app_router.dart`)

The `AppRouter` class provides a centralized, type-safe routing solution for the entire app.

### Available Routes

All routes are defined as constants in `AppRouter`:

```dart
AppRouter.login              // /login
AppRouter.signup             // /signup
AppRouter.home               // /home
AppRouter.calendar           // /calendar
AppRouter.freeTimeFinder     // /free-time-finder
AppRouter.partnerInvite      // /partner-invite
AppRouter.partnerAccept      // /partner-accept
AppRouter.partnerManagement  // /partner-management
AppRouter.addEvent           // /add-event
AppRouter.editEvent          // /edit-event (requires EventModel argument)
AppRouter.notificationSettings // /notification-settings
```

### Navigation Examples

#### Basic Navigation

```dart
// Navigate to a new screen
AppRouter.push(context, AppRouter.calendar);

// Or use Navigator directly
Navigator.pushNamed(context, AppRouter.calendar);
```

#### Navigation with Arguments

```dart
// EditEventScreen requires an EventModel
final event = EventModel(...);
AppRouter.push(
  context,
  AppRouter.editEvent,
  arguments: event,
);
```

#### Replace Current Screen

```dart
// Navigate to home and replace current screen
AppRouter.pushReplacement(context, AppRouter.home);
```

#### Clear Stack and Navigate

```dart
// Navigate to home and remove all previous routes
AppRouter.pushAndRemoveUntil(context, AppRouter.home);

// Navigate to login and clear entire stack (for logout)
AppRouter.pushAndRemoveUntil(context, AppRouter.login);
```

#### Pop/Go Back

```dart
// Simple pop
AppRouter.pop(context);

// Pop with result
AppRouter.pop(context, resultValue);

// Pop until specific route
AppRouter.popUntil(context, AppRouter.home);
```

### Migration from Direct Imports

**Before (old way):**
```dart
import '../screens/calendar/calendar_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CalendarScreen()),
);
```

**After (new way):**
```dart
import '../app_router.dart';

AppRouter.push(context, AppRouter.calendar);
```

### Error Handling

If you navigate to a route that doesn't exist, or provide wrong arguments, you'll see an error screen with:
- Error message
- Route name that was attempted
- A back button to return

### Adding New Routes

To add a new route:

1. Define the route constant:
```dart
static const String myNewScreen = '/my-new-screen';
```

2. Add the case in `onGenerateRoute`:
```dart
case myNewScreen:
  return _buildRoute(const MyNewScreen(), settings);
```

3. Import the screen at the top of the file.

---

## App Theme (`lib/theme/app_theme.dart`)

The `AppTheme` class provides consistent styling across the app with light and dark theme support.

### Using the Theme

The theme is automatically applied in `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,        // Light theme
  darkTheme: AppTheme.darkTheme,     // Dark theme
  themeMode: ThemeMode.light,        // Current mode
  // ...
);
```

### Accessing Theme Colors

```dart
// In any widget
final theme = Theme.of(context);
final primaryColor = theme.colorScheme.primary;
final backgroundColor = theme.colorScheme.surface;
```

### Event Colors

The theme provides standardized event colors:

```dart
// Get event color by name
Color color = AppTheme.getEventColor('blue');

// Available colors:
AppTheme.eventColors // Map<String, Color>
// Keys: 'blue', 'green', 'orange', 'red', 'purple', 'teal', 'pink', 'amber'
```

### Spacing Constants

Use consistent spacing throughout the app:

```dart
AppTheme.spacingXS   // 4.0
AppTheme.spacingS    // 8.0
AppTheme.spacingM    // 16.0
AppTheme.spacingL    // 24.0
AppTheme.spacingXL   // 32.0
AppTheme.spacingXXL  // 48.0

// Example usage:
Padding(
  padding: EdgeInsets.all(AppTheme.spacingM),
  child: Text('Hello'),
)
```

### Border Radius Constants

```dart
AppTheme.radiusS    // 8.0
AppTheme.radiusM    // 12.0
AppTheme.radiusL    // 16.0
AppTheme.radiusXL   // 20.0

// Example usage:
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTheme.radiusM),
  ),
)
```

### Theme Customization

All UI components are pre-styled:

- **ElevatedButton**: 12px border radius, no elevation
- **TextButton**: 8px border radius
- **OutlinedButton**: 12px border radius
- **Card**: 16px border radius, no elevation, 1px border
- **TextField**: Filled style with 12px border radius
- **FloatingActionButton**: 16px border radius
- **Dialog**: 20px border radius
- **BottomSheet**: Rounded top corners (20px)

### Switching to Dark Theme (Future)

When implementing theme switching in settings:

```dart
// Store theme preference
enum AppThemeMode { light, dark, system }

// Update MaterialApp
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: userPreference, // ThemeMode.light, dark, or system
)
```

### Customizing Brand Colors

To change the app's primary color, edit `app_theme.dart`:

```dart
static const Color primaryColor = Colors.deepPurple; // Change this
static const Color secondaryColor = Colors.purpleAccent;
```

---

## Best Practices

### Routing
1. ✅ Always use `AppRouter` constants instead of hardcoded strings
2. ✅ Use `AppRouter` helper methods for common navigation patterns
3. ✅ Pass arguments via the `arguments` parameter
4. ❌ Don't create `MaterialPageRoute` manually unless necessary
5. ❌ Don't hardcode route paths as strings

### Theming
1. ✅ Use `AppTheme` spacing and radius constants
2. ✅ Use `Theme.of(context)` to access theme colors
3. ✅ Use `AppTheme.getEventColor()` for event colors
4. ❌ Don't hardcode colors directly in widgets
5. ❌ Don't hardcode spacing or border radius values

### Example: Before & After

**Before:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CalendarScreen(),
  ),
);

Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**After:**
```dart
AppRouter.push(context, AppRouter.calendar);

Container(
  padding: EdgeInsets.all(AppTheme.spacingM),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary,
    borderRadius: BorderRadius.circular(AppTheme.radiusM),
  ),
)
```

---

## Future Enhancements

### Planned Features
- [ ] Deep linking support
- [ ] Route guards for authentication
- [ ] Route transition animations
- [ ] User-configurable theme switching in settings
- [ ] Custom color scheme builder for accessibility
- [ ] Font size adjustment for accessibility

---

## Troubleshooting

### "Route not found" Error
- Check that the route is defined in `AppRouter` constants
- Verify the route is added to `onGenerateRoute`

### Wrong Arguments Type
- `EditEventScreen` requires `EventModel` as argument
- Check `onGenerateRoute` for required argument types

### Theme Not Applied
- Ensure `MaterialApp` uses `AppTheme.lightTheme`
- Check that theme mode is set correctly
- Restart the app (hot restart with 'R' key)

---

## Additional Resources

- [Flutter Navigation and Routing](https://docs.flutter.dev/development/ui/navigation)
- [Material Design 3 Theming](https://m3.material.io/styles/color/overview)
- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)
