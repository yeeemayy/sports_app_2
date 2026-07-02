import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/generic_standings_model.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/standings/standings_shared.dart';
import 'package:shenghaotiyu/src/features/league/presentation/providers/league_providers.dart';

class DefaultStandingsTab extends ConsumerWidget {
  const DefaultStandingsTab({
    super.key,
    required this.sport,
    required this.leagueId,
    required this.onTeamTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  bool get _showDraws =>
      sport == LeagueSport.cricket || sport == LeagueSport.baseball;
  bool get _showHockeyOT => sport == LeagueSport.iceHockey;
  bool get _showWinRate => sport == LeagueSport.baseball;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      leagueStandingsProvider(sport: sport, leagueId: leagueId),
    );

    final headers = <String>[
      '#',
      'league.col.team'.tr(),
      'league.col.won'.tr(),
      if (_showDraws) 'league.col.draw'.tr(),
      if (_showHockeyOT) ...[
        'league.col.ot_win'.tr(),
        'league.col.ot_loss'.tr(),
      ],
      'league.col.loss'.tr(),
      _showWinRate ? 'league.col.win_rate'.tr() : 'league.col.pts'.tr(),
    ];

    return LeagueTabContent(
      async: async,
      isEmpty: (groups) => groups.isEmpty,
      builder: (groups) => SingleChildScrollView(
        child: Column(
          children: [
            // Column header row
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.appColors.line, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      headers[0],
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        headers[1],
                        style: AppTextStyles.mono(8).copyWith(
                          color: context.appColors.text3,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  for (final h in headers.skip(2).take(headers.length - 3))
                    SizedBox(
                      width: 32,
                      child: Text(
                        h,
                        style: AppTextStyles.mono(8).copyWith(
                          color: context.appColors.text3,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: _showWinRate ? 60 : 32,
                    child: Text(
                      headers.last,
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            for (final entry
                in (groups.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key)))) ...[
              if (groups.length > 1) ConferenceHeader(name: entry.key),
              for (final row in entry.value.rows)
                _StandingsRow(
                  row: row,
                  showDraws: _showDraws,
                  showHockeyOT: _showHockeyOT,
                  showWinRate: _showWinRate,
                  onTap: () => onTeamTap(
                    row.teamId,
                    context.localizedName(
                      en: row.teamInfo?.name ?? '',
                      cn: row.teamInfo?.cnName,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({
    required this.row,
    required this.showDraws,
    required this.showHockeyOT,
    required this.showWinRate,
    required this.onTap,
  });

  final StandingsRow row;
  final bool showDraws;
  final bool showHockeyOT;
  final bool showWinRate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cells = <String>[
      '${row.wins ?? '-'}',
      if (showDraws) '${row.draws ?? '-'}',
      if (showHockeyOT) ...[
        '${row.overtimeWin ?? '-'}',
        '${row.overtimeLoss ?? '-'}',
      ],
      '${row.losses ?? '-'}',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
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
            // Team logo + name
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
            // W / (D) / (OW) / (OL) / L cells
            for (final v in cells)
              SizedBox(
                width: 32,
                child: Text(
                  v,
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: context.appColors.text2),
                  textAlign: TextAlign.center,
                ),
              ),
            // Points / Win rate — highlighted
            SizedBox(
              width: showWinRate ? 60 : 32,
              child: Text(
                showWinRate
                    ? (row.winRate != null
                          ? row.winRate!.toStringAsFixed(3)
                          : '-')
                    : '${row.points ?? '-'}',
                style: AppTextStyles.mono(12).copyWith(
                  color: context.appColors.text,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
