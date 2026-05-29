import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/league_detail_model.dart';

class LeagueOverviewTab extends StatelessWidget {
  const LeagueOverviewTab({
    super.key,
    required this.detail,
    required this.sport,
  });

  final LeagueDetailModel detail;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (_, i) => sections[i],
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    return switch (sport) {
      LeagueSport.football => _footballSections(context),
      LeagueSport.basketball => _basketballSections(context),
      _ => _genericSections(context),
    };
  }

  List<Widget> _footballSections(BuildContext context) {
    return [
      _StatSection(
        label: 'league.overview.general'.tr(),
        items: [
          _StatItem(
            value: '${detail.totalTeams ?? '-'}',
            label: 'league.stat.clubs'.tr(),
            icon: Icons.groups_outlined,
          ),
          _StatItem(
            value: '${detail.totalPlayers ?? '-'}',
            label: 'league.stat.players'.tr(),
            icon: Icons.person_outline,
          ),
          _StatItem(
            value: detail.currSeasonDetails?.year ?? '-',
            label: 'league.stat.season'.tr(),
            icon: Icons.calendar_today_outlined,
          ),
          _StatItem(
            value: '${detail.roundCount ?? '-'}',
            label: 'league.stat.rounds'.tr(),
            icon: Icons.repeat_outlined,
          ),
        ],
      ),
      _StatSection(
        label: 'league.overview.attack'.tr(),
        items: [
          _StatItem(
            value: '${detail.goals ?? '-'}',
            label: 'league.overview.goals'.tr(),
            icon: Icons.sports_soccer_outlined,
          ),
          _StatItem(
            value: '${detail.assists ?? '-'}',
            label: 'league.overview.assists'.tr(),
            icon: Icons.assistant_outlined,
          ),
          _StatItem(
            value: '${detail.shots ?? '-'}',
            label: 'league.overview.shots'.tr(),
            icon: Icons.gps_fixed_outlined,
          ),
        ],
      ),
      _StatSection(
        label: 'league.overview.fouls_section'.tr(),
        items: [
          _StatItem(
            value: '${detail.yellowCards ?? '-'}',
            label: 'league.overview.yellow_cards'.tr(),
            icon: Icons.square_rounded,
            iconColor: const Color(0xFFFFC300),
          ),
          _StatItem(
            value: '${detail.redCards ?? '-'}',
            label: 'league.overview.red_cards'.tr(),
            icon: Icons.square_rounded,
            iconColor: const Color(0xFFE53935),
          ),
          if (detail.yellow2redCards != null)
            _StatItem(
              value: '${detail.yellow2redCards}',
              label: 'league.overview.yellow2red_cards'.tr(),
              icon: Icons.square_rounded,
              iconColor: const Color(0xFFFF6F00),
            ),
          if (detail.fouls != null)
            _StatItem(
              value: '${detail.fouls}',
              label: 'league.overview.fouls'.tr(),
              icon: Icons.warning_amber_outlined,
            ),
        ],
      ),
    ];
  }

  List<Widget> _basketballSections(BuildContext context) {
    return [
      _StatSection(
        label: 'league.overview.general'.tr(),
        items: [
          _StatItem(
            value: '${detail.totalTeams ?? '-'}',
            label: 'league.stat.teams'.tr(),
            icon: Icons.groups_outlined,
          ),
          _StatItem(
            value: '${detail.totalPlayers ?? '-'}',
            label: 'league.stat.players'.tr(),
            icon: Icons.person_outline,
          ),
          _StatItem(
            value: detail.currSeasonDetails?.year ?? '-',
            label: 'league.stat.season'.tr(),
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
      _StatSection(
        label: 'league.overview.season_stats'.tr(),
        items: [
          _StatItem(
            value: '${detail.points ?? '-'}',
            label: 'league.overview.total_points'.tr(),
            icon: Icons.sports_basketball_outlined,
          ),
          _StatItem(
            value: '${detail.rebounds ?? '-'}',
            label: 'league.overview.total_rebounds'.tr(),
            icon: Icons.swap_vert_outlined,
          ),
          _StatItem(
            value: '${detail.assists ?? '-'}',
            label: 'league.overview.total_assists'.tr(),
            icon: Icons.assistant_outlined,
          ),
          _StatItem(
            value: '${detail.blocks ?? '-'}',
            label: 'league.overview.total_blocks'.tr(),
            icon: Icons.block_outlined,
          ),
          if (detail.turnovers != null)
            _StatItem(
              value: '${detail.turnovers}',
              label: 'league.overview.total_turnovers'.tr(),
              icon: Icons.compare_arrows_outlined,
            ),
        ],
      ),
    ];
  }

  List<Widget> _genericSections(BuildContext context) {
    return [
      _StatSection(
        label: 'league.overview.general'.tr(),
        items: [
          _StatItem(
            value: '${detail.totalTeams ?? '-'}',
            label: 'league.stat.teams'.tr(),
            icon: Icons.groups_outlined,
          ),
          _StatItem(
            value: detail.currSeasonDetails?.year ?? '-',
            label: 'league.stat.season'.tr(),
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    ];
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.label, required this.items});

  final String label;
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.mono(10).copyWith(
              color: context.appColors.text3,
              letterSpacing: 10 * 0.16,
            ),
          ),
        ),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: items,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? colors.text3,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.display(18, context).copyWith(
                    color: colors.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.mono(9).copyWith(
                    color: colors.text3,
                    letterSpacing: 9 * 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
