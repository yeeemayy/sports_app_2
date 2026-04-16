// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoDetailImpl _$$VideoDetailImplFromJson(Map<String, dynamic> json) =>
    _$VideoDetailImpl(
      id: (json['id'] as num).toInt(),
      albbHlsUrl: json['albb_hls_url'] as String?,
      cfHlsUrl: json['cf_hls_url'] as String?,
      thumbnailPath: json['thumbnail_path'] as String,
      createTime: json['create_time'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$$VideoDetailImplToJson(_$VideoDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albb_hls_url': instance.albbHlsUrl,
      'cf_hls_url': instance.cfHlsUrl,
      'thumbnail_path': instance.thumbnailPath,
      'create_time': instance.createTime,
      'title': instance.title,
      'path': instance.path,
      'type': instance.type,
    };
