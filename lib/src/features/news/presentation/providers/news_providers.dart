import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/pagination/paginated_state.dart';
import 'package:shenghaotiyu/src/features/news/data/news_repository.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_detail.dart';

part 'news_providers.g.dart';

// ---------------------------------------------------------------------------
// Shared paginated state
// ---------------------------------------------------------------------------

class NewsPaginatedState extends PaginatedState<NewsArticle> {
  const NewsPaginatedState({
    super.items = const [],
    super.currentPage = 0,
    super.lastPage = 1,
    super.isLoadingMore = false,
    super.isLoading = true,
    super.error,
  });

  @override
  NewsPaginatedState copyWith({
    List<NewsArticle>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return NewsPaginatedState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// News list (paginated)
// ---------------------------------------------------------------------------

@riverpod
class NewsPaginated extends _$NewsPaginated {
  String _locale = 'cn';

  @override
  NewsPaginatedState build() {
    return const NewsPaginatedState();
  }

  Future<void> init(String locale) async {
    _locale = locale;
    await _loadPage(1, replace: true);
  }

  Future<void> refresh() async {
    await _loadPage(1, replace: true);
  }

  Future<void> silentRefresh() async {
    await _loadPage(1, replace: true, silent: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> _loadPage(
    int page, {
    required bool replace,
    bool silent = false,
  }) async {
    if (replace && !silent)
      state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref
          .read(newsRepositoryProvider.notifier)
          .getNewsList(locale: _locale, page: page);
      final articles = replace
          ? response.list
          : [...state.items, ...response.list];
      state = state.copyWith(
        items: articles,
        currentPage: response.meta.currentPage,
        lastPage: response.meta.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

// ---------------------------------------------------------------------------
// News keyword search (paginated)
// ---------------------------------------------------------------------------

@riverpod
class NewsSearch extends _$NewsSearch {
  String _locale = 'cn';
  String _keywords = '';

  @override
  NewsPaginatedState build() {
    return const NewsPaginatedState(isLoading: false);
  }

  Future<void> search(String keywords, String locale) async {
    _keywords = keywords;
    _locale = locale;
    await _loadPage(1, replace: true);
  }

  Future<void> refresh() async {
    if (_keywords.isEmpty) return;
    await _loadPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || _keywords.isEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    await _loadPage(state.currentPage + 1, replace: false);
  }

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref
          .read(newsRepositoryProvider.notifier)
          .searchNews(locale: _locale, keywords: _keywords, page: page);
      final articles = replace
          ? response.data
          : [...state.items, ...response.data];
      state = state.copyWith(
        items: articles,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

// ---------------------------------------------------------------------------
// News first page (for home carousel)
// ---------------------------------------------------------------------------

@riverpod
Future<List<NewsArticle>> newsFirstPage(
  NewsFirstPageRef ref,
  String locale,
) async {
  final keyword = locale == 'cn' ? '足球' : 'Football';
  final response = await ref
      .watch(newsRepositoryProvider.notifier)
      .searchNews(locale: locale, keywords: keyword, page: 1, perPage: 10);
  return response.data;
}

// ---------------------------------------------------------------------------
// News detail
// ---------------------------------------------------------------------------

@riverpod
Future<NewsDetail> newsDetail(NewsDetailRef ref, int id, String locale) {
  return ref
      .watch(newsRepositoryProvider.notifier)
      .getNewsDetail(locale: locale, id: id);
}
