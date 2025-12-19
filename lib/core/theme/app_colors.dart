import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF3A36DB);
  static const Color primaryLight = Color(0xFF5956E8);
  static const Color primaryDark = Color(0xFF2825A0);

  // Background colors
  static const Color background = Color(0xFFF1F4FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF06152B);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textLight = Color(0xFF99B2C6);
  static const Color textHint = Color(0xFFABB5C5);

  // Accent colors
  static const Color accent = Color(0xFF03A89E);
  static const Color secondary = Color(0xFFFF69B4);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
