import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/country_model.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class LeagueCountryTile extends StatelessWidget {
  const LeagueCountryTile({
    super.key,
    required this.country,
    required this.sport,
  });

  final CountryModel country;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leagueCountryPath(sport.apiPath, country.id),
        extra: country,
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
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: country.logo,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: context.appColors.surface2),
                errorBuilder: (_, _, _) => Container(
                  width: 24,
                  height: 24,
                  color: context.appColors.surface2,
                  child: Icon(
                    Icons.flag_outlined,
                    size: 12,
                    color: context.appColors.text3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context
                        .localizedName(en: country.name, cn: country.cnName)
                        .toUpperCase(),
                    style: AppTextStyles.display(
                      13,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
