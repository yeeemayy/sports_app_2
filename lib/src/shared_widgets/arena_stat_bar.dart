import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

/// Handoff-style stat comparison row: home value | label | away value
/// with a split progress bar beneath.
class ArenaStatBar extends StatelessWidget {
  const ArenaStatBar({
    super.key,
    required this.label,
    required this.home,
    required this.away,
    this.max,
  });

  final String label;
  final num home;
  final num away;

  /// Optional explicit max for percentage stats (e.g. 100 for possession %).
  final num? max;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveMax =
        max?.toDouble() ??
        (home.toDouble() == 0 && away.toDouble() == 0
            ? 1
            : (home.toDouble() + away.toDouble()));
    final homePct = effectiveMax == 0
        ? 0.0
        : (home.toDouble() / effectiveMax).clamp(0.0, 1.0);
    final awayPct = effectiveMax == 0
        ? 0.0
        : (away.toDouble() / effectiveMax).clamp(0.0, 1.0);

    final homeDisplay = home == home.toInt()
        ? '${home.toInt()}'
        : home.toStringAsFixed(1);
    final awayDisplay = away == away.toInt()
        ? '${away.toInt()}'
        : away.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  homeDisplay,
                  style: AppTextStyles.mono(12).copyWith(color: colors.text),
                ),
              ),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mono(
                    9,
                  ).copyWith(color: colors.text3, letterSpacing: 0.14 * 9),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  awayDisplay,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.mono(12).copyWith(color: colors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              // Home bar (fills from right)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(height: 4, color: colors.surface2),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * homePct,
                        child: Container(color: colors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Away bar (fills from left)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(height: 4, color: colors.surface2),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * awayPct,
                        child: Container(
                          color: colors.text.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
