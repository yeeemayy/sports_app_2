import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/sport_config.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/event_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/event_sport_filter.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/providers/nav_providers.dart';
import 'package:sports_app/src/shared_widgets/shimmer_loading_list.dart';

class EventSportTabContent extends ConsumerStatefulWidget {
  const EventSportTabContent({
    super.key,
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
  ConsumerState<EventSportTabContent> createState() =>
      _EventSportTabContentState();
}

class _EventSportTabContentState extends ConsumerState<EventSportTabContent>
    with AutomaticKeepAliveClientMixin {
  late String _matchStatus;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
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
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
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
    ref
        .read(sportRealtimeProvider(widget.sport).notifier)
        .setWatchedIds('list', ids);
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(_paginatedProvider.notifier).loadMore();
    }
  }

  SportMatchesPaginatedProvider get _paginatedProvider =>
      sportMatchesPaginatedProvider(
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
      ref.invalidate(
        footballScheduledMatchesProvider(date: _formattedScheduledDate),
      );
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

  static const _footballStatuses = [
    'hot',
    'all',
    'live',
    'finished',
    'upcoming',
    'scheduled',
  ];
  static const _statusesWithHot = [
    'hot',
    'all',
    'live',
    'finished',
    'upcoming',
  ];
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
              .watch(
                footballScheduledMatchesProvider(date: _formattedScheduledDate),
              )
              .whenData(
                (list) => PaginatedMatchResult(
                  matches: list,
                  currentPage: 1,
                  totalPage: 1,
                ),
              )
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
        EventSportAndStatusBar(
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
          EventDateSelectorBar(
            selected: _scheduledDate,
            onSelected: (date) => setState(() => _scheduledDate = date),
            isPast: _isFinished,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_isScheduled) {
                ref.invalidate(
                  footballScheduledMatchesProvider(
                    date: _formattedScheduledDate,
                  ),
                );
                await ref.read(
                  footballScheduledMatchesProvider(
                    date: _formattedScheduledDate,
                  ).future,
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
                          style: AppTextStyles.body(
                            14,
                          ).copyWith(color: context.appColors.text3),
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
                    _setRealtimeWatchedIds(
                      result.matches.map((m) => m.id).toList(),
                    );
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
                            style: AppTextStyles.body(
                              14,
                            ).copyWith(color: context.appColors.text3),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == result.matches.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return EventMatchCard(match: result.matches[index]);
                          },
                          childCount:
                              result.matches.length +
                              (result.isLoadingMore ? 1 : 0),
                        ),
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

class EventDateSelectorBar extends StatelessWidget {
  const EventDateSelectorBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.isPast = false,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final bool isPast;

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const _weekdayKeysEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
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
                    color: isSelected
                        ? context.appColors.accent
                        : context.appColors.surface2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayLabel,
                        style: AppTextStyles.mono(10).copyWith(
                          color: isSelected
                              ? context.appColors.ink
                              : context.appColors.text3,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      Text(
                        dayLabel,
                        style: AppTextStyles.display(12, context).copyWith(
                          color: isSelected
                              ? context.appColors.ink
                              : context.appColors.text,
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
