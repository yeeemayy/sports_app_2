import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/country_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/league_item.dart';
import 'package:shenghaotiyu/src/features/league/presentation/providers/league_providers.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

enum _SearchType { all, leagues, countries }

class SearchLeaguesScreen extends ConsumerStatefulWidget {
  const SearchLeaguesScreen({super.key});

  @override
  ConsumerState<SearchLeaguesScreen> createState() =>
      _SearchLeaguesScreenState();
}

class _SearchLeaguesScreenState extends ConsumerState<SearchLeaguesScreen> {
  final _controller = TextEditingController();
  String _query = '';
  _SearchType _type = _SearchType.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLeagues = <(LeagueItem, LeagueSport)>[];
    final allCountries = <(CountryModel, LeagueSport)>[];

    for (final sport in LeagueSport.values) {
      final leagues =
          ref.watch(sportHotLeaguesProvider(sport: sport)).valueOrNull ?? [];
      for (final l in leagues) {
        allLeagues.add((l, sport));
      }

      final countries =
          ref.watch(sportBrowseItemsProvider(sport: sport)).valueOrNull ?? [];
      for (final c in countries) {
        allCountries.add((c, sport));
      }
    }

    // Filter
    final q = _query.toLowerCase();
    final matchedLeagues = _type != _SearchType.countries
        ? allLeagues.where((t) {
            if (q.isEmpty) return true;
            final l = t.$1;
            return l.nameEn.toLowerCase().contains(q) ||
                (l.nameEnShort?.toLowerCase().contains(q) ?? false) ||
                (l.nameCn?.contains(q) ?? false);
          }).toList()
        : <(LeagueItem, LeagueSport)>[];

    final matchedCountries = _type != _SearchType.leagues
        ? allCountries.where((t) {
            if (q.isEmpty) return true;
            final c = t.$1;
            return c.name.toLowerCase().contains(q) ||
                (c.cnName?.contains(q) ?? false);
          }).toList()
        : <(CountryModel, LeagueSport)>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.appColors.surface2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.body(
                          14,
                        ).copyWith(color: context.appColors.text),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          hintText: 'league.search_hint'.tr(),
                          hintStyle: AppTextStyles.body(
                            14,
                          ).copyWith(color: context.appColors.text3),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: context.appColors.text3,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _controller.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: context.appColors.text3,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Type filter chips
            _TypeFilterBar(
              selected: _type,
              onSelect: (t) => setState(() => _type = t),
            ),

            const SizedBox(height: 8),

            // Results
            Expanded(
              child: (matchedLeagues.isEmpty && matchedCountries.isEmpty)
                  ? Center(
                      child: Text(
                        _query.isEmpty
                            ? 'league.search_hint'.tr()
                            : 'league.empty'.tr(),
                        style: AppTextStyles.body(
                          14,
                        ).copyWith(color: context.appColors.text3),
                      ),
                    )
                  : ListView(
                      children: [
                        if (matchedLeagues.isNotEmpty) ...[
                          _SectionHeader(label: 'league.tabs.standings'.tr()),
                          ...matchedLeagues.map(
                            (t) => _LeagueResultRow(league: t.$1, sport: t.$2),
                          ),
                        ],
                        if (matchedCountries.isNotEmpty) ...[
                          _SectionHeader(label: 'league.by_country'.tr()),
                          ...matchedCountries.map(
                            (t) =>
                                _CountryResultRow(country: t.$1, sport: t.$2),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Type Filter ─────────────────────────────────────────────────────────────

class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.selected, required this.onSelect});
  final _SearchType selected;
  final ValueChanged<_SearchType> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TypeChip(
            label: 'league.all_filter'.tr(),
            active: selected == _SearchType.all,
            onTap: () => onSelect(_SearchType.all),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: 'league.filter.leagues'.tr(),
            active: selected == _SearchType.leagues,
            onTap: () => onSelect(_SearchType.leagues),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: 'league.filter.countries'.tr(),
            active: selected == _SearchType.countries,
            onTap: () => onSelect(_SearchType.countries),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? context.appColors.accent : context.appColors.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.mono(10).copyWith(
            color: active ? Colors.white : context.appColors.text3,
            letterSpacing: 10 * 0.1,
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
      child: Text(
        label,
        style: AppTextStyles.mono(
          10,
        ).copyWith(color: context.appColors.text3, letterSpacing: 10 * 0.14),
      ),
    );
  }
}

// ─── Result Rows ─────────────────────────────────────────────────────────────

class _LeagueResultRow extends StatelessWidget {
  const _LeagueResultRow({required this.league, required this.sport});
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: league.logo,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: context.appColors.text3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localizedName(en: league.nameEn, cn: league.nameCn),
                    style: AppTextStyles.display(
                      14,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1.1),
                  ),
                  if (league.nameEnShort != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      league.nameEnShort!,
                      style: AppTextStyles.mono(
                        9,
                      ).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.appColors.surface2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sport.labelKey.tr(),
                style: AppTextStyles.mono(7).copyWith(
                  color: context.appColors.text3,
                  letterSpacing: 7 * 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryResultRow extends StatelessWidget {
  const _CountryResultRow({required this.country, required this.sport});
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: country.logo,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: context.appColors.text3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localizedName(en: country.name, cn: country.cnName),
                style: AppTextStyles.display(
                  14,
                  context,
                ).copyWith(color: context.appColors.text, height: 1.1),
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
}
