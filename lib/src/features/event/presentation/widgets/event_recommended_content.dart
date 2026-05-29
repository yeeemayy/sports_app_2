import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/event_sport_filter.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHPad = 22.0;

class EventRecommendedContent extends ConsumerWidget {
  const EventRecommendedContent({
    super.key,
    required this.onSeeAllLive,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final VoidCallback onSeeAllLive;
  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsFirstPageProvider(context.localeCode));
    final anchorsAsync = ref.watch(anchorListProvider());
    final liveAsync = ref.watch(
      sportMatchesPaginatedProvider(
        sport: SportType.football,
        matchStatus: 'live',
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(newsFirstPageProvider(context.localeCode));
        ref.invalidate(anchorListProvider);
        ref.invalidate(
          sportMatchesPaginatedProvider(
            sport: SportType.football,
            matchStatus: 'live',
          ),
        );
        await Future.wait([
          ref.read(newsFirstPageProvider(context.localeCode).future),
          ref.read(anchorListProvider().future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: EventSportDropdownBar(
              sports: sports,
              selectedFilter: selectedFilter,
              onSelectFilter: onSelectFilter,
            ),
          ),
          SliverToBoxAdapter(
            child: _LiveNowSection(
              liveAsync: liveAsync,
              onSeeAll: onSeeAllLive,
            ),
          ),
          SliverToBoxAdapter(
            child: newsAsync.when(
              skipLoadingOnReload: true,
              loading: () => _heroShimmer(context),
              error: (_, _) => const SizedBox.shrink(),
              data: (articles) {
                final hero = articles
                    .where((a) => a.imageUrl != null)
                    .firstOrNull;
                return hero == null
                    ? const SizedBox.shrink()
                    : _EditorialHeroCard(article: hero);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _AnchorRankingsSection(anchorsAsync: anchorsAsync),
          ),
          SliverToBoxAdapter(
            child: newsAsync.when(
              skipLoadingOnReload: true,
              loading: () => _trendingShimmer(context),
              error: (_, _) => const SizedBox.shrink(),
              data: (articles) {
                final items = articles
                    .skip(1)
                    .where((a) => a.imageUrl != null)
                    .take(4)
                    .toList();
                return items.isEmpty
                    ? const SizedBox.shrink()
                    : _TrendingNewsGrid(articles: items);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
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

// ---------------------------------------------------------------------------
// Live Now section
// ---------------------------------------------------------------------------

class _LiveNowSection extends StatelessWidget {
  const _LiveNowSection({required this.liveAsync, required this.onSeeAll});

  final AsyncValue<PaginatedMatchResult> liveAsync;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final matches = liveAsync.valueOrNull?.matches ?? [];

    if (liveAsync.isLoading && matches.isEmpty) return _shimmer(context);
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 16, _kHPad, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'home.live_now'.tr().toUpperCase(),
                style: AppTextStyles.display(
                  22,
                  context,
                ).copyWith(color: context.appColors.text),
              ),
              const SizedBox(width: 10),
              Text(
                '${matches.length}',
                style: AppTextStyles.mono(
                  10,
                ).copyWith(color: context.appColors.text3),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(10).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 10 * 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: matches.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) =>
                _LiveMatchCard(match: matches[i], sport: SportType.football),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _shimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 22),
      child: Skeletonizer(
        enabled: true,
        child: SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => Container(
              width: 240,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live match card (240 × 118)
// ---------------------------------------------------------------------------

class _LiveMatchCard extends StatelessWidget {
  const _LiveMatchCard({required this.match, required this.sport});

  final SportMatch match;
  final SportType sport;

  @override
  Widget build(BuildContext context) {
    final homeScore = int.tryParse(match.homeScore) ?? 0;
    final awayScore = int.tryParse(match.awayScore) ?? 0;

    return GestureDetector(
      onTap: () {
        final path = switch (sport) {
          SportType.football => AppRoutes.footballMatchDetailPath(match.id),
          SportType.basketball => AppRoutes.basketballMatchDetailPath(match.id),
          SportType.tennis => AppRoutes.tennisMatchDetailPath(match.id),
          SportType.cricket => AppRoutes.cricketMatchDetailPath(match.id),
          SportType.baseball => AppRoutes.baseballMatchDetailPath(match.id),
          SportType.volleyball => AppRoutes.volleyballMatchDetailPath(match.id),
          SportType.badminton => AppRoutes.badmintonMatchDetailPath(match.id),
          SportType.tableTennis => AppRoutes.tableTennisMatchDetailPath(
            match.id,
          ),
          SportType.iceHockey => AppRoutes.iceHockeyMatchDetailPath(match.id),
          SportType.amFootball => AppRoutes.amFootballMatchDetailPath(match.id),
        };
        context.push(path, extra: match);
      },
      child: Container(
        width: 240,
        height: 118,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.appColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _sportIcon(sport),
                      size: 13,
                      color: context.appColors.text2,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName.toUpperCase(),
                        style: AppTextStyles.mono(9).copyWith(
                          color: context.appColors.text2,
                          letterSpacing: 9 * 0.16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _LivePulseBadge(liveMinute: () => match.liveMinute),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.homeName.toUpperCase(),
                        style: AppTextStyles.mono(
                          13,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.homeScore,
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.awayName.toUpperCase(),
                        style: AppTextStyles.mono(
                          13,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.awayScore,
                      style: AppTextStyles.display(22, context).copyWith(
                        color: awayScore > homeScore
                            ? context.appColors.accent
                            : context.appColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live pulse badge
// ---------------------------------------------------------------------------

class _LivePulseBadge extends StatefulWidget {
  const _LivePulseBadge({required this.liveMinute});

  final String? Function() liveMinute;

  @override
  State<_LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<_LivePulseBadge>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final AnimationController _blinkCtrl;
  late final Timer _ticker;
  String? _liveMinute;

  @override
  void initState() {
    super.initState();
    _liveMinute = widget.liveMinute();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = widget.liveMinute();
      if (next != _liveMinute) setState(() => _liveMinute = next);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _ctrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_anim, _blinkCtrl]),
      builder: (_, _) {
        final text = _liveMinute ?? 'event.football.ht'.tr();
        final hasApostrophe = text.endsWith("'");
        final base = hasApostrophe ? text.substring(0, text.length - 1) : text;
        final apostropheOpacity = _blinkCtrl.value < 0.5 ? 1.0 : 0.0;
        final baseStyle = AppTextStyles.mono(9).copyWith(
          color: context.appColors.ink,
          letterSpacing: 9 * 0.12,
          fontWeight: FontWeight.w700,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.appColors.live.withValues(
              alpha: 0.85 + 0.15 * _anim.value,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.appColors.ink.withValues(
                    alpha: 0.4 + 0.6 * _anim.value,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              RichText(
                text: TextSpan(
                  text: base.toUpperCase(),
                  style: baseStyle,
                  children: hasApostrophe
                      ? [
                          TextSpan(
                            text: "'",
                            style: baseStyle.copyWith(
                              color: context.appColors.ink.withValues(
                                alpha: apostropheOpacity,
                              ),
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Editorial hero card (330 px)
// ---------------------------------------------------------------------------

class _EditorialHeroCard extends StatelessWidget {
  const _EditorialHeroCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 22),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: context.appColors.surface2),
                  errorBuilder: (_, _, _) =>
                      Container(color: context.appColors.surface2),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x0D0E0E0E),
                        Color(0xD90E0E0E),
                        Color(0xFF0E0E0E),
                      ],
                      stops: [0, 0.70, 1],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Chip(label: '● ${'home.featured'.tr()}', accent: true),
                        const Spacer(),
                        Text(
                          article.description.isNotEmpty
                              ? article.description.toUpperCase()
                              : '',
                          style: AppTextStyles.mono(9).copyWith(
                            color: context.appColors.accentEcho,
                            letterSpacing: 9 * 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          article.title.toUpperCase(),
                          style: AppTextStyles.display(
                            38,
                            context,
                          ).copyWith(color: Colors.white, height: 0.9),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          DateFormat(
                            context.locale.languageCode == 'zh'
                                ? 'MMMdd日, yyyy HH:mm'
                                : 'dd MMM, yyyy HH:mm',
                            context.locale.languageCode,
                          ).format(DateTime.parse(article.createdAt)),
                          style: AppTextStyles.mono(10).copyWith(
                            color: context.appColors.text2,
                            letterSpacing: 10 * 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Anchor rankings
// ---------------------------------------------------------------------------

class _AnchorRankingsSection extends StatelessWidget {
  const _AnchorRankingsSection({required this.anchorsAsync});

  final AsyncValue<PaginatedResponse<AnchorModel>> anchorsAsync;

  @override
  Widget build(BuildContext context) {
    return anchorsAsync.when(
      skipLoadingOnReload: true,
      loading: () => _shimmer(context),
      error: (_, _) => const SizedBox.shrink(),
      data: (page) {
        final anchors = page.data.take(6).toList();
        if (anchors.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'home.anchor_rankings'.tr(),
                    style: AppTextStyles.display(
                      22,
                      context,
                    ).copyWith(color: context.appColors.text),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.anchorList),
                    child: Text(
                      'home.see_all'.tr(),
                      style: AppTextStyles.mono(10).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 10 * 0.14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
                itemCount: anchors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) =>
                    _AnchorRankingItem(anchor: anchors[i]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _shimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 24),
      child: Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(
              4,
              (_) => Container(
                width: 88,
                height: 118,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchorRankingItem extends StatelessWidget {
  const _AnchorRankingItem({required this.anchor});

  final AnchorModel anchor;

  @override
  Widget build(BuildContext context) {
    final isLive = anchor.isLive == 1;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.anchorPath(anchor.id)),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLive
                              ? context.appColors.accent
                              : context.appColors.lineStrong,
                          width: isLive ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: anchor.avatarUrl,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) => Container(
                          color: context.appColors.surface2,
                          child: Icon(
                            Icons.person,
                            color: context.appColors.text3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'home.anchor.live_badge'.tr(),
                            style: AppTextStyles.display(12, context).copyWith(
                              color: context.appColors.ink,
                              letterSpacing: 12 * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anchor.nickname.toUpperCase(),
              style: AppTextStyles.display(11, context).copyWith(
                color: context.appColors.text,
                letterSpacing: 11 * 0.04,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trending news 2-column grid
// ---------------------------------------------------------------------------

class _TrendingNewsGrid extends StatelessWidget {
  const _TrendingNewsGrid({required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'home.trending'.tr(),
                style: AppTextStyles.display(
                  22,
                  context,
                ).copyWith(color: context.appColors.text),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.news),
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(10).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 10 * 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kHPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < articles.length && i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _TrendingNewsCard(article: articles[i])),
              ],
            ],
          ),
        ),
        if (articles.length > 2) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 2; i < articles.length && i < 4; i++) ...[
                  if (i > 2) const SizedBox(width: 12),
                  Expanded(child: _TrendingNewsCard(article: articles[i])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TrendingNewsCard extends StatelessWidget {
  const _TrendingNewsCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final category = article.keywords.split(',').first.trim().toUpperCase();

    return GestureDetector(
      onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) =>
                            Container(color: context.appColors.surface2),
                      )
                    else
                      Container(color: context.appColors.surface2),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.display(10, context).copyWith(
                            color: context.appColors.ink,
                            letterSpacing: 10 * 0.08,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title.toUpperCase(),
                    style: AppTextStyles.display(
                      15,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1.05),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      context.locale.languageCode == 'zh'
                          ? 'MMMdd日, yyyy HH:mm'
                          : 'dd MMM, yyyy HH:mm',
                      context.locale.languageCode,
                    ).format(DateTime.parse(article.createdAt)),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text3,
                      letterSpacing: 9 * 0.12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x800E0E0E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent
              ? context.appColors.accent
              : context.appColors.lineStrong,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(10).copyWith(
          color: accent ? context.appColors.accent : context.appColors.text2,
          letterSpacing: 10 * 0.14,
        ),
      ),
    );
  }
}

IconData _sportIcon(SportType sport) => switch (sport) {
  SportType.football => Icons.sports_soccer,
  SportType.basketball => Icons.sports_basketball,
  SportType.tennis => Icons.sports_tennis,
  SportType.cricket => Icons.sports_cricket,
  SportType.baseball => Icons.sports_baseball,
  SportType.volleyball => Icons.sports_volleyball,
  SportType.badminton => Icons.sports_tennis,
  SportType.tableTennis => Icons.sports_tennis,
  SportType.iceHockey => Icons.sports_hockey,
  SportType.amFootball => Icons.sports_football,
};
