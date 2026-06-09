import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/pagination/paginated_state.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

part 'event_providers.g.dart';

class PaginatedMatchResult extends PaginatedState<SportMatch> {
  const PaginatedMatchResult({
    required List<SportMatch> matches,
    required int currentPage,
    required int lastPage,
    bool isLoadingMore = false,
  }) : super(
    items: matches,
    currentPage: currentPage,
    lastPage: lastPage,
    isLoadingMore: isLoadingMore,
    isLoading: false,
  );

  @override
  PaginatedMatchResult copyWith({
    List<SportMatch>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) => PaginatedMatchResult(
    matches: items ?? this.items,
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

@riverpod
class SportMatchesPaginated extends _$SportMatchesPaginated {
  late SportType _sport;
  late String _matchStatus;
  late String? _date;
  late bool _isHot;

  @override
  Future<PaginatedMatchResult> build({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
    bool isHot = false,
  }) async {
    _sport = sport;
    _matchStatus = matchStatus;
    _date = date;
    _isHot = isHot;
    final result = await _fetch(page: 1);
    return PaginatedMatchResult(
      matches: result.matches.where((m) => m.statusId != 0).toList(),
      currentPage: 1,
      lastPage: result.totalPage,
    );
  }

  Future<({List<SportMatch> matches, int totalPage})> _fetch({
    required int page,
  }) {
    final repo = ref.read(eventRepositoryProvider.notifier);
    return _isHot
        ? repo.getHotLeagueMatches(sport: _sport, page: page)
        : repo.getMatches(
            sport: _sport,
            matchStatus: _matchStatus,
            date: _date,
            page: page,
          );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await _fetch(page: nextPage);
      state = AsyncData(
        PaginatedMatchResult(
          matches: [
            ...current.items,
            ...result.matches.where((m) => m.statusId != 0),
          ],
          currentPage: nextPage,
          lastPage: result.totalPage,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

@riverpod
Future<List<SportMatch>> footballScheduledMatches(
  FootballScheduledMatchesRef ref, {
  required String date,
}) {
  return ref
      .watch(eventRepositoryProvider.notifier)
      .getScheduledMatches(date: date);
}

@riverpod
Future<FootballLineups?> footballMatchLineups(
  FootballMatchLineupsRef ref, {
  required String matchId,
}) {
  return ref
      .watch(eventRepositoryProvider.notifier)
      .getFootballMatchLineups(matchId);
}

@riverpod
Future<List<BasketballPlayer>> basketballTeamSquad(
  BasketballTeamSquadRef ref, {
  required String teamId,
}) {
  return ref
      .watch(eventRepositoryProvider.notifier)
      .getBasketballTeamSquad(teamId);
}

/// Generic match detail provider family keyed by [SportType].
///
/// Returns `Object` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchDetailProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchDetail)
/// ```
@riverpod
Future<Object> matchDetail(
  MatchDetailRef ref, {
  required SportType sport,
  required String matchId,
}) {
  return ref
      .watch(eventRepositoryProvider.notifier)
      .getMatchDetail(sport, matchId);
}

/// Generic match events provider family keyed by [SportType].
///
/// Returns `Object?` — callers cast to the expected sport-specific type:
/// ```dart
/// ref.watch(matchEventsProvider(sport: SportType.football, matchId: id))
///     .whenData((r) => r as FootballMatchEvents?)
/// ```
@riverpod
Future<Object?> matchEvents(
  MatchEventsRef ref, {
  required SportType sport,
  required String matchId,
}) {
  return ref
      .watch(eventRepositoryProvider.notifier)
      .getMatchEvents(sport, matchId);
}
