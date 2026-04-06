// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'football_lineup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineupPlayerImpl _$$LineupPlayerImplFromJson(Map<String, dynamic> json) =>
    _$LineupPlayerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      cnName: json['cn_name'] as String?,
      logo: json['logo'] as String,
      shirtNumber: (json['shirt_number'] as num).toInt(),
      position: json['position'] as String,
      x: (json['x'] as num?)?.toInt(),
      y: (json['y'] as num?)?.toInt(),
      rating: json['rating'] as String,
      first: (json['first'] as num).toInt(),
      captain: (json['captain'] as num).toInt(),
    );

Map<String, dynamic> _$$LineupPlayerImplToJson(_$LineupPlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cn_name': instance.cnName,
      'logo': instance.logo,
      'shirt_number': instance.shirtNumber,
      'position': instance.position,
      'x': instance.x,
      'y': instance.y,
      'rating': instance.rating,
      'first': instance.first,
      'captain': instance.captain,
    };

_$FootballLineupsImpl _$$FootballLineupsImplFromJson(
  Map<String, dynamic> json,
) => _$FootballLineupsImpl(
  home: (json['home'] as List<dynamic>)
      .map((e) => LineupPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  away: (json['away'] as List<dynamic>)
      .map((e) => LineupPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$FootballLineupsImplToJson(
  _$FootballLineupsImpl instance,
) => <String, dynamic>{'home': instance.home, 'away': instance.away};
