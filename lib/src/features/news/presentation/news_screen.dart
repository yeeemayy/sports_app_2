import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_section_providers.dart';
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
  final _searchController = TextEditingController();
  String _searchKeyword = '';
  String _currentLocale = '';

  String get _locale => context.localeCode;

  // Locale-aware search keywords for each sport section
  String get _footballKeyword => 'news.tab.football'.tr();
  String get _basketballKeyword => 'news.tab.basketball'.tr();
  String get _esportsKeyword => 'news.tab.esports'.tr();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentLocale = _locale;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = _locale;
    if (_currentLocale.isNotEmpty && newLocale != _currentLocale) {
      _currentLocale = newLocale;
      if (_searchKeyword.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(newsSearchProvider.notifier).search(_searchKeyword, newLocale);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchKeyword.isEmpty) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsSearchProvider.notifier).loadMore();
    }
  }

  void _onSearch(String keyword) {
    setState(() => _searchKeyword = keyword);
    if (keyword.isNotEmpty) {
      ref.read(newsSearchProvider.notifier).search(keyword, _locale);
    }
  }

  Future<void> _onRefresh() async {
    if (_searchKeyword.isNotEmpty) {
      await ref.read(newsSearchProvider.notifier).search(_searchKeyword, _locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: Text(
              'news.header'.tr().toUpperCase(),
              style: AppTextStyles.display(46, context).copyWith(color: colors.text),
            ),
          ),
          const SizedBox(height: 14),
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: NewsSearchBar(onSearch: _onSearch, controller: _searchController),
          ),
          const SizedBox(height: 8),
          // ── Body ──
          Expanded(
            child: _searchKeyword.isNotEmpty ? _buildSearchResults() : _buildSectionsLayout(colors),
          ),
        ],
      ),
    );
  }

  // ── Search results (flat list) ────────────────────────────────────────────

  Widget _buildSearchResults() {
    final state = ref.watch(newsSearchProvider);
    final colors = context.appColors;

    if (state.error != null && state.articles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showErrorDialog(title: 'news.load_error'.tr(), error: state.error!);
        }
      });
    }

    if (state.isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
        itemBuilder: (_, _) => const NewsCard.loading(),
      );
    }

    if (state.articles.isEmpty) {
      return Center(
        child: Text('news.no_results'.tr(), style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return RefreshIndicator(
      color: colors.accent,
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
        itemBuilder: (context, index) {
          if (index == state.articles.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: colors.accent)),
            );
          }
          final article = state.articles[index];
          return NewsCard(
            article: article,
            categoryLabel: _searchKeyword,
            onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
          );
        },
      ),
    );
  }

  // ── Default sections layout ───────────────────────────────────────────────

  Widget _buildSectionsLayout(AppColors colors) {
    final locale = _locale;
    final latestKey = (keywords: '', locale: locale);
    final footballKey = (keywords: _footballKeyword, locale: locale);
    final basketballKey = (keywords: _basketballKeyword, locale: locale);
    final esportsKey = (keywords: _esportsKeyword, locale: locale);

    final latestAsync = ref.watch(newsSectionPreviewProvider(latestKey));
    final footballAsync = ref.watch(newsSectionPreviewProvider(footballKey));
    final basketballAsync = ref.watch(newsSectionPreviewProvider(basketballKey));
    final esportsAsync = ref.watch(newsSectionPreviewProvider(esportsKey));

    final carouselLoading =
        footballAsync.isLoading || basketballAsync.isLoading || esportsAsync.isLoading;
    final carouselArticles = <NewsArticle>[
      ...footballAsync.valueOrNull?.take(2).toList() ?? [],
      ...basketballAsync.valueOrNull?.take(2).toList() ?? [],
      ...esportsAsync.valueOrNull?.take(2).toList() ?? [],
    ];

    return RefreshIndicator(
      color: colors.accent,
      onRefresh: () async {
        ref.invalidate(newsSectionPreviewProvider(latestKey));
        ref.invalidate(newsSectionPreviewProvider(footballKey));
        ref.invalidate(newsSectionPreviewProvider(basketballKey));
        ref.invalidate(newsSectionPreviewProvider(esportsKey));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ── Featured carousel ──
          if (carouselLoading)
            const _FeaturedSkeleton()
          else if (carouselArticles.isNotEmpty)
            _FeaturedCarousel(articles: carouselArticles),
          const SizedBox(height: 6),
          // ── Latest section ──
          _SectionHeader(
            title: 'news.section.latest'.tr(),
            onMore: () => context.push(
              AppRoutes.newsCategoryList,
              extra: (title: 'news.section.latest'.tr(), keyword: ''),
            ),
          ),
          latestAsync.when(
            loading: () => _sectionSkeleton(colors),
            error: (_, _) => const SizedBox.shrink(),
            data: (articles) => _buildSectionArticles(articles.take(4).toList(), colors),
          ),
          const SizedBox(height: 22),
          // ── Football section ──
          _SectionHeader(
            title: 'news.tab.football'.tr(),
            onMore: () => context.push(
              AppRoutes.newsCategoryList,
              extra: (title: 'news.tab.football'.tr(), keyword: _footballKeyword),
            ),
          ),
          _SportSection(
            sectionKey: footballKey,
            sectionLabel: 'news.tab.football'.tr(),
            skipCount: 2,
            colors: colors,
            useGrid: true,
          ),
          const SizedBox(height: 22),
          // ── Basketball section ──
          _SectionHeader(
            title: 'news.tab.basketball'.tr(),
            onMore: () => context.push(
              AppRoutes.newsCategoryList,
              extra: (title: 'news.tab.basketball'.tr(), keyword: _basketballKeyword),
            ),
          ),
          _SportSection(
            sectionKey: basketballKey,
            sectionLabel: 'news.tab.basketball'.tr(),
            skipCount: 2,
            colors: colors,
          ),
          const SizedBox(height: 22),
          // ── E-Sports section ──
          _SectionHeader(
            title: 'news.tab.esports'.tr(),
            onMore: () => context.push(
              AppRoutes.newsCategoryList,
              extra: (title: 'news.tab.esports'.tr(), keyword: _esportsKeyword),
            ),
          ),
          _SportSection(
            sectionKey: esportsKey,
            sectionLabel: 'news.tab.esports'.tr(),
            skipCount: 2,
            colors: colors,
            useGrid: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionArticles(List<NewsArticle> articles, AppColors colors) {
    if (articles.isEmpty) return const SizedBox.shrink();
    return Column(
      children: List.generate(articles.length, (i) {
        return Column(
          children: [
            NewsCard(
              article: articles[i],
              onTap: () => context.push(AppRoutes.newsDetailPath(articles[i].id)),
            ),
            if (i < articles.length - 1)
              Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
          ],
        );
      }),
    );
  }

  Widget _sectionSkeleton(AppColors colors) {
    return Column(
      children: List.generate(4, (i) {
        return Column(
          children: [
            const NewsCard.loading(),
            if (i < 3) Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
          ],
        );
      }),
    );
  }
}

// ── Sport section widget (watches its own provider) ──────────────────────────

class _SportSection extends ConsumerWidget {
  const _SportSection({
    required this.sectionKey,
    required this.sectionLabel,
    required this.colors,
    this.skipCount = 0,
    this.useGrid = false,
  });

  final ({String keywords, String locale}) sectionKey;
  final String sectionLabel;
  final AppColors colors;
  final int skipCount;
  final bool useGrid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(newsSectionPreviewProvider(sectionKey));
    return async.when(
      loading: () => useGrid ? _gridSkeleton() : _listSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (articles) {
        final items = articles.skip(skipCount).take(4).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        if (useGrid) return _buildGrid(context, items);
        return _buildList(context, items);
      },
    );
  }

  Widget _listSkeleton() => Column(
    children: List.generate(
      4,
      (i) => Column(
        children: [
          const NewsCard.loading(),
          if (i < 3) Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
        ],
      ),
    ),
  );

  Widget _gridSkeleton() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
    ),
    itemCount: 4,
    itemBuilder: (context, _) => const NewsCard.loading(grid: true),
  );

  Widget _buildList(BuildContext context, List<NewsArticle> items) => Column(
    children: List.generate(
      items.length,
      (i) => Column(
        children: [
          NewsCard(
            article: items[i],
            categoryLabel: sectionLabel,
            onTap: () => context.push(AppRoutes.newsDetailPath(items[i].id)),
          ),
          if (i < items.length - 1)
            Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
        ],
      ),
    ),
  );

  Widget _buildGrid(BuildContext context, List<NewsArticle> items) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
    ),
    itemCount: items.length,
    itemBuilder: (context, i) => NewsCard(
      grid: true,
      article: items[i],
      categoryLabel: sectionLabel,
      onTap: () => context.push(AppRoutes.newsDetailPath(items[i].id)),
    ),
  );
}

