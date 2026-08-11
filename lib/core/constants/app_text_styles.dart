import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Kept in sync with the type scale in [AppTheme.lightTheme]'s textTheme
/// (lib/theme/app_theme.dart), so screens using AppTextStyles.* and
/// screens using Theme.of(context).textTheme.* render at matching sizes.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
