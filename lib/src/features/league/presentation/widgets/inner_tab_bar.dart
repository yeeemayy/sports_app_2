import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

class LeagueInnerTabBar extends StatelessWidget {
  const LeagueInnerTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              _InnerTab(
                label: tabs[i],
                active: i == activeIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _InnerTab extends StatelessWidget {
  const _InnerTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    active ? context.appColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.display(12, context).copyWith(
              color: active
                  ? context.appColors.text
                  : context.appColors.text3,
              letterSpacing: 12 * 0.05,
            ),
          ),
        ),
      ),
    );
  }
}
