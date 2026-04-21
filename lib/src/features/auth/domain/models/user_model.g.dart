// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: (json['uid'] as num).toInt(),
      telephone: json['telephone'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: _avatarUrlFromJson(json['avatarUrl'] as String?),
      gender: (json['gender'] as num).toInt(),
      profit: (json['profit'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      isAnchor: (json['isAnchor'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'telephone': instance.telephone,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'gender': instance.gender,
      'profit': instance.profit,
      'balance': instance.balance,
      'isAnchor': instance.isAnchor,
    };
