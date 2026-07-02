import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';

/// Score display for set-based sports (tennis, badminton, table tennis).
///
/// Shows a dash when not started, `homeTotal - awayTotal` otherwise,
/// and the current set score (`homeSets.last:awaySets.last`) below when sets exist.
class SetScoreDisplay extends StatelessWidget {
  const SetScoreDisplay({
    required this.statusId,
    required this.statusLabel,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
    required this.isLive,
    super.key,
  });

  final int statusId;
  final String statusLabel;
  final String homeTotal;
  final String awayTotal;
  final List<int> homeSets;
  final List<int> awaySets;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final isNotStarted = statusId == 1;
    final scoreColor = isNotStarted
        ? Colors.grey.shade400
        : isLive
        ? context.appColors.accent
        : context.appColors.text;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNotStarted || statusLabel.isEmpty)
          Text(
            '-',
            style: context.textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          RichText(
            text: TextSpan(
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: scoreColor,
              ),
              children: [
                TextSpan(text: homeTotal),
                const TextSpan(text: ' - '),
                TextSpan(text: awayTotal),
              ],
            ),
          ),
        if (homeSets.isNotEmpty)
          Text(
            '${homeSets.last}:${awaySets.last}',
            style: context.textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
      ],
    );
  }
}
