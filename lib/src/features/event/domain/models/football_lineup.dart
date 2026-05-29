import 'package:freezed_annotation/freezed_annotation.dart';

part 'football_lineup.freezed.dart';
part 'football_lineup.g.dart';

@freezed
class LineupPlayer with _$LineupPlayer {
  const factory LineupPlayer({
    required String id,
    required String name,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'cn_name') String? cnName,
    required String logo,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'shirt_number') required int shirtNumber,
    required String position,
    required int? x,
    required int? y,
    required String rating,
    required int first,
    required int captain,
  }) = _LineupPlayer;

  factory LineupPlayer.fromJson(Map<String, dynamic> json) =>
      _$LineupPlayerFromJson(json);
}

@freezed
class FootballLineups with _$FootballLineups {
  const factory FootballLineups({
    required List<LineupPlayer> home,
    required List<LineupPlayer> away,
  }) = _FootballLineups;

  factory FootballLineups.fromJson(Map<String, dynamic> json) =>
      _$FootballLineupsFromJson(json);
}
