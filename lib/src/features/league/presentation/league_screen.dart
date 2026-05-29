import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/country_model.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kPad = 22.0;

/// Maps [SportType] → [LeagueSport].
LeagueSport _toLs(SportType s) => switch (s) {
  SportType.football => LeagueSport.football,
  SportType.basketball => LeagueSport.basketball,
  SportType.tennis => LeagueSport.tennis,
  SportType.cricket => LeagueSport.cricket,
  SportType.baseball => LeagueSport.baseball,
  SportType.volleyball => LeagueSport.volleyball,
  SportType.badminton => LeagueSport.badminton,
  SportType.tableTennis => LeagueSport.tableTennis,
  SportType.iceHockey => LeagueSport.iceHockey,
  SportType.amFootball => LeagueSport.amFootball,
};

class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  LeagueSport _sport = LeagueSport.football;

  static const _sportList = SportType.values;

  @override
  Widget build(BuildContext context) {
    // ── Hot leagues provider ──
    final AsyncValue<List<LeagueItem>> hotAsync = switch (_sport) {
      LeagueSport.football => ref.watch(footballHotLeaguesProvider),
      LeagueSport.basketball => ref.watch(basketballHotLeaguesProvider),
      final s => ref.watch(sportHotLeaguesProvider(sport: s)),
    };

    // ── Browse (countries / categories) provider ──
    final AsyncValue<List<CountryModel>> countriesAsync = switch (_sport) {
      LeagueSport.football => ref.watch(footballCountriesProvider),
      LeagueSport.basketball => ref.watch(basketballCountriesProvider),
      _ when _sport.usesCategoryBrowse == null =>
        const AsyncData([]),
      final s => ref.watch(sportBrowseItemsProvider(sport: s)),
    };

    // ── Tennis parent leagues (Other Leagues section) ──
    final AsyncValue<List<LeagueItem>> tennisParentAsync =
        _sport == LeagueSport.tennis
            ? ref.watch(tennisParentLeaguesProvider)
            : const AsyncData([]);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_kPad, 12, _kPad, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.display(46, context)
                              .copyWith(color: context.appColors.text, height: 1),
                          children: [
                            TextSpan(text: 'league.title'.tr()),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.leagueSearch),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: context.appColors.lineStrong, width: 0.5),
                        ),
                        child: Icon(Icons.search_rounded,
                            size: 20, color: context.appColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sport filter ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.fromLTRB(_kPad, 0, _kPad, _kPad),
                itemCount: _sportList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final s = _sportList[i];
                  final ls = _toLs(s);
                  final isActive = _sport == ls;
                  return _SportFilterChip(
                    sport: s,
                    active: isActive,
                    onTap: () => setState(() => _sport = ls),
                  );
                },
              ),
            ),
          ),

          // ── Hot Leagues heading ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      'league.hot'.tr(),
                      style: AppTextStyles.display(20, context)
                          .copyWith(color: context.appColors.text),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(
                      AppRoutes.leagueHotBrowse,
                      extra: _sport,
                    ),
                    child: Text(
                      'league.all'.tr(),
                      style: AppTextStyles.mono(10).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 10 * 0.14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hot Leagues cards ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 72,
              child: hotAsync.when(
                loading: () => _HotLeaguesShimmer(),
                error: (_, _) => const SizedBox.shrink(),
                data: (leagues) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                  itemCount: leagues.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _HotLeagueCard(
                    league: leagues[i],
                    sport: _sport,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Divider ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Divider(
              thickness: 0.5,
              color: context.appColors.line,
              indent: _kPad,
              endIndent: _kPad,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── By Country / Category heading ────────────────────────────────
          if (_sport.usesCategoryBrowse != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        _sport.usesCategoryBrowse!
                            ? 'league.by_category'.tr()
                            : 'league.by_country'.tr(),
                        style: AppTextStyles.display(20, context)
                            .copyWith(color: context.appColors.text),
                      ),
                    ),
                    countriesAsync.maybeWhen(
                      data: (c) => c.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              'league.regions'.tr(namedArgs: {'n': '${c.length}'}),
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
            ),

          // ── By Country / Category grid ───────────────────────────────────
          if (_sport.usesCategoryBrowse != null)
            countriesAsync.when(
              loading: () => SliverToBoxAdapter(child: _CountriesShimmer()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (countries) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CountryTile(
                      country: countries[i],
                      sport: _sport,
                    ),
                    childCount: countries.length,
                  ),
                ),
              ),
            ),

          // ── Tennis: Other Leagues section ───────────────────────────────
          if (_sport == LeagueSport.tennis) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 14),
                child: Text(
                  'league.other_leagues'.tr(),
                  style: AppTextStyles.display(20, context)
                      .copyWith(color: context.appColors.text),
                ),
              ),
            ),
            tennisParentAsync.when(
              loading: () => SliverToBoxAdapter(child: _CountriesShimmer()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (leagues) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TennisLeagueTile(
                      league: leagues[i],
                      sport: _sport,
                    ),
                    childCount: leagues.length,
                  ),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Sport filter chip ────────────────────────────────────────────────────────

class _SportFilterChip extends StatelessWidget {
  const _SportFilterChip({
    required this.sport,
    required this.active,
    required this.onTap,
  });

  final SportType sport;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? context.appColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? context.appColors.accent
                : context.appColors.line,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sport.icon,
              size: 20,
              color: active
                  ? context.appColors.accent
                  : context.appColors.text2,
            ),
            const SizedBox(height: 8),
            Text(
              sport.i18nKey.tr().toUpperCase(),
              style: AppTextStyles.mono(8).copyWith(
                color: active
                    ? context.appColors.accent
                    : context.appColors.text2,
                letterSpacing: 8 * 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hot league card ──────────────────────────────────────────────────────────

class _HotLeagueCard extends StatelessWidget {
  const _HotLeagueCard({required this.league, required this.sport});

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
            _LeagueLogo(logoUrl: league.logo, size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.localizedName(en: league.nameEn, cn: league.nameCn),
                  style: AppTextStyles.display(14, context)
                      .copyWith(color: context.appColors.text, height: 1),
                ),
                const SizedBox(height: 5),
                if (league.nameEnShort != null && league.nameEnShort!.isNotEmpty)
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

// ─── Country / Category tile ──────────────────────────────────────────────────

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country, required this.sport});

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
                  child: Icon(Icons.flag_outlined,
                      size: 12, color: context.appColors.text3),
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
                    style: AppTextStyles.display(13, context)
                        .copyWith(color: context.appColors.text, height: 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 14, color: context.appColors.text3),
          ],
        ),
      ),
    );
  }
}

