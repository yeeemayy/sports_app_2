import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/core/utils/community_auth_guard.dart';
import 'package:shenghaotiyu/src/core/utils/date_formatting.dart';
import 'package:shenghaotiyu/src/shared_widgets/app_network_image.dart';
import 'package:shenghaotiyu/src/shared_widgets/state_widgets.dart';
import 'package:shenghaotiyu/src/features/community/domain/models/community_post.dart';
import 'package:shenghaotiyu/src/features/community/presentation/community_manage_sheet.dart';
import 'package:shenghaotiyu/src/features/community/presentation/community_post_image.dart';
import 'package:shenghaotiyu/src/features/community/presentation/community_skeletons.dart';
import 'package:shenghaotiyu/src/features/community/presentation/providers/community_providers.dart';

String _relativeDate(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  return dt == null ? iso : DateFormatting.relativeLabel(dt);
}

class CommunityListScreen extends ConsumerStatefulWidget {
  const CommunityListScreen({super.key});

  @override
  ConsumerState<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends ConsumerState<CommunityListScreen> {
  final _scrollController = ScrollController();
  int? _categoryId;

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
      ref.read(communityFeedProvider(_feedKey(context)).notifier).loadMore();
    }
  }

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  CommunityFeedKey _feedKey(BuildContext context) =>
      (locale: _locale(context), categoryId: _categoryId);

  @override
  Widget build(BuildContext context) {
    final locale = _locale(context);
    final feedKey = _feedKey(context);
    final state = ref.watch(communityFeedProvider(feedKey));
    final categoriesAsync = ref.watch(communityCategoriesProvider(locale));

    Widget body;
    if (state.isLoading) {
      body = const CommunityPostListSkeleton();
    } else if (state.error != null && state.posts.isEmpty) {
      body = const ErrorStateWidget();
    } else if (state.posts.isEmpty) {
      body = const EmptyStateWidget(title: 'community.empty');
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(communityFeedProvider(feedKey).notifier).refresh(),
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
              onLike: () => ref.read(communityFeedProvider(feedKey).notifier).toggleLike(post.id),
              onBookmark: () =>
                  ref.read(communityFeedProvider(feedKey).notifier).toggleBookmark(post.id),
            );
          },
        ),
      );
    }

    final unreadAsync = ref.watch(communityUnreadCountProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (ensureCommunityLoggedIn(context, ref)) context.push('/community/create');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Header ── big left-aligned title + bordered icon buttons,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'nav.community'.tr().toUpperCase(),
                      style: AppTextStyles.display(
                        46,
                        context,
                      ).copyWith(color: context.appColors.text, height: 1),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    badge: (unreadAsync.valueOrNull ?? 0) > 0,
                    onTap: () {
                      if (ensureCommunityLoggedIn(context, ref))
                        context.push('/community/notifications');
                    },
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    onTap: () => context.push('/community/search'),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'my_posts':
                          if (ensureCommunityLoggedIn(context, ref))
                            context.push('/community/my-posts');
                        case 'bookmarks':
                          if (ensureCommunityLoggedIn(context, ref))
                            context.push('/community/bookmarks');
                        case 'topics':
                          context.push('/community/topics');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'my_posts', child: Text('community.my_posts'.tr())),
                      PopupMenuItem(value: 'bookmarks', child: Text('community.my_bookmarks'.tr())),
                      PopupMenuItem(value: 'topics', child: Text('community.trending_topics'.tr())),
                    ],
                    child: _HeaderIconButton(icon: Icons.more_vert, onTap: null),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const SizedBox(height: 44),
            error: (e, st) => const SizedBox(height: 44),
            data: (categories) => _CategoryRow(
              categories: categories,
              selected: _categoryId,
              onSelect: (id) => setState(() => _categoryId = id),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Bordered square icon button matching the other root tabs' header actions
/// (see e.g. `league_screen.dart`'s search button) — [onTap] is null when
/// this is wrapped by something else that handles the tap (e.g.
/// [PopupMenuButton]'s own `child`).
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap, this.badge = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.lineStrong, width: 0.5),
            ),
            child: Icon(icon, size: 20, color: context.appColors.text),
          ),
          if (badge)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: context.appColors.danger, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories, required this.selected, required this.onSelect});

  final List<CommunityCategory> categories;
  final int? selected;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: categories.length + 1,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final id = i == 0 ? null : categories[i - 1].id;
          final label = i == 0 ? 'community.all_categories'.tr() : categories[i - 1].name;
          final isSelected = id == selected;
          return GestureDetector(
            onTap: () => onSelect(id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? context.appColors.accent : context.appColors.surface,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.body(
                  12,
                ).copyWith(color: isSelected ? Colors.white : context.appColors.text2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CommunityPostRow extends ConsumerWidget {
  const CommunityPostRow({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onBookmark,
    this.onDeleted,
  });

  final CommunityPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(communityCurrentAuthorProvider)?.id;
    final isOwner = myId != null && myId == post.author.id;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      context.push('/community/user/${post.author.id}', extra: post.author),
                  child: AppNetworkImage(url: post.author.avatarUrl, size: 32),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/community/user/${post.author.id}', extra: post.author),
                    child: Text(
                      post.author.nickname,
                      style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  _relativeDate(post.createdAt),
                  style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.more_horiz, size: 18, color: context.appColors.text3),
                  onPressed: () => showCommunityPostManageSheet(
                    context,
                    ref: ref,
                    post: post,
                    isOwner: isOwner,
                    onDeleted: onDeleted ?? () {},
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: AppTextStyles.body(14).copyWith(color: context.appColors.text),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.categories.isNotEmpty || post.hashtags.isNotEmpty) ...[
              const SizedBox(height: 8),
              _TagRow(categories: post.categories, hashtags: post.hashtags),
            ],
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 10),
              _PostImageGrid(images: post.images),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _CountBadge(icon: Icons.visibility_outlined, count: post.viewsCount),
                const SizedBox(width: 16),
                _CountBadge(icon: Icons.mode_comment_outlined, count: post.commentsCount),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    if (ensureCommunityLoggedIn(context, ref)) onLike();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: post.isLiked ? context.appColors.danger : context.appColors.text3,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(
                          color: post.isLiked ? context.appColors.danger : context.appColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (ensureCommunityLoggedIn(context, ref)) onBookmark();
                  },
                  child: Icon(
                    post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: post.isBookmarked ? context.appColors.text : context.appColors.text3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.categories, required this.hashtags});

  final List<CommunityCategory> categories;
  final List<String> hashtags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final c in categories)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: ShapeDecoration(
              color: context.appColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(c.name, style: AppTextStyles.display(11, context).copyWith(color: Colors.white, letterSpacing: 0.4)),
          ),
        for (final tag in hashtags)
          GestureDetector(
            onTap: () => context.push('/community/hashtag/$tag'),
            child: Text(
              '#$tag',
              style: AppTextStyles.body(11)
                  .copyWith(color: context.appColors.text2)
                  .copyWith(color: context.appColors.accent, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _PostImageGrid extends StatelessWidget {
  const _PostImageGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CommunityPostImage(url: images.first),
      );
    }
    final shown = images.take(3).toList();
    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CommunityPostImage(url: shown[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.appColors.text3),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
        ),
      ],
    );
  }
}
