import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart' show sportsApiServiceProvider;
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

part 'event_repository.g.dart';

@Riverpod(keepAlive: true)
class EventRepository extends _$EventRepository {
  @override
  void build() {}

  Future<List<SportMatch>> getHotLeagueMatches({required SportType sport}) async {
    final dio = ref.read(sportsApiServiceProvider);
    final path = '/${sport.apiPath}/match/list/today-hot-league';
    final response = await dio.get(path);

    final json = response.data as Map<String, dynamic>;
    final list = json[sport.matchListKey] as List<dynamic>? ?? [];

    return list
        .map((item) => SportMatch.fromSportJson(item as Map<String, dynamic>, sport))
        .toList();
  }

  Future<List<SportMatch>> getMatches({
    required SportType sport,
    String matchStatus = 'all',
    String? date,
  }) async {
    final dio = ref.read(sportsApiServiceProvider);
    final path = '/${sport.apiPath}/match/list/today-by-match-time';
    final response = await dio.get(
      path,
      queryParameters: {'matchStatus': matchStatus, 'date': ?date},
    );

    final json = response.data as Map<String, dynamic>;
    debugPrint('[EventRepository] ${sport.apiPath} liveMatches=${json['liveMatches']}');

    final list = json[sport.matchListKey] as List<dynamic>? ?? [];

    return list
        .map((item) => SportMatch.fromSportJson(item as Map<String, dynamic>, sport))
        .toList();
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

  Future<FootballMatchEvents> getFootballMatchEventsKey(String matchId) async {
    final dio = ref.read(sportsApiServiceProvider);
    final response = await dio.get('/football/match/events/key/$matchId');
    return FootballMatchEvents.fromJson(response.data as Map<String, dynamic>);
  }
}
