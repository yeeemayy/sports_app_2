import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/squad_player.dart';
import 'package:sports_app/src/features/league/domain/models/team_detail_model.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({
    super.key,
    required this.sport,
    required this.teamId,
  });

  final LeagueSport sport;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = sport == LeagueSport.football
        ? ref.watch(footballTeamDetailProvider(teamId: teamId))
        : ref.watch(basketballTeamDetailProvider(teamId: teamId));

    final squadAsync = sport == LeagueSport.football
        ? ref.watch(footballSquadProvider(teamId: teamId))
        : ref.watch(basketballSquadProvider(teamId: teamId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: teamAsync.when(
        loading: () => const _TeamDetailSkeleton(),
        error: (e, _) => Center(
          child: Text('league.empty'.tr(),
              style:
                  AppTextStyles.body(14).copyWith(color: context.appColors.text3)),
        ),
        data: (team) => _TeamDetailBody(
          sport: sport,
          team: team,
          squadAsync: squadAsync,
        ),
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────────

class _TeamDetailBody extends StatelessWidget {
  const _TeamDetailBody({
    required this.sport,
    required this.team,
    required this.squadAsync,
  });

  final LeagueSport sport;
  final TeamDetailModel team;
  final AsyncValue<List<SquadPlayer>> squadAsync;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TeamHero(team: team)),
        SliverToBoxAdapter(child: _TeamInfoStrip(team: team, sport: sport)),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: squadAsync.when(
            loading: () => const _SquadSkeleton(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('league.empty'.tr(),
                    style: AppTextStyles.body(14)
                        .copyWith(color: context.appColors.text3)),
              ),
            ),
            data: (squad) => _SquadSection(sport: sport, squad: squad),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────────

class _TeamHero extends StatelessWidget {
  const _TeamHero({required this.team});
  final TeamDetailModel team;

  Color _teamColor() {
    // Generate a seeded color from team id
    final seed = team.id.codeUnits.fold(0, (a, b) => a ^ b);
    final hue = (seed * 137.5) % 360;
    return HSLColor.fromAHSL(1, hue, 0.55, 0.38).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _teamColor();
    final gradientEnd = HSLColor.fromColor(baseColor)
        .withLightness((HSLColor.fromColor(baseColor).lightness + 0.14).clamp(0, 1))
        .toColor();

    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, gradientEnd],
        ),
      ),
      child: Stack(
        children: [
          // Ghost team name watermark
          Positioned(
            right: -20,
            top: 20,
            child: Text(
              (team.shortName ?? context.localizedName(en: team.name, cn: team.cnName)).toUpperCase(),
              style: AppTextStyles.display(72, context).copyWith(
                color: Colors.white.withValues(alpha: 0.07),
                height: 1,
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
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
                ],
              ),
            ),
          ),

          // Logo + name
          Positioned(
            left: 22,
            right: 22,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: team.logo ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.sports_soccer_rounded,
                          color: Colors.white54,
                          size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.localizedName(en: team.name, cn: team.cnName),
                        style: AppTextStyles.display(22, context).copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      if (team.shortName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          team.shortName!,
                          style: AppTextStyles.mono(10).copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 10 * 0.12,
                          ),
                        ),
                      ],
                      if (team.foundationTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${'league.team.est'.tr()} ${team.foundationTime}',
                          style: AppTextStyles.mono(9).copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
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
        ],
      ),
    );
  }
}

// ─── Info Strip ─────────────────────────────────────────────────────────────

class _TeamInfoStrip extends StatelessWidget {
  const _TeamInfoStrip({required this.team, required this.sport});
  final TeamDetailModel team;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StripCell(
            value: '${team.totalPlayers ?? '--'}',
            label: 'league.team.total_players'.tr(),
          ),
          _divider(context),
          _StripCell(
            value: '${team.foreignPlayers ?? '--'}',
            label: 'league.team.foreign'.tr(),
          ),
          _divider(context),
          _StripCell(
            value: '${team.nationalPlayers ?? '--'}',
            label: 'league.squad.nat'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 0.5,
        height: 36,
        color: context.appColors.line,
      );
}

