// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'football_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FootballMatchImpl _$$FootballMatchImplFromJson(Map<String, dynamic> json) =>
    _$FootballMatchImpl(
      id: json['id'] as String,
      statusId: (json['statusId'] as num).toInt(),
      matchTimeSim: json['matchTimeSim'] as String,
      homeName: json['homeName'] as String,
      homeLogo: json['homeLogo'] as String,
      homeScore: json['homeScore'] as String,
      awayName: json['awayName'] as String,
      awayLogo: json['awayLogo'] as String,
      awayScore: json['awayScore'] as String,
      leagueName: json['leagueName'] as String,
      leagueLogo: json['leagueLogo'] as String,
      matchTime: (json['matchTime'] as num?)?.toInt(),
      counterTiming: (json['counterTiming'] as num?)?.toInt(),
      oddsEuro: json['oddsEuro'] as List<dynamic>?,
      statusDescription: json['statusDescription'] as String?,
      htHomeScore: json['htHomeScore'] as String?,
      htAwayScore: json['htAwayScore'] as String?,
    );

Map<String, dynamic> _$$FootballMatchImplToJson(_$FootballMatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'statusId': instance.statusId,
      'matchTimeSim': instance.matchTimeSim,
      'homeName': instance.homeName,
      'homeLogo': instance.homeLogo,
      'homeScore': instance.homeScore,
      'awayName': instance.awayName,
      'awayLogo': instance.awayLogo,
      'awayScore': instance.awayScore,
      'leagueName': instance.leagueName,
      'leagueLogo': instance.leagueLogo,
      'matchTime': instance.matchTime,
      'counterTiming': instance.counterTiming,
      'oddsEuro': instance.oddsEuro,
      'statusDescription': instance.statusDescription,
      'htHomeScore': instance.htHomeScore,
      'htAwayScore': instance.htAwayScore,
    };
