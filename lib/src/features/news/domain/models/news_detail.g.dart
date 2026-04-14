// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsDetailImpl _$$NewsDetailImplFromJson(Map<String, dynamic> json) =>
    _$NewsDetailImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      imageUrl: json['path'] as String?,
      keywords: json['keywords'] as String,
      createdAt: json['create_time'] as String,
      createdAtBj: json['create_time_bj'] as String?,
      slugUrl: json['slug_url'] as String,
      browse: (json['browse'] as num).toInt(),
      category: (json['category'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsDetailImplToJson(_$NewsDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'path': instance.imageUrl,
      'keywords': instance.keywords,
      'create_time': instance.createdAt,
      'create_time_bj': instance.createdAtBj,
      'slug_url': instance.slugUrl,
      'browse': instance.browse,
      'category': instance.category,
    };
