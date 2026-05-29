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

    final playerAsync = ref.watch(
      footballPlayerDetailProvider(playerId: playerId),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: playerAsync.when(
        loading: () => _PlayerSkeleton(squadPlayer: squadPlayer),
        error: (e, _) => Center(
          child: Text(
            'league.empty'.tr(),
            style: AppTextStyles.body(
              14,
            ).copyWith(color: context.appColors.text2),
          ),
        ),
        data: (player) => _FootballPlayerBody(player: player),
      ),
    );
  }
}

// ─── Position localization ───────────────────────────────────────────────────

/// Translates a position code (e.g. "LW", "GK") to its full localized name.
/// Falls back to the uppercased code if no translation exists.
String _localizedPosition(String code) {
  final key = 'league.player.position.${code.toUpperCase()}';
  final result = key.tr();
  return result == key ? code.toUpperCase() : result;
}

// ─── Data parsing helpers ────────────────────────────────────────────────────

typedef _AbilityEntry = ({int typeId, int rating, int avgScore});
typedef _CharEntry = ({int typeId, int worldRank});

List<String> _secondaryPositions(FootballPlayerDetail p) {
  final raw = p.positionsRaw;
  if (raw == null || raw.length < 2) return const [];
  final second = raw[1];
  if (second is List) return second.whereType<String>().toList();
  return const [];
}

String? _specificMainPosition(FootballPlayerDetail p) {
  final raw = p.positionsRaw;
  if (raw == null || raw.isEmpty) return null;
  final first = raw[0];
  return first is String ? first : null;
}

List<_AbilityEntry> _parseAbility(FootballPlayerDetail p) {
  return (p.abilityRaw ?? [])
      .whereType<List>()
      .where((e) => e.length >= 3)
      .map<_AbilityEntry>(
        (e) => (
          typeId: (e[0] as num).toInt(),
          rating: (e[1] as num).toInt(),
          avgScore: (e[2] as num).toInt(),
        ),
      )
      .toList();
}

