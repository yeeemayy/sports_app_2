import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/sport_config.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/event_match_card.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/shared_widgets/shimmer_loading_list.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ValueNotifier<int> _resetTrigger = ValueNotifier(0);

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

  @override
  Widget build(BuildContext context) {
    ref.listen(currentNavIndexProvider, (prev, curr) {
      if (curr == 0 && prev != 0) {
        _tabController.animateTo(0);
        _resetTrigger.value++;
      }
    });

    return Column(
      children: [
        Container(
          color: AppColors.primary,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: _tabController,
                    indicator: const BoxDecoration(),
                    labelStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    tabs: _sports.map((s) => Tab(text: s.i18nKey.tr())).toList(),
                  ),
                ),
                // IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (var i = 0; i < _sports.length; i++)
                _SportTabContent(
                  sport: _sports[i],
                  tabIndex: i,
                  tabController: _tabController,
                  resetTrigger: _resetTrigger,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SportTabContent extends ConsumerStatefulWidget {
  const _SportTabContent({
    required this.sport,
    required this.tabIndex,
    required this.tabController,
    required this.resetTrigger,
  });

  final SportType sport;
  final int tabIndex;
  final TabController tabController;
  final ValueNotifier<int> resetTrigger;

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
    // Only treat an ID as new if it just appeared in this poll (not in the
    // previous realtime state), to avoid spurious refreshes from unrelated
    // live matches that the realtime endpoint always returns.
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

    // Scheduled uses the diary endpoint (no pagination).
    // All other tabs use the paginated notifier.
    final matchesAsync = _isScheduled
        ? ref
              .watch(footballScheduledMatchesProvider(date: _formattedScheduledDate))
              .whenData((list) => PaginatedMatchResult(matches: list, currentPage: 1, totalPage: 1))
        : ref.watch(_paginatedProvider);

    // Pause/resume realtime polling when the event bottom-nav tab goes off/on screen.
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

    final anchorsAsync = ref.watch(anchorListProvider());

    return Column(
      children: [
        _StatusFilterBar(
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
              ref.invalidate(anchorListProvider);
              ref.invalidate(newsFirstPageProvider(context.localeCode));
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
              loading: () => Column(
                children: [
                  Padding(padding: const EdgeInsets.only(top: 16), child: HomeBannerCarousel()),
                  const Expanded(child: ShimmerLoadingList()),
                ],
              ),
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
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: HomeBannerCarousel(),
                      ),
                    ),
                    if (_isHot)
                      SliverToBoxAdapter(
                        child: anchorsAsync.when(
                          skipLoadingOnRefresh: false,
                          data: (page) => page.data.isEmpty
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    HomeSectionTitle(
                                      icon: 'assets/images/live-tv.png',
                                      title: 'home.section.anchor_live'.tr(),
                                      onPressed: () => context.push(AppRoutes.anchorList),
                                    ),
                                    HomeAnchorLiveGrid(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      itemCount: 4,
                                      anchors: page.data,
                                    ),
                                  ],
                                ),
                          error: (err, stack) {
                            print('$err\n$stack');
                            return Column(
                              children: [
                                HomeSectionTitle(
                                  icon: 'assets/images/live-tv.png',
                                  title: 'home.section.anchor_live'.tr(),
                                  onPressed: () => context.push(AppRoutes.anchorList),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 48),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'home.error.load_failed'.tr(),
                                        style: TextStyle(color: Colors.grey.shade500),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () => ref.refresh(anchorListProvider().future),
                                        child: Text('common.retry'.tr()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => Column(
                            children: [
                              HomeSectionTitle(
                                icon: 'assets/images/live-tv.png',
                                title: 'home.section.anchor_live'.tr(),
                                onPressed: () => context.push(AppRoutes.anchorList),
                              ),
                              const HomeAnchorLiveGrid(),
                            ],
                          ),
                        ),
                      ),
                    if (result.matches.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'event.empty'.tr(),
                            style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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

class _StatusFilterBar extends StatefulWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.onSelected,
    required this.statuses,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> statuses;

  @override
  State<_StatusFilterBar> createState() => _StatusFilterBarState();
}

class _StatusFilterBarState extends State<_StatusFilterBar> with SingleTickerProviderStateMixin {
  late TabController _controller;

  int get _selectedIndex =>
      widget.statuses.indexOf(widget.selected).clamp(0, widget.statuses.length - 1);

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.statuses.length,
      initialIndex: _selectedIndex,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_StatusFilterBar old) {
    super.didUpdateWidget(old);
    if (old.statuses.length != widget.statuses.length) {
      _controller.dispose();
      _controller = TabController(
        length: widget.statuses.length,
        initialIndex: _selectedIndex,
        vsync: this,
      );
    } else if (_controller.index != _selectedIndex) {
      _controller.index = _selectedIndex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: TabBar(
        controller: _controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (i) => widget.onSelected(widget.statuses[i]),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: context.textTheme.labelMedium,
        indicatorColor: Colors.white,
        indicatorPadding: EdgeInsets.only(bottom: 6),
        dividerColor: Colors.transparent,
        tabs: widget.statuses.map((s) => Tab(text: 'event.status.$s'.tr())).toList(),
      ),
    );
  }
}

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

    return SizedBox(
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
                    color: isSelected ? AppColors.primary : AppTheme.of(context).shimmerHighlight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      Text(
                        dayLabel,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: isSelected ? Colors.white : null,
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
