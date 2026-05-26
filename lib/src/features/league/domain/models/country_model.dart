// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_model.freezed.dart';
part 'country_model.g.dart';

@freezed
class CountryModel with _$CountryModel {
  const factory CountryModel({
    required String id,
    required String name,
    required String logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _CountryModel;

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      _$CountryModelFromJson(json);

  /// Creates a [CountryModel] from a /category/list item, which has no logo.
  static CountryModel fromCategoryJson(Map<String, dynamic> json) =>
      CountryModel(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        logo: '',
        cnName: json['cn_name'] as String?,
      );
}
