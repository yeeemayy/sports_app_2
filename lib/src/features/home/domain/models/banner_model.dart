import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
class RefAppModel with _$RefAppModel {
  const factory RefAppModel({
    required String icon,
    String? name,
    required String description,
    required String url,
  }) = _RefAppModel;

  factory RefAppModel.fromJson(Map<String, dynamic> json) =>
      _$RefAppModelFromJson(json);
}

@freezed
class BannerModel with _$BannerModel {
  const factory BannerModel({
    required int id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'app_name') String? appName,
    required String cover,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'ref_app') required List<RefAppModel> refApp,
    required String updated,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
}
