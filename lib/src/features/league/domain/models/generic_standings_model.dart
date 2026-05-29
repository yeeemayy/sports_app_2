/// Generic standings models used by all sports except Football & Basketball,
/// which have their own richer models.
///
/// Key challenge: the API may return `teamInfo` as either a Map or an empty
/// List `[]` when the participant has no registered info.  We handle this with
/// [GenericStandingsTeamInfo.fromJsonOrNull].

class GenericStandingsTeamInfo {
  final String id;
  final String name;
  final String? shortName;
  final String? abbr;
  final String logo;
  final String? cnName;

  const GenericStandingsTeamInfo({
    required this.id,
    required this.name,
    this.shortName,
    this.abbr,
    this.logo = '',
    this.cnName,
  });

  /// Returns null when [json] is not a Map (e.g. it is an empty List `[]`).
  static GenericStandingsTeamInfo? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return GenericStandingsTeamInfo(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      shortName: json['short_name'] as String?,
      abbr: json['abbr'] as String?,
      logo: (json['logo'] as String?) ?? '',
      cnName: json['cn_name'] as String?,
    );
  }
}

class GenericStandingsRow {
  final String teamId;
  final int position;

  /// Wins – normalised from either "win" or "won" key
  final int? wins;

  /// Losses – normalised from either "loss" or "lost" key
  final int? losses;

  final int? draws;
  final int? total;
  final int? points;
  final int? goals;
  final int? goalsAgainst;
  final double? winRate;

  // Ice hockey only
  final int? overtimeWin;
  final int? overtimeLoss;
  final int? shootoutWin;
  final int? shootoutLoss;

  final GenericStandingsTeamInfo? teamInfo;

  const GenericStandingsRow({
    required this.teamId,
    required this.position,
    this.wins,
    this.losses,
    this.draws,
    this.total,
    this.points,
    this.goals,
    this.goalsAgainst,
    this.winRate,
    this.overtimeWin,
    this.overtimeLoss,
    this.shootoutWin,
    this.shootoutLoss,
    this.teamInfo,
  });

  factory GenericStandingsRow.fromJson(Map<String, dynamic> json) {
    int? _int(String key) {
      final v = json[key];
      if (v == null) return null;
      return (v as num).toInt();
    }

    return GenericStandingsRow(
      teamId: (json['team_id'] as String?) ?? '',
      position: ((json['position'] as num?)?.toInt()) ?? 0,
      wins: _int('win') ?? _int('won'),
      losses: _int('loss') ?? _int('lost'),
      draws: _int('draw'),
      total: _int('total'),
      points: _int('points'),
      goals: _int('goals'),
      goalsAgainst: _int('goals_against'),
      winRate: json['win_rate'] != null
          ? (json['win_rate'] as num).toDouble()
          : null,
      overtimeWin: _int('overtime_win'),
      overtimeLoss: _int('overtime_loss'),
      shootoutWin: _int('shootout_win'),
      shootoutLoss: _int('shootout_loss'),
      teamInfo: GenericStandingsTeamInfo.fromJsonOrNull(json['teamInfo']),
    );
  }
}

class GenericStandingsGroup {
  final String id;
  final String name;
  final String? stageId;
  final List<GenericStandingsRow> rows;

  const GenericStandingsGroup({
    required this.id,
    required this.name,
    this.stageId,
    required this.rows,
  });

  factory GenericStandingsGroup.fromJson(Map<String, dynamic> json) {
    final rawRows = (json['rows'] as List?) ?? [];
    return GenericStandingsGroup(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      stageId: json['stage_id'] as String?,
      rows: rawRows
          .map((r) => GenericStandingsRow.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
