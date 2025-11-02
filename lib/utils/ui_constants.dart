import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable UI constants for VelloShift design system
///
/// This file contains common BoxDecorations, TextStyles, and other UI constants
/// to ensure consistency across the app and reduce code duplication.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: UIConstants.cardDecoration,
///   child: YourContent(),
/// )
/// ```
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Standard border radius for cards and containers (16px)
  static const BorderRadius borderRadiusStandard = BorderRadius.all(Radius.circular(16));

  /// Small border radius for compact elements (12px)
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(12));

  /// Large border radius for prominent elements (24px)
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(24));

  /// Border radius for buttons (16px)
  static const BorderRadius borderRadiusButton = BorderRadius.all(Radius.circular(16));

  /// Border radius for inputs (16px)
  static const BorderRadius borderRadiusInput = BorderRadius.all(Radius.circular(16));

  // ============================================================================
  // SHADOWS
  // ============================================================================

  /// Subtle shadow for nested cards and list items (5% opacity)
  ///
  /// Use for: List items, nested cards, inline elements
  /// Elevation: Low
  static final List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Standard shadow for main cards and containers (10% opacity)
  ///
  /// Use for: Cards, containers, buttons
  /// Elevation: Medium
  static final List<BoxShadow> shadowStandard = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Prominent shadow for modals and elevated dialogs (15% opacity)
  ///
  /// Use for: Modals, dialogs, popovers, floating action buttons
  /// Elevation: High
  static final List<BoxShadow> shadowProminent = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Soft shadow for floating elements
  ///
  /// Use for: Bottom sheets, date pickers, custom dropdowns
  static final List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 2,
    ),
  ];

  // ============================================================================
  // BOX DECORATIONS - Cards
  // ============================================================================

  /// Standard white card with subtle shadow
  ///
  /// Most common card style in the app
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusStandard,
    boxShadow: shadowSubtle,
  );

  /// Card with standard shadow (more prominent)
  static final BoxDecoration cardDecorationElevated = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusStandard,
    boxShadow: shadowStandard,
  );

  /// Small card with compact border radius
  static final BoxDecoration cardDecorationSmall = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusSmall,
    boxShadow: shadowSubtle,
  );

  /// Card with border (for outlined cards)
  static final BoxDecoration cardDecorationOutlined = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusStandard,
    border: Border.all(color: AppColors.divider, width: 1),
  );

  /// Card with teal background (for selected/highlighted cards)
  static final BoxDecoration cardDecorationHighlighted = BoxDecoration(
    color: AppColors.primaryTeal,
    borderRadius: borderRadiusStandard,
    boxShadow: shadowSubtle,
  );

  // ============================================================================
  // BOX DECORATIONS - Containers
  // ============================================================================

  /// Container on cream background
  static final BoxDecoration containerOnCream = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusStandard,
    boxShadow: shadowSubtle,
  );

  /// Nested container (lighter shadow)
  static final BoxDecoration containerNested = BoxDecoration(
    color: AppColors.lightCream,
    borderRadius: borderRadiusSmall,
  );

  // ============================================================================
  // BOX DECORATIONS - Modals & Dialogs
  // ============================================================================

  /// Bottom sheet decoration
  static const BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  /// Modal decoration with prominent shadow
  static final BoxDecoration modalDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusLarge,
    boxShadow: shadowProminent,
  );

  /// Dialog decoration
  static final BoxDecoration dialogDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusStandard,
    boxShadow: shadowStandard,
  );

  // ============================================================================
  // BOX DECORATIONS - Input Fields
  // ============================================================================

  /// Standard text input decoration
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 17,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(
          color: AppColors.primaryTeal,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadiusInput,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    );
  }

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  /// Primary button style (teal background)
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryTeal,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusButton,
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Secondary button style (white background with teal border)
  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.primaryTeal,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusButton,
      side: const BorderSide(color: AppColors.primaryTeal, width: 2),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Destructive button style (red background)
  static final ButtonStyle destructiveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusButton,
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Disabled button style
  static final ButtonStyle disabledButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.textLight,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusButton,
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  );

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  /// Heading 1 - Large titles (36px)
  static const TextStyle heading1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  /// Heading 2 - Section titles (28px)
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  /// Heading 3 - Subsection titles (24px)
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  /// Heading 4 - Card titles (20px)
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  /// Heading 5 - Small titles (18px)
  static const TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Body large - Main content (17px)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    color: AppColors.textDark,
  );

  /// Body medium - Secondary content (16px)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: AppColors.textGrey,
  );

  /// Body small - Tertiary content (15px)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 15,
    color: AppColors.textGrey,
  );

  /// Caption - Timestamps, labels (13px)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.textLight,
  );

  /// Caption small - Very small text (12px)
  static const TextStyle captionSmall = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  /// Button text style
  static const TextStyle buttonText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  // ============================================================================
  // SPACING
  // ============================================================================

  /// Extra small spacing (4px)
  static const double spacingXS = 4.0;

  /// Small spacing (8px)
  static const double spacingS = 8.0;

  /// Medium spacing (16px) - Most common
  static const double spacingM = 16.0;

  /// Large spacing (24px)
  static const double spacingL = 24.0;

  /// Extra large spacing (32px)
  static const double spacingXL = 32.0;

  /// Huge spacing (48px)
  static const double spacingXXL = 48.0;

  // ============================================================================
  // PADDING
  // ============================================================================

  /// Screen padding (horizontal)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);

  /// Screen padding (all sides)
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(16);

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  /// Card padding compact
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(16);

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 18);

  // ============================================================================
  // SIZES
  // ============================================================================

  /// Minimum tap target size (44px) - Accessibility guideline
  static const double minTapTargetSize = 44.0;

  /// Button height
  static const double buttonHeight = 54.0;

  /// Input field height
  static const double inputHeight = 54.0;

  /// Icon size small
  static const double iconSizeSmall = 16.0;

  /// Icon size medium
  static const double iconSizeMedium = 24.0;

  /// Icon size large
  static const double iconSizeLarge = 32.0;
}
