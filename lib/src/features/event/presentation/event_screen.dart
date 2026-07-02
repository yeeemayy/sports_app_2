import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/event_home_header.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/event_recommended_content.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/event_sport_filter.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/event_sport_tab_content.dart';
import 'package:shenghaotiyu/src/providers/nav_providers.dart';

const _kRecommended = 'recommended';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen>
    with SingleTickerProviderStateMixin {
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
        EventHomeHeader(selectedFilter: _selectedFilter),
        EventSportDropdownBar(
          sports: _sports,
          selectedFilter: _selectedFilter,
          onSelectFilter: _selectFilter,
        ),
        Expanded(
          child: Stack(
            children: [
              Offstage(
                offstage: _selectedFilter == _kRecommended,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < _sports.length; i++)
                      EventSportTabContent(
                        sport: _sports[i],
                        tabIndex: i,
                        tabController: _tabController,
                        resetTrigger: _resetTrigger,
                      ),
                  ],
                ),
              ),
              if (_selectedFilter == _kRecommended)
                EventRecommendedContent(
                  onSeeAllLive: () => _selectFilter(SportType.football.apiPath),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
