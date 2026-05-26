import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_standings_model.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/standings/standings_shared.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

class BasketballStandingsTab extends ConsumerWidget {
  const BasketballStandingsTab({
    super.key,
    required this.leagueId,
    required this.onTeamTap,
  });

  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballStandingsProvider(leagueId: leagueId));

    return LeagueTabContent(
      async: async,
      isEmpty: (conferences) => conferences.isEmpty,
      builder: (conferences) => SingleChildScrollView(
        child: Column(
          children: [
            for (final entry in conferences.entries) ...[
              ConferenceHeader(name: entry.key),
              // Col headers
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.appColors.line,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '#',
                        style: AppTextStyles.mono(
                          8,
                        ).copyWith(color: context.appColors.text3),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'league.col.team'.tr(),
                          style: AppTextStyles.mono(8).copyWith(
                            color: context.appColors.text3,
                            letterSpacing: 8 * 0.1,
                          ),
                        ),
                      ),
                    ),
                    for (final h in [
                      'league.col.won'.tr(),
                      'league.col.loss'.tr(),
                      'league.col.win_rate'.tr(),
                      'league.col.game_back'.tr(),
                      'league.col.ppg'.tr(),
                      'league.col.papg'.tr(),
                    ])
                      SizedBox(
                        width: 45,
                        child: Text(
                          h,
                          style: AppTextStyles.mono(8).copyWith(
                            color: context.appColors.text3,
                            letterSpacing: 8 * 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              for (final row in entry.value.rows)
                _BasketballStandingsRow(
                  row: row,
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

class _BasketballStandingsRow extends StatelessWidget {
  const _BasketballStandingsRow({required this.row, required this.onTap});

  final BasketballStandingsRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
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
                '${row.position}',
                style: AppTextStyles.mono(
                  11,
                ).copyWith(color: context.appColors.text3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    LeagueTeamAvatar(logoUrl: row.teamInfo?.logo, size: 20),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        context.localizedName(
                          en: row.teamInfo?.name ?? '-',
                          cn: row.teamInfo?.cnName,
                        ),
                        style: AppTextStyles.mono(
                          11,
                        ).copyWith(color: context.appColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bCell('${row.won}', context),
            _bCell('${row.lost}', context),
            _bCell(
              row.wonRate != null
                  ? (row.wonRate! * 100).toStringAsFixed(1)
                  : '-',
              context,
            ),
            _bCell(row.gameBack ?? '-', context),
            _bCell(
              row.pointsAvg?.toStringAsFixed(1) ?? '-',
              context,
              accent: true,
            ),
            _bCell(row.pointsAgainstAvg?.toStringAsFixed(1) ?? '-', context),
          ],
        ),
      ),
    );
  }

  Widget _bCell(String v, BuildContext context, {bool accent = false}) =>
      SizedBox(
        width: 45,
        child: Text(
          v,
          style: AppTextStyles.mono(11).copyWith(
            color: accent ? context.appColors.accent : context.appColors.text2,
          ),
          textAlign: TextAlign.center,
        ),
      );
}
