import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink,
    required this.ink2,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.lineStrong,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentEcho,
    required this.live,
    required this.success,
    required this.danger,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.inningHeaderBg,
    required this.inningAwayRowBg,
    required this.inningHomeRowBg,
  });

  final Color ink;
  final Color ink2;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color lineStrong;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentEcho;
  final Color live;
  final Color success;
  final Color danger;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color inningHeaderBg;
  final Color inningAwayRowBg;
  final Color inningHomeRowBg;

  static const AppColors dark = AppColors(
    ink: Color(0xFF0E0E0E),
    ink2: Color(0xFF161616),
    surface: Color(0xFF1A1A1A),
    surface2: Color(0xFF232323),
    line: Color(0x14F0F4FF),
    lineStrong: Color(0x2EF0F4FF),
    text: Color(0xFFF0F4FF),
    text2: Color(0x9EF0F4FF),
    text3: Color(0x5CF0F4FF),
    accent: Color(0xFFFF3C00),
    accentEcho: Color(0xFFFF7A45),
    live: Color(0xFFFFB300),
    success: Color(0xFF00E5A8),
    danger: Color(0xFFE63946),
    shimmerBase: Color(0xFF232323),
    shimmerHighlight: Color(0xFF2E2E2E),
    inningHeaderBg: Color(0xFF232323),
    inningAwayRowBg: Color(0xFF2D1F1A),
    inningHomeRowBg: Color(0xFF1A2435),
  );

  static const AppColors light = AppColors(
    ink: Color(0xFFF8F8F8),
    ink2: Color(0xFFEFEFEF),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2F2F2),
    line: Color(0x140E0E0E),
    lineStrong: Color(0x2E0E0E0E),
    text: Color(0xFF0E0E0E),
    text2: Color(0x9E0E0E0E),
    text3: Color(0x5C0E0E0E),
    accent: Color(0xFFFF3C00),
    accentEcho: Color(0xFFFF7A45),
    live: Color(0xFFFFB300),
    success: Color(0xFF00C48C),
    danger: Color(0xFFE63946),
    shimmerBase: Color(0xFFE4E4E4),
    shimmerHighlight: Color(0xFFF0F0F0),
    inningHeaderBg: Color(0xFFECECEC),
    inningAwayRowBg: Color(0xFFFFF0ED),
    inningHomeRowBg: Color(0xFFEEF2FB),
  );

  @override
  AppColors copyWith({
    Color? ink,
    Color? ink2,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? lineStrong,
    Color? text,
    Color? text2,
    Color? text3,
    Color? accent,
    Color? accentEcho,
    Color? live,
    Color? success,
    Color? danger,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? inningHeaderBg,
    Color? inningAwayRowBg,
    Color? inningHomeRowBg,
  }) => AppColors(
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    line: line ?? this.line,
    lineStrong: lineStrong ?? this.lineStrong,
    text: text ?? this.text,
    text2: text2 ?? this.text2,
    text3: text3 ?? this.text3,
    accent: accent ?? this.accent,
    accentEcho: accentEcho ?? this.accentEcho,
    live: live ?? this.live,
    success: success ?? this.success,
    danger: danger ?? this.danger,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    inningHeaderBg: inningHeaderBg ?? this.inningHeaderBg,
    inningAwayRowBg: inningAwayRowBg ?? this.inningAwayRowBg,
    inningHomeRowBg: inningHomeRowBg ?? this.inningHomeRowBg,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentEcho: Color.lerp(accentEcho, other.accentEcho, t)!,
      live: Color.lerp(live, other.live, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      inningHeaderBg: Color.lerp(inningHeaderBg, other.inningHeaderBg, t)!,
      inningAwayRowBg: Color.lerp(inningAwayRowBg, other.inningAwayRowBg, t)!,
      inningHomeRowBg: Color.lerp(inningHomeRowBg, other.inningHomeRowBg, t)!,
    );
  }
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(double size, BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    return isChinese
        ? GoogleFonts.wdxlLubrifontSc(fontSize: size, height: 0.85)
        : GoogleFonts.anton(fontSize: size, height: 0.85);
  }

  static TextStyle body(double size) => GoogleFonts.spaceGrotesk(fontSize: size);

  static TextStyle mono(double size) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    letterSpacing: size * 0.16,
  );
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
