import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

class BasketballTeamStatsTab extends ConsumerWidget {
  const BasketballTeamStatsTab({
    super.key,
    required this.leagueId,
    required this.onTeamTap,
  });

  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballTeamStatsProvider(leagueId: leagueId));

    return LeagueTabContent(
      async: async,
      builder: (teams) => Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(_kPad, 7, _kPad, 7),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.appColors.line, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'league.col.team'.tr(),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text3,
                      letterSpacing: 9 * 0.1,
                    ),
                  ),
                ),
                for (final h in [
                  'league.col.fg'.tr(),
                  'league.col.three_p'.tr(),
                  'league.col.reb'.tr(),
                  'league.col.ast'.tr(),
                ])
                  SizedBox(
                    width: 44,
                    child: Text(
                      h,
                      style: AppTextStyles.mono(9).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 9 * 0.1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: teams.length,
              itemBuilder: (context, i) {
                final t = teams[i];
                return GestureDetector(
                  onTap: () => onTeamTap(t.teamId ?? t.team?.id ?? ''),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(_kPad, 12, _kPad, 12),
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
                        Expanded(
                          child: Row(
                            children: [
                              LeagueTeamAvatar(
                                logoUrl: t.team?.logo,
                                size: 26,
                                circleFallback: false,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  context.localizedName(
                                    en: t.team?.name ?? '-',
                                    cn: t.team?.cnName,
                                  ),
                                  style: AppTextStyles.mono(
                                    12,
                                  ).copyWith(color: context.appColors.text),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _btsCell(t.fieldGoalsAccuracy ?? '-', context),
                        _btsCell(t.threePointersAccuracy ?? '-', context),
                        _btsCell('${t.rebounds ?? '-'}', context),
                        _btsCell('${t.assists ?? '-'}', context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _btsCell(String v, BuildContext context) => SizedBox(
    width: 44,
    child: Text(
      v,
      style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.right,
    ),
  );
}
