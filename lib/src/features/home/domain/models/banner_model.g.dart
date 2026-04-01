// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RefAppModelImpl _$$RefAppModelImplFromJson(Map<String, dynamic> json) =>
    _$RefAppModelImpl(
      icon: json['icon'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$RefAppModelImplToJson(_$RefAppModelImpl instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
    };

_$BannerModelImpl _$$BannerModelImplFromJson(Map<String, dynamic> json) =>
    _$BannerModelImpl(
      id: (json['id'] as num).toInt(),
      appName: json['app_name'] as String,
      cover: json['cover'] as String,
      refApp: (json['ref_app'] as List<dynamic>)
          .map((e) => RefAppModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      updated: json['updated'] as String,
    );

Map<String, dynamic> _$$BannerModelImplToJson(_$BannerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'app_name': instance.appName,
      'cover': instance.cover,
      'ref_app': instance.refApp,
      'updated': instance.updated,
    };
