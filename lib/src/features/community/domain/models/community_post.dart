import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
sealed class CommunityAuthor with _$CommunityAuthor {
  const factory CommunityAuthor({
    required int id,
    required String nickname,
    String? avatarUrl,
    // Present when this author came embedded on a post/comment (sports_forum
    // eager-loads the full user resource there) — null when it hasn't been
    // fetched that way, e.g. a locally-built placeholder.
    String? bio,
    // Only present on the signed-in user's own profile (`/login`, `/me`) —
    // sports_forum doesn't embed `username` on post/comment authors.
    String? username,
    String? createdAt,
    @Default(0) int postsCount,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    bool? isFollowing,
  }) = _CommunityAuthor;

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) => _$CommunityAuthorFromJson(json);
}

@freezed
sealed class CommunityCategory with _$CommunityCategory {
  const factory CommunityCategory({required int id, required String name}) = _CommunityCategory;

  factory CommunityCategory.fromJson(Map<String, dynamic> json) => _$CommunityCategoryFromJson(json);
}

@freezed
sealed class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required int id,
    required String content,
    @Default([]) List<String> images,
    @Default([]) List<CommunityCategory> categories,
    @Default([]) List<String> hashtags,
    required int likesCount,
    required int commentsCount,
    required int viewsCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
    required String createdAt,
    required CommunityAuthor author,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) => _$CommunityPostFromJson(json);
}

@freezed
sealed class CommunityPostListMeta with _$CommunityPostListMeta {
  const factory CommunityPostListMeta({required int currentPage, required int lastPage}) =
      _CommunityPostListMeta;

  factory CommunityPostListMeta.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostListMetaFromJson(json);
}

@freezed
sealed class CommunityPostListResponse with _$CommunityPostListResponse {
  const factory CommunityPostListResponse({
    required List<CommunityPost> list,
    required CommunityPostListMeta meta,
  }) = _CommunityPostListResponse;

  factory CommunityPostListResponse.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostListResponseFromJson(json);
}

@freezed
sealed class CommunityUserListResponse with _$CommunityUserListResponse {
  const factory CommunityUserListResponse({
    required List<CommunityAuthor> list,
    required CommunityPostListMeta meta,
  }) = _CommunityUserListResponse;

  factory CommunityUserListResponse.fromJson(Map<String, dynamic> json) =>
      _$CommunityUserListResponseFromJson(json);
}
