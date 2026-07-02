import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/country_league_item.dart';
import 'package:shenghaotiyu/src/features/league/presentation/providers/league_providers.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

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
    final leaguesAsync = switch (sport) {
      LeagueSport.football => ref.watch(
        footballLeaguesByCountryProvider(countryId: countryId),
      ),
      LeagueSport.basketball => ref.watch(
        basketballLeaguesByCountryProvider(countryId: countryId),
      ),
      final s => ref.watch(
        sportLeaguesByBrowseIdProvider(sport: s, id: countryId),
      ),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_circle_left_outlined,
                      color: context.appColors.text,
                    ),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 14),
                  if (countryLogoUrl != null)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: countryLogoUrl!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  if (countryLogoUrl != null) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context
                              .localizedName(en: countryName, cn: countryNameCn)
                              .toUpperCase(),
                          style: AppTextStyles.display(
                            26,
                            context,
                          ).copyWith(color: context.appColors.text, height: 1),
                        ),
                        leaguesAsync.maybeWhen(
                          data: (l) => Text(
                            'league.competitions'.tr(
                              namedArgs: {'n': '${l.length}'},
                            ),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'league.empty'.tr(),
                    style: AppTextStyles.body(
                      14,
                    ).copyWith(color: context.appColors.text3),
                  ),
                ),
                data: (leagues) => leagues.isEmpty
                    ? Center(
                        child: Text(
                          'league.empty'.tr(),
                          style: AppTextStyles.body(
                            14,
                          ).copyWith(color: context.appColors.text3),
                        ),
                      )
                    : ListView.builder(
                        itemCount: leagues.length,
                        itemBuilder: (context, i) =>
                            _CountryLeagueRow(item: leagues[i], sport: sport),
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

  String? _compTypeKey(int? type) => switch (type) {
    1 => 'league.comp_type_league',
    2 => 'league.comp_type_cup',
    3 => 'league.comp_type_friendly',
    _ => null,
  };

  Color _compTypeColor(BuildContext context, int? type) => switch (type) {
    1 => context.appColors.accent, // league — orange
    2 => context.appColors.live, // cup — red
    3 => context.appColors.success, // friendly — green
    _ => context.appColors.live,
  };

  @override
  Widget build(BuildContext context) {
    final compTypeKey = _compTypeKey(item.type);
    final compTypeColor = _compTypeColor(context, item.type);

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leagueDetailPath(sport.apiPath, item.id),
        extra: item,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
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
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 20,
                    color: context.appColors.text3,
                  ),
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
                    style: AppTextStyles.display(
                      17,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                  ),
                  if (sport == LeagueSport.football ||
                      sport == LeagueSport.basketball) ...[
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
                        if (compTypeKey != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: compTypeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              compTypeKey.tr(),
                              style: AppTextStyles.mono(8).copyWith(
                                color: compTypeColor,
                                letterSpacing: 8 * 0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: context.appColors.text3,
            ),
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
