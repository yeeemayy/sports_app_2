import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/forum_api_service.dart';
import 'community_auth_providers.dart';
import '../../data/community_repository.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_hashtag.dart';
import '../../domain/models/community_notification.dart';
import '../../domain/models/community_post.dart';

export '../../../../core/services/forum_api_service.dart' show communityRepositoryProvider;

final communityCategoriesProvider = FutureProvider.autoDispose.family<List<CommunityCategory>, String>(
  (ref, locale) => ref.watch(communityRepositoryProvider).fetchCategories(locale),
);

final communityHashtagsProvider = FutureProvider.autoDispose.family<List<CommunityHashtag>, String>(
  (ref, locale) => ref.watch(communityRepositoryProvider).fetchTrendingHashtags(locale),
);

/// The real signed-in user — used to gate the edit/delete menu on
/// posts/comments "I" authored. Derived from [communityAuthControllerProvider] (rather
/// than independently re-fetching `/me`) so it's always in sync with
/// login/logout/session-restore instead of caching a stale/errored result
/// from a race with token restoration.
final communityCurrentAuthorProvider = Provider<CommunityAuthor?>((ref) {
  return ref.watch(communityAuthControllerProvider).valueOrNull;
});

// ---------------------------------------------------------------------------
// Paginated community feed for CommunityListScreen, mirroring VideoFeedNotifier
// (plus a category filter and like/delete mutations sports_forum's feed has).
// ---------------------------------------------------------------------------

class CommunityPaginatedState {
  const CommunityPaginatedState({
    this.posts = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  final List<CommunityPost> posts;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  bool get hasMore => currentPage < lastPage;

  CommunityPaginatedState copyWith({
    List<CommunityPost>? posts,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return CommunityPaginatedState(
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

typedef CommunityFeedKey = ({String locale, int? categoryId});

class CommunityFeedNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunityFeedNotifier(this._repo, this._key) : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final CommunityFeedKey _key;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> toggleLike(int postId) async {
    final result = await _repo.toggleLike(_key.locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isLiked: result.liked, likesCount: result.likesCount) else p,
      ],
    );
  }

  Future<void> toggleBookmark(int postId) async {
    final bookmarked = await _repo.toggleBookmark(_key.locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isBookmarked: bookmarked) else p,
      ],
    );
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchPostList(_key.locale, page, categoryId: _key.categoryId);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityFeedProvider =
    StateNotifierProvider.autoDispose.family<CommunityFeedNotifier, CommunityPaginatedState, CommunityFeedKey>(
  (ref, key) => CommunityFeedNotifier(ref.watch(communityRepositoryProvider), key),
);

// ---------------------------------------------------------------------------
// Single post detail — a small mutable notifier (not a plain FutureProvider)
// so like/edit/delete can update the already-loaded post in place, mirroring
// how sports_forum's `PostDetailScreen`/`CommentThreadScreen` keep a local
// mutable copy after actions.
// ---------------------------------------------------------------------------

class CommunityPostDetailNotifier extends StateNotifier<AsyncValue<CommunityPost>> {
  CommunityPostDetailNotifier(this._repo, this._locale, this._postId) : super(const AsyncValue.loading()) {
    _load();
  }

  final CommunityRepository _repo;
  final String _locale;
  final int _postId;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final post = await _repo.fetchPostDetail(_locale, _postId);
      if (!mounted) return;
      state = AsyncValue.data(post);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike() async {
    final result = await _repo.toggleLike(_locale, _postId);
    if (!mounted) return;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(isLiked: result.liked, likesCount: result.likesCount));
    }
  }

  Future<void> toggleBookmark() async {
    final bookmarked = await _repo.toggleBookmark(_locale, _postId);
    if (!mounted) return;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(isBookmarked: bookmarked));
    }
  }
}

final communityPostDetailProvider = StateNotifierProvider.autoDispose
    .family<CommunityPostDetailNotifier, AsyncValue<CommunityPost>, ({String locale, int id})>(
  (ref, q) => CommunityPostDetailNotifier(ref.watch(communityRepositoryProvider), q.locale, q.id),
);

// ---------------------------------------------------------------------------
// Comments — top-level list, each with one level of nested replies.
// ---------------------------------------------------------------------------

class CommunityCommentsNotifier extends StateNotifier<AsyncValue<List<CommunityComment>>> {
  CommunityCommentsNotifier(this._repo, this._locale, this._postId) : super(const AsyncValue.loading()) {
    _load();
  }

