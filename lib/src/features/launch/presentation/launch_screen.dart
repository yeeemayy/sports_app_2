import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/event_match_card.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';
import 'package:shenghaotiyu/src/features/news/presentation/providers/news_providers.dart';
import 'package:shenghaotiyu/src/features/news/presentation/widgets/news_card.dart';
import 'package:shenghaotiyu/src/features/prediction/domain/leaderboard_entry.dart';
import 'package:shenghaotiyu/src/features/prediction/presentation/providers/leaderboard_providers.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

const _kHPad = 22.0;

class LaunchScreen extends ConsumerWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final localeCode = context.localeCode;

    final footballHot = ref.watch(
      sportMatchesPaginatedProvider(sport: SportType.football, isHot: true),
    );
    final basketballHot = ref.watch(
      sportMatchesPaginatedProvider(sport: SportType.basketball, isHot: true),
    );
    final news = ref.watch(newsFirstPageProvider(localeCode));

    return Scaffold(
      backgroundColor: colors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(_kHPad, 24, _kHPad, 24),
                children: [
                  Text(
                    'launch.brand_title'.tr(),
                    style: AppTextStyles.display(36, context).copyWith(color: colors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'launch.tagline'.tr(),
                    style: AppTextStyles.body(14).copyWith(color: colors.text2),
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'launch.leaderboard'.tr()),
                  const SizedBox(height: 12),
                  const _LeaderboardSection(),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'launch.hot_matches'.tr()),
                  const SizedBox(height: 12),
                  _HotMatchesList(footballAsync: footballHot, basketballAsync: basketballHot),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'launch.news'.tr()),
                  const SizedBox(height: 12),
                  _NewsList(newsAsync: news),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(
                    'launch.enter_app'.tr(),
                    style: AppTextStyles.body(
                      16,
                    ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.display(20, context).copyWith(color: context.appColors.text),
    );
  }
}

class _HotMatchesList extends StatelessWidget {
  const _HotMatchesList({required this.footballAsync, required this.basketballAsync});

  final AsyncValue<PaginatedMatchResult> footballAsync;
  final AsyncValue<PaginatedMatchResult> basketballAsync;

  @override
  Widget build(BuildContext context) {
    final matches = <SportMatch>[
      ...(footballAsync.valueOrNull?.items ?? const []).take(3),
      ...(basketballAsync.valueOrNull?.items ?? const []).take(3),
    ];

    if (footballAsync.isLoading && basketballAsync.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              height: 96,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
    }

    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(children: [for (final m in matches) EventMatchCard(match: m)]);
  }
}

const _kLeaderboardSorts = ['correct', 'streak', 'bestStreak'];

class _LeaderboardSection extends StatefulWidget {
  const _LeaderboardSection();

  @override
  State<_LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<_LeaderboardSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: _kLeaderboardSorts.length, vsync: this)..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colors.accent,
          unselectedLabelColor: colors.text3,
          indicatorColor: colors.accent,
          dividerColor: Colors.transparent,
          labelStyle: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'launch.tabs.correct'.tr()),
            Tab(text: 'launch.tabs.streak'.tr()),
            Tab(text: 'launch.tabs.best_streak'.tr()),
          ],
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, _) {
            final sortBy = _kLeaderboardSorts[_tabController.index];
            final leaderboard = ref.watch(leaderboardTopProvider((limit: 20, sortBy: sortBy)));
            return _LeaderboardList(leaderboardAsync: leaderboard, sortBy: sortBy);
          },
        ),
      ],
    );
  }
}

int _leaderboardValue(LeaderboardEntry e, String sortBy) => switch (sortBy) {
  'bestStreak' => e.bestStreak,
  'correct' => e.correct,
  _ => e.streak,
};

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.leaderboardAsync, required this.sortBy});

  final AsyncValue<List<LeaderboardEntry>> leaderboardAsync;
  final String sortBy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final entries = leaderboardAsync.valueOrNull ?? const <LeaderboardEntry>[];

    if (leaderboardAsync.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: Container(
          height: 160,
          decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('#${i + 1}', style: AppTextStyles.mono(12).copyWith(color: colors.accent)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entries[i].nickname.isEmpty ? '—' : entries[i].nickname,
                      style: AppTextStyles.body(14).copyWith(color: colors.text),
                    ),
                  ),
                  Text(
                    '${_leaderboardValue(entries[i], sortBy)}',
                    style: AppTextStyles.mono(12).copyWith(color: colors.text2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NewsList extends StatelessWidget {
  const _NewsList({required this.newsAsync});

  final AsyncValue<List<NewsArticle>> newsAsync;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final articles = newsAsync.valueOrNull?.take(3).toList() ?? const [];

    if (newsAsync.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              height: 90,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
    }

    if (articles.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          for (final a in articles)
            NewsCard(article: a, onTap: () => context.push(AppRoutes.newsDetailPath(a.id))),
        ],
      ),
    );
  }
}
