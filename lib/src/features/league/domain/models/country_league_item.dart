// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_league_item.freezed.dart';
part 'country_league_item.g.dart';

/// A league as returned by /football/country/leagues/:id or /basketball/country/leagues/:id
@freezed
class CountryLeagueItem with _$CountryLeagueItem {
  const factory CountryLeagueItem({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    required String logo,

    /// 1 = regular league, 2 = cup
    int? type,
    @JsonKey(name: 'cur_season_id') String? curSeasonId,
    @JsonKey(name: 'cur_round') int? curRound,
    @JsonKey(name: 'round_count') int? roundCount,
    @JsonKey(name: 'cn_name') String? cnName,
    @JsonKey(name: 'primary_color') String? primaryColor,
    @JsonKey(name: 'secondary_color') String? secondaryColor,
  }) = _CountryLeagueItem;

  factory CountryLeagueItem.fromJson(Map<String, dynamic> json) =>
      _$CountryLeagueItemFromJson(json);
}