List<_CharEntry> _parseCharList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<List>()
      .where((e) => e.length >= 2)
      .map<_CharEntry>(
        (e) =>
            (typeId: (e[0] as num).toInt(), worldRank: (e[1] as num).toInt()),
      )
      .toList();
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

  String? _footLabel() {
    return switch (player.preferredFoot) {
      1 => 'league.player.foot_left'.tr(),
      2 => 'league.player.foot_right'.tr(),
      3 => 'league.player.foot_both'.tr(),
      _ => null,
    };
  }

  bool _hasCareerInfo() =>
      (player.birthday != null && player.birthday! > 0) ||
      (player.marketValue != null && player.marketValue! > 0) ||
      (player.contractUntil != null && player.contractUntil! > 0);

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final gradientEnd = HSLColor.fromColor(accent)
        .withLightness(
          (HSLColor.fromColor(accent).lightness + 0.15).clamp(0, 1),
        )
        .toColor();

    final countryFlagUrl = player.countryDetails?.logo ?? player.nationalLogo;
    final countryName = player.countryDetails?.name != null
        ? context.localizedName(
            en: player.countryDetails!.name,
            cn: player.countryDetails?.cnName,
          )
        : null;

    final specificPos = _specificMainPosition(player);
    final secondaryPos = _secondaryPositions(player);
    final footLabel = _footLabel();
    final abilityEntries = _parseAbility(player);
    final advantages = _parseCharList(
      player.characteristicsRaw?.isNotEmpty == true
          ? player.characteristicsRaw![0]
          : null,
    );
    final disadvantages = _parseCharList(
      (player.characteristicsRaw?.length ?? 0) >= 2
          ? player.characteristicsRaw![1]
          : null,
    );
    final hasChar = advantages.isNotEmpty || disadvantages.isNotEmpty;

    return CustomScrollView(
      slivers: [
        _PlayerHero(
          name: context.localizedName(en: player.name, cn: player.cnName),
          logo: player.logo,
          position: specificPos ?? player.position,
          shirtNumber: null,
          accent: accent,
          gradientEnd: gradientEnd,
          nationalityFlagUrl: countryFlagUrl,
          nationalityName: countryName,
        ),
        SliverToBoxAdapter(
          child: _BioStrip(
            age: player.age,
            height: player.height,
            weight: player.weight,
            extra: footLabel != null
                ? _BioCell(label: 'league.player.foot'.tr(), value: footLabel)
                : null,
          ),
        ),
        if (secondaryPos.isNotEmpty)
          SliverToBoxAdapter(
            child: _SecondaryPositionsStrip(positions: secondaryPos),
          ),
        if (_hasCareerInfo())
          SliverToBoxAdapter(child: _CareerInfoCard(player: player)),
        if (abilityEntries.isNotEmpty)
          SliverToBoxAdapter(
            child: _AbilitySection(entries: abilityEntries, accent: accent),
          ),
        if (hasChar)
          SliverToBoxAdapter(
            child: _CharacteristicsSection(
              advantages: advantages,
              disadvantages: disadvantages,
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
    final shirtNumber = stat?.player?.shirtNumber ?? squadPlayer?.shirtNumber;
    final accent = _accentColor(playerId);
    final gradientEnd = HSLColor.fromColor(accent)
        .withLightness(
          (HSLColor.fromColor(accent).lightness + 0.15).clamp(0, 1),
        )
        .toColor();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _PlayerHero(
            name: name,
            logo: logo,
            position: position,
            shirtNumber: shirtNumber,
            accent: accent,
            gradientEnd: gradientEnd,
            nationalityFlagUrl: squadPlayer?.nationalLogo,
            nationalityName: squadPlayer?.nationality,
          ),
          SliverToBoxAdapter(
            child: _BioStrip(
              age: squadPlayer?.age,
              height: squadPlayer?.height,
              weight: squadPlayer?.weight,
            ),
          ),
          if (stat != null)
            SliverToBoxAdapter(child: _BasketballStatGrid(stat: stat!)),
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
    this.nationalityFlagUrl,
    this.nationalityName,
  });

  final String name;
  final String? logo;
  final String? position;
  final int? shirtNumber;
  final Color accent;
  final Color gradientEnd;
  final String? nationalityFlagUrl;
  final String? nationalityName;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: accent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
        iconSize: 24,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 0.5,
          ),
          shape: const CircleBorder(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsetsDirectional.fromSTEB(56, 0, 16, 14),
        title: Builder(
          builder: (context) {
            final settings = context
                .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
            if (settings == null) return const SizedBox.shrink();
            final t =
                ((settings.maxExtent - settings.currentExtent) /
                        (settings.maxExtent - settings.minExtent))
                    .clamp(0.0, 1.0);
            final opacity = ((t - 0.7) / 0.3).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Text(
                name,
                style: AppTextStyles.display(
                  15,
                  context,
                ).copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, gradientEnd],
                ),
              ),
            ),

            // Ghost flag — large faded nationality flag on the right
            if (nationalityFlagUrl != null && nationalityFlagUrl!.isNotEmpty)
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.05,
                  child: CachedNetworkImage(
                    imageUrl: nationalityFlagUrl!,
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Avatar + name
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: logo != null
                          ? CachedNetworkImage(
                              imageUrl: logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white54,
                                size: 34,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white54,
                              size: 34,
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
                          name,
                          style: AppTextStyles.display(
                            20,
                            context,
                          ).copyWith(color: Colors.white, height: 1.1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (position != null)
                              _HeroChip(label: _localizedPosition(position!)),
                            if (nationalityFlagUrl != null &&
                                nationalityFlagUrl!.isNotEmpty)
                              _NationalityChip(
                                flagUrl: nationalityFlagUrl!,
                                name: nationalityName,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero chips ──────────────────────────────────────────────────────────────

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          9,
        ).copyWith(color: Colors.white, letterSpacing: 9 * 0.1),
      ),
    );
  }
}

