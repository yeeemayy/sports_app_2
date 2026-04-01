import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (labelKey: 'nav.home', icon: Icons.home_outlined, activeIcon: Icons.home, path: '/home'),
    (labelKey: 'nav.event', icon: Icons.event_outlined, activeIcon: Icons.event, path: '/event'),
    (labelKey: 'nav.news', icon: Icons.article_outlined, activeIcon: Icons.article, path: '/news'),
    (labelKey: 'nav.data', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, path: '/data'),
    (labelKey: 'nav.profile', icon: Icons.person_outline, activeIcon: Icons.person, path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.labelKey.tr(),
              ),
            )
            .toList(),
      ),
    );
  }
}
