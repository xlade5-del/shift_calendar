import 'package:flutter/material.dart';

/// VelloShift Brand Color Palette
/// Derived from the VelloShift logo color scheme
class AppColors {
  // Primary Brand Colors
  static const Color primaryTeal = Color(0xFF2B7A78);
  static const Color darkTeal = Color(0xFF1F5654);
  static const Color lightTeal = Color(0xFF3D9B98);

  // Accent Colors
  static const Color peach = Color(0xFFF4C49A);
  static const Color lightPeach = Color(0xFFF8D9B8);
  static const Color mint = Color(0xFFA8DADC);
  static const Color lightMint = Color(0xFFCCEBEC);

  // Background Colors
  static const Color cream = Color(0xFFF5E6D3);
  static const Color lightCream = Color(0xFFFAF3E8);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Semantic Colors
  static const Color success = Color(0xFF2B7A78); // Using brand teal
  static const Color error = Color(0xFFD63031);
  static const Color errorDark = Color(0xFFB71C1C); // Darker red for text on light backgrounds
  static const Color errorLight = Color(0xFFFFEBEE); // Light red background for warnings
  static const Color errorBorder = Color(0xFFEF5350); // Medium red for borders
  static const Color warning = Color(0xFFF4C49A); // Using brand peach
  static const Color info = Color(0xFFA8DADC); // Using brand mint

  // UI Element Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFDFE6E9);
  static const Color shadow = Color(0x1A000000); // 10% opacity - standard shadow
  static const Color shadowLight = Color(0x0D000000); // 5% opacity - subtle shadow
  static const Color shadowDark = Color(0x26000000); // 15% opacity - prominent shadow

  // Overlay Colors
  static const Color overlayLight = Color(0xB3FFFFFF); // 70% white overlay

  // Calendar Event Colors (keeping existing palette but adjusting to match theme)
  static const Color eventBlue = Color(0xFF4A90E2);
  static const Color eventGreen = Color(0xFF2B7A78); // Using brand teal
  static const Color eventOrange = Color(0xFFF4C49A); // Using brand peach
  static const Color eventRed = Color(0xFFD63031);
  static const Color eventPurple = Color(0xFF9B59B6);
  static const Color eventTeal = Color(0xFF2B7A78); // Using brand teal
  static const Color eventPink = Color(0xFFE84393);
  static const Color eventAmber = Color(0xFFF39C12);
}
