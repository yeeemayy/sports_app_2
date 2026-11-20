import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/state_widgets.dart';
import 'community_header_bar.dart';
import 'community_list_screen.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';

class CommunityBookmarksScreen extends ConsumerStatefulWidget {
  const CommunityBookmarksScreen({super.key});

  @override
  ConsumerState<CommunityBookmarksScreen> createState() => _CommunityBookmarksScreenState();
}

class _CommunityBookmarksScreenState extends ConsumerState<CommunityBookmarksScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(communityBookmarksProvider(_locale(context)).notifier).loadMore();
    }
  }

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  Widget build(BuildContext context) {
    final locale = _locale(context);
    final state = ref.watch(communityBookmarksProvider(locale));
    final notifier = ref.read(communityBookmarksProvider(locale).notifier);

    Widget body;
    if (state.isLoading) {
      body = const CommunityPostListSkeleton();
    } else if (state.error != null && state.posts.isEmpty) {
      body = const ErrorStateWidget();
    } else if (state.posts.isEmpty) {
      body = const EmptyStateWidget(title: 'community.no_bookmarks');
    } else {
      body = RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
          itemBuilder: (context, i) {
            if (i >= state.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final post = state.posts[i];
            return CommunityPostRow(
              post: post,
              onTap: () => context.push('/community/${post.id}'),
              onLike: () => notifier.toggleLike(post.id),
              onBookmark: () => notifier.removeBookmark(post.id),
              onDeleted: notifier.refresh,
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: communityHeaderBar(context, title: 'community.my_bookmarks'.tr()),
      body: body,
    );
  }
}
