import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/squads/squad_list.dart';
import 'package:shenghaotiyu/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

class LeagueSquadsTab extends ConsumerWidget {
  const LeagueSquadsTab({
    super.key,
    required this.sport,
    required this.leagueId,
    required this.selectedTeamId,
    required this.selectedTeamName,
    required this.onTeamSelected,
    required this.onPlayerTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final String? selectedTeamId;
  final String? selectedTeamName;
  final void Function(String id, String name) onTeamSelected;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Derive team list from the already-loaded standings provider so no extra
    // network call is needed.
    final teamsAsync = sport == LeagueSport.football
        ? ref
              .watch(footballStandingsProvider(leagueId: leagueId))
              .whenData(
                (groups) => groups.isEmpty
                    ? <({String id, String name, String logo})>[]
                    : groups.first.rows
                          .take(8)
                          .map(
                            (r) => (
                              id: r.teamId,
                              name: context.localizedName(
                                en: r.teamInfo?.name ?? '-',
                                cn: r.teamInfo?.cnName,
                              ),
                              logo: r.teamInfo?.logo ?? '',
                            ),
                          )
                          .toList(),
              )
        : ref.watch(basketballStandingsProvider(leagueId: leagueId)).whenData((
            conferences,
          ) {
            final allRows = conferences.values
                .expand((c) => c.rows)
                .take(8)
                .toList();
            return allRows
                .map(
                  (r) => (
                    id: r.teamId,
                    name: context.localizedName(
                      en: r.teamInfo?.name ?? '-',
                      cn: r.teamInfo?.cnName,
                    ),
                    logo: r.teamInfo?.logo ?? '',
                  ),
                )
                .toList();
          });

    return LeagueTabContent(
      async: teamsAsync,
      isEmpty: (teams) => teams.isEmpty,
      builder: (teams) {
        // Auto-select first team if none selected yet
        final activeId =
            selectedTeamId ?? (teams.isNotEmpty ? teams.first.id : null);

        if (activeId == null) {
          return Center(
            child: Text(
              'league.empty'.tr(),
              style: AppTextStyles.body(
                14,
              ).copyWith(color: context.appColors.text3),
            ),
          );
        }

        return Column(
          children: [
            // Team selector chips
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(_kPad, 8, _kPad, 8),
                itemCount: teams.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = teams[i];
                  final isActive = t.id == activeId;
                  return GestureDetector(
                    onTap: () => onTeamSelected(t.id, t.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.appColors.surface2
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? context.appColors.accent
                              : context.appColors.lineStrong,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (t.logo.isNotEmpty) ...[
                            LeagueTeamAvatar(
                              logoUrl: t.logo,
                              size: 20,
                              circleFallback: false,
                            ),
                            const SizedBox(width: 7),
                          ],
                          Text(
                            t.name,
                            style: AppTextStyles.mono(
                              11,
                            ).copyWith(color: context.appColors.text),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Squad list
            Expanded(
              child: SquadList(
                sport: sport,
                teamId: activeId,
                onPlayerTap: onPlayerTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
