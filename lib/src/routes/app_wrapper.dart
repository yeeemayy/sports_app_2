import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class AppWrapper extends ConsumerWidget {
  const AppWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (labelKey: 'nav.home', icon: Icons.home_outlined, activeIcon: Icons.home, path: AppRoutes.home),
    (labelKey: 'nav.live', icon: Icons.play_circle_outline, activeIcon: Icons.play_circle, path: AppRoutes.anchor),
    (labelKey: 'nav.news', icon: Icons.article_outlined, activeIcon: Icons.article, path: AppRoutes.news),
    (labelKey: 'nav.me', icon: Icons.person_outline, activeIcon: Icons.person, path: AppRoutes.profile),
  ];

  void _onTap(WidgetRef ref, BuildContext context, int index) {
    ref.read(currentNavIndexProvider.notifier).state = index;
    if (index <= 1 && index != navigationShell.currentIndex) {
      ref.invalidate(anchorListProvider);
      if (index == 0) {
        ref.invalidate(newsFirstPageProvider(context.localeCode));
      }
    }
    if (index == 2 && index != navigationShell.currentIndex) {
      ref.read(newsSearchProvider.notifier).refresh();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    context.locale;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: navigationShell,
          ),
          Positioned(
            bottom: 18,
            left: 14,
            right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        blurRadius: 40,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < _tabs.length; i++)
                        if (currentIndex == i)
                          Expanded(
                            child: _ActiveNavItem(
                              label: _tabs[i].labelKey.tr(),
                              icon: _tabs[i].activeIcon,
                              onTap: () => _onTap(ref, context, i),
                            ),
                          )
                        else
                          _InactiveNavItem(
                            icon: _tabs[i].icon,
                            onTap: () => _onTap(ref, context, i),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveNavItem extends StatelessWidget {
  const _ActiveNavItem({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 18),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.display(12, context).copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                letterSpacing: 12 * 0.08,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InactiveNavItem extends StatelessWidget {
  const _InactiveNavItem({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62), size: 18),
      ),
    );
  }
}
