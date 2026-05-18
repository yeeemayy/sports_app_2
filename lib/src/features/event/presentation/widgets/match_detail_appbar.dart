import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

/// Shared AppBar for all sport match-detail screens.
///
/// Shows the [leagueName] as the primary title and, when [matchTimestamp]
/// is a positive Unix timestamp (seconds), formats and shows the match date
/// below it in a locale-aware format.
class MatchDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MatchDetailAppBar({super.key, required this.leagueName, this.matchTimestamp});

  final String leagueName;

  /// Unix timestamp in seconds. Omit or pass null / 0 to hide the date line.
  final int? matchTimestamp;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ts = matchTimestamp;
    return AppBar(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            leagueName,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (ts != null && ts > 0)
            Text(
              DateFormat(
                context.locale.languageCode == 'zh'
                    ? 'yyyy年MM月dd日 EEEE ahh:mm'
                    : 'yyyy MMM dd EEEE hh:mmaa',
                context.locale.toString(),
              ).format(DateTime.fromMillisecondsSinceEpoch(ts * 1000)),
              style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
        ],
      ),
    );
  }
}