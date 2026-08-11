import 'package:flutter/material.dart';

/// Kept in sync with [AppTheme] in lib/theme/app_theme.dart, which is the
/// single source of truth applied via MaterialApp.theme in main.dart.
/// Prefer using AppTheme directly in new code — this class exists for
/// any legacy references and mirrors the same canonical values so the
/// app never ends up with two different color systems again.
import '../../theme/app_theme.dart';

class AppColors {
  AppColors._();

  static const Color primary = AppTheme.primaryBlue;

  static const Color primaryLight = AppTheme.lightBlue;

  static const Color background = AppTheme.background;

  static const Color card = AppTheme.surface;

  static const Color textPrimary = AppTheme.textPrimary;

  static const Color textSecondary = AppTheme.textSecondary;

  static const Color border = AppTheme.border;

  static const Color error = Color(0xFFD92D20);
}