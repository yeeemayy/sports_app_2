import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';

part 'event_providers.g.dart';

class PaginatedMatchResult {
  const PaginatedMatchResult({
    required this.matches,
    required this.currentPage,
    required this.totalPage,
    this.isLoadingMore = false,
  });

  final List<SportMatch> matches;
  final int currentPage;
  final int totalPage;
  final bool isLoadingMore;

  bool get hasMore => currentPage < totalPage;

  PaginatedMatchResult copyWith({
    List<SportMatch>? matches,
    int? currentPage,
    int? totalPage,
    bool? isLoadingMore,
  }) => PaginatedMatchResult(
    matches: matches ?? this.matches,
    currentPage: currentPage ?? this.currentPage,
    totalPage: totalPage ?? this.totalPage,
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
      matches: result.matches,
      currentPage: 1,
      totalPage: result.totalPage,
    );
  }

  Future<({List<SportMatch> matches, int totalPage})> _fetch({required int page}) {
    final repo = ref.read(eventRepositoryProvider.notifier);
    return _isHot
        ? repo.getHotLeagueMatches(sport: _sport, page: page)
        : repo.getMatches(sport: _sport, matchStatus: _matchStatus, date: _date, page: page);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await _fetch(page: nextPage);
      state = AsyncData(PaginatedMatchResult(
        matches: [...current.matches, ...result.matches],
        currentPage: nextPage,
        totalPage: result.totalPage,
      ));
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
  return ref.watch(eventRepositoryProvider.notifier).getScheduledMatches(date: date);
}

@riverpod
Future<FootballMatchDetail> footballMatchDetail(
  FootballMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.football, matchId)
      .then((r) => r as FootballMatchDetail);
}

@riverpod
Future<FootballLineups?> footballMatchLineups(
  FootballMatchLineupsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getFootballMatchLineups(matchId);
}

@riverpod
Future<FootballMatchEvents?> footballMatchEventsKey(
  FootballMatchEventsKeyRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.football, matchId)
      .then((r) => r as FootballMatchEvents?);
}

@riverpod
Future<BasketballMatchDetail> basketballMatchDetail(
  BasketballMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.basketball, matchId)
      .then((r) => r as BasketballMatchDetail);
}

@riverpod
Future<BasketballMatchEventsData?> basketballMatchEventsKey(
  BasketballMatchEventsKeyRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.basketball, matchId)
      .then((r) => r as BasketballMatchEventsData?);
}

@riverpod
Future<List<BasketballPlayer>> basketballTeamSquad(
  BasketballTeamSquadRef ref, {
  required String teamId,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getBasketballTeamSquad(teamId);
}

@riverpod
Future<TennisMatchDetail> tennisMatchDetail(
  TennisMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.tennis, matchId)
      .then((r) => r as TennisMatchDetail);
}

@riverpod
Future<TennisMatchEventsData?> tennisMatchEvents(
  TennisMatchEventsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.tennis, matchId)
      .then((r) => r as TennisMatchEventsData?);
}

@riverpod
Future<BadmintonMatchDetail> badmintonMatchDetail(
  BadmintonMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.badminton, matchId)
      .then((r) => r as BadmintonMatchDetail);
}

@riverpod
Future<BadmintonMatchEventsData?> badmintonMatchEvents(
  BadmintonMatchEventsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.badminton, matchId)
      .then((r) => r as BadmintonMatchEventsData?);
}

@riverpod
Future<TableTennisMatchDetail> tableTennisMatchDetail(
  TableTennisMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.tableTennis, matchId)
      .then((r) => r as TableTennisMatchDetail);
}

@riverpod
Future<TableTennisMatchEventsData?> tableTennisMatchEvents(
  TableTennisMatchEventsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.tableTennis, matchId)
      .then((r) => r as TableTennisMatchEventsData?);
}

@riverpod
Future<BaseballMatchDetail> baseballMatchDetail(
  BaseballMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchDetail(SportType.baseball, matchId)
      .then((r) => r as BaseballMatchDetail);
}

@riverpod
Future<BaseballMatchEventsData?> baseballMatchEvents(
  BaseballMatchEventsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier)
      .getMatchEvents(SportType.baseball, matchId)
      .then((r) => r as BaseballMatchEventsData?);
}
