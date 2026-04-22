import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE91E63);
  static const Color primaryShade50 = Color(0xFFFCE4EC);
  static const Color primaryShade200 = Color(0xFFF48FB1);
  static const Color primaryShade300 = Color(0xFFF06292);
}

class AppTheme {
  AppTheme._();

  static AppThemeColors of(BuildContext context) => AppThemeColors(Theme.of(context));
}

class AppThemeColors {
  const AppThemeColors(this._theme);
  final ThemeData _theme;

  Color get surface => _theme.colorScheme.surface;

  Color get greyText => _theme.brightness == Brightness.dark
      ? Colors.grey.shade400
      : Colors.grey.shade700;

  Color get baseText => _theme.brightness == Brightness.dark
      ? Colors.white
      : Colors.black87;

  Color get shimmerBase => _theme.brightness == Brightness.dark
      ? Colors.grey.shade600
      : Colors.grey.shade300;

  Color get shimmerHighlight => _theme.brightness == Brightness.dark
      ? Colors.grey.shade800
      : Colors.grey.shade100;

  Color get grey_3 => _theme.brightness == Brightness.dark
      ? Colors.grey.shade700
      : Colors.grey.shade200;

  Color get grey_4 => _theme.brightness == Brightness.dark
      ? Colors.grey.shade200
      : Colors.grey.shade700;

  Color get grey_5 => _theme.brightness == Brightness.dark
      ? Colors.grey.shade300
      : Colors.grey.shade600;

  Color get inningHeaderBg => _theme.brightness == Brightness.dark
      ? const Color(0xFF252D3A)
      : const Color(0xFFEEF2F7);

  Color get inningAwayRowBg => _theme.brightness == Brightness.dark
      ? const Color(0xFF2D1F1A)
      : const Color(0xFFFFF4F0);

  Color get inningHomeRowBg => _theme.brightness == Brightness.dark
      ? const Color(0xFF1A2435)
      : const Color(0xFFEFF6FF);
}

extension AppThemeColorExtension on BuildContext {
  AppThemeColors get appTheme => AppThemeColors(Theme.of(this));
}
