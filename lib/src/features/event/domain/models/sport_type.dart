import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/features/event/domain/am_football_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/badminton_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/baseball_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/basketball_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/cricket_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/football_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/ice_hockey_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/table_tennis_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/tennis_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/volleyball_status.dart';

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

  String statusLabel(int statusId, [String? fallback]) => switch (this) {
    SportType.football => footballStatusLabel(statusId, fallback),
    SportType.basketball => basketballStatusLabel(statusId, fallback),
    SportType.tennis => tennisStatusLabel(statusId, fallback),
    SportType.cricket => cricketStatusLabel(statusId, fallback),
    SportType.baseball => baseballStatusLabel(statusId),
    SportType.volleyball => volleyballStatusLabel(statusId, fallback),
    SportType.badminton => badmintonStatusLabel(statusId, fallback),
    SportType.tableTennis => tableTennisStatusLabel(statusId, fallback),
    SportType.iceHockey => iceHockeyStatusLabel(statusId, fallback),
    SportType.amFootball => amFootballStatusLabel(statusId, fallback),
  };

  bool isLiveStatus(int statusId) => switch (this) {
    SportType.football => footballIsLive(statusId),
    SportType.basketball => basketballIsLive(statusId),
    SportType.tennis => tennisIsLive(statusId),
    SportType.cricket => cricketIsLive(statusId),
    SportType.baseball => baseballIsLive(statusId),
    SportType.volleyball => volleyballIsLive(statusId),
    SportType.badminton => badmintonIsLive(statusId),
    SportType.tableTennis => tableTennisIsLive(statusId),
    SportType.iceHockey => iceHockeyIsLive(statusId),
    SportType.amFootball => amFootballIsLive(statusId),
  };
}
