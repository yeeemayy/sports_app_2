// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int uid,
    required String telephone,
    required String nickname,
    @JsonKey(name: 'avatarUrl') required String? avatarUrl,
    required int gender,
    @JsonKey(defaultValue: 0) required int profit,
    @JsonKey(defaultValue: 0) required int balance,
    @JsonKey(name: 'isAnchor', defaultValue: -1) required int isAnchor,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
