import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/recommended_content_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/anchor_rankings_section.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/editorial_hero_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/live_now_section.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/trending_news_section.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/features/watchlist/presentation/providers/watchlist_notifier.dart';

const _kHPad = 22.0;

class EventRecommendedContent extends ConsumerWidget {
  const EventRecommendedContent({super.key, required this.onSeeAllLive});

  final VoidCallback onSeeAllLive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(
      recommendedContentViewModelProvider(context.localeCode),
    );
    final newsAsync = vm.newsAsync;
    final anchorsAsync = vm.anchorsAsync;
    final liveAsync = vm.liveAsync;
    final upcomingMatches = vm.upcomingMatches;
    final favUpcoming = vm.favUpcoming;
    final favTeamNames = vm.favTeamNames;
    final allFavNames = vm.allFavNames;

    return RefreshIndicator(
      onRefresh: () async {
        final favSports = ref
            .read(recommendedContentViewModelProvider(context.localeCode))
            .favSports;
        ref.invalidate(newsFirstPageProvider(context.localeCode));
        ref.invalidate(anchorListProvider);
        ref.invalidate(
          sportMatchesPaginatedProvider(
            sport: SportType.football,
            matchStatus: 'live',
          ),
        );
        for (final s in favSports) {
          ref.invalidate(
            sportMatchesPaginatedProvider(sport: s, matchStatus: 'upcoming'),
          );
        }
        ref.invalidate(watchlistNotifierProvider);
        await Future.wait([
          ref.read(newsFirstPageProvider(context.localeCode).future),
          ref.read(anchorListProvider().future),
          ref.read(watchlistNotifierProvider.future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // if (upcomingMatches.isNotEmpty)
          //   SliverToBoxAdapter(
          //     child: YourMatchesTodaySection(entries: upcomingMatches),
          //   ),
          // if (favUpcoming.isNotEmpty)
          //   SliverToBoxAdapter(
          //     child: FavTeamUpcomingSection(items: favUpcoming),
          //   ),
          // if (upcomingMatches.isEmpty && favUpcoming.isEmpty)
          //   SliverToBoxAdapter(
          //     child: EmptyPersonalizationPrompt(onViewLive: onSeeAllLive),
          //   ),
          SliverToBoxAdapter(
            child: LiveNowSection(
              liveAsync: liveAsync,
              onSeeAll: onSeeAllLive,
              favTeamNames: favTeamNames,
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: _currentSwitcherChildOnly,
              child: _heroSlot(context, newsAsync),
            ),
          ),
          SliverToBoxAdapter(
            child: AnchorRankingsSection(anchorsAsync: anchorsAsync),
          ),
          // SliverToBoxAdapter(
          //   child: newsAsync.when(
          //     skipLoadingOnReload: true,
          //     loading: () => const SizedBox.shrink(),
          //     error: (_, _) => const SizedBox.shrink(),
          //     data: (articles) {
          //       final forYou = allFavNames.isEmpty
          //           ? <NewsArticle>[]
          //           : articles.where((a) {
          //               final title = a.title.toLowerCase();
          //               final keywords = a.keywords.toLowerCase();
          //               final description = a.description.toLowerCase();
          //               return allFavNames.any(
          //                 (n) => n.isNotEmpty && (
          //                   title.contains(n) ||
          //                   keywords.contains(n) ||
          //                   description.contains(n)
          //                 ),
          //               );
          //             }).take(2).toList();
          //       return forYou.isEmpty
          //           ? const SizedBox.shrink()
          //           : ForYouNewsSection(articles: forYou);
          //     },
          //   ),
          // ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: _currentSwitcherChildOnly,
              child: _trendingSlot(context, newsAsync),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  static Widget _currentSwitcherChildOnly(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return currentChild ?? const SizedBox.shrink();
  }

  Widget _heroSlot(
    BuildContext context,
    AsyncValue<List<NewsArticle>> newsAsync,
  ) {
    return newsAsync.when(
      skipLoadingOnReload: true,
      loading: () => KeyedSubtree(
        key: const ValueKey('hero-loading'),
        child: _heroShimmer(context),
      ),
      error: (_, _) => const SizedBox.shrink(key: ValueKey('hero-error')),
      data: (articles) {
        final hero = articles.where((a) => a.imageUrl != null).firstOrNull;
        return hero == null
            ? const SizedBox.shrink(key: ValueKey('hero-empty'))
            : EditorialHeroCard(
                key: ValueKey('hero-${hero.id}'),
                article: hero,
              );
      },
    );
  }

  Widget _trendingSlot(
    BuildContext context,
    AsyncValue<List<NewsArticle>> newsAsync,
  ) {
    return newsAsync.when(
      skipLoadingOnReload: true,
      loading: () => KeyedSubtree(
        key: const ValueKey('trending-loading'),
        child: _trendingShimmer(context),
      ),
      error: (_, _) => const SizedBox.shrink(key: ValueKey('trending-error')),
      data: (articles) {
        final items = articles
            .skip(1)
            .where((a) => a.imageUrl != null)
            .take(4)
            .toList();
        return items.isEmpty
            ? const SizedBox.shrink(key: ValueKey('trending-empty'))
            : TrendingNewsGrid(
                key: ValueKey('trending-${items.map((a) => a.id).join('-')}'),
                articles: items,
              );
      },
    );
  }

  Widget _heroShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 22),
      child: Skeletonizer(
        enabled: true,
        child: Container(
          height: 330,
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _trendingShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
      child: Skeletonizer(
        enabled: true,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
