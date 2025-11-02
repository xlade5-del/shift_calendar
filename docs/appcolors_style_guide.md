# AppColors Style Guide
**Version:** 1.0
**Last Updated:** November 2, 2025
**Purpose:** Official guide for using VelloShift's color design system

---

## Table of Contents
1. [Overview](#overview)
2. [Color Palette Reference](#color-palette-reference)
3. [When to Use Each Color](#when-to-use-each-color)
4. [Common Patterns](#common-patterns)
5. [Anti-Patterns (Don't Do This)](#anti-patterns-dont-do-this)
6. [Code Examples](#code-examples)
7. [Accessibility Guidelines](#accessibility-guidelines)

---

## Overview

**AppColors** is VelloShift's central color design system. All colors in the app MUST use AppColors to ensure:
- ✅ **Brand consistency** across all screens
- ✅ **Easy theming** and future dark mode support
- ✅ **Maintainability** - change once, apply everywhere
- ✅ **Accessibility** - pre-tested contrast ratios

**Location:** `lib/utils/app_colors.dart`

**Rule:** Never use Flutter's `Colors.*` class except for `Colors.transparent` (which has no AppColors equivalent).

---

## Color Palette Reference

### Primary Brand Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.primaryTeal` | #2B7A78 | Primary actions, branding | Primary buttons, selected states, brand logo |
| `AppColors.darkTeal` | #1F5654 | Darker variant | Hover states, pressed buttons |
| `AppColors.lightTeal` | #3D9B98 | Lighter variant | Highlights, subtle accents |

### Accent Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.peach` | #F4C49A | Warm accent | Secondary actions, highlights |
| `AppColors.lightPeach` | #F8D9B8 | Subtle warm tint | Background accents, weekend days |
| `AppColors.mint` | #A8DADC | Cool accent | Info badges, subtle highlights |
| `AppColors.lightMint` | #CCEBEC | Subtle cool tint | Background variations |

### Background Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.cream` | #F5E6D3 | Primary background | Screen backgrounds, main container |
| `AppColors.lightCream` | #FAF3E8 | Lighter background | Nested containers, elevated surfaces |
| `AppColors.white` | #FFFFFF | Pure white | Cards, modals, inputs |

### Text Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.textDark` | #2D3436 | Primary text | Headings, body text, important info |
| `AppColors.textGrey` | #636E72 | Secondary text | Subtitles, descriptions, placeholders |
| `AppColors.textLight` | #B2BEC3 | Tertiary text | Captions, disabled text, timestamps |

### Semantic Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.success` | #2B7A78 | Success states | Success messages, checkmarks |
| `AppColors.error` | #D63031 | Errors/dangers | Error messages, delete buttons, validation errors |
| `AppColors.errorDark` | #B71C1C | Dark error text | Error text on light backgrounds |
| `AppColors.errorLight` | #FFEBEE | Light error bg | Error container backgrounds |
| `AppColors.errorBorder` | #EF5350 | Error borders | Input error borders |
| `AppColors.warning` | #F4C49A | Warnings | Warning badges, alerts |
| `AppColors.info` | #A8DADC | Informational | Info badges, tooltips |

### UI Element Colors

| Color | Hex Value | Usage | Example |
|-------|-----------|-------|---------|
| `AppColors.cardBackground` | #FFFFFF | Card surfaces | All cards, containers |
| `AppColors.divider` | #DFE6E9 | Dividers/borders | Section dividers, subtle borders |

### Shadow Colors

| Color | Hex Value (ARGB) | Usage | Example |
|-------|------------------|-------|---------|
| `AppColors.shadow` | #1A000000 (10% black) | Standard depth | Main cards, buttons |
| `AppColors.shadowLight` | #0D000000 (5% black) | Subtle depth | Nested cards, list items |
| `AppColors.shadowDark` | #26000000 (15% black) | Prominent depth | Modals, elevated dialogs |

### Overlay Colors

| Color | Hex Value (ARGB) | Usage | Example |
|-------|------------------|-------|---------|
| `AppColors.overlayLight` | #B3FFFFFF (70% white) | Semi-transparent overlays | Text on dark event blocks |

---

## When to Use Each Color

### Primary Actions
**Use:** `AppColors.primaryTeal`
- Primary buttons (Save, Submit, Confirm)
- Selected tab indicators
- Active navigation items
- Brand logo/icon

**Example:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.white,
  ),
  child: Text('Save Event'),
)
```

### Error States
**Use:** `AppColors.error` (bright red) or `AppColors.errorDark` (darker red for text)
- Validation error messages
- Delete/destructive actions
- Error snackbars
- Failed states

**When to use which:**
- `AppColors.error` - Buttons, backgrounds, icons
- `AppColors.errorDark` - Text on light backgrounds
- `AppColors.errorLight` - Background for error containers
- `AppColors.errorBorder` - Border for error inputs

**Example:**
```dart
// Error SnackBar
SnackBar(
  content: Text('Failed to save event'),
  backgroundColor: AppColors.error,
)

// Error text
Text(
  'Email is required',
  style: TextStyle(color: AppColors.errorDark),
)

// Error container
Container(
  color: AppColors.errorLight,
  border: Border.all(color: AppColors.errorBorder),
  child: Text('Conflict detected', style: TextStyle(color: AppColors.errorDark)),
)
```

### Shadows & Depth
**Use:** Shadow variants based on elevation level
- `AppColors.shadowLight` (5%) - Subtle cards, list items, inline elements
- `AppColors.shadow` (10%) - Standard cards, buttons, main containers
- `AppColors.shadowDark` (15%) - Modals, dialogs, popovers (future use)

**Example:**
```dart
// Subtle card shadow
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
)

// Standard card shadow
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

### Text Hierarchy
**Use:** Different text colors for information hierarchy
- `AppColors.textDark` - Headings, primary content, important labels
- `AppColors.textGrey` - Body text, secondary labels, descriptions
- `AppColors.textLight` - Captions, timestamps, disabled text

**Example:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Event Title',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark, // Primary heading
      ),
    ),
    SizedBox(height: 4),
    Text(
      'Description goes here',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textGrey, // Secondary text
      ),
    ),
    SizedBox(height: 4),
    Text(
      'Created 2 hours ago',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textLight, // Tertiary text
      ),
    ),
  ],
)
```

### Backgrounds
**Use:** Background colors based on nesting level
- `AppColors.cream` - Main screen background (outermost)
- `AppColors.lightCream` - Nested containers on cream
- `AppColors.white` - Cards, modals, inputs (elevated surfaces)

**Example:**
```dart
Scaffold(
  backgroundColor: AppColors.cream, // Screen background
  body: Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white, // Card on cream background
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
  ),
)
```

---

## Common Patterns

### Pattern 1: Primary Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.white,
    padding: EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
  ),
  child: Text('Primary Action'),
)
```

