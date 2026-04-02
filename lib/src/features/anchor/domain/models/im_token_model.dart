// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'im_token_model.freezed.dart';
part 'im_token_model.g.dart';

@freezed
class ImTokenModel with _$ImTokenModel {
  const factory ImTokenModel({
    required String token,
    required String id,
    required String name,
    required String cid,
    required String appKey,
  }) = _ImTokenModel;

  factory ImTokenModel.fromJson(Map<String, dynamic> json) =>
      _$ImTokenModelFromJson(json);
}

extension ImTokenModelX on ImTokenModel {
  /// Guest IDs from the API are negative numbers (e.g. "-117745928634310").
  bool get isGuest => id.startsWith('-');
}
