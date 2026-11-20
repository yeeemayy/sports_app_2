import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post.dart';

part 'community_comment.freezed.dart';
part 'community_comment.g.dart';

/// One level of nesting only — a top-level comment's `replies` holds direct
/// replies to it (matching sports_forum's own shape), but a reply can't
/// itself be replied to.
@freezed
sealed class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required int id,
    required int postId,
    required String content,
    required String createdAt,
    required CommunityAuthor author,
    @Default(0) int likesCount,
    @Default(false) bool isLiked,
    int? parentId,
    @Default([]) List<CommunityComment> replies,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) => _$CommunityCommentFromJson(json);
}