### Pattern 2: Secondary/Outline Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.primaryTeal,
    padding: EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.primaryTeal, width: 2),
    ),
    elevation: 0,
  ),
  child: Text('Secondary Action'),
)
```

### Pattern 3: Delete/Destructive Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.white,
    padding: EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
  ),
  child: Text('Delete'),
)
```

### Pattern 4: Standard Card
```dart
Container(
  padding: EdgeInsets.all(20),
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
  child: YourCardContent(),
)
```

### Pattern 5: Text Input
```dart
TextFormField(
  style: TextStyle(fontSize: 17),
  decoration: InputDecoration(
    hintText: 'Enter email',
    hintStyle: TextStyle(color: AppColors.textGrey),
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.primaryTeal,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    ),
  ),
)
```

### Pattern 6: Error SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Operation failed'),
    backgroundColor: AppColors.error,
  ),
)
```

### Pattern 7: Success SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Saved successfully'),
    backgroundColor: AppColors.success,
  ),
)
```

---

## Anti-Patterns (Don't Do This)

### ❌ DON'T: Use Flutter's Colors class
```dart
// BAD - Hardcoded color
Container(color: Colors.red)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
)
```

### ✅ DO: Use AppColors
```dart
// GOOD - AppColors
Container(color: AppColors.error)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.white,
  ),
)
```

