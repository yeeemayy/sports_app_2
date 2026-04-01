// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnchorDetailModelImpl _$$AnchorDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$AnchorDetailModelImpl(
  id: (json['id'] as num).toInt(),
  isLive: (json['isLive'] as num).toInt(),
  nickname: json['nickname'] as String,
  avatarUrl: json['avatarUrl'] as String,
  collectStatus: (json['collect_status'] as num).toInt(),
  title: json['title'] as String,
  collect: (json['collect'] as num).toInt(),
  notice: json['notice'] as String,
  liveMode: (json['liveMode'] as num).toInt(),
  m3u8Url: json['m3u8Url'] as String?,
  cover: json['cover'] as String,
  matchId: json['matchId'] as String,
  mode: json['mode'] as String? ?? '',
  live: json['live'] as List<dynamic>? ?? [],
  schedule: json['schedule'] as String? ?? '',
  playAnimate: json['playAnimate'] as bool? ?? false,
  client: json['client'] as String? ?? '',
  updated: json['updated'] as String,
);

Map<String, dynamic> _$$AnchorDetailModelImplToJson(
  _$AnchorDetailModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'isLive': instance.isLive,
  'nickname': instance.nickname,
  'avatarUrl': instance.avatarUrl,
  'collect_status': instance.collectStatus,
  'title': instance.title,
  'collect': instance.collect,
  'notice': instance.notice,
  'liveMode': instance.liveMode,
  'm3u8Url': instance.m3u8Url,
  'cover': instance.cover,
  'matchId': instance.matchId,
  'mode': instance.mode,
  'live': instance.live,
  'schedule': instance.schedule,
  'playAnimate': instance.playAnimate,
  'client': instance.client,
  'updated': instance.updated,
};
