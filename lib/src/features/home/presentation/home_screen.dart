import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';
import 'home_tab_others.dart';
import 'home_tab_recommended.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.hasValue && (authState.value?.isAuthenticated ?? false);

    print(authState.value?.user);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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
              onPressed: () => context.push('/auth/register'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: Text('auth.register.register'.tr()),
            ),
            SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => context.push('/auth/login'),
              child: Text('auth.login.login'.tr()),
            ),
            SizedBox(width: 10),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
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
                  errorBuilder: (context, url, error) => AvatarFallback(size: 40, iconSize: 20),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: _tabController,
          indicator: BoxDecoration(),
          labelStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: context.textTheme.bodyMedium,
          tabs: [
            Tab(text: 'home.tab.recommended'.tr()),
            Tab(text: 'home.tab.basketball'.tr()),
            Tab(text: 'home.tab.football'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [HomeTabRecommended(), HomeTabOthers(), HomeTabOthers()],
      ),
    );
  }
}
