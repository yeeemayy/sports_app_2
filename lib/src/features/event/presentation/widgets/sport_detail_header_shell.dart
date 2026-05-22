import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

/// Arena-styled gradient header shell used by every sport detail screen.
///
/// Provides the dark gradient background, the top navigation bar (back +
/// league info), a subtle accent glow, and a content slot [builder] for the
/// sport-specific score area.
class SportDetailHeaderShell<T> extends StatelessWidget {
  const SportDetailHeaderShell({
    super.key,
    required this.detailAsync,
    required this.builder,
    this.leagueName,
    this.matchTimestamp,
    this.skeletonHeight = 80.0,
    this.fallback,
  });

  final AsyncValue<dynamic> detailAsync;
  final Widget Function(T detail) builder;
  final String? leagueName;
  final int? matchTimestamp;
  final double skeletonHeight;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.surface2, colors.ink],
        ),
      ),
      child: Stack(
        children: [
          // Accent radial glow — top-right corner
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nav bar
                _ArenaNavBar(leagueName: leagueName, matchTimestamp: matchTimestamp),

                // Sport-specific score content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: detailAsync.when(
                    loading: () =>
                        fallback ?? SizedBox(height: skeletonHeight),
                    error: (_, __) =>
                        fallback ?? SizedBox(height: skeletonHeight),
                    data: (obj) => builder(obj as T),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaNavBar extends StatelessWidget {
  const _ArenaNavBar({this.leagueName, this.matchTimestamp});

  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = context.locale;

    String subtitle = '';
    final ts = matchTimestamp;
    if (ts != null && ts > 0) {
      subtitle = DateFormat(
        locale.languageCode == 'zh' ? 'MM月dd日 EEEE' : 'dd MMM · EEEE',
        locale.toString(),
      ).format(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: colors.lineStrong, width: 0.5),
              ),
              child: Icon(Icons.arrow_circle_left_outlined, color: Colors.white, size: 24),
            ),
          ),

          // League + date
          Expanded(
            child: Column(
              children: [
                if (leagueName != null && leagueName!.isNotEmpty)
                  Text(
                    leagueName!.toUpperCase(),
                    style: AppTextStyles.mono(10).copyWith(
                      color: colors.text2,
                      letterSpacing: 0.18 * 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle.toUpperCase(),
                    style: AppTextStyles.mono(9).copyWith(
                      color: colors.text3,
                      letterSpacing: 0.14 * 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          // Placeholder to balance back button
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}
