// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'im_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImTokenModelImpl _$$ImTokenModelImplFromJson(Map<String, dynamic> json) =>
    _$ImTokenModelImpl(
      token: json['token'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      cid: json['cid'] as String,
      appKey: json['appKey'] as String,
    );

Map<String, dynamic> _$$ImTokenModelImplToJson(_$ImTokenModelImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'id': instance.id,
      'name': instance.name,
      'cid': instance.cid,
      'appKey': instance.appKey,
    };
