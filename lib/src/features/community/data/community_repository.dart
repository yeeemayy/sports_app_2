import 'dart:io';

import 'package:dio/dio.dart';

import '../domain/models/login_response.dart';
import '../domain/models/community_comment.dart';
import '../domain/models/community_hashtag.dart';
import '../domain/models/community_notification.dart';
import '../domain/models/community_post.dart';

/// Talks directly to sports_forum's real API (`EnvConfig.forumApiUrl`) — the
/// app's one auth surface (login/register/profile, see [login]/[register]/
/// [fetchCurrentUser]) and the Community tab's backing API. Every request is
/// authenticated as the real signed-in user via [buildForumApiService]'s
/// interceptor.
///
/// `locale` parameters are kept on the community-specific methods (unused by
/// the forum API, which isn't localized) so their signatures don't have to
/// change again once real localized backing lands.
///
/// Known limitation: [updatePost] can't tell sports_forum which
/// already-uploaded images to keep (it needs their numeric ids, which this
/// app's simplified `CommunityPost.images` doesn't retain — just URLs), so
/// editing a post while attaching a new local image drops any previously
/// uploaded ones instead of merging them.
class CommunityRepository {
  CommunityRepository(this._dio);

  final Dio _dio;

  /// `POST /login` — unlike most of this API, the response isn't wrapped in
  /// a `{data: ...}` envelope.
  Future<LoginResponse> login({required String username, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'username': username, 'password': password},
    );
    final data = response.data!;
    return LoginResponse(
      token: data['token'] as String,
      rcKey: data['rc_key'] as String,
      rcToken: data['rc_token'] as String,
      user: _mapAuthor(data['user'] as Map<String, dynamic>),
    );
  }

  /// `POST /register` — only returns a token (no `user`/`rc_*` fields), so
  /// the caller re-fetches the profile via [fetchCurrentUser] afterward.
  Future<String> register({required String username, required String password, required String name}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/register',
      data: {'username': username, 'password': password, 'password_confirmation': password, 'name': name},
    );
    return response.data!['token'] as String;
  }

  Future<void> logout() => _dio.post<void>('/logout');

  Future<CommunityAuthor> fetchCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/me');
    return _mapAuthor(response.data!['data'] as Map<String, dynamic>);
  }

  Future<CommunityAuthor> updateProfile({String? name, String? bio}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/me',
      data: {if (name != null) 'name': name, if (bio != null) 'bio': bio},
    );
    return _mapAuthor(response.data!['data'] as Map<String, dynamic>);
  }

  Future<CommunityAuthor> uploadAvatar(File file) async {
    final formData = FormData.fromMap({'avatar': await MultipartFile.fromFile(file.path)});
    final response = await _dio.post<Map<String, dynamic>>('/me/avatar', data: formData);
    return _mapAuthor(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _dio.put<void>(
      '/me/password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  Future<void> deleteAccount() => _dio.delete<void>('/account');

  Future<List<CommunityCategory>> fetchCategories(String locale) async {
    final response = await _dio.get<Map<String, dynamic>>('/categories');
    return [
      for (final c in response.data!['data'] as List) _mapCategory(c as Map<String, dynamic>),
    ];
  }

  Future<List<CommunityHashtag>> fetchTrendingHashtags(String locale) async {
    final response = await _dio.get<Map<String, dynamic>>('/hashtags/trending');
    return [
      for (final h in response.data!['data'] as List) _mapHashtag(h as Map<String, dynamic>),
    ];
  }

  Future<CommunityPostListResponse> fetchPostsByHashtag(String locale, String name, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/hashtags/$name/posts',
      queryParameters: {'page': page},
    );
    return _mapListResponse(response.data!);
  }

  Future<CommunityPost> createPost(
    String locale, {
    required String content,
    List<String>? images,
    List<int>? categoryIds,
    List<String>? hashtags,
  }) async {
    final formData = FormData.fromMap({
      'content': content,
      if (categoryIds != null)
        for (var i = 0; i < categoryIds.length; i++) 'category_ids[$i]': categoryIds[i],
      if (hashtags != null)
        for (var i = 0; i < hashtags.length; i++) 'hashtags[$i]': hashtags[i],
      if (images != null)
        for (var i = 0; i < images.length; i++) 'images[$i]': await MultipartFile.fromFile(images[i]),
    });
    final response = await _dio.post<Map<String, dynamic>>('/posts', data: formData);
    return _mapPost(response.data!['data'] as Map<String, dynamic>);
  }

  Future<CommunityPost> updatePost(
    String locale,
    int postId, {
    required String content,
    List<String>? images,
    List<int>? categoryIds,
    List<String>? hashtags,
  }) async {
    final newImages = (images ?? const []).where((p) => !p.startsWith('http')).toList();
    if (newImages.isEmpty) {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/posts/$postId',
        data: {'content': content, 'category_ids': ?categoryIds, 'hashtags': ?hashtags},
      );
      return _mapPost(response.data!['data'] as Map<String, dynamic>);
    }
    final formData = FormData.fromMap({
      'content': content,
      if (categoryIds != null)
        for (var i = 0; i < categoryIds.length; i++) 'category_ids[$i]': categoryIds[i],
      if (hashtags != null)
        for (var i = 0; i < hashtags.length; i++) 'hashtags[$i]': hashtags[i],
      for (var i = 0; i < newImages.length; i++) 'images[$i]': await MultipartFile.fromFile(newImages[i]),
    });
    final response = await _dio.post<Map<String, dynamic>>('/posts/$postId', data: formData);
    return _mapPost(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> deletePost(String locale, int postId) async {
    await _dio.delete('/me/posts/$postId');
  }

  Future<({bool liked, int likesCount})> toggleLike(String locale, int postId) async {
    final response = await _dio.post<Map<String, dynamic>>('/posts/$postId/like');
    final data = response.data!;
    return (liked: data['liked'] as bool, likesCount: data['likes_count'] as int);
  }

  Future<bool> toggleBookmark(String locale, int postId) async {
    final response = await _dio.post<Map<String, dynamic>>('/posts/$postId/bookmark');
    return response.data!['bookmarked'] as bool;
  }

  Future<CommunityPostListResponse> fetchMyBookmarks(String locale, int page) async {
    final response = await _dio.get<Map<String, dynamic>>('/me/bookmarks', queryParameters: {'page': page});
    return _mapListResponse(response.data!);
  }

  Future<CommunityPostListResponse> fetchPostList(String locale, int page, {int? categoryId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {'page': page, 'category_id': ?categoryId},
    );
    return _mapListResponse(response.data!);
  }

  Future<CommunityPostListResponse> searchPosts(String locale, String query, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/posts',
      queryParameters: {'q': query, 'page': page},
    );
    return _mapListResponse(response.data!);
  }

  /// `authorId` is unused — sports_forum's `/me/posts` infers the caller
  /// from the auth token — kept only so this signature (and its provider's
  /// family key) doesn't have to change once real per-user auth lands.
  Future<CommunityPostListResponse> fetchMyPosts(String locale, int authorId, int page) async {
    final response = await _dio.get<Map<String, dynamic>>('/me/posts', queryParameters: {'page': page});
    return _mapListResponse(response.data!);
  }

  Future<CommunityPost> fetchPostDetail(String locale, int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    return _mapPost(response.data!['data'] as Map<String, dynamic>);
  }

  Future<List<CommunityComment>> fetchComments(String locale, int postId) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$postId/comments');
    return [
      for (final c in response.data!['data'] as List) _mapComment(c as Map<String, dynamic>),
    ];
  }

  Future<CommunityComment> createComment(
    String locale,
    int postId, {
    required String content,
    int? parentId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/posts/$postId/comments',
      data: {'content': content, 'parent_id': ?parentId},
    );
    return _mapComment(response.data!['data'] as Map<String, dynamic>);
  }

  Future<({bool liked, int likesCount})> toggleCommentLike(int commentId) async {
    final response = await _dio.post<Map<String, dynamic>>('/comments/$commentId/like');
    final data = response.data!;
    return (liked: data['liked'] as bool, likesCount: data['likes_count'] as int);
  }

  Future<void> deleteComment(int commentId) async {
    await _dio.delete('/me/comments/$commentId');
  }

  /// For @mention autocomplete — only the first page of matches is used.
  Future<List<CommunityAuthor>> searchUsers(String query) async => (await searchUsersPaged(query, 1)).list;

  Future<CommunityUserListResponse> searchUsersPaged(String query, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/users',
      queryParameters: {'q': query, 'page': page},
    );
    return CommunityUserListResponse(
      list: [for (final u in response.data!['data'] as List) _mapAuthor(u as Map<String, dynamic>)],
      meta: _mapMeta(response.data!['meta'] as Map<String, dynamic>),
    );
  }

  /// `type` is one of `post`, `comment`, `user`; `reason` one of `spam`,
  /// `abuse`, `misinformation`, `inappropriate`, `other` (sports_forum's
  /// fixed reason keys).
  Future<void> report({required String type, required int id, required String reason, String? detail}) async {
    await _dio.post<void>(
      '/reports',
      data: {'type': type, 'id': id, 'reason': reason, if (detail != null && detail.isNotEmpty) 'detail': detail},
    );
  }

  Future<bool> toggleFollow(int userId) async {
    final response = await _dio.post<Map<String, dynamic>>('/users/$userId/follow');
    return response.data!['following'] as bool;
  }

  Future<CommunityPostListResponse> fetchUserPosts(String locale, int userId, int page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/$userId/posts',
      queryParameters: {'page': page},
    );
    return _mapListResponse(response.data!);
  }

  Future<CommunityNotificationListResponse> fetchNotifications(int page) async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications', queryParameters: {'page': page});
    return CommunityNotificationListResponse(
      list: [for (final n in response.data!['data'] as List) _mapNotification(n as Map<String, dynamic>)],
      meta: _mapMeta(response.data!['meta'] as Map<String, dynamic>),
    );
  }

  Future<int> fetchUnreadNotificationCount() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return (response.data!['unread_count'] as num).toInt();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.post<void>('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post<void>('/notifications/read-all');
  }
}

