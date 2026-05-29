import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/news/data/news_repository.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';

// ---------------------------------------------------------------------------
// Section preview — up to 5 articles for the main screen sections
// (empty keywords = getNewsList; non-empty = searchNews)
// ---------------------------------------------------------------------------

typedef _SectionKey = ({String keywords, String locale});

final newsSectionPreviewProvider = FutureProvider.autoDispose
    .family<List<NewsArticle>, _SectionKey>((ref, key) async {
      if (key.keywords.isEmpty) {
        final response = await ref
            .read(newsRepositoryProvider.notifier)
            .getNewsList(locale: key.locale, page: 1);
        return response.list.take(4).toList();
      } else {
        final response = await ref
            .read(newsRepositoryProvider.notifier)
            .searchNews(
              locale: key.locale,
              keywords: key.keywords,
              page: 1,
              perPage: 6,
            );
        return response.data;
      }
    });

// ---------------------------------------------------------------------------
// Category full paginated — used by NewsCategoryScreen
// Keyed by keyword; empty keyword uses getNewsList.
// ---------------------------------------------------------------------------

class NewsCategoryNotifier extends StateNotifier<NewsPaginatedState> {
  NewsCategoryNotifier(this._ref, this._keyword)
    : super(const NewsPaginatedState());

  final Ref _ref;
  final String _keyword;
  String _locale = 'en';

  Future<void> init(String locale) async {
    _locale = locale;
    await _load(1, replace: true);
  }

  Future<void> refresh() async => _load(1, replace: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _load(state.currentPage + 1, replace: false);
  }

  Future<void> _load(int page, {required bool replace}) async {
    if (replace) state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (_keyword.isEmpty) {
        final res = await _ref
            .read(newsRepositoryProvider.notifier)
            .getNewsList(locale: _locale, page: page);
        final articles = replace ? res.list : [...state.articles, ...res.list];
        state = state.copyWith(
          articles: articles,
          currentPage: res.meta.currentPage,
          lastPage: res.meta.lastPage,
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
        );
      } else {
        final res = await _ref
            .read(newsRepositoryProvider.notifier)
            .searchNews(locale: _locale, keywords: _keyword, page: page);
        final articles = replace ? res.data : [...state.articles, ...res.data];
        state = state.copyWith(
          articles: articles,
          currentPage: res.currentPage,
          lastPage: res.lastPage,
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e);
    }
  }
}

final newsCategoryPaginatedProvider = StateNotifierProvider.autoDispose
    .family<NewsCategoryNotifier, NewsPaginatedState, String>(
      (ref, keyword) => NewsCategoryNotifier(ref, keyword),
    );
