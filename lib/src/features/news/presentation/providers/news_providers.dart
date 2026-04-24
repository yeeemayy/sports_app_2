import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/news/data/news_repository.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/domain/models/news_detail.dart';

part 'news_providers.g.dart';

// ---------------------------------------------------------------------------
// Shared paginated state
// ---------------------------------------------------------------------------

class NewsPaginatedState {
  const NewsPaginatedState({
    this.articles = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.isLoading = true,
    this.error,
  });

  final List<NewsArticle> articles;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool isLoading;
  final Object? error;

  bool get hasMore => currentPage < lastPage;

  NewsPaginatedState copyWith({
    List<NewsArticle>? articles,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return NewsPaginatedState(
      articles: articles ?? this.articles,
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

  Future<void> _loadPage(int page, {required bool replace, bool silent = false}) async {
    if (replace && !silent) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref
          .read(newsRepositoryProvider.notifier)
          .getNewsList(locale: _locale, page: page);
      final articles = replace ? response.list : [...state.articles, ...response.list];
      state = state.copyWith(
        articles: articles,
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
      final articles = replace ? response.data : [...state.articles, ...response.data];
      state = state.copyWith(
        articles: articles,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e, st) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

// ---------------------------------------------------------------------------
// News first page (for home carousel)
// ---------------------------------------------------------------------------

@riverpod
Future<List<NewsArticle>> newsFirstPage(NewsFirstPageRef ref, String locale) async {
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
  return ref.watch(newsRepositoryProvider.notifier).getNewsDetail(locale: locale, id: id);
}
