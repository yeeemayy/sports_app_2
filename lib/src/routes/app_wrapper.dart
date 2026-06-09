import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/providers/theme_provider.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/consent_dialog.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  static const _tabs = [
    (labelKey: 'nav.home', icon: Icons.home_outlined, activeIcon: Icons.home, path: AppRoutes.home),
    (
      labelKey: 'nav.live',
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle,
      path: AppRoutes.anchor,
    ),
    (
      labelKey: 'nav.news',
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      path: AppRoutes.news,
    ),
    (
      labelKey: 'nav.league',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      path: AppRoutes.league,
    ),
    (
      labelKey: 'nav.me',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      path: AppRoutes.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prefs = ref.read(sharedPreferencesProvider);
      showConsentDialogIfNeeded(context, prefs);
    });
  }

  void _onTap(int index) {
    ref.read(currentNavIndexProvider.notifier).state = index;
    if (index <= 1 && index != widget.navigationShell.currentIndex) {
      ref.invalidate(anchorListProvider);
      if (index == 0) {
        ref.invalidate(newsFirstPageProvider(context.localeCode));
      }
    }
    // index 2 = news
    if (index == 2 && index != widget.navigationShell.currentIndex) {
      ref.read(newsSearchProvider.notifier).refresh();
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    final currentIndex = widget.navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
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
                child: GNav(
                  selectedIndex: currentIndex,
                  onTabChange: _onTap,
                  gap: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  tabBorderRadius: 999,
                  iconSize: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                  activeColor: Colors.white,
                  tabBackgroundColor: colorScheme.primary,
                  textStyle: AppTextStyles.display(12, context).copyWith(
                    letterSpacing: 12 * 0.08,
                    height: 1.2,
                    color: Colors.white
                  ),
                  tabs: [
                    for (final tab in _tabs)
                      GButton(
                        iconActiveColor: Colors.white,
                        icon: tab.icon,
                        text: tab.labelKey.tr().toUpperCase(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
