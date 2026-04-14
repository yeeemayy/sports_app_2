// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsListResponseImpl _$$NewsListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$NewsListResponseImpl(
  list: (json['list'] as List<dynamic>)
      .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: NewsListMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$NewsListResponseImplToJson(
  _$NewsListResponseImpl instance,
) => <String, dynamic>{'list': instance.list, 'meta': instance.meta};

_$NewsListMetaImpl _$$NewsListMetaImplFromJson(Map<String, dynamic> json) =>
    _$NewsListMetaImpl(
      currentPage: (json['currentPage'] as num).toInt(),
      lastPage: (json['lastPage'] as num).toInt(),
      perPage: (json['perPage'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsListMetaImplToJson(_$NewsListMetaImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'lastPage': instance.lastPage,
      'perPage': instance.perPage,
      'total': instance.total,
    };
