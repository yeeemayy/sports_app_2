import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
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

class _NewsScreenState extends ConsumerState<NewsScreen> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final TabController _tabController;
  String _searchKeyword = '';
  String _currentLocale = '';
  int _previousTabIndex = 0;

  List<String> get _tabApiKeywords => [
        'news.tab.football'.tr(),
        'news.tab.basketball'.tr(),
        'news.tab.esports'.tr(),
      ];

  String get _locale => context.localeCode;
  String get _activeKeyword => _searchKeyword.isNotEmpty ? _searchKeyword : _tabApiKeywords[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentLocale = _locale;
      ref.read(newsSearchProvider.notifier).search(_activeKeyword, _locale);
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
        ref.read(newsSearchProvider.notifier).search(_activeKeyword, newLocale);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == _previousTabIndex) return;
    _previousTabIndex = _tabController.index;
    _searchController.clear();
    setState(() {
      _searchKeyword = '';
    });
    ref.read(newsSearchProvider.notifier).search(_activeKeyword, _locale);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsSearchProvider.notifier).loadMore();
    }
  }

  void _onSearch(String keyword) {
    setState(() => _searchKeyword = keyword);
    ref.read(newsSearchProvider.notifier).search(_activeKeyword, _locale);
  }

  Future<void> _onRefresh() async {
    await ref.read(newsSearchProvider.notifier).search(_activeKeyword, _locale);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsSearchProvider);

    if (state.error != null && state.articles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showErrorDialog(title: 'news.load_error'.tr(), error: state.error!);
        }
      });
    }

    return SafeArea(
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            controller: _tabController,
            tabs: [
              Tab(text: 'news.tab.football'.tr()),
              Tab(text: 'news.tab.basketball'.tr()),
              Tab(text: 'news.tab.esports'.tr()),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          //   child: NewsSearchBar(onSearch: _onSearch, controller: _searchController),
          // ),
          SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(onRefresh: _onRefresh, child: _buildBody(state)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NewsPaginatedState state) {
    if (state.isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) => const NewsCard.loading(),
      );
    }

    if (state.articles.isEmpty) {
      return Center(
        child: Text('news.no_results'.tr(), style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        print(state.articles.length);
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
