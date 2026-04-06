// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basketball_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BasketballMatchImpl _$$BasketballMatchImplFromJson(
  Map<String, dynamic> json,
) => _$BasketballMatchImpl(
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
  counterTiming: json['counterTiming'] as String?,
  runningTime: (json['runningTime'] as num?)?.toInt(),
  oddsEuro: json['oddsEuro'] as List<dynamic>?,
  statusDescription: json['statusDescription'] as String?,
);

Map<String, dynamic> _$$BasketballMatchImplToJson(
  _$BasketballMatchImpl instance,
) => <String, dynamic>{
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
  'runningTime': instance.runningTime,
  'oddsEuro': instance.oddsEuro,
  'statusDescription': instance.statusDescription,
};