CommunityAuthor _mapAuthor(Map<String, dynamic> json) => CommunityAuthor(
      id: json['id'] as int,
      nickname: (json['name'] ?? json['username'] ?? '') as String,
      avatarUrl: (json['avatar_url'] ?? json['avatar']) as String?,
      bio: json['bio'] as String?,
      username: json['username'] as String?,
      createdAt: json['created_at'] as String?,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] as bool?,
    );

CommunityCategory _mapCategory(Map<String, dynamic> json) =>
    CommunityCategory(id: json['id'] as int, name: json['name'] as String);

CommunityHashtag _mapHashtag(Map<String, dynamic> json) => CommunityHashtag(
      name: json['name'] as String,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
    );

CommunityNotification _mapNotification(Map<String, dynamic> json) => CommunityNotification(
      id: '${json['id']}',
      type: json['type'] as String? ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
    );

CommunityPost _mapPost(Map<String, dynamic> json) => CommunityPost(
      id: json['id'] as int,
      content: json['content'] as String,
      images: [
        for (final img in (json['images'] as List? ?? const []))
          (img as Map<String, dynamic>)['url'] as String,
      ],
      categories: [
        for (final c in (json['categories'] as List? ?? const [])) _mapCategory(c as Map<String, dynamic>),
      ],
      hashtags: [
        for (final h in (json['hashtags'] as List? ?? const [])) h as String,
      ],
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      author: _mapAuthor(json['author'] as Map<String, dynamic>),
    );

CommunityComment _mapComment(Map<String, dynamic> json) => CommunityComment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      author: _mapAuthor(json['author'] as Map<String, dynamic>? ?? const {'id': 0}),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      parentId: (json['parent_id'] as num?)?.toInt(),
      replies: [
        for (final r in (json['replies'] as List? ?? const [])) _mapComment(r as Map<String, dynamic>),
      ],
    );

CommunityPostListMeta _mapMeta(Map<String, dynamic> meta) => CommunityPostListMeta(
      currentPage: (meta['current_page'] as num).toInt(),
      lastPage: (meta['last_page'] as num).toInt(),
    );

CommunityPostListResponse _mapListResponse(Map<String, dynamic> json) => CommunityPostListResponse(
      list: [for (final p in json['data'] as List) _mapPost(p as Map<String, dynamic>)],
      meta: _mapMeta(json['meta'] as Map<String, dynamic>),
    );
