import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/football_standings_model.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/standings/standings_shared.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

class FootballStandingsTab extends ConsumerWidget {
  const FootballStandingsTab({
    super.key,
    required this.leagueId,
    required this.onTeamTap,
  });

  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  static const _zoneColors = {
    'ucl': Color(0xFF3B82F6),
    'europa': Color(0xFFFF7A45),
    'relegation': Color(0xFFE63946),
  };

  Color _zoneColor(int pos, int total) {
    if (pos <= 4) return _zoneColors['ucl']!;
    if (pos <= 6) return _zoneColors['europa']!;
    if (total > 0 && pos > total - 3) return _zoneColors['relegation']!;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(footballStandingsProvider(leagueId: leagueId));

    return LeagueTabContent(
      async: async,
      isEmpty: (groups) => groups.isEmpty,
      builder: (groups) => SingleChildScrollView(
        child: Column(
          children: [
            StandingsTableHeader(
              cols: [
                '',
                '#',
                'league.col.club'.tr(),
                'league.col.played'.tr(),
                'league.col.won'.tr(),
                'league.col.draw'.tr(),
                'league.col.gd'.tr(),
                'league.col.pts'.tr(),
              ],
              colWidths: const [14, 22, 0, 24, 24, 24, 32, 32],
            ),
            for (final group in groups)
              for (int i = 0; i < group.rows.length; i++)
                _FootballStandingsRow(
                  row: group.rows[i],
                  zoneColor: _zoneColor(
                    group.rows[i].position,
                    group.rows.length,
                  ),
                  onTap: () => onTeamTap(
                    group.rows[i].teamId,
                    context.localizedName(
                      en: group.rows[i].teamInfo?.name ?? '',
                      cn: group.rows[i].teamInfo?.cnName,
                    ),
                  ),
                ),
            _ZoneLegend(),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _FootballStandingsRow extends StatelessWidget {
  const _FootballStandingsRow({
    required this.row,
    required this.zoneColor,
    required this.onTap,
  });

  final FootballStandingsRow row;
  final Color zoneColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        decoration: BoxDecoration(
          color: zoneColor == const Color(0xFFE63946)
              ? zoneColor.withValues(alpha: 0.04)
              : null,
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Zone indicator
            Container(
              width: 3,
              height: 20,
              margin: const EdgeInsets.only(right: 11),
              decoration: BoxDecoration(
                color: zoneColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Position
            SizedBox(
              width: 22,
              child: Text(
                '${row.position}',
                style: AppTextStyles.mono(
                  11,
                ).copyWith(color: context.appColors.text3),
              ),
            ),
            // Team
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    LeagueTeamAvatar(logoUrl: row.teamInfo?.logo, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.localizedName(
                          en: row.teamInfo?.name ?? '-',
                          cn: row.teamInfo?.cnName,
                        ),
                        style: AppTextStyles.mono(
                          11,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Stats
            _statCell('${row.total}', context),
            _statCell('${row.won}', context),
            _statCell('${row.draw}', context),
            _statCell(
              '${row.goalDiff >= 0 ? '+' : ''}${row.goalDiff}',
              context,
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${row.points}',
                style: AppTextStyles.mono(12).copyWith(
                  color: context.appColors.text,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell(String v, BuildContext context) => SizedBox(
    width: 24,
    child: Text(
      v,
      style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.center,
    ),
  );
}

class _ZoneLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _LegendItem(
            color: const Color(0xFF3B82F6),
            label: 'league.zone.ucl'.tr(),
          ),
          const SizedBox(width: 14),
          _LegendItem(
            color: const Color(0xFFFF7A45),
            label: 'league.zone.europa'.tr(),
          ),
          const SizedBox(width: 14),
          _LegendItem(
            color: const Color(0xFFE63946),
            label: 'league.zone.relegation'.tr(),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.mono(
            8,
          ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
        ),
      ],
    );
  }
}
