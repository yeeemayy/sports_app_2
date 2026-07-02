import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';

const _kRecommended = 'recommended';
const _kHPad = 22.0;

class EventSportDropdownBar extends StatelessWidget {
  const EventSportDropdownBar({
    super.key,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: _SportChipRow(
        sports: sports,
        selectedFilter: selectedFilter,
        onSelectFilter: onSelectFilter,
      ),
    );
  }
}

class EventStatusBar extends StatelessWidget {
  const EventStatusBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.statuses,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> statuses;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(_kHPad, 6, _kHPad, 6),
        children: statuses.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final active = s == selected;
          return Padding(
            padding: EdgeInsets.only(right: i < statuses.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelected(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: active ? context.appColors.text : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: active
                      ? null
                      : Border.all(color: context.appColors.lineStrong, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    'event.status.$s'.tr().toUpperCase(),
                    style: AppTextStyles.display(12, context).copyWith(
                      color: active ? context.appColors.ink : context.appColors.text2,
                      letterSpacing: 12 * 0.06,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SportChipRow extends StatefulWidget {
  const _SportChipRow({
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  State<_SportChipRow> createState() => _SportChipRowState();
}

class _SportChipRowState extends State<_SportChipRow> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <({String value, IconData icon, String label})>[
      (
        value: _kRecommended,
        icon: Icons.auto_awesome,
        label: 'home.tab.recommended'.tr(),
      ),
      for (final s in widget.sports)
        (value: s.apiPath, icon: s.icon, label: s.i18nKey.tr()),
    ];

    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: _kHPad, vertical: 6),
      itemCount: items.length,
      separatorBuilder: (context, i) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final item = items[i];
        final active = item.value == widget.selectedFilter;
        return GestureDetector(
          onTap: () => widget.onSelectFilter(item.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: active ? context.appColors.text : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: active
                  ? null
                  : Border.all(color: context.appColors.lineStrong, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(
                  item.icon,
                  size: 14,
                  color: active ? context.appColors.ink : context.appColors.text2,
                ),
                Text(
                  item.label.toUpperCase(),
                  style: AppTextStyles.display(12, context).copyWith(
                    color: active ? context.appColors.ink : context.appColors.text2,
                    letterSpacing: 12 * 0.06,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
