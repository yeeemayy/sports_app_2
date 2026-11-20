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

class CommunityHashtagFeedScreen extends ConsumerStatefulWidget {
  const CommunityHashtagFeedScreen({super.key, required this.hashtag});

  final String hashtag;

  @override
  ConsumerState<CommunityHashtagFeedScreen> createState() => _CommunityHashtagFeedScreenState();
}

class _CommunityHashtagFeedScreenState extends ConsumerState<CommunityHashtagFeedScreen> {
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
      ref.read(communityHashtagFeedProvider(_key(context)).notifier).loadMore();
    }
  }

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  ({String locale, String hashtag}) _key(BuildContext context) =>
      (locale: _locale(context), hashtag: widget.hashtag);

  @override
  Widget build(BuildContext context) {
    final key = _key(context);
    final state = ref.watch(communityHashtagFeedProvider(key));
    final notifier = ref.read(communityHashtagFeedProvider(key).notifier);

    Widget body;
    if (state.isLoading) {
      body = const CommunityPostListSkeleton();
    } else if (state.error != null && state.posts.isEmpty) {
      body = const ErrorStateWidget();
    } else if (state.posts.isEmpty) {
      body = const EmptyStateWidget(title: 'community.empty');
    } else {
      body = ListView.separated(
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
            onBookmark: () => notifier.toggleBookmark(post.id),
            onDeleted: notifier.refresh,
          );
        },
      );
    }

    return Scaffold(
      appBar: communityHeaderBar(context, title: '#${widget.hashtag}'),
      body: body,
    );
  }
}
