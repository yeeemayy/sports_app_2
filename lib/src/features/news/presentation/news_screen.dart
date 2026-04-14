import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/features/news/presentation/widgets/news_card.dart';
import 'package:sports_app/src/features/news/presentation/widgets/news_search_bar.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _scrollController = ScrollController();
  String _searchKeyword = '';
  String _currentLocale = '';

  String get _locale =>
      context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentLocale = _locale;
      ref.read(newsPaginatedProvider.notifier).init(_locale);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = _locale;
    if (_currentLocale.isNotEmpty && newLocale != _currentLocale) {
      _currentLocale = newLocale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_searchKeyword.isEmpty) {
          ref.read(newsPaginatedProvider.notifier).init(newLocale);
        } else {
          ref.read(newsSearchProvider.notifier).search(_searchKeyword, newLocale);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (_searchKeyword.isEmpty) {
        ref.read(newsPaginatedProvider.notifier).loadMore();
      } else {
        ref.read(newsSearchProvider.notifier).loadMore();
      }
    }
  }

  void _onSearch(String keyword) {
    if (keyword.isNotEmpty) {
      ref.read(newsSearchProvider.notifier).search(keyword, _locale);
    }
    setState(() => _searchKeyword = keyword);
    if (keyword.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(newsPaginatedProvider.notifier).init(_locale);
      });
    }
  }

  Future<void> _onRefresh() async {
    if (_searchKeyword.isEmpty) {
      await ref.read(newsPaginatedProvider.notifier).refresh();
    } else {
      await ref.read(newsSearchProvider.notifier).search(_searchKeyword, _locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _searchKeyword.isEmpty
        ? ref.watch(newsPaginatedProvider)
        : ref.watch(newsSearchProvider);

    if (state.error != null && state.articles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showErrorDialog(
            title: 'news.load_error'.tr(),
            error: state.error!,
          );
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: NewsSearchBar(onSearch: _onSearch),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NewsPaginatedState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.articles.isEmpty) {
      return Center(
        child: Text(
          'news.no_results'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final article = state.articles[index];
        return NewsCard(
          article: article,
          onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
        );
      },
    );
  }
}
