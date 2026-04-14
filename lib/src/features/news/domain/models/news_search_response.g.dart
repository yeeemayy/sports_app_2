// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsSearchResponseImpl _$$NewsSearchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$NewsSearchResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$$NewsSearchResponseImplToJson(
  _$NewsSearchResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};
