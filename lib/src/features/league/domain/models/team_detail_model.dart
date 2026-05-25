// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_detail_model.freezed.dart';
part 'team_detail_model.g.dart';

@freezed
class TeamCountryDetails with _$TeamCountryDetails {
  const factory TeamCountryDetails({
    required String id,
    required String name,
    String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _TeamCountryDetails;

  factory TeamCountryDetails.fromJson(Map<String, dynamic> json) =>
      _$TeamCountryDetailsFromJson(json);
}

@freezed
class TeamDetailModel with _$TeamDetailModel {
  const factory TeamDetailModel({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? logo,
    @JsonKey(name: 'foundation_time') int? foundationTime,
    String? website,
    @JsonKey(name: 'total_players') int? totalPlayers,
    @JsonKey(name: 'foreign_players') int? foreignPlayers,
    @JsonKey(name: 'national_players') int? nationalPlayers,
    @JsonKey(name: 'cn_name') String? cnName,
    @JsonKey(name: 'conference_id') int? conferenceId,
    @JsonKey(name: 'countryDetails') TeamCountryDetails? countryDetails,
  }) = _TeamDetailModel;

  factory TeamDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TeamDetailModelFromJson(json);
}
