import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_logo.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class LeagueHotCard extends StatelessWidget {
  const LeagueHotCard({super.key, required this.league, required this.sport});

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
        constraints: const BoxConstraints(minWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LeagueLogoWidget(logoUrl: league.logo, size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.localizedName(en: league.nameEn, cn: league.nameCn),
                  style: AppTextStyles.display(
                    14,
                    context,
                  ).copyWith(color: context.appColors.text, height: 1),
                ),
                const SizedBox(height: 5),
                if (league.nameEnShort != null &&
                    league.nameEnShort!.isNotEmpty)
                  Text(
                    league.nameEnShort!.toUpperCase(),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text3,
                      letterSpacing: 9 * 0.1,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
