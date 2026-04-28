import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryShade50 = Color(0xFFE8F5E9);
  static const Color primaryShade200 = Color(0xFFA5D6A7);
  static const Color primaryShade300 = Color(0xFF81C784);
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
      ? Colors.white70
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

  Color get textFieldBg => _theme.brightness == Brightness.dark
      ? Colors.grey.shade800
      : const Color(0xFFF5F5F5);

  Color get textFieldLabel => _theme.brightness == Brightness.dark
      ? Colors.white70
      : const Color(0xFF343C44);
}

extension AppThemeColorExtension on BuildContext {
  AppThemeColors get appTheme => AppThemeColors(Theme.of(this));
}
