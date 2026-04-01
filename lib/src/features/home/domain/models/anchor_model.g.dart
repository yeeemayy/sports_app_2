// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnchorModelImpl _$$AnchorModelImplFromJson(Map<String, dynamic> json) =>
    _$AnchorModelImpl(
      id: (json['id'] as num).toInt(),
      isLive: (json['isLive'] as num).toInt(),
      title: json['title'] as String,
      notice: json['notice'] as String,
      liveMode: (json['liveMode'] as num).toInt(),
      nickname: json['nickname'] as String,
      collect: (json['collect'] as num).toInt(),
      avatarUrl: json['avatarUrl'] as String,
      collectStatus: (json['collect_status'] as num).toInt(),
      cover: json['cover'] as String,
    );

Map<String, dynamic> _$$AnchorModelImplToJson(_$AnchorModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isLive': instance.isLive,
      'title': instance.title,
      'notice': instance.notice,
      'liveMode': instance.liveMode,
      'nickname': instance.nickname,
      'collect': instance.collect,
      'avatarUrl': instance.avatarUrl,
      'collect_status': instance.collectStatus,
      'cover': instance.cover,
    };
