import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF0E0E0E);
  static const Color ink2 = Color(0xFF161616);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surface2 = Color(0xFF232323);
  static const Color line = Color(0x14F0F4FF);
  static const Color lineStrong = Color(0x2EF0F4FF);
  static const Color text = Color(0xFFF0F4FF);
  static const Color text2 = Color(0x9EF0F4FF);
  static const Color text3 = Color(0x5CF0F4FF);
  static const Color accent = Color(0xFFFF3C00);
  static const Color accentEcho = Color(0xFFFF7A45);
  static const Color live = Color(0xFFFFB300);
  static const Color success = Color(0xFF00E5A8);
  static const Color danger = Color(0xFFE63946);

  // Shimmer
  static const Color shimmerBase = surface2;
  static const Color shimmerHighlight = Color(0xFF2E2E2E);

  // Sport-specific row colours
  static const Color inningHeaderBg = surface2;
  static const Color inningAwayRowBg = Color(0xFF2D1F1A);
  static const Color inningHomeRowBg = Color(0xFF1A2435);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(double size, BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    return isChinese
        ? GoogleFonts.wdxlLubrifontSc(fontSize: size, height: 0.85)
        : GoogleFonts.anton(fontSize: size, height: 0.85);
  }

  static TextStyle body(double size) => GoogleFonts.spaceGrotesk(
    fontSize: size,
  );

  static TextStyle mono(double size) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    letterSpacing: size * 0.16,
  );
}

/// Thin wrapper kept so existing `context.appTheme.*` call sites compile
/// without change. All values are now Arena dark-first constants.
class AppThemeColors {
  const AppThemeColors();

  Color get surface => AppColors.surface;
  Color get greyText => AppColors.text2;
  Color get baseText => AppColors.text;
  Color get shimmerBase => AppColors.shimmerBase;
  Color get shimmerHighlight => AppColors.shimmerHighlight;
  Color get grey_3 => AppColors.lineStrong;
  Color get grey_4 => AppColors.text2;
  Color get grey_5 => AppColors.text3;
  Color get inningHeaderBg => AppColors.inningHeaderBg;
  Color get inningAwayRowBg => AppColors.inningAwayRowBg;
  Color get inningHomeRowBg => AppColors.inningHomeRowBg;
  Color get textFieldBg => AppColors.surface2;
  Color get textFieldLabel => AppColors.text2;
}

extension AppThemeColorExtension on BuildContext {
  AppThemeColors get appTheme => const AppThemeColors();
}
