import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/community_auth_guard.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../shared_widgets/app_network_image.dart';
import '../../../shared_widgets/state_widgets.dart';
import '../../../extensions/context_extensions.dart';
import 'providers/community_auth_providers.dart';
import '../domain/models/community_comment.dart';
import '../domain/models/community_post.dart';
import 'community_header_bar.dart';
import 'community_manage_sheet.dart';
import 'community_post_image.dart';
import 'community_report_sheet.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';
import '../../../shared_widgets/custom_status_dialog.dart';

String _relativeDate(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  return dt == null ? iso : DateFormatting.relativeLabel(dt);
}

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  const CommunityPostDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends ConsumerState<CommunityPostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  bool _sendingComment = false;
  Timer? _mentionDebounce;
  List<CommunityAuthor> _mentionSuggestions = const [];
  CommunityComment? _replyingTo;

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _mentionDebounce?.cancel();
    super.dispose();
  }

  void _startReply(CommunityComment comment) {
    setState(() => _replyingTo = comment);
    _commentFocusNode.requestFocus();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (!ensureCommunityLoggedIn(context, ref)) return;
    setState(() => _sendingComment = true);
    try {
      await ref
          .read(communityCommentsProvider((locale: _locale(context), postId: widget.id)).notifier)
          .addComment(text, parentId: _replyingTo?.id);
      _commentController.clear();
      if (mounted) setState(() => _replyingTo = null);
    } catch (e) {
      if (mounted) context.showErrorDialog(title: 'common.error_generic'.tr(), error: e);
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  /// Detects an in-progress `@name` token before the cursor (no space
  /// between the `@` and the cursor) and debounce-searches for matching
  /// users, mirroring sports_forum's `comment_input_sheet.dart`.
  void _onCommentChanged(String text) {
    final cursor = _commentController.selection.baseOffset;
    if (cursor < 0) {
      _clearMentionSuggestions();
      return;
    }
    final before = text.substring(0, cursor);
    final at = before.lastIndexOf('@');
    if (at == -1 || before.substring(at).contains(' ')) {
      _clearMentionSuggestions();
      return;
    }
    final query = before.substring(at + 1);
    if (query.isEmpty) {
      _clearMentionSuggestions();
      return;
    }
    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ref.read(communityRepositoryProvider).searchUsers(query);
        if (mounted) setState(() => _mentionSuggestions = results);
      } catch (_) {
        // silently drop — mention autocomplete is a non-critical affordance
      }
    });
  }

  void _clearMentionSuggestions() {
    _mentionDebounce?.cancel();
    if (_mentionSuggestions.isNotEmpty) setState(() => _mentionSuggestions = const []);
  }

  void _insertMention(CommunityAuthor user) {
    final text = _commentController.text;
    final cursor = _commentController.selection.baseOffset;
    final before = cursor < 0 ? text : text.substring(0, cursor);
    final after = cursor < 0 ? '' : text.substring(cursor);
    final at = before.lastIndexOf('@');
    if (at == -1) return;
    final newText = '${before.substring(0, at)}@${user.nickname} $after';
    final newCursor = at + user.nickname.length + 2;
    _commentController.value = TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newCursor));
    setState(() => _mentionSuggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale(context);
    final async = ref.watch(communityPostDetailProvider((locale: locale, id: widget.id)));
    final myId = ref.watch(communityCurrentAuthorProvider)?.id ?? 0;
    final isLoggedIn = ref.watch(isCommunityLoggedInProvider);

    return Scaffold(
      appBar: communityHeaderBar(
        context,
        title: 'community.post_detail_title'.tr(),
        actions: [
          if (async.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => showCommunityPostManageSheet(
                context,
                ref: ref,
                post: async.value!,
                isOwner: async.value!.author.id == myId,
                onDeleted: () {
                  if (mounted) context.pop();
                },
              ),
            ),
        ],
      ),
      body: async.when(
        loading: () => const CommunityPostDetailSkeleton(),
        error: (e, st) => ErrorStateWidget(
          title: e is ApiClientException && e.response?.statusCode == 404
              ? 'community.post_deleted'.tr()
              : null,
        ),
        data: (post) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GestureDetector(
                    onTap: () => context.push('/community/user/${post.author.id}', extra: post.author),
                    child: Row(
                      children: [
                        AppNetworkImage(url: post.author.avatarUrl, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.author.nickname, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                              Text(
                                _relativeDate(post.createdAt),
                                style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(post.content, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
                  if (post.categories.isNotEmpty || post.hashtags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in post.categories)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: context.appColors.accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Text(c.name, style: AppTextStyles.display(11, context).copyWith(color: Colors.white, letterSpacing: 0.4)),
                          ),
                        for (final tag in post.hashtags)
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
                    ),
                  ],
                  for (final url in post.images) ...[
                    const SizedBox(height: 16),
                    ClipRRect(borderRadius: BorderRadius.circular(16), child: CommunityPostImage(url: url)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _CountBadge(icon: Icons.visibility_outlined, count: post.viewsCount),
                      const SizedBox(width: 20),
                      _CountBadge(icon: Icons.mode_comment_outlined, count: post.commentsCount),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          if (ensureCommunityLoggedIn(context, ref)) {
                            ref
                                .read(communityPostDetailProvider((locale: locale, id: widget.id)).notifier)
                                .toggleLike();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: post.isLiked ? context.appColors.danger : context.appColors.text3,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likesCount}',
                              style: AppTextStyles.body(14)
                                  .copyWith(color: context.appColors.text)
                                  .copyWith(color: post.isLiked ? context.appColors.danger : context.appColors.text3),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (ensureCommunityLoggedIn(context, ref)) {
                            ref
                                .read(communityPostDetailProvider((locale: locale, id: widget.id)).notifier)
                                .toggleBookmark();
                          }
                        },
                        child: Icon(
                          post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: post.isBookmarked ? context.appColors.text : context.appColors.text3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: context.appColors.surface2),
                  const SizedBox(height: 12),
                  _CommentsSection(locale: locale, postId: widget.id, myId: myId, onReply: _startReply),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: !isLoggedIn
                  ? _LoginToCommentBar(returnPath: '/community/${widget.id}')
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_mentionSuggestions.isNotEmpty)
                    SizedBox(
                      height: 68,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _mentionSuggestions.length,
                        itemBuilder: (context, i) {
                          final user = _mentionSuggestions[i];
                          return GestureDetector(
                            onTap: () => _insertMention(user),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppNetworkImage(url: user.avatarUrl, size: 32),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.nickname,
                                    style: AppTextStyles.body(11).copyWith(color: context.appColors.text2),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_replyingTo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'community.replying_to'.tr(namedArgs: {'name': _replyingTo!.author.nickname}),
                              style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _replyingTo = null),
                            child: Icon(Icons.close, size: 16, color: context.appColors.text3),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            onChanged: _onCommentChanged,
                            decoration: InputDecoration(
                              hintText: 'community.comment_hint'.tr(),
                              filled: true,
                              fillColor: context.appColors.surface,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _sendingComment
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.send, color: context.appColors.text),
                          onPressed: _sendingComment ? null : _sendComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSection extends ConsumerWidget {
  const _CommentsSection({required this.locale, required this.postId, required this.myId, required this.onReply});

  final String locale;
  final int postId;
  final int myId;
  final ValueChanged<CommunityComment> onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(communityCommentsProvider((locale: locale, postId: postId)));
    return async.when(
      loading: () => const CommunityCommentListSkeleton(),
      error: (e, st) => const SizedBox.shrink(),
      data: (comments) {
        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'community.no_comments'.tr(),
              style: AppTextStyles.body(12).copyWith(color: context.appColors.text2),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final comment in comments)
              _CommentTile(
                comment: comment,
                locale: locale,
                postId: postId,
                myId: myId,
                onReply: onReply,
              ),
          ],
        );
      },
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({
    required this.comment,
    required this.locale,
    required this.postId,
    required this.myId,
    this.onReply,
  });

  final CommunityComment comment;
  final String locale;
  final int postId;
  final int myId;

  /// Null for a rendered reply tile — sports_forum nests only one level, so
  /// a reply itself can't be replied to.
  final ValueChanged<CommunityComment>? onReply;

  void _showManageSheet(BuildContext context, WidgetRef ref) {
    final isMine = comment.author.id == myId;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine)
              ListTile(
                leading: Icon(Icons.delete_outline, color: sheetContext.appColors.danger),
                title: Text(
                  'community.delete'.tr(),
                  style: AppTextStyles.body(14).copyWith(color: sheetContext.appColors.text).copyWith(color: sheetContext.appColors.danger),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmDeleteComment(context, ref);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text('community.report'.tr(), style: AppTextStyles.body(14).copyWith(color: sheetContext.appColors.text)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (ensureCommunityLoggedIn(context, ref)) {
                    showCommunityReportSheet(context, type: 'comment', id: comment.id);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, WidgetRef ref) {
    showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.delete_outline,
      overrideIconBackgroundColor: context.appColors.danger,
      title: 'community.delete_comment_confirm_title'.tr(),
      buttonText: 'community.delete'.tr(),
      buttonBackgroundColor: context.appColors.danger,
      onButtonPressed: () {
        context.pop();
        ref.read(communityCommentsProvider((locale: locale, postId: postId)).notifier).deleteComment(comment.id);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/community/user/${comment.author.id}', extra: comment.author),
                child: AppNetworkImage(url: comment.author.avatarUrl, size: 28),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/community/user/${comment.author.id}', extra: comment.author),
                  child: Text(comment.author.nickname, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                ),
              ),
              Text(
                _relativeDate(comment.createdAt),
                style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showManageSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (ensureCommunityLoggedIn(context, ref)) {
                    ref
                        .read(communityCommentsProvider((locale: locale, postId: postId)).notifier)
                        .toggleLike(comment.id);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: comment.isLiked ? context.appColors.danger : context.appColors.text3,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likesCount}',
                      style: AppTextStyles.body(11)
                          .copyWith(color: context.appColors.text2)
                          .copyWith(color: comment.isLiked ? context.appColors.danger : context.appColors.text3),
                    ),
                  ],
                ),
              ),
              if (onReply != null) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => onReply!(comment),
                  child: Text(
                    'community.reply'.tr(),
                    style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                  ),
                ),
              ],
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  for (final reply in comment.replies)
                    _CommentTile(comment: reply, locale: locale, postId: postId, myId: myId),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginToCommentBar extends StatelessWidget {
  const _LoginToCommentBar({required this.returnPath});

  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.appColors.surface2))),
      child: TextButton.icon(
        onPressed: () => context.push('/community/login?returnPath=${Uri.encodeComponent(returnPath)}'),
        icon: Icon(Icons.lock_outline, size: 16, color: context.appColors.text),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'community.login_to_comment_action'.tr(),
                style: TextStyle(color: context.appColors.text),
              ),
              TextSpan(text: 'community.login_to_comment_suffix'.tr()),
            ],
          ),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          foregroundColor: context.appColors.text2,
        ),
      ),
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
        Icon(icon, size: 18, color: context.appColors.text3),
        const SizedBox(width: 4),
        Text('$count', style: AppTextStyles.body(14).copyWith(color: context.appColors.text).copyWith(color: context.appColors.text3)),
      ],
    );
  }
}
