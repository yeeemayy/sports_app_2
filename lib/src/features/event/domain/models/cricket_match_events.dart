import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/cricket_match_detail.dart';

@immutable
class CricketBall {
  const CricketBall({
    required this.overNumber,
    required this.ballNumber,
    required this.runs,
    required this.extraRuns,
    required this.extraType,
    required this.isWicket,
  });

  final int overNumber;
  final int ballNumber;
  final int runs;
  final int extraRuns;

  /// WD = wide, NB = no ball, B = bye, LB = leg bye, P = penalty, "" = normal
  final String extraType;
  final bool isWicket;

  bool get isExtra => extraType.isNotEmpty;
  int get totalRuns => runs + extraRuns;
}

@immutable
class CricketOver {
  const CricketOver({required this.overNumber, required this.balls});

  final int overNumber;
  final List<CricketBall> balls;

  int get totalRuns => balls.fold(0, (s, b) => s + b.runs + b.extraRuns);
  int get wicketCount => balls.where((b) => b.isWicket).length;
}

@immutable
class CricketTimelineInning {
  const CricketTimelineInning({
    required this.inning,
    required this.teamId,
    required this.overs,
  });

  final int inning;
  final String teamId;
  final List<CricketOver> overs;
}

@immutable
class CricketBattingStats {
  const CricketBattingStats({
    required this.teamId,
    required this.runs,
    required this.ballsFaced,
    required this.fours,
    required this.sixes,
  });

  final String teamId;
  final int runs;
  final int ballsFaced;
  final int fours;
  final int sixes;
}

@immutable
class CricketBowlingStats {
  const CricketBowlingStats({
    required this.teamId,
    required this.wides,
    required this.byes,
    required this.legByes,
    required this.noBalls,
    required this.penalty,
    required this.extra,
  });

  final String teamId;
  final int wides;
  final int byes;
  final int legByes;
  final int noBalls;
  final int penalty;
  final int extra;
}

@immutable
class CricketInningPlayerStats {
  const CricketInningPlayerStats({
    required this.inning,
    required this.batting,
    required this.bowling,
  });

  final int inning;
  final CricketBattingStats batting;
  final CricketBowlingStats bowling;
}

@immutable
class CricketMatchEventsData {
  const CricketMatchEventsData({
    required this.id,
    required this.statusId,
    required this.battingTeam,
    required this.homeScore,
    required this.awayScore,
    required this.innings,
    this.results,
    this.timeline = const [],
    this.inningStats = const [],
  });

  final String id;
  final int statusId;

  /// 1 = home batting, 2 = away batting
  final int battingTeam;
  final int homeScore;
  final int awayScore;
  final List<CricketInnings> innings;
  final CricketResults? results;
  final List<CricketTimelineInning> timeline;

  /// Pre-aggregated batting/bowling stats per inning from the server.
  final List<CricketInningPlayerStats> inningStats;

  factory CricketMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];

    final id = score.isNotEmpty ? score[0] as String? ?? '' : '';
    final statusId = score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0;
    final battingTeam = score.length > 2 ? (score[2] as num?)?.toInt() ?? 0 : 0;

    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final ft = scoreData['ft'] as List<dynamic>?;
    final homeScore = (ft?[0] as num?)?.toInt() ?? 0;
    final awayScore = (ft?[1] as num?)?.toInt() ?? 0;

    // extra_scores is at score[4]
    final extraScores = score.length > 4 && score[4] is Map
        ? (score[4] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final rawInnings = extraScores['innings'] as List<dynamic>? ?? [];
    final innings = rawInnings
        .whereType<List<dynamic>>()
        .map((i) => CricketInnings.fromList(i))
        .toList();

    final rawResults = extraScores['results'];
    CricketResults? results;
    if (rawResults is Map) {
      results = CricketResults.fromJson(rawResults.cast<String, dynamic>());
    }

    final timeline = _parseTimeline(json['timeline'] as List<dynamic>? ?? []);
    final inningStats = _parseInningStats(
      json['players'] as List<dynamic>? ?? [],
    );

    return CricketMatchEventsData(
      id: id,
      statusId: statusId,
      battingTeam: battingTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      innings: innings,
      results: results,
      timeline: timeline,
      inningStats: inningStats,
    );
  }

  static List<CricketInningPlayerStats> _parseInningStats(List<dynamic> raw) {
    return raw.whereType<Map>().map((item) {
      final map = item.cast<String, dynamic>();
      final inning = (map['inning'] as num?)?.toInt() ?? 0;
      final bat = map['batting'] is Map
          ? (map['batting'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final bowl = map['bowling'] is Map
          ? (map['bowling'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      return CricketInningPlayerStats(
        inning: inning,
        batting: CricketBattingStats(
          teamId: bat['team_id'] as String? ?? '',
          runs: (bat['runs'] as num?)?.toInt() ?? 0,
          ballsFaced: (bat['balls_faced'] as num?)?.toInt() ?? 0,
          fours: (bat['fours'] as num?)?.toInt() ?? 0,
          sixes: (bat['sixes'] as num?)?.toInt() ?? 0,
        ),
        bowling: CricketBowlingStats(
          teamId: bowl['team_id'] as String? ?? '',
          wides: (bowl['wides'] as num?)?.toInt() ?? 0,
          byes: (bowl['byes'] as num?)?.toInt() ?? 0,
          legByes: (bowl['leg_byes'] as num?)?.toInt() ?? 0,
          noBalls: (bowl['no_balls'] as num?)?.toInt() ?? 0,
          penalty: (bowl['penalty'] as num?)?.toInt() ?? 0,
          extra: (bowl['extra'] as num?)?.toInt() ?? 0,
        ),
      );
    }).toList();
  }

  static List<CricketTimelineInning> _parseTimeline(List<dynamic> raw) {
    return raw.whereType<Map>().map((item) {
      final map = item.cast<String, dynamic>();
      final inning = (map['inning'] as num?)?.toInt() ?? 0;
      final teamId = map['team_id'] as String? ?? '';
      final rawBalls = map['overs'] as List<dynamic>? ?? [];
      final rawWickets = map['wickets'] as List<dynamic>? ?? [];

      final wicketSet = <String>{};
      for (final w in rawWickets.whereType<List>()) {
        if (w.length >= 2) wicketSet.add('${w[0]}_${w[1]}');
      }

      final oversMap = <int, List<CricketBall>>{};
      for (final b in rawBalls.whereType<List>()) {
        if (b.length < 5) continue;
        final overNum = (b[0] as num).toInt();
        final ballNum = (b[1] as num).toInt();
        final runs = (b[2] as num).toInt();
        final extraRuns = (b[3] as num).toInt();
        final extraType = b[4] as String? ?? '';
        final isWicket = wicketSet.contains('${overNum}_${ballNum}');

        oversMap
            .putIfAbsent(overNum, () => [])
            .add(
              CricketBall(
                overNumber: overNum,
                ballNumber: ballNum,
                runs: runs,
                extraRuns: extraRuns,
                extraType: extraType,
                isWicket: isWicket,
              ),
            );
      }

      final overs = oversMap.entries.map((e) {
        final sortedBalls = List<CricketBall>.from(e.value)
          ..sort((a, b) => a.ballNumber.compareTo(b.ballNumber));
        return CricketOver(overNumber: e.key, balls: sortedBalls);
      }).toList()..sort((a, b) => a.overNumber.compareTo(b.overNumber));

      return CricketTimelineInning(
        inning: inning,
        teamId: teamId,
        overs: overs,
      );
    }).toList();
  }
}
