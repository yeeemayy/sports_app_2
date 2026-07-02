import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/api_service.dart'
    show sportsApiServiceProvider;
import 'package:shenghaotiyu/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_lineup.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_realtime_data.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/domain/sport_config.dart';

part 'event_repository.g.dart';

@Riverpod(keepAlive: true)
class EventRepository extends _$EventRepository {
  @override
  void build() {}

  Future<({List<SportMatch> matches, int totalPage})> getHotLeagueMatches({
    required SportType sport,
    int page = 1,
  }) async {
    final dio = ref.read(sportsApiServiceProvider);
    final path = '/${sport.apiPath}/match/list/today-hot-league';
    final response = await dio.get(path, queryParameters: {'page': page});

    final json = response.data as Map<String, dynamic>;
    final list = json[sport.matchListKey] as List<dynamic>? ?? [];
    final totalPage = (json['totalPage'] as num?)?.toInt() ?? 1;

    return (
      matches: list
          .map(
            (item) =>
                SportMatch.fromSportJson(item as Map<String, dynamic>, sport),
          )
          .toList(),
      totalPage: totalPage,
    );
  }

  Future<({List<SportMatch> matches, int totalPage})> getMatches({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
    int page = 1,
  }) async {
    final dio = ref.read(sportsApiServiceProvider);
    final path = '/${sport.apiPath}/match/list/today-by-match-time';
    final response = await dio.get(
      path,
      queryParameters: {
        'matchStatus': matchStatus,
        'date': ?date,
        'page': page,
      },
    );

    final json = response.data as Map<String, dynamic>;
    debugPrint(
      '[EventRepository] ${sport.apiPath} liveMatches=${json['liveMatches']}',
    );

    final list = json[sport.matchListKey] as List<dynamic>? ?? [];
    final totalPage = (json['totalPage'] as num?)?.toInt() ?? 1;

    return (
      matches: list
          .map(
            (item) =>
                SportMatch.fromSportJson(item as Map<String, dynamic>, sport),
          )
          .toList(),
      totalPage: totalPage,
    );
  }

  Future<List<SportMatch>> getScheduledMatches({required String date}) async {
    final dio = ref.read(sportsApiServiceProvider);
    const path = '/football/match/list/diary';
    final response = await dio.get(path, queryParameters: {'date': date});
    final json = response.data as Map<String, dynamic>;
    final list = json['footballMatchList'] as List<dynamic>? ?? [];
    return list
        .map(
          (item) => SportMatch.fromSportJson(
            item as Map<String, dynamic>,
            SportType.football,
          ),
        )
        .toList();
  }

  // ─── Generic sport detail / events / realtime ─────────────────────────────

  /// Fetches and parses the match detail for [sport].
  /// Returns `Object` — callers cast to the expected sport-specific type.
  Future<Object> getMatchDetail(SportType sport, String matchId) async {
    final parse = sport.config.parseDetail;
    assert(parse != null, 'No detail parser configured for $sport');
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('${sport.config.detailPath}/$matchId');
    return parse!(response.data as Map<String, dynamic>);
  }

  /// Fetches and parses the match events for [sport].
  /// Returns null if the sport has no events endpoint or the response is not a map.
  Future<Object?> getMatchEvents(SportType sport, String matchId) async {
    final parse = sport.config.parseEvents;
    if (parse == null) return null;
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('${sport.config.eventsPath}/$matchId');
    if (response.data is! Map<String, dynamic>) return null;
    return parse(response.data as Map<String, dynamic>);
  }

  /// Fetches the realtime list for [sport] as typed [SportRealtimeData] objects.
  Future<List<SportRealtimeData>> getTypedRealtime(SportType sport) async {
    final parse = sport.config.parseRealtime;
    if (parse == null) return const [];
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get(sport.config.realtimePath);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((item) => parse(item as Map<String, dynamic>)).toList();
  }

  // ─── Football-specific ────────────────────────────────────────────────────

  Future<FootballLineups?> getFootballMatchLineups(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/lineups/$matchId');
    if (response.data is! Map<String, dynamic>) return null;
    return FootballLineups.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Basketball-specific ──────────────────────────────────────────────────

  Future<List<BasketballPlayer>> getBasketballTeamSquad(String teamId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/basketball/team/squad/$teamId');
    final json = response.data as Map<String, dynamic>;
    if (json['teamPlayers'] is! List) return [];
    final list = json['teamPlayers'] as List<dynamic>? ?? [];
    return list
        .map((item) => BasketballPlayer.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