// ─── League logo widget ───────────────────────────────────────────────────────

class _LeagueLogo extends StatelessWidget {
  const _LeagueLogo({required this.logoUrl, this.size = 44});

  final String logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(color: context.appColors.surface2),
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.surface2,
          ),
          child: Icon(Icons.emoji_events_outlined,
              size: size * 0.45, color: context.appColors.text3),
        ),
      ),
    );
  }
}

// ─── Shimmer placeholders ─────────────────────────────────────────────────────

class _HotLeaguesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, _) => Container(
          width: 160,
          height: 60,
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _CountriesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kPad),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            8,
            (_) => Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tennis Other League tile ─────────────────────────────────────────────────

class _TennisLeagueTile extends StatelessWidget {
  const _TennisLeagueTile({required this.league, required this.sport});

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
            _LeagueLogo(logoUrl: league.logo, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context
                    .localizedName(en: league.nameEn, cn: league.nameCn)
                    .toUpperCase(),
                style: AppTextStyles.display(13, context)
                    .copyWith(color: context.appColors.text, height: 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 14, color: context.appColors.text3),
          ],
        ),
      ),
    );
  }
}

// ─── Public re-export of league logo (used by other screens) ─────────────────

class LeagueLogoWidget extends StatelessWidget {
  const LeagueLogoWidget({super.key, required this.logoUrl, this.size = 44});

  final String logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(color: context.appColors.surface2),
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.surface2,
          ),
          child: Icon(Icons.emoji_events_outlined,
              size: size * 0.45, color: context.appColors.text3),
        ),
      ),
    );
  }
}