class _StripCell extends StatelessWidget {
  const _StripCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.display(22, context)
                .copyWith(color: context.appColors.text, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.mono(9).copyWith(
              color: context.appColors.text3,
              letterSpacing: 9 * 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Squad Section ──────────────────────────────────────────────────────────

class _SquadSection extends StatelessWidget {
  const _SquadSection({required this.sport, required this.squad});
  final LeagueSport sport;
  final List<SquadPlayer> squad;

  List<String> get _positionOrder => sport == LeagueSport.football
      ? ['GK', 'DEF', 'MID', 'FWD']
      : ['PG', 'SG', 'SF', 'PF', 'C'];

  String _normalizePosition(String? raw) {
    if (raw == null) return 'FWD';
    final u = raw.toUpperCase();
    if (sport == LeagueSport.football) {
      if (u.contains('G') && (u.contains('K') || u.contains('GOAL'))) return 'GK';
      if (u.contains('D')) return 'DEF';
      if (u.contains('M')) return 'MID';
      return 'FWD';
    } else {
      if (u == 'PG' || u.contains('POINT')) return 'PG';
      if (u == 'SG' || u.contains('SHOOT')) return 'SG';
      if (u == 'SF' || (u.contains('SMALL') && u.contains('F'))) return 'SF';
      if (u == 'PF' || (u.contains('POWER') && u.contains('F'))) return 'PF';
      if (u == 'C' || u.contains('CENTER') || u.contains('CENTRE')) return 'C';
      return 'C';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group by normalized position
    final grouped = <String, List<SquadPlayer>>{};
    for (final p in squad) {
      final pos = _normalizePosition(p.position);
      grouped.putIfAbsent(pos, () => []).add(p);
    }

    final sections = <Widget>[];
    for (final pos in _positionOrder) {
      final players = grouped[pos];
      if (players == null || players.isEmpty) continue;
      sections.add(_PositionHeader(position: pos));
      sections.add(_SquadColumnHeader(sport: sport));
      for (final p in players) {
        sections.add(_PlayerRow(player: p, sport: sport));
      }
    }

    // Ungrouped fallback
    final known = _positionOrder.expand((p) => grouped[p] ?? []).toList();
    final unknown = squad.where((p) => !known.contains(p)).toList();
    if (unknown.isNotEmpty) {
      sections.add(_SquadColumnHeader(sport: sport));
      for (final p in unknown) {
        sections.add(_PlayerRow(player: p, sport: sport));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

class _PositionHeader extends StatelessWidget {
  const _PositionHeader({required this.position});
  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Text(
        position,
        style: AppTextStyles.mono(11).copyWith(
          color: context.appColors.text,
          letterSpacing: 11 * 0.14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SquadColumnHeader extends StatelessWidget {
  const _SquadColumnHeader({required this.sport});
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 6),
      child: Row(
        children: [
          if (sport == LeagueSport.basketball)
            SizedBox(
              width: 28,
              child: Text(
                'league.squad.num'.tr(),
                style: AppTextStyles.mono(9)
                    .copyWith(color: context.appColors.text3),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'league.squad.player'.tr(),
              style:
                  AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'league.squad.nat'.tr(),
              style:
                  AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'league.squad.age'.tr(),
              style:
                  AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              'league.squad.height'.tr(),
              style:
                  AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.sport});
  final SquadPlayer player;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.leaguePlayerPath(sport.apiPath, player.id),
        extra: player,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Shirt number (basketball)
            if (sport == LeagueSport.basketball)
              SizedBox(
                width: 28,
                child: Text(
                  player.shirtNumber != null ? '#${player.shirtNumber}' : '--',
                  style: AppTextStyles.mono(10).copyWith(
                      color: context.appColors.text3),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(width: 8),
            // Avatar
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: player.logo ?? '',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(Icons.person_outline_rounded,
                      size: 18, color: context.appColors.text3),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localizedName(en: player.name, cn: player.cnName),
                    style: AppTextStyles.display(13, context)
                        .copyWith(color: context.appColors.text, height: 1.1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Nationality flag
            SizedBox(
              width: 36,
              child: player.nationalLogo != null
                  ? CachedNetworkImage(
                      imageUrl: player.nationalLogo!,
                      width: 20,
                      height: 14,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
            // Age
            SizedBox(
              width: 36,
              child: Text(
                player.age != null ? '${player.age}' : '--',
                style: AppTextStyles.mono(11)
                    .copyWith(color: context.appColors.text3),
                textAlign: TextAlign.center,
              ),
            ),
            // Height
            SizedBox(
              width: 52,
              child: Text(
                player.height != null ? '${player.height}cm' : '--',
                style: AppTextStyles.mono(11)
                    .copyWith(color: context.appColors.text3),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeletons ──────────────────────────────────────────────────────────────

class _TeamDetailSkeleton extends StatelessWidget {
  const _TeamDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 220,
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

class _SquadSkeleton extends StatelessWidget {
  const _SquadSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        8,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          height: 44,
          decoration: BoxDecoration(
            color: context.appColors.surface2,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
