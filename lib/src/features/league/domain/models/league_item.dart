// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'league_item.freezed.dart';
part 'league_item.g.dart';

/// Shared model for a hot-league list entry (football & basketball).
@freezed
class LeagueItem with _$LeagueItem {
  const factory LeagueItem({
    required String id,
    @JsonKey(name: 'nameEn') required String nameEn,
    @JsonKey(name: 'nameEnShort') String? nameEnShort,
    @JsonKey(name: 'nameCn') String? nameCn,
    required String logo,
  }) = _LeagueItem;

  factory LeagueItem.fromJson(Map<String, dynamic> json) =>
      _$LeagueItemFromJson(json);
}
