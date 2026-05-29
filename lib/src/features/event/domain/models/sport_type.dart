import 'package:flutter/material.dart';

enum SportType {
  football('football', 'footballMatchList', 'event.sport.football'),
  basketball('basketball', 'basketballMatchList', 'event.sport.basketball'),
  tennis('tennis', 'tennisMatchList', 'event.sport.tennis'),
  cricket('cricket', 'cricketMatchList', 'event.sport.cricket'),
  baseball('baseball', 'baseballMatchList', 'event.sport.baseball'),
  volleyball('volleyball', 'volleyballMatchList', 'event.sport.volleyball'),
  badminton('badminton', 'badmintonMatchList', 'event.sport.badminton'),
  tableTennis(
    'table_tennis',
    'table_tennisMatchList',
    'event.sport.table_tennis',
  ),
  iceHockey('hockey', 'hockeyMatchList', 'event.sport.ice_hockey'),
  amFootball('amfootball', 'amFootballMatchList', 'event.sport.am_football');

  const SportType(this.apiPath, this.matchListKey, this.i18nKey);
  final String apiPath;
  final String matchListKey;
  final String i18nKey;

  String get heroAsset => switch (this) {
    SportType.football => 'assets/images/football.jpg',
    SportType.basketball => 'assets/images/basketball.jpg',
    SportType.tennis => 'assets/images/tennis.jpg',
    SportType.cricket => 'assets/images/cricket.jpg',
    SportType.baseball => 'assets/images/baseball.jpg',
    SportType.volleyball => 'assets/images/volleyball.jpg',
    SportType.badminton => 'assets/images/badminton.jpg',
    SportType.tableTennis => 'assets/images/table_tennis.jpg',
    SportType.iceHockey => 'assets/images/ice_hockey.jpg',
    SportType.amFootball => 'assets/images/am_football.jpg',
  };

  IconData get icon => switch (this) {
    SportType.football => Icons.sports_soccer,
    SportType.basketball => Icons.sports_basketball,
    SportType.tennis => Icons.sports_tennis,
    SportType.cricket => Icons.sports_cricket,
    SportType.baseball => Icons.sports_baseball,
    SportType.volleyball => Icons.sports_volleyball,
    SportType.badminton => Icons.sports_handball,
    SportType.tableTennis => Icons.sports,
    SportType.iceHockey => Icons.sports_hockey,
    SportType.amFootball => Icons.sports_football,
  };
}