class _NationalityChip extends StatelessWidget {
  const _NationalityChip({required this.flagUrl, this.name});
  final String flagUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              imageUrl: flagUrl,
              width: 16,
              height: 11,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(width: 16, height: 11),
            ),
          ),
          if (name != null && name!.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(
              name!,
              style: AppTextStyles.mono(
                9,
              ).copyWith(color: Colors.white, letterSpacing: 9 * 0.1),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Bio Strip ───────────────────────────────────────────────────────────────

class _BioStrip extends StatelessWidget {
  const _BioStrip({
    required this.age,
    required this.height,
    required this.weight,
    this.extra,
  });

  final int? age;
  final int? height;
  final int? weight;
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
      ?extra,
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
              Container(width: 0.5, height: 36, color: context.appColors.line),
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
          style: AppTextStyles.display(
            20,
            context,
          ).copyWith(color: context.appColors.text, height: 1),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.mono(
            9,
          ).copyWith(color: context.appColors.text2, letterSpacing: 9 * 0.1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Secondary Positions Strip ───────────────────────────────────────────────

class _SecondaryPositionsStrip extends StatelessWidget {
  const _SecondaryPositionsStrip({required this.positions});
  final List<String> positions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Text(
            'league.player.secondary_pos'.tr(),
            style: AppTextStyles.mono(
              9,
            ).copyWith(color: context.appColors.text2, letterSpacing: 9 * 0.1),
          ),
          const SizedBox(width: 10),
          Wrap(
            spacing: 6,
            children: positions
                .map(
                  (pos) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: context.appColors.line,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _localizedPosition(pos),
                      style: AppTextStyles.mono(9).copyWith(
                        color: context.appColors.text2,
                        letterSpacing: 9 * 0.1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Career Info Card ────────────────────────────────────────────────────────

class _CareerInfoCard extends StatelessWidget {
  const _CareerInfoCard({required this.player});
  final FootballPlayerDetail player;

  String _formatBirthday(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatMarketValue(int value, String? currency) {
    final sym = (currency != null && currency.isNotEmpty) ? currency : '€';
    if (value >= 1000000) {
      final m = value / 1000000;
      return '$sym${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
    }
    if (value >= 1000) return '$sym${(value / 1000).toStringAsFixed(0)}K';
    return '$sym$value';
  }

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String value})>[
      if ((player.birthday ?? 0) > 0)
        (
          label: 'league.player.born'.tr(),
          value: _formatBirthday(player.birthday!),
        ),
      if ((player.marketValue ?? 0) > 0)
        (
          label: 'league.player.market_val'.tr(),
          value: _formatMarketValue(
            player.marketValue!,
            player.marketValueCurrency,
          ),
        ),
      if ((player.contractUntil ?? 0) > 0)
        (
          label: 'league.player.contract'.tr(),
          value:
              '${DateTime.fromMillisecondsSinceEpoch(player.contractUntil! * 1000).year}',
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'league.player.career_info'.tr()),
          Container(
            decoration: BoxDecoration(
              color: context.appColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: context.appColors.line,
                      indent: 16,
                      endIndent: 16,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          items[i].label,
                          style: AppTextStyles.mono(10).copyWith(
                            color: context.appColors.text2,
                            letterSpacing: 10 * 0.1,
                          ),
                        ),
                        Text(
                          items[i].value,
                          style: AppTextStyles.body(14).copyWith(
                            color: context.appColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ability Section ─────────────────────────────────────────────────────────

class _AbilitySection extends StatelessWidget {
  const _AbilitySection({required this.entries, required this.accent});
  final List<_AbilityEntry> entries;
  final Color accent;

  String _abilityName(int typeId) {
    final key = 'league.player.ability.$typeId';
    final result = key.tr();
    // Fallback: if key not translated, return the key suffix
    return result == key ? typeId.toString() : result;
  }

  @override
  Widget build(BuildContext context) {
    // Sort descending by rating for visual impact
    final sorted = [...entries]..sort((a, b) => b.rating.compareTo(a.rating));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'league.player.ability_section'.tr()),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: context.appColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: sorted.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          _abilityName(e.typeId),
                          style: AppTextStyles.mono(10).copyWith(
                            color: context.appColors.text2,
                            letterSpacing: 10 * 0.08,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: e.rating / 100,
                            minHeight: 6,
                            backgroundColor: context.appColors.line,
                            valueColor: AlwaysStoppedAnimation(accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${e.rating}',
                          style: AppTextStyles.body(13).copyWith(
                            color: context.appColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Characteristics Section ─────────────────────────────────────────────────

class _CharacteristicsSection extends StatelessWidget {
  const _CharacteristicsSection({
    required this.advantages,
    required this.disadvantages,
  });

  final List<_CharEntry> advantages;
  final List<_CharEntry> disadvantages;

  String _charName(int typeId) {
    final key = 'league.player.char.$typeId';
    final result = key.tr();
    return result == key ? typeId.toString() : result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'league.player.char_section'.tr()),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (advantages.isNotEmpty) ...[
                  Text(
                    'league.player.strengths'.tr(),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text2,
                      letterSpacing: 9 * 0.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: advantages
                        .map(
                          (e) => _CharChip(
                            label: _charName(e.typeId),
                            positive: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (advantages.isNotEmpty && disadvantages.isNotEmpty)
                  const SizedBox(height: 14),
                if (disadvantages.isNotEmpty) ...[
                  Text(
                    'league.player.weaknesses'.tr(),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text2,
                      letterSpacing: 9 * 0.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: disadvantages
                        .map(
                          (e) => _CharChip(
                            label: _charName(e.typeId),
                            positive: false,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharChip extends StatelessWidget {
  const _CharChip({required this.label, required this.positive});
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final bg = positive
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);
    final fg = positive ? Colors.green.shade600 : Colors.red.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          9,
        ).copyWith(color: fg, letterSpacing: 9 * 0.08),
      ),
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
      (label: 'league.player.ppg'.tr(), value: '${stat.points}'),
      (label: 'league.player.rpg'.tr(), value: '${stat.rebounds}'),
      (label: 'league.player.apg'.tr(), value: '${stat.assists}'),
      (label: 'STL', value: '${stat.steals}'),
      (label: 'BLK', value: '${stat.blocks}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: 'league.player.season_stats'.tr()),
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
                        style: AppTextStyles.display(
                          18,
                          context,
                        ).copyWith(color: context.appColors.text, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.mono(8).copyWith(
                          color: context.appColors.text2,
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

// ─── Shared section header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: AppTextStyles.mono(11).copyWith(
          color: context.appColors.text,
          letterSpacing: 11 * 0.14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _PlayerSkeleton extends StatelessWidget {
  const _PlayerSkeleton({this.squadPlayer});
  final SquadPlayer? squadPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 260, color: context.appColors.surface2),
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
