enum LeagueSport {
  football,
  basketball,
  tennis,
  cricket,
  baseball,
  volleyball,
  badminton,
  tableTennis,
  iceHockey,
  amFootball;

  String get labelKey => switch (this) {
    LeagueSport.football => 'league.sport.football',
    LeagueSport.basketball => 'league.sport.basketball',
    LeagueSport.tennis => 'league.sport.tennis',
    LeagueSport.cricket => 'league.sport.cricket',
    LeagueSport.baseball => 'league.sport.baseball',
    LeagueSport.volleyball => 'league.sport.volleyball',
    LeagueSport.badminton => 'league.sport.badminton',
    LeagueSport.tableTennis => 'league.sport.table_tennis',
    LeagueSport.iceHockey => 'league.sport.ice_hockey',
    LeagueSport.amFootball => 'league.sport.am_football',
  };

  String get apiPath => switch (this) {
    LeagueSport.football => 'football',
    LeagueSport.basketball => 'basketball',
    LeagueSport.tennis => 'tennis',
    LeagueSport.cricket => 'cricket',
    LeagueSport.baseball => 'baseball',
    LeagueSport.volleyball => 'volleyball',
    LeagueSport.badminton => 'badminton',
    LeagueSport.tableTennis => 'table_tennis',
    LeagueSport.iceHockey => 'hockey',
    LeagueSport.amFootball => 'amfootball',
  };

  /// JSON key for the hot leagues list response
  String get hotLeaguesListKey => switch (this) {
    LeagueSport.football => 'footballHotLeaguesList',
    LeagueSport.basketball => 'basketballHotLeaguesList',
    LeagueSport.tennis => 'tennisHotLeaguesList',
    LeagueSport.cricket => 'cricketHotLeaguesList',
    LeagueSport.baseball => 'baseballHotLeaguesList',
    LeagueSport.volleyball => 'volleyballHotLeaguesList',
    LeagueSport.badminton => 'badmintonHotLeaguesList',
    LeagueSport.tableTennis => 'table_tennisHotLeaguesList',
    LeagueSport.iceHockey => 'HockeyHotLeaguesList',
    LeagueSport.amFootball => 'amFootballHotLeaguesList',
  };

  /// Whether this sport uses /category/list (true), /country/list (false),
  /// or has no browse at all (null).
  bool? get usesCategoryBrowse => switch (this) {
    LeagueSport.football => false,
    LeagueSport.basketball => false,
    LeagueSport.tennis => null,
    LeagueSport.cricket => true,
    LeagueSport.baseball => false,
    LeagueSport.volleyball => false,
    LeagueSport.badminton => true,
    LeagueSport.tableTennis => true,
    LeagueSport.iceHockey => true,
    LeagueSport.amFootball => true,
  };

  /// Whether this sport has standings data worth showing
  bool get hasStandings => switch (this) {
    LeagueSport.volleyball => false,
    _ => true,
  };

  /// Whether this sport has player-stats and top-scorers tab
  bool get hasPlayerStats => switch (this) {
    LeagueSport.football => true,
    LeagueSport.basketball => true,
    _ => false,
  };

  /// Whether this sport has team-stats tab
  bool get hasTeamStats => switch (this) {
    LeagueSport.football => true,
    LeagueSport.basketball => true,
    _ => false,
  };

  /// Whether this sport has squad browsing
  bool get hasSquads => switch (this) {
    LeagueSport.football => true,
    LeagueSport.basketball => true,
    _ => false,
  };

  static LeagueSport fromString(String value) => switch (value) {
    'basketball' => LeagueSport.basketball,
    'tennis' => LeagueSport.tennis,
    'cricket' => LeagueSport.cricket,
    'baseball' => LeagueSport.baseball,
    'volleyball' => LeagueSport.volleyball,
    'badminton' => LeagueSport.badminton,
    'table_tennis' => LeagueSport.tableTennis,
    'hockey' => LeagueSport.iceHockey,
    'amfootball' => LeagueSport.amFootball,
    _ => LeagueSport.football,
  };
}
