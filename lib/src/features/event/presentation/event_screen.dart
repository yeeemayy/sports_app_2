import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/sport_config.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/event_match_card.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/shimmer_loading_list.dart';

const _kHPad = 22.0;
const _kRecommended = 'recommended';

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ValueNotifier<int> _resetTrigger = ValueNotifier(0);
  String _selectedFilter = _kRecommended;

  static const _sports = SportType.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sports.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _resetTrigger.dispose();
    super.dispose();
  }

  void _selectFilter(String filter) {
    setState(() => _selectedFilter = filter);
    if (filter != _kRecommended) {
      final i = _sports.indexWhere((s) => s.apiPath == filter);
      if (i >= 0) _tabController.animateTo(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentNavIndexProvider, (prev, curr) {
      if (curr == 0 && prev != 0) {
        setState(() => _selectedFilter = _kRecommended);
        _tabController.animateTo(0);
        _resetTrigger.value++;
      }
    });

    return Column(
      children: [
        _HomeHeader(selectedFilter: _selectedFilter),
        Expanded(
          child: Stack(
            children: [
              // Sport tabs — kept alive with Offstage so subscriptions persist
              Offstage(
                offstage: _selectedFilter == _kRecommended,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < _sports.length; i++)
                      _SportTabContent(
                        sport: _sports[i],
                        tabIndex: i,
                        tabController: _tabController,
                        resetTrigger: _resetTrigger,
                        sports: _sports,
                        selectedFilter: _selectedFilter,
                        onSelectFilter: _selectFilter,
                      ),
                  ],
                ),
              ),
              if (_selectedFilter == _kRecommended)
                _RecommendedContent(
                  onSeeAllLive: () => _selectFilter(SportType.football.apiPath),
                  sports: _sports,
                  selectedFilter: _selectedFilter,
                  onSelectFilter: _selectFilter,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.selectedFilter});

  final String selectedFilter;

  String get _heroAsset {
    if (selectedFilter == _kRecommended) return 'assets/images/image_01.jpeg';
    try {
      return SportType.values.firstWhere((s) => s.apiPath == selectedFilter).heroAsset;
    } catch (_) {
      return 'assets/images/image_01.jpeg';
    }
  }

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'home.greeting.morning';
    if (h >= 12 && h < 17) return 'home.greeting.afternoon';
    return 'home.greeting.evening';
  }

  String _dateEyebrow(BuildContext context) {
    final now = DateTime.now();
    final locale = context.locale.toString();
    final isZh = context.locale.languageCode == 'zh';
    final pattern = isZh ? 'EEEE · MMMdd日' : 'EEE · dd MMM';
    final formatted = DateFormat(pattern, locale).format(now);
    return isZh ? formatted : formatted.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);
    final nickname = authAsync.valueOrNull?.user?.nickname ?? '';
    final displayName = nickname.isNotEmpty ? nickname.toUpperCase() : '';
    final heroAsset = _heroAsset;

    return ColoredBox(
      color: context.appColors.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sport hero image — right-aligned with horizontal gradient fade, extends into dropdown bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: Align(
                key: ValueKey(heroAsset),
                alignment: Alignment.centerRight,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.55],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    heroAsset,
                    height: double.infinity,
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                    color: Colors.white.withValues(alpha: 0.18),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              ),
            ),
          ),
          // Text content
          SafeArea(
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.fromLTRB(_kHPad, 12, _kHPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateEyebrow(context),
                    style: AppTextStyles.mono(
                      10,
                    ).copyWith(color: context.appColors.text2, letterSpacing: 10 * 0.18),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.display(
                        32,
                        context,
                      ).copyWith(color: context.appColors.text),
                      children: [
                        TextSpan(text: _greetingKey().tr()),
                        if (displayName.isNotEmpty) ...[
                          TextSpan(text: ',\n'),
                          TextSpan(
                            text: displayName,
                            style: AppTextStyles.display(
                              32,
                              context,
                            ).copyWith(color: context.appColors.accent, height: 1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sport dropdown bar (standalone, for Recommended page)
// ---------------------------------------------------------------------------

class _SportDropdownBar extends StatelessWidget {
  const _SportDropdownBar({
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  String _label(BuildContext context) {
    if (selectedFilter == _kRecommended) return 'home.tab.recommended'.tr();
    final s = sports.firstWhere((s) => s.apiPath == selectedFilter, orElse: () => sports.first);
    return s.i18nKey.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: context.appColors.surface,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: _kHPad, vertical: 6),
      child: _SportDropdownButton(
        label: _label(context),
        sports: sports,
        selectedFilter: selectedFilter,
        onSelectFilter: onSelectFilter,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sport dropdown + status pills combined bar (for sport tabs)
// ---------------------------------------------------------------------------

class _SportAndStatusBar extends StatelessWidget {
  const _SportAndStatusBar({
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.selected,
    required this.onSelected,
    required this.statuses,
  });

  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> statuses;

  String _dropdownLabel(BuildContext context) {
    if (selectedFilter == _kRecommended) return 'home.tab.recommended'.tr();
    final s = sports.firstWhere((s) => s.apiPath == selectedFilter, orElse: () => sports.first);
    return s.i18nKey.tr();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _kHPad, top: 6, bottom: 6),
            child: _SportDropdownButton(
              label: _dropdownLabel(context),
              sports: sports,
              selectedFilter: selectedFilter,
              onSelectFilter: onSelectFilter,
            ),
          ),
          VerticalDivider(
            thickness: 0.5,
            width: 20,
            color: context.appColors.lineStrong,
            indent: 12,
            endIndent: 12,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(0, 6, _kHPad, 6),
              children: statuses.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final active = s == selected;
                return Padding(
                  padding: EdgeInsets.only(right: i < statuses.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onSelected(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                      decoration: BoxDecoration(
                        color: active ? context.appColors.text : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: active
                            ? null
                            : Border.all(color: context.appColors.lineStrong, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          'event.status.$s'.tr().toUpperCase(),
                          style: AppTextStyles.display(12, context).copyWith(
                            color: active ? context.appColors.ink : context.appColors.text2,
                            letterSpacing: 12 * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportMenuItem extends StatelessWidget {
  const _SportMenuItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.context,
  });

  final IconData icon;
  final String label;
  final bool active;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final color = active ? context.appColors.accent : context.appColors.text;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.display(
            13,
            context,
          ).copyWith(color: color, letterSpacing: 13 * 0.06),
        ),
      ],
    );
  }
}

class _SportDropdownButton extends StatelessWidget {
  const _SportDropdownButton({
    required this.label,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final String label;
  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelectFilter,
      color: context.appColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.appColors.lineStrong, width: 0.5),
      ),
      offset: const Offset(0, 36),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _kRecommended,
          child: _SportMenuItem(
            icon: Icons.auto_awesome,
            label: 'home.tab.recommended'.tr(),
            active: selectedFilter == _kRecommended,
            context: context,
          ),
        ),
        for (final s in sports)
          PopupMenuItem(
            value: s.apiPath,
            child: _SportMenuItem(
              icon: s.icon,
              label: s.i18nKey.tr(),
              active: selectedFilter == s.apiPath,
              context: context,
            ),
          ),
      ],
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selectedFilter == _kRecommended
                ? Icons.auto_awesome
                : sports
                      .firstWhere((s) => s.apiPath == selectedFilter, orElse: () => sports.first)
                      .icon,
            size: 16,
            color: context.appColors.text2,
          ),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.display(
              13,
              context,
            ).copyWith(color: context.appColors.text, letterSpacing: 13 * 0.06),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.appColors.text2),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommended tab content
// ---------------------------------------------------------------------------

class _RecommendedContent extends ConsumerWidget {
  const _RecommendedContent({
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
      sportMatchesPaginatedProvider(sport: SportType.football, matchStatus: 'live'),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(newsFirstPageProvider(context.localeCode));
        ref.invalidate(anchorListProvider);
        ref.invalidate(
          sportMatchesPaginatedProvider(sport: SportType.football, matchStatus: 'live'),
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
            child: _SportDropdownBar(
              sports: sports,
              selectedFilter: selectedFilter,
              onSelectFilter: onSelectFilter,
            ),
          ),
          // Live Now
          SliverToBoxAdapter(
            child: _LiveNowSection(liveAsync: liveAsync, onSeeAll: onSeeAllLive),
          ),
          // Editorial hero
          SliverToBoxAdapter(
            child: newsAsync.when(
              skipLoadingOnReload: true,
              loading: () => _heroShimmer(context),
              error: (_, _) => const SizedBox.shrink(),
              data: (articles) {
                final hero = articles.where((a) => a.imageUrl != null).firstOrNull;
                return hero == null ? const SizedBox.shrink() : _EditorialHeroCard(article: hero);
              },
            ),
          ),
          // Anchor rankings
          SliverToBoxAdapter(child: _AnchorRankingsSection(anchorsAsync: anchorsAsync)),
          // Trending news
          SliverToBoxAdapter(
            child: newsAsync.when(
              skipLoadingOnReload: true,
              loading: () => _trendingShimmer(context),
              error: (_, _) => const SizedBox.shrink(),
              data: (articles) {
                final items = articles.skip(1).where((a) => a.imageUrl != null).take(4).toList();
                return items.isEmpty ? const SizedBox.shrink() : _TrendingNewsGrid(articles: items);
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

    if (liveAsync.isLoading && matches.isEmpty) {
      return _shimmer(context);
    }

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
                style: AppTextStyles.display(22, context).copyWith(color: context.appColors.text),
              ),
              const SizedBox(width: 10),
              Text(
                '${matches.length}',
                style: AppTextStyles.mono(10).copyWith(color: context.appColors.text3),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: context.appColors.text3, letterSpacing: 10 * 0.14),
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
          SportType.tableTennis => AppRoutes.tableTennisMatchDetailPath(match.id),
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
            // Accent corner glow
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [context.appColors.accent.withValues(alpha: 0.08), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: sport + league + live pulse
                Row(
                  children: [
                    Icon(_sportIcon(sport), size: 13, color: context.appColors.text2),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName.toUpperCase(),
                        style: AppTextStyles.mono(
                          9,
                        ).copyWith(color: context.appColors.text2, letterSpacing: 9 * 0.16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _LivePulseBadge(liveMinute: () => match.liveMinute),
                  ],
                ),
                const Spacer(),
                // Home team row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.homeName.toUpperCase(),
                        style: AppTextStyles.mono(13).copyWith(color: context.appColors.text),
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
                // Away team row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.awayName.toUpperCase(),
                        style: AppTextStyles.mono(13).copyWith(color: context.appColors.text),
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

class _LivePulseBadge extends StatefulWidget {
  const _LivePulseBadge({required this.liveMinute});

  final String? Function() liveMinute;

  @override
  State<_LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<_LivePulseBadge> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final AnimationController _blinkCtrl;
  late final Timer _ticker;
  String? _liveMinute;

  @override
  void initState() {
    super.initState();
    _liveMinute = widget.liveMinute();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
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
            color: context.appColors.live.withValues(alpha: 0.85 + 0.15 * _anim.value),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.appColors.ink.withValues(alpha: 0.4 + 0.6 * _anim.value),
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
                              color: context.appColors.ink.withValues(alpha: apostropheOpacity),
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
                // Background image
                CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: context.appColors.surface2),
                  errorBuilder: (_, _, _) => Container(color: context.appColors.surface2),
                ),
                // Gradient overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0D0E0E0E), Color(0xD90E0E0E), Color(0xFF0E0E0E)],
                      stops: [0, 0.70, 1],
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Chip(label: '● ${_featuredLabel(context)}', accent: true),
                        const Spacer(),
                        Text(
                          article.description.isNotEmpty ? article.description.toUpperCase() : '',
                          style: AppTextStyles.mono(
                            9,
                          ).copyWith(color: context.appColors.accentEcho, letterSpacing: 9 * 0.1),
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
                          style: AppTextStyles.mono(
                            10,
                          ).copyWith(color: context.appColors.text2, letterSpacing: 10 * 0.1),
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

  String _featuredLabel(BuildContext context) => 'home.featured'.tr();
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
                      style: AppTextStyles.mono(
                        10,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 10 * 0.14),
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
                itemBuilder: (context, i) => _AnchorRankingItem(anchor: anchors[i]),
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
                  // Outer ring
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLive ? context.appColors.accent : context.appColors.lineStrong,
                          width: isLive ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  // Avatar
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: anchor.avatarUrl,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) => Container(
                          color: context.appColors.surface2,
                          child: Icon(Icons.person, color: context.appColors.text3),
                        ),
                      ),
                    ),
                  ),
                  // Live badge
                  if (isLive)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.appColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'home.anchor.live_badge'.tr(),
                            style: AppTextStyles.display(
                              12,
                              context,
                            ).copyWith(color: context.appColors.ink, letterSpacing: 12 * 0.04),
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
              style: AppTextStyles.display(
                11,
                context,
              ).copyWith(color: context.appColors.text, letterSpacing: 11 * 0.04),
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
                style: AppTextStyles.display(22, context).copyWith(color: context.appColors.text),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.news),
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: context.appColors.text3, letterSpacing: 10 * 0.14),
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
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                        placeholder: (_, _) => Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) => Container(color: context.appColors.surface2),
                      )
                    else
                      Container(color: context.appColors.surface2),
                    // Category badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.appColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.display(
                            10,
                            context,
                          ).copyWith(color: context.appColors.ink, letterSpacing: 10 * 0.08),
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
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.12),
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
// Sport tab content (existing logic, restyled)
// ---------------------------------------------------------------------------

class _SportTabContent extends ConsumerStatefulWidget {
  const _SportTabContent({
    required this.sport,
    required this.tabIndex,
    required this.tabController,
    required this.resetTrigger,
    required this.sports,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final SportType sport;
  final int tabIndex;
  final TabController tabController;
  final ValueNotifier<int> resetTrigger;
  final List<SportType> sports;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  ConsumerState<_SportTabContent> createState() => _SportTabContentState();
}

class _SportTabContentState extends ConsumerState<_SportTabContent>
    with AutomaticKeepAliveClientMixin {
  late String _matchStatus;
  DateTime _scheduledDate = DateTime.now().add(Duration(days: 1));
  final ScrollController _scrollController = ScrollController();

  String get _formattedScheduledDate {
    final d = _scheduledDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool get _isActiveTab => widget.tabController.index == widget.tabIndex;

  @override
  void initState() {
    super.initState();
    _matchStatus = _hotLeagueSports.contains(widget.sport) ? 'hot' : 'all';
    _scrollController.addListener(_onScroll);
    widget.tabController.addListener(_onTabChanged);
    widget.resetTrigger.addListener(_onReset);
  }

  void _onReset() {
    setState(() {
      _matchStatus = _hotLeagueSports.contains(widget.sport) ? 'hot' : 'all';
      _scheduledDate = DateTime.now().add(const Duration(days: 1));
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    ref.invalidate(_paginatedProvider);
  }

  void _onTabChanged() {
    if (_isActiveTab) {
      _reRegisterRealtimeIds();
      ref.invalidate(newsFirstPageProvider(context.localeCode));
    } else {
      _clearRealtimeSource();
    }
  }

  void _setRealtimeWatchedIds(List<String> ids) {
    if (widget.sport.config.parseRealtime == null) return;
    if (ref.read(currentNavIndexProvider) != 0) return;
    ref.read(sportRealtimeProvider(widget.sport).notifier).setWatchedIds('list', ids);
  }

  void _clearRealtimeSource() {
    if (widget.sport.config.parseRealtime == null) return;
    ref.read(sportRealtimeProvider(widget.sport).notifier).clearSource('list');
  }

  void _reRegisterRealtimeIds() {
    final result = ref.read(_paginatedProvider).valueOrNull;
    if (result == null) return;
    _setRealtimeWatchedIds(result.matches.map((m) => m.id).toList());
  }

  void _onScroll() {
    if (_isScheduled) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(_paginatedProvider.notifier).loadMore();
    }
  }

  SportMatchesPaginatedProvider get _paginatedProvider => sportMatchesPaginatedProvider(
    sport: widget.sport,
    matchStatus: _matchStatus,
    date: _isFinished ? _formattedScheduledDate : null,
    isHot: _isHot,
  );

  void _onRealtimeUpdate(
    AsyncValue<PaginatedMatchResult> matchesAsync,
    Map<String, int> prevStatusIds,
    Map<String, int> currStatusIds,
  ) {
    final matches = matchesAsync.valueOrNull?.matches;
    if (matches == null || currStatusIds.isEmpty) return;
    final matchIds = matches.map((m) => m.id).toSet();
    final hasNewId = currStatusIds.keys.any(
      (id) => !matchIds.contains(id) && !prevStatusIds.containsKey(id),
    );
    final statusChanged = prevStatusIds.entries.any((e) {
      final curr = currStatusIds[e.key];
      return curr != null && e.value != curr;
    });
    if (hasNewId || statusChanged) _refresh();
  }

  void _refresh() {
    if (_isScheduled) {
      ref.invalidate(footballScheduledMatchesProvider(date: _formattedScheduledDate));
    } else {
      ref.invalidate(_paginatedProvider);
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    widget.resetTrigger.removeListener(_onReset);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  static const _footballStatuses = ['hot', 'all', 'live', 'finished', 'upcoming', 'scheduled'];
  static const _statusesWithHot = ['hot', 'all', 'live', 'finished', 'upcoming'];
  static const _statuses = ['all', 'live', 'finished', 'upcoming'];
  static const _hotLeagueSports = {SportType.football, SportType.basketball};

  List<String> get _availableStatuses {
    if (widget.sport == SportType.football) return _footballStatuses;
    if (_hotLeagueSports.contains(widget.sport)) return _statusesWithHot;
    return _statuses;
  }

  bool get _isHot => _matchStatus == 'hot';
  bool get _isScheduled => _matchStatus == 'scheduled';
  bool get _isFinished => _matchStatus == 'finished';

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final matchesAsync = _isScheduled
        ? ref
              .watch(footballScheduledMatchesProvider(date: _formattedScheduledDate))
              .whenData((list) => PaginatedMatchResult(matches: list, currentPage: 1, totalPage: 1))
        : ref.watch(_paginatedProvider);

    ref.listen(currentNavIndexProvider, (prev, curr) {
      const eventTabIndex = 0;
      if (curr == eventTabIndex && _isActiveTab) {
        _reRegisterRealtimeIds();
      } else if (curr != eventTabIndex) {
        _clearRealtimeSource();
      }
    });

    if (widget.sport.config.parseRealtime != null) {
      ref.listen(sportRealtimeProvider(widget.sport), (prev, curr) {
        _onRealtimeUpdate(
          matchesAsync,
          prev?.map((k, v) => MapEntry(k, v.statusId)) ?? {},
          curr.map((k, v) => MapEntry(k, v.statusId)),
        );
      });
    }

    return Column(
      children: [
        _SportAndStatusBar(
          sports: widget.sports,
          selectedFilter: widget.selectedFilter,
          onSelectFilter: widget.onSelectFilter,
          selected: _matchStatus,
          onSelected: (status) {
            setState(() {
              _matchStatus = status;
              if (status == 'finished') {
                _scheduledDate = DateTime.now();
              } else if (status == 'scheduled') {
                _scheduledDate = DateTime.now().add(const Duration(days: 1));
              }
            });
            ref.invalidate(newsFirstPageProvider(context.localeCode));
          },
          statuses: _availableStatuses,
        ),
        if (_isScheduled || (widget.sport == SportType.football && _isFinished))
          _DateSelectorBar(
            selected: _scheduledDate,
            onSelected: (date) => setState(() => _scheduledDate = date),
            isPast: _isFinished,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_isScheduled) {
                ref.invalidate(footballScheduledMatchesProvider(date: _formattedScheduledDate));
                await ref.read(
                  footballScheduledMatchesProvider(date: _formattedScheduledDate).future,
                );
              } else {
                ref.invalidate(_paginatedProvider);
                await ref.read(_paginatedProvider.future);
              }
            },
            child: matchesAsync.when(
              loading: () => const ShimmerLoadingList(),
              error: (e, st) {
                debugPrint('$e, $st');
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Text(
                          'event.error.load_failed'.tr(),
                          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
                        ),
                      ),
                    ),
                  ),
                );
              },
              data: (result) {
                if (_isActiveTab) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted || !_isActiveTab) return;
                    _setRealtimeWatchedIds(result.matches.map((m) => m.id).toList());
                  });
                }
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (result.matches.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'event.empty'.tr(),
                            style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == result.matches.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return EventMatchCard(match: result.matches[index]);
                        }, childCount: result.matches.length + (result.isLoadingMore ? 1 : 0)),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date selector bar
// ---------------------------------------------------------------------------

class _DateSelectorBar extends StatelessWidget {
  const _DateSelectorBar({required this.selected, required this.onSelected, this.isPast = false});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final bool isPast;

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const _weekdayKeysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdayKeysZh = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isZh = context.locale.languageCode == 'zh';
    final weekdays = isZh ? _weekdayKeysZh : _weekdayKeysEn;

    return Container(
      color: context.appColors.ink2,
      height: 56,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: List.generate(7, (index) {
            final date = isPast
                ? today.subtract(Duration(days: index))
                : today.add(Duration(days: index + 1));
            final isSelected = _formatDate(date) == _formatDate(selected);
            final weekdayLabel = weekdays[date.weekday - 1];
            final dayLabel = '${date.day}'.padLeft(2, '0');

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? context.appColors.accent : context.appColors.surface2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayLabel,
                        style: AppTextStyles.mono(10).copyWith(
                          color: isSelected ? context.appColors.ink : context.appColors.text3,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      Text(
                        dayLabel,
                        style: AppTextStyles.display(12, context).copyWith(
                          color: isSelected ? context.appColors.ink : context.appColors.text,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
          color: accent ? context.appColors.accent : context.appColors.lineStrong,
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
