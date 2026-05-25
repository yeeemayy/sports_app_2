import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_detail.dart';
import 'package:sports_app/src/features/league/domain/models/squad_player.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({
    super.key,
    required this.sport,
    required this.playerId,
    this.squadPlayer,
    this.basketballStat,
  });

  final LeagueSport sport;
  final String playerId;

  /// Passed as extra from squad row — used as fallback when full detail not loaded.
  final SquadPlayer? squadPlayer;

  /// Basketball player stat passed as extra (no dedicated basketball player endpoint).
  final BasketballPlayerStat? basketballStat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.basketball) {
      return _BasketballPlayerDetail(
        playerId: playerId,
        stat: basketballStat,
        squadPlayer: squadPlayer,
      );
    }

    // Football: load full player detail
    final playerAsync =
        ref.watch(footballPlayerDetailProvider(playerId: playerId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: playerAsync.when(
        loading: () => _PlayerSkeleton(squadPlayer: squadPlayer),
        error: (e, _) => Center(
          child: Text('league.empty'.tr(),
              style: AppTextStyles.body(14)
                  .copyWith(color: context.appColors.text3)),
        ),
        data: (player) => _FootballPlayerBody(player: player),
      ),
    );
  }
}

// ─── Football Player Body ────────────────────────────────────────────────────

class _FootballPlayerBody extends StatelessWidget {
  const _FootballPlayerBody({required this.player});
  final FootballPlayerDetail player;

