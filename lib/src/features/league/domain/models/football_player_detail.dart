// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'football_player_detail.freezed.dart';
part 'football_player_detail.g.dart';

@freezed
class PlayerCountryDetails with _$PlayerCountryDetails {
  const factory PlayerCountryDetails({
    required String id,
    required String name,
    String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _PlayerCountryDetails;

  factory PlayerCountryDetails.fromJson(Map<String, dynamic> json) =>
      _$PlayerCountryDetailsFromJson(json);
}

@freezed
class FootballPlayerDetail with _$FootballPlayerDetail {
  const factory FootballPlayerDetail({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? logo,
    int? age,
    int? height,
    int? weight,
    String? nationality,
    String? position,
    @JsonKey(name: 'preferred_foot') int? preferredFoot,
    @JsonKey(name: 'cn_name') String? cnName,
    @JsonKey(name: 'countryDetails') PlayerCountryDetails? countryDetails,
  }) = _FootballPlayerDetail;

  factory FootballPlayerDetail.fromJson(Map<String, dynamic> json) =>
      _$FootballPlayerDetailFromJson(json);
}
