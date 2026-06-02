import 'dart:convert';

class WatchlistEntry {
  const WatchlistEntry({
    required this.matchId,
    required this.sport,
    required this.homeName,
    required this.awayName,
    required this.leagueName,
    required this.matchTimeMs,
  });

  final String matchId;
  final String sport;
  final String homeName;
  final String awayName;
  final String leagueName;

  /// Epoch milliseconds (UTC).
  final int matchTimeMs;

  DateTime get matchTime => DateTime.fromMillisecondsSinceEpoch(matchTimeMs);

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'sport': sport,
    'homeName': homeName,
    'awayName': awayName,
    'leagueName': leagueName,
    'matchTimeMs': matchTimeMs,
  };

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    matchId: json['matchId'] as String,
    sport: json['sport'] as String,
    homeName: json['homeName'] as String,
    awayName: json['awayName'] as String,
    leagueName: json['leagueName'] as String? ?? '',
    matchTimeMs: json['matchTimeMs'] as int,
  );

  static WatchlistEntry? tryFromRaw(String raw) {
    try {
      return WatchlistEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  String toRaw() => jsonEncode(toJson());
}
