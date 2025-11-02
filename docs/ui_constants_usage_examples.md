# UIConstants Usage Examples
**Created:** November 2, 2025
**Purpose:** Practical examples for using UIConstants design system

---

## Quick Start

Instead of writing the same BoxDecoration code repeatedly:

**Before (repetitive):**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: YourContent(),
)
```

**After (using UIConstants):**
```dart
Container(
  decoration: UIConstants.cardDecoration,
  child: YourContent(),
)
```

---

## Example 1: Simple Card

```dart
import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import '../utils/app_colors.dart';

class SimpleCard extends StatelessWidget {
  final String title;
  final String description;

  const SimpleCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: UIConstants.cardPadding,
      decoration: UIConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: UIConstants.heading4),
          SizedBox(height: UIConstants.spacingS),
          Text(description, style: UIConstants.bodyMedium),
        ],
      ),
    );
  }
}
```

---

## Example 2: Form with Input Fields

```dart
class ExampleForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: UIConstants.screenPaddingAll,
      decoration: UIConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text('Sign In', style: UIConstants.heading2),
          SizedBox(height: UIConstants.spacingL),

          // Email field
          TextFormField(
            decoration: UIConstants.inputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          SizedBox(height: UIConstants.spacingM),

          // Password field
          TextFormField(
            obscureText: true,
            decoration: UIConstants.inputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(Icons.visibility_off),
            ),
          ),
          SizedBox(height: UIConstants.spacingL),

          // Submit button
          ElevatedButton(
            onPressed: () {},
            style: UIConstants.primaryButtonStyle,
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

---

## Example 3: Multiple Button Types

```dart
class ButtonExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary action
        ElevatedButton(
          onPressed: () {},
          style: UIConstants.primaryButtonStyle,
          child: Text('Save Changes'),
        ),
        SizedBox(height: UIConstants.spacingM),

        // Secondary action
        ElevatedButton(
          onPressed: () {},
          style: UIConstants.secondaryButtonStyle,
          child: Text('Cancel'),
        ),
        SizedBox(height: UIConstants.spacingM),

        // Destructive action
        ElevatedButton(
          onPressed: () {},
          style: UIConstants.destructiveButtonStyle,
          child: Text('Delete Account'),
        ),
      ],
    );
  }
}
```

---

## Example 4: Different Card Elevations

```dart
class CardElevationExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Subtle shadow (default)
        Container(
          padding: UIConstants.cardPadding,
          decoration: UIConstants.cardDecoration,
          child: Text('Subtle shadow', style: UIConstants.bodyLarge),
        ),
        SizedBox(height: UIConstants.spacingM),

        // Elevated card
        Container(
          padding: UIConstants.cardPadding,
          decoration: UIConstants.cardDecorationElevated,
          child: Text('Elevated shadow', style: UIConstants.bodyLarge),
        ),
        SizedBox(height: UIConstants.spacingM),

        // Outlined card
        Container(
          padding: UIConstants.cardPadding,
          decoration: UIConstants.cardDecorationOutlined,
          child: Text('Outlined card', style: UIConstants.bodyLarge),
        ),
      ],
    );
  }
}
```

---

## Example 5: Modal/Dialog

```dart
void showExampleDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusStandard,
      ),
      child: Container(
        padding: UIConstants.cardPadding,
        decoration: UIConstants.dialogDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Action', style: UIConstants.heading4),
            SizedBox(height: UIConstants.spacingM),
            Text(
              'Are you sure you want to proceed?',
              style: UIConstants.bodyMedium,
            ),
            SizedBox(height: UIConstants.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: UIConstants.spacingM),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: UIConstants.primaryButtonStyle,
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## Example 6: Bottom Sheet

```dart
void showExampleBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: UIConstants.cardPadding,
      decoration: UIConstants.bottomSheetDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Option', style: UIConstants.heading4),
          SizedBox(height: UIConstants.spacingM),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit', style: UIConstants.bodyLarge),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete', style: UIConstants.bodyLarge),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
