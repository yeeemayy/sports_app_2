import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class MatchCardHeader extends StatelessWidget {
  const MatchCardHeader({
    super.key,
    required this.leagueLogo,
    required this.leagueName,
    required this.matchTime,
    this.statusWidget,
  });

  final String leagueLogo;
  final String leagueName;
  final String matchTime;
  final Widget? statusWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LeagueLogo(url: leagueLogo),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            leagueName,
            style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (statusWidget != null) ...[
          const SizedBox(width: 6),
          statusWidget!,
        ],
        const SizedBox(width: 6),
        Text(
          matchTime,
          style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
        ),
      ],
    );
  }
}
