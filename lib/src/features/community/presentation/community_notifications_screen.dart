import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../shared_widgets/app_network_image.dart';
import '../../../shared_widgets/state_widgets.dart';
import '../domain/models/community_notification.dart';
import '../domain/models/community_post.dart';
import 'community_header_bar.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';

String _relativeDate(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  return dt == null ? iso : DateFormatting.relativeLabel(dt);
}

IconData _iconFor(String type) {
  switch (type) {
    case 'post_liked':
    case 'comment_liked':
      return Icons.favorite;
    case 'post_commented':
    case 'comment_replied':
      return Icons.mode_comment;
    case 'user_followed':
      return Icons.person_add;
    case 'user_mentioned':
      return Icons.alternate_email;
    case 'post_bookmarked':
      return Icons.bookmark;
    default:
      return Icons.notifications;
  }
}

Color _colorFor(BuildContext context, String type) {
  switch (type) {
    case 'post_liked':
    case 'comment_liked':
      return context.appColors.danger;
    case 'post_commented':
    case 'comment_replied':
      return context.appColors.text2;
    case 'user_followed':
      return context.appColors.success;
    case 'user_mentioned':
      return context.appColors.accentEcho;
    case 'post_bookmarked':
      return context.appColors.accent;
    default:
      return context.appColors.text2;
  }
}

class CommunityNotificationsScreen extends ConsumerStatefulWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  ConsumerState<CommunityNotificationsScreen> createState() => _CommunityNotificationsScreenState();
}

class _CommunityNotificationsScreenState extends ConsumerState<CommunityNotificationsScreen> {
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
      ref.read(communityNotificationsProvider.notifier).loadMore();
    }
  }

  void _handleTap(CommunityNotification n) {
    ref.read(communityNotificationsProvider.notifier).markRead(n.id);
    ref.invalidate(communityUnreadCountProvider);
    switch (n.dataType) {
      case 'post_liked':
      case 'post_commented':
      case 'user_mentioned':
      case 'post_bookmarked':
      case 'comment_liked':
      case 'comment_replied':
        if (n.postId != null) context.push('/community/${n.postId}');
      case 'user_followed':
        final actorId = n.actorId;
        if (actorId != null) {
          context.push(
            '/community/user/$actorId',
            extra: CommunityAuthor(id: actorId, nickname: n.actorUsername ?? '', avatarUrl: n.actorAvatar),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityNotificationsProvider);

    Widget body;
    if (state.isLoading) {
      body = const CommunityAvatarRowSkeleton();
    } else if (state.error != null && state.items.isEmpty) {
      body = const ErrorStateWidget();
    } else if (state.items.isEmpty) {
      body = const EmptyStateWidget(title: 'community.no_notifications');
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(communityNotificationsProvider.notifier).refresh(),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
          itemBuilder: (context, i) {
            if (i >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final n = state.items[i];
            return _NotificationTile(notification: n, onTap: () => _handleTap(n));
          },
        ),
      );
    }

    return Scaffold(
      appBar: communityHeaderBar(
        context,
        title: 'community.notifications'.tr(),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(communityNotificationsProvider.notifier).markAllRead();
              ref.invalidate(communityUnreadCountProvider);
            },
            child: Text('community.mark_all_read'.tr()),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final CommunityNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isUnread ? context.appColors.accent.withValues(alpha: 0.06) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppNetworkImage(url: notification.actorAvatar, size: 40),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _colorFor(context, notification.dataType),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconFor(notification.dataType), size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'community.notification_${notification.dataType}'.tr(
                        namedArgs: {'name': notification.actorUsername ?? ''},
                      ),
                      style: AppTextStyles.body(14).copyWith(color: context.appColors.text),
                    ),
                    if (notification.preview != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        notification.preview!,
                        style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      _relativeDate(notification.createdAt),
                      style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
              ),
              if (notification.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: context.appColors.danger, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