```

---

## Example 7: Complete Screen

```dart
import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import '../utils/app_colors.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Example Screen', style: UIConstants.heading4),
      ),
      body: SingleChildScrollView(
        padding: UIConstants.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            Text('Welcome', style: UIConstants.heading1),
            SizedBox(height: UIConstants.spacingS),
            Text(
              'Here are your recent events',
              style: UIConstants.bodyMedium,
            ),
            SizedBox(height: UIConstants.spacingL),

            // Card 1
            Container(
              padding: UIConstants.cardPadding,
              decoration: UIConstants.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Title', style: UIConstants.heading4),
                  SizedBox(height: UIConstants.spacingS),
                  Text(
                    'Card description goes here',
                    style: UIConstants.bodyMedium,
                  ),
                  SizedBox(height: UIConstants.spacingXS),
                  Text('2 hours ago', style: UIConstants.caption),
                ],
              ),
            ),
            SizedBox(height: UIConstants.spacingM),

            // Card 2
            Container(
              padding: UIConstants.cardPadding,
              decoration: UIConstants.cardDecorationElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Highlighted Card', style: UIConstants.heading4),
                  SizedBox(height: UIConstants.spacingS),
                  Text(
                    'This card has more elevation',
                    style: UIConstants.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: UIConstants.spacingL),

            // Action buttons
            ElevatedButton(
              onPressed: () {},
              style: UIConstants.primaryButtonStyle,
              child: Text('Primary Action'),
            ),
            SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: () {},
              style: UIConstants.secondaryButtonStyle,
              child: Text('Secondary Action'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Migration Guide

### Before (Old Code)

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Text(
        'Title',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Description',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF636E72),
        ),
      ),
    ],
  ),
)
```

### After (Using UIConstants)

```dart
Container(
  decoration: UIConstants.cardDecoration,
  padding: UIConstants.cardPadding,
  child: Column(
    children: [
      Text('Title', style: UIConstants.heading4),
      SizedBox(height: UIConstants.spacingS),
      Text('Description', style: UIConstants.bodyMedium),
    ],
  ),
)
```

**Benefits:**
- 50% less code
- Consistent styling
- Easy to maintain
- Type-safe constants

---

## Best Practices

1. **Always import UIConstants** when creating new screens:
   ```dart
   import '../utils/ui_constants.dart';
   import '../utils/app_colors.dart';
   ```

2. **Use semantic constants** over hardcoded values:
   ```dart
   // Good
   SizedBox(height: UIConstants.spacingM)

   // Bad
   SizedBox(height: 16)
   ```

3. **Combine with AppColors** for complete design system:
   ```dart
   Container(
     decoration: UIConstants.cardDecoration,
     child: Text(
       'Hello',
       style: UIConstants.heading4.copyWith(color: AppColors.primaryTeal),
     ),
   )
   ```

4. **Extend with copyWith** when you need variations:
   ```dart
   Text(
     'Special Title',
     style: UIConstants.heading4.copyWith(
       color: AppColors.primaryTeal,
       fontWeight: FontWeight.w900,
     ),
   )
   ```

---

## Available Constants Quick Reference

### Decorations
- `UIConstants.cardDecoration` - Standard card
- `UIConstants.cardDecorationElevated` - Elevated card
- `UIConstants.cardDecorationSmall` - Compact card
- `UIConstants.cardDecorationOutlined` - Outlined card
- `UIConstants.modalDecoration` - Modal/dialog
- `UIConstants.bottomSheetDecoration` - Bottom sheet

### Button Styles
- `UIConstants.primaryButtonStyle` - Primary action
- `UIConstants.secondaryButtonStyle` - Secondary action
- `UIConstants.destructiveButtonStyle` - Delete/danger

### Text Styles
- `UIConstants.heading1` through `heading5` - Headings
- `UIConstants.bodyLarge`, `bodyMedium`, `bodySmall` - Body text
- `UIConstants.caption` - Small text

### Spacing
- `UIConstants.spacingXS` - 4px
- `UIConstants.spacingS` - 8px
- `UIConstants.spacingM` - 16px (most common)
- `UIConstants.spacingL` - 24px
- `UIConstants.spacingXL` - 32px

### Shadows
- `UIConstants.shadowSubtle` - List items
- `UIConstants.shadowStandard` - Cards
- `UIConstants.shadowProminent` - Modals

---

See `docs/appcolors_style_guide.md` for complete color usage guidelines.
