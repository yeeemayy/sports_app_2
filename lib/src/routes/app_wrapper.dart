import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> with TickerProviderStateMixin {
  static const _tabs = [
    (labelKey: 'nav.home', icon: Icons.home_outlined, activeIcon: Icons.home, path: AppRoutes.home),
    (
      labelKey: 'nav.event',
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      path: AppRoutes.event,
    ),
    (
      labelKey: 'nav.news',
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      path: AppRoutes.news,
    ),
    // (
    //   labelKey: 'nav.data',
    //   icon: Icons.bar_chart_outlined,
    //   activeIcon: Icons.bar_chart,
    //   path: AppRoutes.data,
    // ),
    (
      labelKey: 'nav.profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      path: AppRoutes.profile,
    ),
  ];

  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _tabs.length,
      initialIndex: widget.navigationShell.currentIndex,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AppWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when go_router changes index externally (e.g. deep link, back).
    final newIndex = widget.navigationShell.currentIndex;
    if (oldWidget.navigationShell.currentIndex != newIndex) {
      _controller.index = newIndex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    ref.read(currentNavIndexProvider.notifier).state = index;
    if (index == 2 && index != widget.navigationShell.currentIndex) {
      final newsState = ref.read(newsPaginatedProvider);
      if (newsState.articles.isNotEmpty) {
        ref.read(newsPaginatedProvider.notifier).silentRefresh();
      }
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when locale changes so .tr() calls update.
    context.locale;
    final currentIndex = widget.navigationShell.currentIndex;
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.hasValue && (authState.value?.isAuthenticated ?? false);

    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(
              centerTitle: false,
              elevation: 0,
              title: Placeholder(child: SizedBox(height: 40, width: 100)),
              actions: [
                if (authState.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(backgroundColor: Colors.white),
                    ),
                  )
                else if (!isAuthenticated) ...[
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('auth.register.register'.tr()),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: Text('auth.login.login'.tr()),
                  ),
                  SizedBox(width: 10),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.profile),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: '${authState.value?.user?.avatarUrl}',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: const ColoredBox(color: Colors.white),
                          ),
                          errorBuilder: (context, url, error) =>
                              AvatarFallback(size: 40, iconSize: 20),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : currentIndex == 3
          ? AppBar(
              centerTitle: true,
              title: Text(_tabs[currentIndex].labelKey.tr()),
            )
          : null,
      body: widget.navigationShell,
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: AppColors.primary,
        controller: _controller,
        initialActiveIndex: currentIndex,
        items: _tabs
            .map((t) => TabItem(icon: t.icon, title: t.labelKey.tr()))
            .toList(),
        onTap: _onTap,
      ),
    );
  }
}