// ── Section header row ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onMore});

  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.display(22, context).copyWith(color: colors.text),
          ),
          GestureDetector(
            onTap: onMore,
            child: Text(
              'news.more'.tr(),
              style: AppTextStyles.mono(10).copyWith(color: colors.text3, letterSpacing: 0.14 * 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured carousel ─────────────────────────────────────────────────────────

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.articles});

  final List<NewsArticle> articles;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.articles.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.articles.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 260,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.articles.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _FeaturedSlide(article: widget.articles[i]),
              ),
              // dot indicators
              Positioned(
                bottom: 14,
                right: 16,
                child: Row(
                  children: List.generate(widget.articles.length, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 4),
                      width: active ? 16 : 6,
                      height: 2,
                      decoration: BoxDecoration(
                        color: active ? colors.accent : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedSlide extends StatelessWidget {
  const _FeaturedSlide({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _FeaturedImage(url: article.imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 1.0],
                colors: [Colors.transparent, const Color(0xFF0E0E0E).withValues(alpha: 0.95)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.accent, width: 0.5),
                  ),
                  child: Text(
                    '● ${'news.featured'.tr()}',
                    style: AppTextStyles.mono(9).copyWith(color: colors.accent, letterSpacing: 1.2),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.display(
                        28,
                        context,
                      ).copyWith(color: Colors.white, height: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '● ${_timeAgo(article.createdAt)}',
                      style: AppTextStyles.mono(
                        9,
                      ).copyWith(color: Colors.white54, letterSpacing: 1.08),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} MIN AGO';
      if (diff.inHours < 24) return '${diff.inHours} HR AGO';
      if (diff.inDays < 30) return '${diff.inDays} DAYS AGO';
      return '${(diff.inDays / 30).floor()} MO AGO';
    } catch (_) {
      return iso;
    }
  }
}

class _FeaturedImage extends StatelessWidget {
  const _FeaturedImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (url == null || url!.isEmpty) {
      return Container(
        color: colors.surface2,
        child: Icon(Icons.article_outlined, color: colors.text3, size: 48),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Skeletonizer(
        enabled: true,
        child: Container(color: colors.surface),
      ),
      errorBuilder: (context, error, stackTrace) => Container(
        color: colors.surface2,
        child: Icon(Icons.broken_image_outlined, color: colors.text3, size: 48),
      ),
    );
  }
}

class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
      child: Skeletonizer(
        enabled: true,
        child: Container(
          height: 260,
          decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
