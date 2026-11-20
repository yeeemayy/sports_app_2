import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/theme/app_theme.dart';

/// Skeletonizer's default `PulseEffect` pulses between two near-white grays
/// (0xFFf4f4f4/0xFFe5e5e5) — invisible against this app's light-mode
/// background (0xFFECEEF1), even though it reads fine on dark backgrounds.
/// Pulsing between [surface2] and a blend toward [text2] instead keeps
/// bones visible in both themes.
PaintingEffect _skeletonEffect(BuildContext context) {
  final colors = context.appColors;
  return PulseEffect(from: colors.surface2, to: Color.lerp(colors.surface2, colors.text2, 0.4)!);
}

/// Shared placeholder shapes for the Community tab's initial-load states —
/// mirrors sports_forum's `skeleton_loaders.dart` (`PostCardSkeleton`,
/// `PostDetailSkeleton`, `UserRowSkeleton`, `TopicRowSkeleton`), reusing this
/// app's `Skeletonizer` + `BoneMock` convention (see `video_list_screen.dart`,
/// `news_list_screen.dart`) instead of porting those types verbatim. Only
/// initial loads use these — "load more" pagination keeps a small spinner.
class CommunityPostListSkeleton extends StatelessWidget {
  const CommunityPostListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: context.appColors.surface2,
      effect: _skeletonEffect(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: count,
        separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: context.appColors.surface, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(BoneMock.name, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                  const Spacer(),
                  Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                ],
              ),
              const SizedBox(height: 8),
              Text(BoneMock.subtitle, style: AppTextStyles.body(14).copyWith(color: context.appColors.text), maxLines: 3),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 16, color: context.appColors.text3),
                  const SizedBox(width: 4),
                  Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                  const SizedBox(width: 16),
                  Icon(Icons.mode_comment_outlined, size: 16, color: context.appColors.text3),
                  const SizedBox(width: 4),
                  Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite_border, size: 16, color: context.appColors.text3),
                  const SizedBox(width: 4),
                  Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single avatar + two text lines row — used for user search results and
/// the notifications feed (sports_forum reuses its `UserRowSkeleton` for
/// notifications too).
class CommunityAvatarRowSkeleton extends StatelessWidget {
  const CommunityAvatarRowSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: context.appColors.surface2,
      effect: _skeletonEffect(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: count,
        separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: context.appColors.surface, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BoneMock.name, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
                    const SizedBox(height: 4),
                    Text(BoneMock.subtitle, style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ranked hashtag row — used by the trending topics screen.
class CommunityTopicRowSkeleton extends StatelessWidget {
  const CommunityTopicRowSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: context.appColors.surface2,
      effect: _skeletonEffect(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: count,
        separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: context.appColors.surface, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(BoneMock.name, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
              const Spacer(),
              Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The comments section's initial load — avatar + author line + a couple of
/// text lines per comment, matching `_CommentTile`'s real layout.
class CommunityCommentListSkeleton extends StatelessWidget {
  const CommunityCommentListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: context.appColors.surface2,
      effect: _skeletonEffect(context),
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: context.appColors.surface, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(BoneMock.name, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                      const SizedBox(height: 4),
                      Text(BoneMock.subtitle, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The post-detail screen's initial load — header row, body text, and a
/// counts row, matching `community_post_detail_screen.dart`'s real layout.
class CommunityPostDetailSkeleton extends StatelessWidget {
  const CommunityPostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: context.appColors.surface2,
      effect: _skeletonEffect(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: context.appColors.surface, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BoneMock.name, style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                    const SizedBox(height: 4),
                    Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(BoneMock.paragraph, style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
            const SizedBox(height: 16),
            Container(height: 180, width: double.infinity, color: context.appColors.surface),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.favorite_border, size: 18, color: context.appColors.text3),
                const SizedBox(width: 6),
                Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
                const SizedBox(width: 20),
                Icon(Icons.mode_comment_outlined, size: 18, color: context.appColors.text3),
                const SizedBox(width: 6),
                Text(BoneMock.words(1), style: AppTextStyles.body(11).copyWith(color: context.appColors.text2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
