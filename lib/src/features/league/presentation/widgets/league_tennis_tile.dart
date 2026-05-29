import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_logo.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class LeagueTennisTile extends StatelessWidget {
  const LeagueTennisTile({
    super.key,
    required this.league,
    required this.sport,
  });

  final LeagueItem league;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leagueDetailPath(sport.apiPath, league.id),
        extra: league,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Row(
          children: [
            LeagueLogoWidget(logoUrl: league.logo, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context
                    .localizedName(en: league.nameEn, cn: league.nameCn)
                    .toUpperCase(),
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: context.appColors.text, height: 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: context.appColors.text3,
            ),
          ],
        ),
      ),
    );
  }
}
