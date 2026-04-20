// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoModelImpl _$$VideoModelImplFromJson(Map<String, dynamic> json) =>
    _$VideoModelImpl(
      id: (json['id'] as num).toInt(),
      cfHlsUrl: json['cf_hls_url'] as String?,
      video: json['video'] as String,
      createTime: json['create_time'] as String,
      thumbnailPath: json['thumbnail_path'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      createTimeBj: json['create_time_bj'] as String,
    );

Map<String, dynamic> _$$VideoModelImplToJson(_$VideoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cf_hls_url': instance.cfHlsUrl,
      'video': instance.video,
      'create_time': instance.createTime,
      'thumbnail_path': instance.thumbnailPath,
      'title': instance.title,
      'path': instance.path,
      'create_time_bj': instance.createTimeBj,
    };

_$VideoListResponseImpl _$$VideoListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$VideoListResponseImpl(
  list: (json['list'] as List<dynamic>)
      .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: VideoListMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$VideoListResponseImplToJson(
  _$VideoListResponseImpl instance,
) => <String, dynamic>{'list': instance.list, 'meta': instance.meta};

_$VideoListMetaImpl _$$VideoListMetaImplFromJson(Map<String, dynamic> json) =>
    _$VideoListMetaImpl(
      currentPage: (json['currentPage'] as num).toInt(),
      lastPage: (json['lastPage'] as num).toInt(),
      perPage: (json['perPage'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$VideoListMetaImplToJson(_$VideoListMetaImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'lastPage': instance.lastPage,
      'perPage': instance.perPage,
      'total': instance.total,
    };
