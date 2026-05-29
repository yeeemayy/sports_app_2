import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

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

  String _label(BuildContext context) {
    if (selectedFilter == _kRecommended) return 'home.tab.recommended'.tr();
    final s = sports.firstWhere(
      (s) => s.apiPath == selectedFilter,
      orElse: () => sports.first,
    );
    return s.i18nKey.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: _kHPad, vertical: 6),
      child: _SportDropdownButton(
        label: _label(context),
        sports: sports,
        selectedFilter: selectedFilter,
        onSelectFilter: onSelectFilter,
      ),
    );
  }
}

class EventSportAndStatusBar extends StatelessWidget {
  const EventSportAndStatusBar({
    super.key,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.selected,
    required this.onSelected,
    required this.statuses,
  });

  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> statuses;

  String _dropdownLabel(BuildContext context) {
    if (selectedFilter == _kRecommended) return 'home.tab.recommended'.tr();
    final s = sports.firstWhere(
      (s) => s.apiPath == selectedFilter,
      orElse: () => sports.first,
    );
    return s.i18nKey.tr();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _kHPad, top: 6, bottom: 6),
            child: _SportDropdownButton(
              label: _dropdownLabel(context),
              sports: sports,
              selectedFilter: selectedFilter,
              onSelectFilter: onSelectFilter,
            ),
          ),
          VerticalDivider(
            thickness: 0.5,
            width: 20,
            color: context.appColors.lineStrong,
            indent: 12,
            endIndent: 12,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(0, 6, _kHPad, 6),
              children: statuses.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final active = s == selected;
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < statuses.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onSelected(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? context.appColors.text
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: active
                            ? null
                            : Border.all(
                                color: context.appColors.lineStrong,
                                width: 0.5,
                              ),
                      ),
                      child: Center(
                        child: Text(
                          'event.status.$s'.tr().toUpperCase(),
                          style: AppTextStyles.display(12, context).copyWith(
                            color: active
                                ? context.appColors.ink
                                : context.appColors.text2,
                            letterSpacing: 12 * 0.06,
                          ),
                        ),
                      ),
                    ),
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

class _SportMenuItem extends StatelessWidget {
  const _SportMenuItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.context,
  });

  final IconData icon;
  final String label;
  final bool active;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final color = active ? context.appColors.accent : context.appColors.text;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.display(
            13,
            context,
          ).copyWith(color: color, letterSpacing: 13 * 0.06),
        ),
      ],
    );
  }
}

class _SportDropdownButton extends StatelessWidget {
  const _SportDropdownButton({
    required this.label,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final String label;
  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelectFilter,
      color: context.appColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.lineStrong, width: 0.5),
      ),
      offset: const Offset(0, 36),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _kRecommended,
          child: _SportMenuItem(
            icon: Icons.auto_awesome,
            label: 'home.tab.recommended'.tr(),
            active: selectedFilter == _kRecommended,
            context: context,
          ),
        ),
        for (final s in sports)
          PopupMenuItem(
            value: s.apiPath,
            child: _SportMenuItem(
              icon: s.icon,
              label: s.i18nKey.tr(),
              active: selectedFilter == s.apiPath,
              context: context,
            ),
          ),
      ],
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selectedFilter == _kRecommended
                ? Icons.auto_awesome
                : sports
                      .firstWhere(
                        (s) => s.apiPath == selectedFilter,
                        orElse: () => sports.first,
                      )
                      .icon,
            size: 16,
            color: context.appColors.text2,
          ),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.display(
              13,
              context,
            ).copyWith(color: context.appColors.text, letterSpacing: 13 * 0.06),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: context.appColors.text2,
          ),
        ],
      ),
    );
  }
}
