import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/country_league_item.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class CountryLeaguesScreen extends ConsumerWidget {
  const CountryLeaguesScreen({
    super.key,
    required this.sport,
    required this.countryId,
    required this.countryName,
    this.countryNameCn,
    this.countryLogoUrl,
  });

  final LeagueSport sport;
  final String countryId;
  final String countryName;
  final String? countryNameCn;
  final String? countryLogoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = sport == LeagueSport.football
        ? ref.watch(
            footballLeaguesByCountryProvider(countryId: countryId))
        : ref.watch(
            basketballLeaguesByCountryProvider(countryId: countryId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(22, 10, 22, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.appColors.lineStrong,
                            width: 0.5),
                      ),
                      child: Icon(Icons.chevron_left_rounded,
                          size: 20, color: context.appColors.text),
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (countryLogoUrl != null)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: countryLogoUrl!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  if (countryLogoUrl != null) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.localizedName(en: countryName, cn: countryNameCn).toUpperCase(),
                          style: AppTextStyles.display(26, context)
                              .copyWith(
                                  color: context.appColors.text,
                                  height: 1),
                        ),
                        leaguesAsync.maybeWhen(
                          data: (l) => Text(
                            'league.competitions'.tr(
                                namedArgs: {'n': '${l.length}'}),
                            style: AppTextStyles.mono(10).copyWith(
                              color: context.appColors.text3,
                              letterSpacing: 10 * 0.14,
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // League list
            Expanded(
              child: leaguesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'league.empty'.tr(),
                    style: AppTextStyles.body(14)
                        .copyWith(color: context.appColors.text3),
                  ),
                ),
                data: (leagues) => leagues.isEmpty
                    ? Center(
                        child: Text(
                          'league.empty'.tr(),
                          style: AppTextStyles.body(14)
                              .copyWith(color: context.appColors.text3),
                        ),
                      )
                    : ListView.builder(
                        itemCount: leagues.length,
                        itemBuilder: (context, i) =>
                            _CountryLeagueRow(
                          item: leagues[i],
                          sport: sport,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryLeagueRow extends StatelessWidget {
  const _CountryLeagueRow({required this.item, required this.sport});

  final CountryLeagueItem item;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    final isCup = item.type == 2;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leagueDetailPath(sport.apiPath, item.id),
        extra: item,
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: item.logo,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: context.appColors.surface2),
                errorBuilder: (_, _, _) => Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(Icons.emoji_events_outlined,
                      size: 20, color: context.appColors.text3),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localizedName(en: item.name, cn: item.cnName),
                    style: AppTextStyles.display(17, context)
                        .copyWith(
                            color: context.appColors.text, height: 1),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      if (item.shortName != null) ...[
                        Text(
                          item.shortName!,
                          style: AppTextStyles.mono(9).copyWith(
                            color: context.appColors.text3,
                            letterSpacing: 9 * 0.1,
                          ),
                        ),
                        _dot(context),
                      ],
                      if (item.curRound != null &&
                          item.roundCount != null &&
                          !isCup) ...[
                        Text(
                          'GW ${item.curRound}/${item.roundCount}',
                          style: AppTextStyles.mono(9).copyWith(
                            color: context.appColors.text3,
                          ),
                        ),
                      ],
                      if (isCup)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: context.appColors.live
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CUP',
                            style: AppTextStyles.mono(8).copyWith(
                              color: context.appColors.live,
                              letterSpacing: 8 * 0.1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: context.appColors.text3),
          ],
        ),
      ),
    );
  }

  Widget _dot(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.lineStrong,
          ),
        ),
      );
}
