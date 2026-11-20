import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/community_auth_guard.dart';
import '../../../extensions/context_extensions.dart';
import '../../../shared_widgets/app_network_image.dart';
import '../../../shared_widgets/custom_status_dialog.dart';
import '../../../shared_widgets/state_widgets.dart';
import '../domain/models/community_post.dart';
import 'community_header_bar.dart';
import 'community_list_screen.dart';
import 'providers/community_auth_providers.dart';
import 'community_report_sheet.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';

/// [seed] is the author object as it was embedded on whichever post/comment
/// was tapped to get here — shown immediately while the real posts list
/// loads. sports_forum has no dedicated `GET /users/{id}` endpoint (its own
/// `user_profile_screen.dart` has the same limitation), so once posts load,
/// the first post's `author` (which carries bio/counts) replaces the seed
/// for anything more authoritative than what's already known.
class CommunityUserProfileScreen extends ConsumerStatefulWidget {
  const CommunityUserProfileScreen({super.key, required this.userId, this.seed});

  final int userId;
  final CommunityAuthor? seed;

  @override
  ConsumerState<CommunityUserProfileScreen> createState() => _CommunityUserProfileScreenState();
}

class _CommunityUserProfileScreenState extends ConsumerState<CommunityUserProfileScreen> {
  final _scrollController = ScrollController();
  bool? _followOverride;
  bool _followBusy = false;

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
      ref.read(communityUserPostsProvider(_key(context)).notifier).loadMore();
    }
  }

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  ({String locale, int userId}) _key(BuildContext context) => (locale: _locale(context), userId: widget.userId);

  void _onFollowTap(bool isFollowing, CommunityAuthor? author) {
    if (!ensureCommunityLoggedIn(context, ref)) return;
    if (!isFollowing) {
      _performToggleFollow();
      return;
    }
    showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.person_remove_outlined,
      overrideIconBackgroundColor: context.appColors.danger,
      title: 'community.unfollow_confirm_title'.tr(namedArgs: {'name': author?.nickname ?? ''}),
      buttonText: 'community.unfollow'.tr(),
      buttonBackgroundColor: context.appColors.danger,
      onButtonPressed: () {
        context.pop();
        _performToggleFollow();
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
      ),
    );
  }

  Future<void> _performToggleFollow() async {
    setState(() => _followBusy = true);
    try {
      final following = await ref.read(communityRepositoryProvider).toggleFollow(widget.userId);
      if (mounted) setState(() => _followOverride = following);
    } catch (e) {
      if (mounted) context.showErrorDialog(title: 'common.error_generic'.tr(), error: e);
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = _key(context);
    final state = ref.watch(communityUserPostsProvider(key));
    final notifier = ref.read(communityUserPostsProvider(key).notifier);
    final author = state.posts.isNotEmpty ? state.posts.first.author : widget.seed;
    final isOwnProfile = ref.watch(communityAuthControllerProvider).valueOrNull?.id == widget.userId;
    final isFollowing = _followOverride ?? author?.isFollowing ?? false;

    List<Widget> postSlivers;
    if (state.isLoading) {
      postSlivers = [const SliverToBoxAdapter(child: CommunityPostListSkeleton())];
    } else if (state.error != null && state.posts.isEmpty) {
      final error = state.error;
      postSlivers = [
        SliverToBoxAdapter(
          child: ErrorStateWidget(
            title: error is ApiClientException && error.response?.statusCode == 404
                ? 'community.user_not_found'.tr()
                : null,
          ),
        ),
      ];
    } else if (state.posts.isEmpty) {
      postSlivers = [
        SliverToBoxAdapter(
          child: EmptyStateWidget(title: isOwnProfile ? 'community.no_posts_mine' : 'community.no_posts_user'),
        ),
      ];
    } else {
      postSlivers = [
        SliverList.separated(
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
        ),
      ];
    }

    return Scaffold(
      appBar: communityHeaderBar(
        context,
        title: author?.nickname ?? '',
        actions: [
          if (!isOwnProfile)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report' && ensureCommunityLoggedIn(context, ref)) {
                  showCommunityReportSheet(context, type: 'user', id: widget.userId);
                }
              },
              itemBuilder: (context) => [PopupMenuItem(value: 'report', child: Text('community.report'.tr()))],
            ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (author != null)
            SliverToBoxAdapter(
              child: _ProfileHeader(
                author: author,
                isOwnProfile: isOwnProfile,
                isFollowing: isFollowing,
                followBusy: _followBusy,
                onFollowTap: () => _onFollowTap(isFollowing, author),
              ),
            ),
          ...postSlivers,
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.author,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.followBusy,
    required this.onFollowTap,
  });

  final CommunityAuthor author;
  final bool isOwnProfile;
  final bool isFollowing;
  final bool followBusy;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          AppNetworkImage(url: author.avatarUrl, size: 72),
          const SizedBox(height: 10),
          Text(author.nickname, style: AppTextStyles.display(18, context).copyWith(color: context.appColors.text, height: 1)),
          if (author.bio != null && author.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              author.bio!,
              style: AppTextStyles.body(12).copyWith(color: context.appColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatColumn(count: author.postsCount, labelKey: 'community.stat_posts'),
              const SizedBox(width: 28),
              _StatColumn(count: author.followersCount, labelKey: 'community.stat_followers'),
              const SizedBox(width: 28),
              _StatColumn(count: author.followingCount, labelKey: 'community.stat_following'),
            ],
          ),
          if (!isOwnProfile) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isFollowing
                  ? OutlinedButton(
                      onPressed: followBusy ? null : onFollowTap,
                      child: Text('community.following'.tr()),
                    )
                  : ElevatedButton(
                      onPressed: followBusy ? null : onFollowTap,
                      child: Text('community.follow'.tr()),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.count, required this.labelKey});

  final int count;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
        Text(labelKey.tr(), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3)),
      ],
    );
  }
}
