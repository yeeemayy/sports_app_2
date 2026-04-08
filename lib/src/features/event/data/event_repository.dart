import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart' show sportsApiServiceProvider;
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

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
          .map((item) => SportMatch.fromSportJson(item as Map<String, dynamic>, sport))
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
      queryParameters: {'matchStatus': matchStatus, 'date': ?date, 'page': page},
    );

    final json = response.data as Map<String, dynamic>;
    debugPrint('[EventRepository] ${sport.apiPath} liveMatches=${json['liveMatches']}');

    final list = json[sport.matchListKey] as List<dynamic>? ?? [];
    final totalPage = (json['totalPage'] as num?)?.toInt() ?? 1;

    return (
      matches: list
          .map((item) => SportMatch.fromSportJson(item as Map<String, dynamic>, sport))
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
        .map((item) => SportMatch.fromSportJson(item as Map<String, dynamic>, SportType.football))
        .toList();
  }

  Future<FootballMatchDetail> getFootballMatchDetail(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/details/$matchId');
    return FootballMatchDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FootballLineups?> getFootballMatchLineups(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/lineups/$matchId');
    if (response.data is! Map<String, dynamic>) {
      return null;
    }
    return FootballLineups.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FootballMatchEvents?> getFootballMatchEventsKey(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/events/key/$matchId');
    if (response.data is! Map<String, dynamic>) {
      return null;
    }
    return FootballMatchEvents.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MatchRealtimeData>> getRealtimeMatches() async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/realtime');
    final list = response.data as List<dynamic>? ?? [];
    return list.map((item) => MatchRealtimeData.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<BasketballMatchDetail> getBasketballMatchDetail(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/basketball/match/details/$matchId');
    return BasketballMatchDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BasketballMatchEventsData?> getBasketballMatchEventsKey(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/basketball/match/events/$matchId');
    if (response.data is! Map<String, dynamic>) return null;
    return BasketballMatchEventsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BasketballRealtimeData>> getBasketballRealtimeMatches() async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/basketball/match/realtime');
    final list = response.data as List<dynamic>? ?? [];
    return list
        .map((item) => BasketballRealtimeData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BasketballPlayer>> getBasketballTeamSquad(String teamId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/basketball/team/squad/$teamId');
    final json = response.data as Map<String, dynamic>;
    if (json['teamPlayers'] is! List) return [];
    final list = json['teamPlayers'] as List<dynamic>? ?? [];
    return list.map((item) => BasketballPlayer.fromJson(item as Map<String, dynamic>)).toList();
  }
}
