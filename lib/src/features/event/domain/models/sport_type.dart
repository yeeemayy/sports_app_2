enum SportType {
  football('football', 'footballMatchList', 'event.sport.football'),
  basketball('basketball', 'basketballMatchList', 'event.sport.basketball'),
  tennis('tennis', 'tennisMatchList', 'event.sport.tennis'),
  cricket('cricket', 'cricketMatchList', 'event.sport.cricket'),
  baseball('baseball', 'baseballMatchList', 'event.sport.baseball'),
  volleyball('volleyball', 'volleyballMatchList', 'event.sport.volleyball'),
  badminton('badminton', 'badmintonMatchList', 'event.sport.badminton'),
  tableTennis('table_tennis', 'table_tennisMatchList', 'event.sport.table_tennis'),
  iceHockey('hockey', 'hockeyMatchList', 'event.sport.ice_hockey'),
  amFootball('amfootball', 'amFootballMatchList', 'event.sport.am_football');

  const SportType(this.apiPath, this.matchListKey, this.i18nKey);
  final String apiPath;
  final String matchListKey;
  final String i18nKey;
}
