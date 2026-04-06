import 'package:sports_app/src/core/utils/app_locale.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

abstract class SportMatch {
  String get id;
  int get statusId;
  String get matchTimeSim;
  int? get matchTime;

  String get homeName;
  String get homeLogo;
  String get homeScore;

  String get awayName;
  String get awayLogo;
  String get awayScore;

  String get leagueName;
  String get leagueLogo;

  String? get statusDescription;
  List<dynamic>? get oddsEuro;

  /// Sport-specific live clock string (e.g. "35'" for football, "01:23" for basketball).
  String? get liveMinute;

  static SportMatch fromSportJson(Map<String, dynamic> json, SportType sport) {
    return switch (sport) {
      SportType.football => FootballMatch.fromSportJson(json),
      SportType.basketball => BasketballMatch.fromSportJson(json),
      SportType.tennis => TennisMatch.fromSportJson(json),
      SportType.cricket => CricketMatch.fromSportJson(json),
      SportType.baseball => BaseballMatch.fromSportJson(json),
      SportType.volleyball => VolleyballMatch.fromSportJson(json),
      SportType.badminton => BadmintonMatch.fromSportJson(json),
      SportType.tableTennis => TableTennisMatch.fromSportJson(json),
      SportType.iceHockey => IceHockeyMatch.fromSportJson(json),
      SportType.amFootball => AmFootballMatch.fromSportJson(json),
    };
  }

  /// Extracts a localised team/league name based on the current app locale.
  /// Prefers Chinese names when locale is zh, English names otherwise.
  static String teamName(Map<String, dynamic> info) {
    final cn = info['cn_name'] as String?;
    final en = info['en_name'] as String? ??
        info['en_short_name'] as String? ??
        info['short_name'] as String?;
    if (AppLocale.isChinese) {
      return (cn != null && cn.isNotEmpty) ? cn : (en ?? '');
    } else {
      return (en != null && en.isNotEmpty) ? en : (cn ?? '');
    }
  }

  /// Parses [home, away] total score from the top-level `scores.ft` list.
  static (String, String) ftScore(Map<String, dynamic> json) {
    final scores = json['scores'];
    if (scores is Map) {
      final ft = scores['ft'] as List?;
      if (ft != null && ft.length >= 2) {
        return (ft[0].toString(), ft[1].toString());
      }
    }
    return ('-', '-');
  }
}
