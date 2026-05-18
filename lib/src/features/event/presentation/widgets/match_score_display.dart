import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

/// Shared score display for match cards that show a plain `home – away` score.
///
/// Shows a dash when [isNotStarted] is true. Colours the score with [AppColors.accent]
/// when [isLive], otherwise uses the theme base text colour. Pass [color] to
/// override the score colour (e.g. for sport-specific brand colours).
class MatchScoreDisplay extends StatelessWidget {
  const MatchScoreDisplay({
    super.key,
    required this.homeScore,
    required this.awayScore,
    required this.isNotStarted,
    required this.isLive,
    this.color,
  });

  final String homeScore;
  final String awayScore;
  final bool isNotStarted;
  final bool isLive;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isNotStarted) {
      return Text(
        '-',
        style: context.textTheme.titleMedium?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final scoreColor = color ?? (isLive ? AppColors.accent : context.appTheme.baseText);
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          TextSpan(text: ' - ', style: TextStyle(color: Colors.grey.shade400)),
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}
