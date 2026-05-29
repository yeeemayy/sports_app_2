class AmFootballLineupPlayerInfo {
  final String? countryId;
  final String name;
  final String? shortName;
  final String? logo;

  const AmFootballLineupPlayerInfo({
    this.countryId,
    required this.name,
    this.shortName,
    this.logo,
  });

  factory AmFootballLineupPlayerInfo.fromJson(Map<String, dynamic> json) {
    return AmFootballLineupPlayerInfo(
      countryId: json['country_id'] as String?,
      name: (json['name'] as String?) ?? '',
      shortName: json['short_name'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

class AmFootballLineupPlayer {
  final String teamId;
  final String playerId;
  final String position;
  final String jerseyNo;
  final AmFootballLineupPlayerInfo? playerInfo;

  const AmFootballLineupPlayer({
    required this.teamId,
    required this.playerId,
    required this.position,
    required this.jerseyNo,
    this.playerInfo,
  });

  factory AmFootballLineupPlayer.fromJson(Map<String, dynamic> json) {
    final info = json['playerInfo'];
    return AmFootballLineupPlayer(
      teamId: (json['team_id'] as String?) ?? '',
      playerId: (json['player_id'] as String?) ?? '',
      position: (json['position'] as String?) ?? '',
      jerseyNo: (json['jersery_no'] as String?) ?? '',
      playerInfo: info is Map<String, dynamic>
          ? AmFootballLineupPlayerInfo.fromJson(info)
          : null,
    );
  }
}