  final CommunityRepository _repo;
  final String _locale;
  final int _postId;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _repo.fetchComments(_locale, _postId);
      if (!mounted) return;
      state = AsyncValue.data(comments);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  /// [parentId] set means this is a reply to a top-level comment — it's
  /// appended to that comment's `replies` rather than the top-level list
  /// (sports_forum only nests one level deep, so a reply can't itself take
  /// a `parentId`).
  Future<void> addComment(String content, {int? parentId}) async {
    final comment = await _repo.createComment(_locale, _postId, content: content, parentId: parentId);
    if (!mounted) return;
    final current = state.valueOrNull ?? const [];
    if (parentId == null) {
      state = AsyncValue.data([...current, comment]);
    } else {
      state = AsyncValue.data([
        for (final c in current)
          if (c.id == parentId) c.copyWith(replies: [...c.replies, comment]) else c,
      ]);
    }
  }

  Future<void> toggleLike(int commentId) async {
    final result = await _repo.toggleCommentLike(commentId);
    if (!mounted) return;
    state = AsyncValue.data([for (final c in state.valueOrNull ?? const []) _applyLike(c, commentId, result)]);
  }

  CommunityComment _applyLike(CommunityComment c, int commentId, ({bool liked, int likesCount}) result) {
    if (c.id == commentId) return c.copyWith(isLiked: result.liked, likesCount: result.likesCount);
    if (c.replies.isEmpty) return c;
    return c.copyWith(replies: [for (final r in c.replies) _applyLike(r, commentId, result)]);
  }

  Future<void> deleteComment(int commentId) async {
    await _repo.deleteComment(commentId);
    if (!mounted) return;
    state = AsyncValue.data([
      for (final c in state.valueOrNull ?? const [])
        if (c.id != commentId) c.copyWith(replies: [for (final r in c.replies) if (r.id != commentId) r]),
    ]);
  }
}

final communityCommentsProvider = StateNotifierProvider.autoDispose
    .family<CommunityCommentsNotifier, AsyncValue<List<CommunityComment>>, ({String locale, int postId})>(
  (ref, q) => CommunityCommentsNotifier(ref.watch(communityRepositoryProvider), q.locale, q.postId),
);

// ---------------------------------------------------------------------------
// My posts — filtered by the current user's id, with delete.
// ---------------------------------------------------------------------------

class CommunityMyPostsNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunityMyPostsNotifier(this._repo, this._locale, this._authorId)
      : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _locale;
  final int _authorId;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> deletePost(int postId) async {
    await _repo.deletePost(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(posts: state.posts.where((p) => p.id != postId).toList());
  }

  Future<void> toggleLike(int postId) async {
    final result = await _repo.toggleLike(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isLiked: result.liked, likesCount: result.likesCount) else p,
      ],
    );
  }

  Future<void> toggleBookmark(int postId) async {
    final bookmarked = await _repo.toggleBookmark(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isBookmarked: bookmarked) else p,
      ],
    );
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchMyPosts(_locale, _authorId, page);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityMyPostsProvider =
    StateNotifierProvider.autoDispose.family<CommunityMyPostsNotifier, CommunityPaginatedState, String>(
  // `authorId` is unused by the real `/me/posts` endpoint (the backend
  // infers the caller from the auth token) — see CommunityRepository.fetchMyPosts.
  (ref, locale) => CommunityMyPostsNotifier(ref.watch(communityRepositoryProvider), locale, 0),
);

// ---------------------------------------------------------------------------
// Search — separate from the main feed's pagination since it's keyed by a
// free-text query rather than a category.
// ---------------------------------------------------------------------------

class CommunitySearchNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunitySearchNotifier(this._repo, this._locale, this._query) : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _locale;
  final String _query;

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.searchPosts(_locale, _query, page);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communitySearchProvider = StateNotifierProvider.autoDispose
    .family<CommunitySearchNotifier, CommunityPaginatedState, ({String locale, String query})>(
  (ref, q) => CommunitySearchNotifier(ref.watch(communityRepositoryProvider), q.locale, q.query),
);

// ---------------------------------------------------------------------------
// Another user's posts — for CommunityUserProfileScreen.
// ---------------------------------------------------------------------------

class CommunityUserPostsNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunityUserPostsNotifier(this._repo, this._locale, this._userId) : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _locale;
  final int _userId;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> toggleLike(int postId) async {
    final result = await _repo.toggleLike(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isLiked: result.liked, likesCount: result.likesCount) else p,
      ],
    );
  }

  Future<void> toggleBookmark(int postId) async {
    final bookmarked = await _repo.toggleBookmark(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isBookmarked: bookmarked) else p,
      ],
    );
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchUserPosts(_locale, _userId, page);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityUserPostsProvider = StateNotifierProvider.autoDispose
    .family<CommunityUserPostsNotifier, CommunityPaginatedState, ({String locale, int userId})>(
  (ref, q) => CommunityUserPostsNotifier(ref.watch(communityRepositoryProvider), q.locale, q.userId),
);

// ---------------------------------------------------------------------------
// Posts for one hashtag — CommunityHashtagFeedScreen.
// ---------------------------------------------------------------------------

class CommunityHashtagFeedNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunityHashtagFeedNotifier(this._repo, this._locale, this._hashtag)
      : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _locale;
  final String _hashtag;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> toggleLike(int postId) async {
    final result = await _repo.toggleLike(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isLiked: result.liked, likesCount: result.likesCount) else p,
      ],
    );
  }

  Future<void> toggleBookmark(int postId) async {
    final bookmarked = await _repo.toggleBookmark(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isBookmarked: bookmarked) else p,
      ],
    );
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchPostsByHashtag(_locale, _hashtag, page);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityHashtagFeedProvider = StateNotifierProvider.autoDispose
    .family<CommunityHashtagFeedNotifier, CommunityPaginatedState, ({String locale, String hashtag})>(
  (ref, q) => CommunityHashtagFeedNotifier(ref.watch(communityRepositoryProvider), q.locale, q.hashtag),
);

// ---------------------------------------------------------------------------
// Notifications.
// ---------------------------------------------------------------------------

class CommunityNotificationsState {
  const CommunityNotificationsState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  final List<CommunityNotification> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  bool get hasMore => currentPage < lastPage;

  CommunityNotificationsState copyWith({
    List<CommunityNotification>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return CommunityNotificationsState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommunityNotificationsNotifier extends StateNotifier<CommunityNotificationsState> {
  CommunityNotificationsNotifier(this._repo) : super(const CommunityNotificationsState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> markRead(String id) async {
    await _repo.markNotificationRead(id);
    if (!mounted) return;
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.id == id) n.copyWith(readAt: DateTime.now().toIso8601String()) else n,
      ],
    );
  }

  Future<void> markAllRead() async {
    await _repo.markAllNotificationsRead();
    if (!mounted) return;
    final now = DateTime.now().toIso8601String();
    state = state.copyWith(items: [for (final n in state.items) n.copyWith(readAt: n.readAt ?? now)]);
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchNotifications(page);
      if (!mounted) return;
      state = state.copyWith(
        items: replace ? r.list : [...state.items, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityNotificationsProvider =
    StateNotifierProvider.autoDispose<CommunityNotificationsNotifier, CommunityNotificationsState>(
  (ref) => CommunityNotificationsNotifier(ref.watch(communityRepositoryProvider)),
);

final communityUnreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(communityRepositoryProvider).fetchUnreadNotificationCount(),
);

// ---------------------------------------------------------------------------
// My bookmarks — CommunityBookmarksScreen.
// ---------------------------------------------------------------------------

class CommunityBookmarksNotifier extends StateNotifier<CommunityPaginatedState> {
  CommunityBookmarksNotifier(this._repo, this._locale) : super(const CommunityPaginatedState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _locale;

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> toggleLike(int postId) async {
    final result = await _repo.toggleLike(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(
      posts: [
        for (final p in state.posts)
          if (p.id == postId) p.copyWith(isLiked: result.liked, likesCount: result.likesCount) else p,
      ],
    );
  }

  /// Removes the post from this list once un-bookmarked, since a bookmarks
  /// screen showing a no-longer-bookmarked post would be confusing.
  Future<void> removeBookmark(int postId) async {
    await _repo.toggleBookmark(_locale, postId);
    if (!mounted) return;
    state = state.copyWith(posts: state.posts.where((p) => p.id != postId).toList());
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.fetchMyBookmarks(_locale, page);
      if (!mounted) return;
      state = state.copyWith(
        posts: replace ? r.list : [...state.posts, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityBookmarksProvider =
    StateNotifierProvider.autoDispose.family<CommunityBookmarksNotifier, CommunityPaginatedState, String>(
  (ref, locale) => CommunityBookmarksNotifier(ref.watch(communityRepositoryProvider), locale),
);

// ---------------------------------------------------------------------------
// User search — separate results tab from post search.
// ---------------------------------------------------------------------------

class CommunityUserSearchState {
  const CommunityUserSearchState({
    this.users = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  final List<CommunityAuthor> users;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  bool get hasMore => currentPage < lastPage;

  CommunityUserSearchState copyWith({
    List<CommunityAuthor>? users,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return CommunityUserSearchState(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommunityUserSearchNotifier extends StateNotifier<CommunityUserSearchState> {
  CommunityUserSearchNotifier(this._repo, this._query) : super(const CommunityUserSearchState()) {
    _loadPage(1, replace: true);
  }

  final CommunityRepository _repo;
  final String _query;

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    state = state.copyWith(isLoadingMore: true);
    return _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final r = await _repo.searchUsersPaged(_query, page);
      if (!mounted) return;
      state = state.copyWith(
        users: replace ? r.list : [...state.users, ...r.list],
        currentPage: r.meta.currentPage,
        lastPage: r.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final communityUserSearchProvider =
    StateNotifierProvider.autoDispose.family<CommunityUserSearchNotifier, CommunityUserSearchState, String>(
  (ref, query) => CommunityUserSearchNotifier(ref.watch(communityRepositoryProvider), query),
);
