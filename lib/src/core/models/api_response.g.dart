// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseImpl<T> _$$ApiResponseImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$ApiResponseImpl<T>(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  time: (json['time'] as num).toInt(),
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$$ApiResponseImplToJson<T>(
  _$ApiResponseImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'time': instance.time,
  'data': toJsonT(instance.data),
};