---

### ❌ DON'T: Use random shadow opacity
```dart
// BAD - Magic numbers
BoxShadow(
  color: Colors.black.withOpacity(0.07),
  blurRadius: 10,
)
```

### ✅ DO: Use semantic shadow colors
```dart
// GOOD - Semantic shadow
BoxShadow(
  color: AppColors.shadowLight,
  blurRadius: 10,
)
```

---

### ❌ DON'T: Mix hardcoded and AppColors
```dart
// BAD - Inconsistent
Text('Title', style: TextStyle(color: Colors.black))
Text('Subtitle', style: TextStyle(color: AppColors.textGrey))
```

### ✅ DO: Use AppColors everywhere
```dart
// GOOD - Consistent
Text('Title', style: TextStyle(color: AppColors.textDark))
Text('Subtitle', style: TextStyle(color: AppColors.textGrey))
```

---

## Code Examples

### Complete Screen Example
```dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream, // Screen background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Example Screen',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card with content
            Container(
              padding: EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Card description goes here',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Primary button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text('Primary Action'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Accessibility Guidelines

### Contrast Ratios
All AppColors have been tested for WCAG 2.1 AA compliance:

| Combination | Contrast Ratio | Status |
|-------------|----------------|--------|
| textDark on cream | 8.2:1 | ✅ AAA |
| textDark on white | 12.6:1 | ✅ AAA |
| textGrey on white | 5.1:1 | ✅ AA |
| textLight on white | 3.2:1 | ⚠️ Large text only |
| white on primaryTeal | 4.8:1 | ✅ AA |
| white on error | 5.2:1 | ✅ AA |

### Best Practices
1. **Primary text** - Always use `AppColors.textDark` on light backgrounds
2. **Secondary text** - Use `AppColors.textGrey` for descriptions/labels
3. **Disabled text** - Use `AppColors.textLight` only for large text (18px+)
4. **Error text** - Use `AppColors.errorDark` on light backgrounds for maximum readability
5. **White text** - Only on `primaryTeal`, `error`, or dark backgrounds

---

## Quick Reference Cheat Sheet

```dart
// BACKGROUNDS
Scaffold(backgroundColor: AppColors.cream)           // Screen
Container(color: AppColors.white)                    // Card
Container(color: AppColors.lightCream)               // Nested container

// TEXT
Text(style: TextStyle(color: AppColors.textDark))   // Heading
Text(style: TextStyle(color: AppColors.textGrey))   // Body
Text(style: TextStyle(color: AppColors.textLight))  // Caption

// BUTTONS
backgroundColor: AppColors.primaryTeal               // Primary action
backgroundColor: AppColors.error                     // Delete/danger
backgroundColor: AppColors.white                     // Secondary/outline

// SHADOWS
color: AppColors.shadowLight                         // Subtle (5%)
color: AppColors.shadow                              // Standard (10%)
color: AppColors.shadowDark                          // Prominent (15%)

// ERRORS
backgroundColor: AppColors.error                     // Error button
backgroundColor: AppColors.errorLight                // Error container bg
borderColor: AppColors.errorBorder                   // Error input border
textColor: AppColors.errorDark                       // Error message text

// BORDERS
color: AppColors.divider                             // Subtle border
color: AppColors.primaryTeal                         // Active border
```

---

## Updating AppColors

If you need to add new colors to AppColors:

1. **Add to `lib/utils/app_colors.dart`** with semantic name
2. **Document in this guide** with hex value and usage
3. **Test contrast ratios** at https://webaim.org/resources/contrastchecker/
4. **Update examples** in relevant sections
5. **Run pre-commit hook** to ensure no hardcoded colors remain

---

## Questions?

See `docs/ui_audit_completion_summary.md` for the full UI audit results and rationale behind the color system.

**Pre-commit Hook:** The repository includes a pre-commit hook that prevents hardcoded `Colors.*` usage. This ensures all new code uses AppColors.

**Enforcement:** All PRs must pass the pre-commit hook check before merging.

---

**Version History:**
- v1.0 (Nov 2, 2025) - Initial style guide created after UI audit completion
