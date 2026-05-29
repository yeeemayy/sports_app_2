import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/country_model.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_country_tile.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_hot_card.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_shimmer.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_sport_chip.dart';
import 'package:sports_app/src/features/league/presentation/widgets/league_tennis_tile.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kPad = 22.0;

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
    final AsyncValue<List<LeagueItem>> hotAsync = switch (_sport) {
      LeagueSport.football => ref.watch(footballHotLeaguesProvider),
      LeagueSport.basketball => ref.watch(basketballHotLeaguesProvider),
      final s => ref.watch(sportHotLeaguesProvider(sport: s)),
    };

    final AsyncValue<List<CountryModel>> countriesAsync = switch (_sport) {
      LeagueSport.football => ref.watch(footballCountriesProvider),
      LeagueSport.basketball => ref.watch(basketballCountriesProvider),
      _ when _sport.usesCategoryBrowse == null => const AsyncData([]),
      final s => ref.watch(sportBrowseItemsProvider(sport: s)),
    };

    final AsyncValue<List<LeagueItem>> tennisParentAsync =
        _sport == LeagueSport.tennis
        ? ref.watch(tennisParentLeaguesProvider)
        : const AsyncData([]);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
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
                          style: AppTextStyles.display(
                            46,
                            context,
                          ).copyWith(color: context.appColors.text, height: 1),
                          children: [TextSpan(text: 'league.title'.tr())],
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
                            color: context.appColors.lineStrong,
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: context.appColors.text,
                        ),
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
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, _kPad),
                itemCount: _sportList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final s = _sportList[i];
                  final ls = LeagueSport.fromSportType(s);
                  final isActive = _sport == ls;
                  return LeagueSportChip(
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
              padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      'league.hot'.tr(),
                      style: AppTextStyles.display(
                        20,
                        context,
                      ).copyWith(color: context.appColors.text),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.leagueHotBrowse, extra: _sport),
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
                loading: () => const LeagueHotShimmer(),
                error: (_, _) => const SizedBox.shrink(),
                data: (leagues) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                  itemCount: leagues.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) =>
                      LeagueHotCard(league: leagues[i], sport: _sport),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

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
                        style: AppTextStyles.display(
                          20,
                          context,
                        ).copyWith(color: context.appColors.text),
                      ),
                    ),
                    countriesAsync.maybeWhen(
                      data: (c) => c.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              'league.regions'.tr(
                                namedArgs: {'n': '${c.length}'},
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
            ),

          // ── By Country / Category grid ───────────────────────────────────
          if (_sport.usesCategoryBrowse != null)
            countriesAsync.when(
              loading: () =>
                  const SliverToBoxAdapter(child: LeagueCountriesShimmer()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (countries) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        LeagueCountryTile(country: countries[i], sport: _sport),
                    childCount: countries.length,
                  ),
                ),
              ),
            ),

          // ── Tennis: Other Leagues section ────────────────────────────────
          if (_sport == LeagueSport.tennis) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 14),
                child: Text(
                  'league.other_leagues'.tr(),
                  style: AppTextStyles.display(
                    20,
                    context,
                  ).copyWith(color: context.appColors.text),
                ),
              ),
            ),
            tennisParentAsync.when(
              loading: () =>
                  const SliverToBoxAdapter(child: LeagueCountriesShimmer()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (leagues) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(_kPad, 0, _kPad, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        LeagueTennisTile(league: leagues[i], sport: _sport),
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