  Color _accentColor() {
    final seed = player.id.codeUnits.fold(0, (a, b) => a ^ b);
    final hue = (seed * 137.5) % 360;
    return HSLColor.fromAHSL(1, hue, 0.6, 0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final gradientEnd = HSLColor.fromColor(accent)
        .withLightness(
            (HSLColor.fromColor(accent).lightness + 0.15).clamp(0, 1))
        .toColor();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _PlayerHero(
            name: context.localizedName(en: player.name, cn: player.cnName),
            logo: player.logo,
            position: player.position,
            shirtNumber: null,
            accent: accent,
            gradientEnd: gradientEnd,
          ),
        ),
        SliverToBoxAdapter(
          child: _BioStrip(
            age: player.age,
            height: player.height,
            weight: player.weight,
            nationality: player.countryDetails?.name,
            nationalLogo: player.countryDetails?.logo,
            extra: player.preferredFoot != null
                ? _BioCell(
                    label: 'FOOT',
                    value: player.preferredFoot == 1 ? 'RIGHT' : 'LEFT')
                : null,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ─── Basketball Player Body ──────────────────────────────────────────────────

class _BasketballPlayerDetail extends StatelessWidget {
  const _BasketballPlayerDetail({
    required this.playerId,
    this.stat,
    this.squadPlayer,
  });

  final String playerId;
  final BasketballPlayerStat? stat;
  final SquadPlayer? squadPlayer;

  Color _accentColor(String id) {
    final seed = id.codeUnits.fold(0, (a, b) => a ^ b);
    final hue = (seed * 137.5) % 360;
    return HSLColor.fromAHSL(1, hue, 0.6, 0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final nameEn = stat?.player?.name ?? squadPlayer?.name ?? '—';
    final nameCn = stat?.player?.cnName ?? squadPlayer?.cnName;
    final name = context.localizedName(en: nameEn, cn: nameCn);
    final logo = stat?.player?.logo ?? squadPlayer?.logo;
    final position = stat?.player?.position ?? squadPlayer?.position;
    final shirtNumber =
        stat?.player?.shirtNumber ?? squadPlayer?.shirtNumber;
    final accent = _accentColor(playerId);
    final gradientEnd = HSLColor.fromColor(accent)
        .withLightness(
            (HSLColor.fromColor(accent).lightness + 0.15).clamp(0, 1))
        .toColor();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _PlayerHero(
              name: name,
              logo: logo,
              position: position,
              shirtNumber: shirtNumber,
              accent: accent,
              gradientEnd: gradientEnd,
            ),
          ),
          SliverToBoxAdapter(
            child: _BioStrip(
              age: squadPlayer?.age,
              height: squadPlayer?.height,
              weight: squadPlayer?.weight,
              nationality: squadPlayer?.nationality,
              nationalLogo: squadPlayer?.nationalLogo,
            ),
          ),
          if (stat != null)
            SliverToBoxAdapter(
              child: _BasketballStatGrid(stat: stat!),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Shared Player Hero ──────────────────────────────────────────────────────

class _PlayerHero extends StatelessWidget {
  const _PlayerHero({
    required this.name,
    required this.logo,
    required this.position,
    required this.shirtNumber,
    required this.accent,
    required this.gradientEnd,
  });

  final String name;
  final String? logo;
  final String? position;
  final int? shirtNumber;
  final Color accent;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, gradientEnd],
        ),
      ),
      child: Stack(
        children: [
          // Ghost shirt number watermark
          if (shirtNumber != null)
            Positioned(
              right: -8,
              bottom: -8,
              child: Text(
                '$shirtNumber',
                style: AppTextStyles.display(130, context).copyWith(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
              ),
            ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.5),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      size: 20, color: Colors.white),
                ),
              ),
            ),
          ),

          // Player info (bottom left)
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1),
                  ),
                  child: ClipOval(
                    child: logo != null
                        ? CachedNetworkImage(
                            imageUrl: logo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white54,
                                size: 34),
                          )
                        : const Icon(Icons.person_outline_rounded,
                            color: Colors.white54, size: 34),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.display(20, context).copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (position != null) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            position!.toUpperCase(),
                            style: AppTextStyles.mono(9).copyWith(
                              color: Colors.white,
                              letterSpacing: 9 * 0.1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bio Strip ──────────────────────────────────────────────────────────────

class _BioStrip extends StatelessWidget {
  const _BioStrip({
    required this.age,
    required this.height,
    required this.weight,
    required this.nationality,
    required this.nationalLogo,
    this.extra,
  });

  final int? age;
  final int? height;
  final int? weight;
  final String? nationality;
  final String? nationalLogo;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[
      _BioCell(
        label: 'league.squad.age'.tr(),
        value: age != null ? '$age' : '--',
      ),
      _BioCell(
        label: 'league.squad.height'.tr(),
        value: height != null ? '${height}cm' : '--',
      ),
      _BioCell(
        label: 'league.squad.weight'.tr(),
        value: weight != null ? '${weight}kg' : '--',
      ),
      if (extra != null) extra!,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(
                width: 0.5,
                height: 36,
                color: context.appColors.line,
              ),
            Expanded(child: cells[i]),
          ],
        ],
      ),
    );
  }
}

class _BioCell extends StatelessWidget {
  const _BioCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.display(20, context)
              .copyWith(color: context.appColors.text, height: 1),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.mono(9)
              .copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Basketball Stat Grid ────────────────────────────────────────────────────

class _BasketballStatGrid extends StatelessWidget {
  const _BasketballStatGrid({required this.stat});
  final BasketballPlayerStat stat;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(label: 'league.player.ppg'.tr(), value: '${stat.points}'),
      _StatItem(label: 'league.player.rpg'.tr(), value: '${stat.rebounds}'),
      _StatItem(label: 'league.player.apg'.tr(), value: '${stat.assists}'),
      _StatItem(label: 'STL', value: '${stat.steals}'),
      _StatItem(label: 'BLK', value: '${stat.blocks}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'league.player.season_stats'.tr(),
              style: AppTextStyles.mono(11).copyWith(
                color: context.appColors.text,
                letterSpacing: 11 * 0.14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: context.appColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.value,
                        style: AppTextStyles.display(18, context)
                            .copyWith(color: context.appColors.text, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.mono(8).copyWith(
                          color: context.appColors.text3,
                          letterSpacing: 8 * 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _PlayerSkeleton extends StatelessWidget {
  const _PlayerSkeleton({this.squadPlayer});
  final SquadPlayer? squadPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 240,
          color: context.appColors.surface2,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: context.appColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
