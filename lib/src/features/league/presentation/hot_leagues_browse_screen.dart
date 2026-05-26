import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class HotLeaguesBrowseScreen extends ConsumerStatefulWidget {
  const HotLeaguesBrowseScreen({super.key, this.initialSport});

  final LeagueSport? initialSport;

  @override
  ConsumerState<HotLeaguesBrowseScreen> createState() =>
      _HotLeaguesBrowseScreenState();
}

class _HotLeaguesBrowseScreenState
    extends ConsumerState<HotLeaguesBrowseScreen> {
  // null = all
  LeagueSport? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialSport;
  }

  @override
  Widget build(BuildContext context) {
    final footballAsync = ref.watch(footballHotLeaguesProvider);
    final basketballAsync = ref.watch(basketballHotLeaguesProvider);

    final footballLeagues =
        footballAsync.valueOrNull?.map((l) => (l, LeagueSport.football)).toList() ?? [];
    final basketballLeagues = basketballAsync.valueOrNull
            ?.map((l) => (l, LeagueSport.basketball))
            .toList() ??
        [];

    final all = [...footballLeagues, ...basketballLeagues];
    final filtered = _filter == null
        ? all
        : all.where((t) => t.$2 == _filter).toList();

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
                    icon: Icon(Icons.arrow_circle_left_outlined,
                        color: context.appColors.text),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'league.hot'.tr(),
                      style: AppTextStyles.display(22, context)
                          .copyWith(color: context.appColors.text, height: 1),
                    ),
                  ),
                ],
              ),
            ),

            // Sport filter chips
            _SportFilterBar(
              selected: _filter,
              onSelect: (s) => setState(() => _filter = s),
            ),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: (footballAsync.isLoading || basketballAsync.isLoading) &&
                      all.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'league.empty'.tr(),
                            style: AppTextStyles.body(14).copyWith(
                                color: context.appColors.text3),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final (league, sport) = filtered[i];
                            return _LeagueCard(league: league, sport: sport);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sport filter bar ────────────────────────────────────────────────────────

class _SportFilterBar extends StatelessWidget {
  const _SportFilterBar({required this.selected, required this.onSelect});
  final LeagueSport? selected;
  final ValueChanged<LeagueSport?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'ALL',
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'FOOTBALL',
            active: selected == LeagueSport.football,
            onTap: () => onSelect(LeagueSport.football),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'BASKETBALL',
            active: selected == LeagueSport.basketball,
            onTap: () => onSelect(LeagueSport.basketball),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          color: active
              ? context.appColors.accent
              : context.appColors.surface2,
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

// ─── League card ─────────────────────────────────────────────────────────────

class _LeagueCard extends StatefulWidget {
  const _LeagueCard({required this.league, required this.sport});
  final LeagueItem league;
  final LeagueSport sport;

  @override
  State<_LeagueCard> createState() => _LeagueCardState();
}

class _LeagueCardState extends State<_LeagueCard> {
  // Fallback: a neutral dark surface used before palette resolves
  static const _fallbackBase = Color(0xFF1E2330);

  Color? _base;

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Future<void> _extractPalette() async {
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.league.logo),
        maximumColorCount: 8,
      );
      final picked = generator.darkVibrantColor ??
          generator.vibrantColor ??
          generator.darkMutedColor ??
          generator.dominantColor;
      if (picked != null && mounted) {
        setState(() => _base = picked.color);
      }
    } catch (_) {
      // Keep fallback silently
    }
  }

  Color get _effectiveBase => _base ?? _fallbackBase;

  Color get _effectiveEnd {
    final hsl = HSLColor.fromColor(_effectiveBase);
    return hsl
        .withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leagueDetailPath(widget.sport.apiPath, widget.league.id),
        extra: widget.league,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_effectiveBase, _effectiveEnd],
          ),
        ),
        child: Stack(
          children: [
            // Ghost logo watermark
            Positioned(
              right: -12,
              bottom: -12,
              child: Opacity(
                opacity: 0.1,
                child: CachedNetworkImage(
                  imageUrl: widget.league.logo,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50, width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: widget.league.logo,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, _, _) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.emoji_events_outlined,
                            color: Colors.white54, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.localizedName(
                        en: widget.league.nameEn, cn: widget.league.nameCn),
                    style: AppTextStyles.display(13, context).copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.league.nameEnShort != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.league.nameEnShort!,
                      style: AppTextStyles.mono(9).copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 9 * 0.1,
                      ),
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
