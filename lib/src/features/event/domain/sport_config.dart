import 'package:sports_app/src/features/event/domain/models/badminton_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';

/// Per-sport API + parsing configuration.
/// Used by the generic repository methods and the [SportRealtime] family provider.
class SportConfig {
  const SportConfig({
    required this.detailPath,
    required this.eventsPath,
    required this.realtimePath,
    required this.pollInterval,
    this.parseDetail,
    this.parseEvents,
    this.parseRealtime,
  });

  /// Base path for the detail endpoint, e.g. '/football/match/details'.
  final String detailPath;

  /// Base path for the events endpoint, e.g. '/football/match/events/key'.
  final String eventsPath;

  /// Path for the realtime list endpoint, e.g. '/football/match/realtime'.
  final String realtimePath;

  final Duration pollInterval;

  /// Null for sports without a detail screen yet.
  final Object Function(Map<String, dynamic>)? parseDetail;

  /// Null for sports without an events endpoint.
  final Object Function(Map<String, dynamic>)? parseEvents;

  /// Null for sports without a realtime endpoint yet.
  final SportRealtimeData Function(Map<String, dynamic>)? parseRealtime;
}

const _configs = <SportType, SportConfig>{
  SportType.football: SportConfig(
    detailPath: '/football/match/details',
    eventsPath: '/football/match/events/key',
    realtimePath: '/football/match/realtime',
    pollInterval: Duration(seconds: 1),
    parseDetail: FootballMatchDetail.fromJson,
    parseEvents: FootballMatchEvents.fromJson,
    parseRealtime: MatchRealtimeData.fromJson,
  ),
  SportType.basketball: SportConfig(
    detailPath: '/basketball/match/details',
    eventsPath: '/basketball/match/events',
    realtimePath: '/basketball/match/realtime',
    pollInterval: Duration(seconds: 2),
    parseDetail: BasketballMatchDetail.fromJson,
    parseEvents: BasketballMatchEventsData.fromJson,
    parseRealtime: BasketballRealtimeData.fromJson,
  ),
  SportType.tennis: SportConfig(
    detailPath: '/tennis/match/details',
    eventsPath: '/tennis/match/events',
    realtimePath: '/tennis/match/realtime',
    pollInterval: Duration(seconds: 2),
    parseDetail: TennisMatchDetail.fromJson,
    parseEvents: TennisMatchEventsData.fromJson,
    parseRealtime: TennisRealtimeData.fromJson,
  ),
  SportType.badminton: SportConfig(
    detailPath: '/badminton/match/details',
    eventsPath: '/badminton/match/events',
    realtimePath: '/badminton/match/realtime',
    pollInterval: Duration(seconds: 2),
    parseDetail: BadmintonMatchDetail.fromJson,
    parseEvents: BadmintonMatchEventsData.fromJson,
    parseRealtime: BadmintonRealtimeData.fromJson,
  ),
  SportType.baseball: SportConfig(
    detailPath: '/baseball/match/details',
    eventsPath: '/baseball/match/events',
    realtimePath: '/baseball/match/realtime',
    pollInterval: Duration(seconds: 5),
    parseDetail: BaseballMatchDetail.fromJson,
    parseEvents: BaseballMatchEventsData.fromJson,
    parseRealtime: BaseballRealtimeData.fromJson,
  ),
  SportType.tableTennis: SportConfig(
    detailPath: '/table_tennis/match/details',
    eventsPath: '/table_tennis/match/events',
    realtimePath: '/table_tennis/match/realtime',
    pollInterval: Duration(seconds: 2),
    parseDetail: TableTennisMatchDetail.fromJson,
    parseEvents: TableTennisMatchEventsData.fromJson,
    parseRealtime: TableTennisRealtimeData.fromJson,
  ),
  SportType.cricket: SportConfig(
    detailPath: '/cricket/match/details',
    eventsPath: '/cricket/match/events',
    realtimePath: '/cricket/match/realtime',
    pollInterval: Duration(seconds: 5),
  ),
  SportType.volleyball: SportConfig(
    detailPath: '/volleyball/match/details',
    eventsPath: '/volleyball/match/events',
    realtimePath: '/volleyball/match/realtime',
    pollInterval: Duration(seconds: 2),
  ),
  SportType.iceHockey: SportConfig(
    detailPath: '/hockey/match/details',
    eventsPath: '/hockey/match/events',
    realtimePath: '/hockey/match/realtime',
    pollInterval: Duration(seconds: 2),
  ),
  SportType.amFootball: SportConfig(
    detailPath: '/amfootball/match/details',
    eventsPath: '/amfootball/match/events',
    realtimePath: '/amfootball/match/realtime',
    pollInterval: Duration(seconds: 2),
  ),
};

extension SportTypeConfig on SportType {
  SportConfig get config => _configs[this]!;
}
