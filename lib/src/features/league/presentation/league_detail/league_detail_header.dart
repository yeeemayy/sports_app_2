import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/favourites/data/favourites_repository.dart';
import 'package:shenghaotiyu/src/features/favourites/presentation/providers/favourites_providers.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/league_detail_model.dart';
import 'package:shenghaotiyu/src/features/league/presentation/utils/logo_color.dart';

const _kHeroHeight = 160.0;

// ─── Hero banner ─────────────────────────────────────────────────────────────

class LeagueDetailHeader extends ConsumerStatefulWidget {
  const LeagueDetailHeader({
    super.key,
    required this.detail,
    required this.sport,
    required this.onBack,
  });

  final LeagueDetailModel detail;
  final LeagueSport sport;
  final VoidCallback onBack;

  @override
  ConsumerState<LeagueDetailHeader> createState() => _LeagueDetailHeaderState();
}

class _LeagueDetailHeaderState extends ConsumerState<LeagueDetailHeader>
    with LogoColorMixin<LeagueDetailHeader> {
  static Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Only extract from logo when the API provides no primary color.
    if (_parseHex(widget.detail.primaryColor) == null) {
      extractLogoColor(widget.detail.logo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiC1 = _parseHex(widget.detail.primaryColor);
    final apiC2 = _parseHex(widget.detail.secondaryColor);

    // Prefer API-supplied colors; fall back to palette → seeded → surface.
    final c1 = apiC1 ?? logoColor ?? seededColorFromId(widget.detail.id);
    final c2 = apiC2 ?? lightenColor(c1);
    final onHero = ThemeData.estimateBrightnessForColor(c1) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      height: _kHeroHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c1.withValues(alpha: 0.7), c2.withValues(alpha: 0.3)],
        ),
      ),
      child: Stack(
        children: [
          // Accent blob
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [c2.withValues(alpha: 0.22), Colors.transparent],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.white,
              ),
              iconSize: 24,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                shape: const CircleBorder(),
              ),
            ),
          ),
          // Favourite star button
          if (ref.watch(firebaseUidProvider) case final uid?)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: _LeagueFavButton(
                uid: uid,
                sport: widget.sport.apiPath,
                leagueId: widget.detail.id,
                name: widget.detail.name,
                cnName: widget.detail.cnName,
                logoUrl: widget.detail.logo,
                repo: ref.read(favouritesRepositoryProvider),
              ),
            ),
          // Center content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                CachedNetworkImage(
                  imageUrl: widget.detail.logo,
                  height: 52,
                  placeholder: (_, _) =>
                      Container(color: Colors.white12, width: 52, height: 52),
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      size: 26,
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context
                      .localizedName(
                        en: widget.detail.name,
                        cn: widget.detail.cnName,
                      )
                      .toUpperCase(),
                  style: AppTextStyles.display(
                    22,
                    context,
                  ).copyWith(height: 1, color: onHero),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    if (widget.detail.categoryDetails?.name != null)
                      context
                          .localizedName(
                            en: widget.detail.categoryDetails!.name,
                            cn: widget.detail.categoryDetails!.cnName,
                          )
                          .toUpperCase(),
                    if (widget.detail.currSeasonDetails?.year != null)
                      widget.detail.currSeasonDetails!.year,
                  ].join(' · '),
                  style: AppTextStyles.mono(10).copyWith(
                    color: onHero.withValues(alpha: 0.55),
                    letterSpacing: 10 * 0.14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat strip ───────────────────────────────────────────────────────────────

class LeagueDetailStatStrip extends StatelessWidget {
  const LeagueDetailStatStrip({
    super.key,
    required this.detail,
    required this.sport,
  });

  final LeagueDetailModel detail;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    final stats = switch (sport) {
      LeagueSport.football => [
        ('${detail.roundCount ?? '-'}', 'league.stat.rounds'.tr()),
        ('${detail.goals ?? '-'}', 'league.stat.goals'.tr()),
        ('${detail.totalTeams ?? '-'}', 'league.stat.clubs'.tr()),
        ('${detail.totalPlayers ?? '-'}', 'league.stat.players'.tr()),
      ],
      LeagueSport.basketball => [
        (detail.currSeasonDetails?.year ?? '-', 'league.stat.season'.tr()),
        ('${detail.totalTeams ?? '-'}', 'league.stat.teams'.tr()),
        ('${detail.totalPlayers ?? '-'}', 'league.stat.players'.tr()),
      ],
      _ => [
        (detail.currSeasonDetails?.year ?? '-', 'league.stat.season'.tr()),
        ('${detail.totalTeams ?? '-'}', 'league.stat.teams'.tr()),
      ],
    };

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(
              child: _StatCell(value: stats[i].$1, label: stats[i].$2),
            ),
            if (i < stats.length - 1)
              VerticalDivider(
                thickness: 0.5,
                width: 1,
                color: context.appColors.line,
                indent: 8,
                endIndent: 8,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.display(
              16,
              context,
            ).copyWith(color: context.appColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.mono(
              8,
            ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.12),
          ),
        ],
      ),
    );
  }
}

// ─── League favourite star button ────────────────────────────────────────────

class _LeagueFavButton extends ConsumerWidget {
  const _LeagueFavButton({
    required this.uid,
    required this.sport,
    required this.leagueId,
    required this.name,
    this.cnName,
    this.logoUrl,
    required this.repo,
  });

  final String uid;
  final String sport;
  final String leagueId;
  final String name;
  final String? cnName;
  final String? logoUrl;
  final FavouritesRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavAsync = ref.watch(
      isLeagueFavouritedProvider((uid: uid, sport: sport, leagueId: leagueId)),
    );
    final isFav = isFavAsync.valueOrNull ?? false;

    return IconButton(
      onPressed: () => repo.toggleLeague(
        uid: uid,
        sport: sport,
        leagueId: leagueId,
        name: name,
        cnName: cnName,
        logoUrl: logoUrl,
      ),
      icon: Icon(
        isFav ? Icons.star_rounded : Icons.star_border_rounded,
        color: isFav ? const Color(0xFFFFD60A) : Colors.white,
      ),
      iconSize: 24,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
        shape: const CircleBorder(),
      ),
    );
  }
}
