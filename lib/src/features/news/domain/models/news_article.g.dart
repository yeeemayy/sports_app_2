// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsArticleImpl _$$NewsArticleImplFromJson(Map<String, dynamic> json) =>
    _$NewsArticleImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['path'] as String?,
      keywords: json['keywords'] as String,
      createdAt: json['create_time'] as String,
      slugUrl: json['slug_url'] as String,
      browse: (json['browse'] as num).toInt(),
      category: (json['category'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsArticleImplToJson(_$NewsArticleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'path': instance.imageUrl,
      'keywords': instance.keywords,
      'create_time': instance.createdAt,
      'slug_url': instance.slugUrl,
      'browse': instance.browse,
      'category': instance.category,
    };
