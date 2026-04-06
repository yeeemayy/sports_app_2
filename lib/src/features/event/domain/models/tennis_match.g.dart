// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tennis_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TennisMatchImpl _$$TennisMatchImplFromJson(Map<String, dynamic> json) =>
    _$TennisMatchImpl(
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
      bestof: (json['bestof'] as num?)?.toInt(),
      scores: json['scores'] as Map<String, dynamic>?,
      oddsEuro: json['oddsEuro'] as List<dynamic>?,
      statusDescription: json['statusDescription'] as String?,
    );

Map<String, dynamic> _$$TennisMatchImplToJson(_$TennisMatchImpl instance) =>
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
      'bestof': instance.bestof,
      'scores': instance.scores,
      'oddsEuro': instance.oddsEuro,
      'statusDescription': instance.statusDescription,
    };
