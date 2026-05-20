import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_section_providers.dart';
import 'package:sports_app/src/features/news/presentation/widgets/news_card.dart';
import 'package:sports_app/src/routes/app_routes.dart';

/// Intermediary screen shown when the user taps "MORE" on a news section.
/// [title] is the already-translated section label (used in the AppBar).
/// [keyword] is the search keyword — empty string means "latest" (no filter).
class NewsCategoryScreen extends ConsumerStatefulWidget {
  const NewsCategoryScreen({super.key, required this.title, required this.keyword});

  final String title;
  final String keyword;

  @override
  ConsumerState<NewsCategoryScreen> createState() => _NewsCategoryScreenState();
}

class _NewsCategoryScreenState extends ConsumerState<NewsCategoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(newsCategoryPaginatedProvider(widget.keyword).notifier)
          .init(context.localeCode);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsCategoryPaginatedProvider(widget.keyword).notifier).loadMore();
    }
  }

  Future<void> _onRefresh() =>
      ref.read(newsCategoryPaginatedProvider(widget.keyword).notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsCategoryPaginatedProvider(widget.keyword));
    final colors = context.appColors;

    if (state.error != null && state.articles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.showErrorDialog(title: 'news.load_error'.tr(), error: state.error!);
        }
      });
    }

    return Scaffold(
      backgroundColor: colors.ink,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 22, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.title.toUpperCase(),
                    style: AppTextStyles.display(28, context).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Article list ──
            Expanded(
              child: RefreshIndicator(
                color: colors.accent,
                onRefresh: _onRefresh,
                child: _buildBody(state, colors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NewsPaginatedState state, AppColors colors) {
    if (state.isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        separatorBuilder: (_, __) =>
            Divider(height: 1, indent: 22, endIndent: 22, color: colors.line),
        itemBuilder: (_, __) => const NewsCard.loading(),
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
      separatorBuilder: (_, __) =>
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
          categoryLabel: widget.title,
          onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
        );
      },
    );
  }
}
